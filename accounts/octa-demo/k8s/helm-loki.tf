resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  version          = "6.44.0"  
  namespace        = "loki"

  values = [
    file("./values/loki/loki-values.yaml")
  ]
  provider = helm.helm
}