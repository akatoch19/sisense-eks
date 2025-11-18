
############################################################
# EBS CSI as a managed EKS Add-on (no Kubernetes API needed)
############################################################
terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      configuration_aliases = [kubernetes.eks]
    }
    helm = {
      source = "hashicorp/helm"
      configuration_aliases = [helm.eks]
    }
  }
}
#######################################
# EKS Addon: aws-ebs-csi-driver
#######################################
resource "aws_eks_addon" "ebs_csi" {
  count        = var.enable_ebs_csi ? 1 : 0
  cluster_name = var.cluster_name
  addon_name   = "aws-ebs-csi-driver"
  service_account_role_arn   =  var.ebs_csi_role_arn
  resolve_conflicts_on_update = "OVERWRITE"
  tags                        = var.tags
}
########################
# StorageClasses
########################
 
resource "kubernetes_storage_class" "ebs" {
  provider = kubernetes.eks
  metadata {
    name = "ebs"
  }
 
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
 
  parameters = {
    type                        = "gp3"
    encrypted                   = "true"
    "csi.storage.k8s.io/fstype" = "xfs"
 
    # ------- TAGS ----------
    tagSpecification_1 = "cst_environment=stg"
    tagSpecification_2 = "cst_backup_policy=none"
    tagSpecification_3 = "cst_product_line=foundation"
    tagSpecification_4 = "cst_tenant=foundation"
    tagSpecification_5 = "cst_cost_center=infrastructure"
    tagSpecification_6 = "cst_name=psj_crimeanalytics"
    tagSpecification_7 = "cst_compliance_domain=cjis"
    tagSpecification_8 = "cst_tenancy=multiple"
    tagSpecification_9 = "cst_application=psj_crimeanalytics"
  }
 
  depends_on = [
    aws_eks_addon.ebs_csi[0]
  ]
}
 
resource "kubernetes_storage_class" "ebs_temp" {
  provider = kubernetes.eks
  metadata {
    name = "ebs-temp"
  }
 
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
 
  parameters = {
    type                        = "gp3"
    encrypted                   = "true"
    "csi.storage.k8s.io/fstype" = "xfs"
 
    # ------- TAGS ----------
    tagSpecification_1 = "cst_environment=stg"
    tagSpecification_2 = "cst_backup_policy=none"
    tagSpecification_3 = "cst_product_line=foundation"
    tagSpecification_4 = "cst_tenant=foundation"
    tagSpecification_5 = "cst_cost_center=infrastructure"
    tagSpecification_6 = "cst_name=psj_crimeanalytics"
    tagSpecification_7 = "cst_compliance_domain=cjis"
    tagSpecification_8 = "cst_tenancy=multiple"
    tagSpecification_9 = "cst_application=psj_crimeanalytics"
  }
 
  depends_on = [
    aws_eks_addon.ebs_csi[0]
  ]
}

##########################################
# Cluster autoscaler (optional Helm chart)
###########################################
resource "helm_release" "cluster_autoscaler" {
  provider   = helm.eks
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "default"
  version    = "9.24.0" 
 
  values = [yamlencode({
    autoDiscovery = { clusterName = var.cluster_name }
    awsRegion     = var.region
    image         = { tag = "v1.33.0" }
    fullnameOverride = "cluster-autoscaler"
 
    serviceAccount = {
      create = true
      name   = "cluster-autoscaler"
    }
    rbac = {
      create = true
    }
  })]
 
}
resource "kubernetes_annotations" "cluster_autoscaler_irsa" {
   provider   = kubernetes.eks
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name      = "cluster-autoscaler"
    namespace = "default" 
  }
 
  annotations = {
    "eks.amazonaws.com/role-arn" = var.cluster_autoscaler_irsa_role_arn
  }
 
  force = true
}

#########################################
# aws-fsx-csi-driver
#########################################
############################
resource "helm_release" "fsx_csi" {
  provider   = helm.eks
  name       = "aws-fsx-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-fsx-csi-driver"
  chart      = "aws-fsx-csi-driver"
  version    = "1.6.0" 
  set {
    name  = "controller.serviceAccount.create"
    value = "false"
  }
  set {
    name  = "controller.serviceAccount.name"
    value = "fsx-csi-controller-sa"
  }
  depends_on = [
    kubernetes_service_account.fsx_csi_controller
  ]
}
resource "kubernetes_service_account" "fsx_csi_controller" {
  provider = kubernetes.eks
  metadata {
    name      = "fsx-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.fsx_csi_irsa_role_arn
    }
  }
}
 
 

 
