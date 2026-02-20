resource "kubernetes_service_account" "autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = var.service_account_role_arn
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.37.0"

  values = [
    yamlencode({
      autoDiscovery = {
        clusterName = var.cluster_name
      }

      awsRegion = var.region

      rbac = {
        serviceAccount = {
          create = false
          name   = kubernetes_service_account.autoscaler.metadata[0].name
        }
      }

      extraArgs = {
        "balance-similar-node-groups" = "true"
        "skip-nodes-with-system-pods" = "false"
        "skip-nodes-with-local-storage" = "false"
      }
    })
  ]
}