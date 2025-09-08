# --------------------------------------------------------
# AWS Load Balancer Controller
# --------------------------------------------------------
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}

# --------------------------------------------------------
# Sisense Deployment via Helm
# --------------------------------------------------------
resource "kubernetes_namespace" "sisense" {
  metadata {
    name = "sisense"
  }
}

resource "helm_release" "sisense" {
  name       = "sisense"
  namespace  = kubernetes_namespace.sisense.metadata[0].name
  repository = "https://charts.sisense.com/" # requires access from Sisense
  chart      = "sisense"

  # General Config
  set {
    name  = "global.storageClass"
    value = "gp3" # or custom SC if you created FSx storage class
  }

  # FSx Integration (if enabled)
  set {
    name  = "global.fsx.enabled"
    value = "true"
  }

  # Ingress (ALB + Route53 via ExternalDNS)
  set {
    name  = "ingress.enabled"
    value = "true"
  }
  set {
    name  = "ingress.className"
    value = "alb"
  }
  set {
    name  = "ingress.hosts[0].host"
    value = "${var.env}.sisense.${var.base_domain}" # e.g. dev.sisense.example.com
  }
  set {
    name  = "ingress.hosts[0].paths[0].path"
    value = "/"
  }
  set {
    name  = "ingress.hosts[0].paths[0].pathType"
    value = "Prefix"
  }

  depends_on = [
    helm_release.aws_load_balancer_controller
  ]
}
