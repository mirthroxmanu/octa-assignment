# Mimir Helm Release
resource "helm_release" "mimir" {
  name       = "mimir"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "mimir-distributed"
  version    = "5.8.0"
  namespace  = "mimir"
  create_namespace = true

  values = [
    file("./values/mimir/mimir-values.yaml")
  ]
  timeout = 600
  wait = true
  wait_for_jobs = true
  cleanup_on_fail = true

  provider = helm.helm
}