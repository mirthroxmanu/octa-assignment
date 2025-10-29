# outputs.tf - EKS Module Outputs

output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = aws_eks_cluster.eks.id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = aws_eks_cluster.eks.arn
}

output "cluster_name" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_oidc_issuer" {
  description = "Endpoint for your Kubernetes API server"
  value       = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

output "cluster_version" {
  description = "The Kubernetes server version for the cluster"
  value       = aws_eks_cluster.eks.version
}

output "cluster_platform_version" {
  description = "The platform version for the cluster"
  value       = aws_eks_cluster.eks.platform_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.eks.certificate_authority[0].data
}



output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = aws_eks_cluster.eks.status
}

output "vpc_config" {
  description = "VPC configuration of the cluster"
  value       = aws_eks_cluster.eks.vpc_config
}

# # Addon Outputs
# output "vpc_cni_addon_id" {
#   description = "ID of the VPC CNI addon"
#   value       = try(aws_eks_addon.vpc-cni[0].id, null)
# }

# output "ebs_csi_addon_id" {
#   description = "ID of the EBS CSI driver addon"
#   value       = try(aws_eks_addon.ebs-csi[0].id, null)
# }

# output "coredns_addon_id" {
#   description = "ID of the CoreDNS addon"
#   value       = try(aws_eks_addon.coredns[0].id, null)
# }

# output "kube_proxy_addon_id" {
#   description = "ID of the Kube Proxy addon"
#   value       = try(aws_eks_addon.kube-proxy[0].id, null)
# }

output "cluster_primary_securitygroup_id" {
  description = "SG ID For the primary security group"
  value       = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}