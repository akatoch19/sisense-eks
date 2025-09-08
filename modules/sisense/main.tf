variable "cluster_name" {}
variable "cluster_endpoint" {}
variable "cluster_certificate_authority" {}
variable "environment" {}
variable "sisense_license_key" {}
variable "sisense_domain" {}
variable "namespace" {}
variable "fsx_filesystem_id" {}
variable "ebs_csi_driver_role_arn" {}
variable "node_iam_instance_profile" {}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority)
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

# Namespace
resource "kubernetes_namespace" "sisense" {
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}

# EBS CSI Driver
resource "helm_release" "aws_ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = "2.20.0"
  namespace  = "kube-system"

  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "ebs-csi-controller-sa"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.ebs_csi_driver_role_arn
  }
}

# Configuration
resource "kubernetes_config_map" "sisense_config" {
  metadata {
    name      = "sisense-config"
    namespace = var.namespace
  }

  data = {
    "sisense.yaml" = <<-EOT
    cloud_auto_scaler: true
    management:
      TimeToWaitBeforeCheckIfCubeStartedSeconds: 360
    storage:
      fsx:
        enabled: true
        filesystemId: ${var.fsx_filesystem_id}
    EOT
  }
}

# Node labeling script
resource "local_file" "node_labeling_script" {
  content = templatefile("${path.module}/templates/node-labeling.sh.tpl", {
    namespace = var.namespace
  })
  filename = "${path.module}/scripts/label-nodes.sh"
}

# Package installation script
resource "local_file" "install_packages_script" {
  content = templatefile("${path.module}/templates/install-packages.sh.tpl", {})
  filename = "${path.module}/scripts/install-packages.sh"
}
