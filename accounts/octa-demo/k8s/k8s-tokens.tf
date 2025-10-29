#Admin Token
resource "kubernetes_manifest" "k8s_admin_crb" {
  manifest = yamldecode(file("./custom/Tokens/Admin/k8s-admin-crb.yaml"))
  provider = kubernetes.kube
}

resource "kubernetes_manifest" "k8s_admin_sa" {
  manifest = yamldecode(file("./custom/Tokens/Admin/k8s-admin-sa.yaml"))
  provider = kubernetes.kube
}

resource "kubernetes_manifest" "k8s_admin_secret" {
  manifest = yamldecode(file("./custom/Tokens/Admin/k8s-admin-secret.yaml"))
  provider = kubernetes.kube
}

# resource "kubernetes_manifest" "k8s_admin_secret" {
#   manifest = yamldecode(file("./custom/Tokens/Admin/k8s-admin-secret.yaml"))
#   provider = kubernetes.kube
# }

resource "kubernetes_manifest" "k8s_admin_secret_token" {
  manifest = yamldecode(file("./custom/Tokens/Admin/service-account-token.yaml"))
  provider = kubernetes.kube
}