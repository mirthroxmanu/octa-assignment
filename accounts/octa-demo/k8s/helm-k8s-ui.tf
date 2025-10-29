resource "helm_release" "kubernetes_dashboard" {
  name             = "kubernetes-dashboard"
  repository       = "https://kubernetes.github.io/dashboard/"
  chart            = "kubernetes-dashboard"
  version          = "7.13.0"
  namespace        = "k8s-ui"

  values = [
    file("./values/kubernetes-dashboard/dashboard-values.yaml")
  ]

  provider = helm.helm
}