resource "kubernetes_manifest" "k8s_xfs_storage_class" {
  manifest = yamldecode(file("./custom/storage-class-xfs.yaml"))
  provider = kubernetes.kube
}