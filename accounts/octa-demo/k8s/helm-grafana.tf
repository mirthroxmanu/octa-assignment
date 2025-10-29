# Grafana Helm Release
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "10.1.2"  
  namespace  = "monitoring"

  values = [
    file("./values/grafana/grafana-values.yaml")
  ]
  provider = helm.helm
}