locals {
  vpc_cidr_block     = var.vpc_cidr_block
  private_subnet_ids = var.private_subnet_ids
}


#EKS cluster configuration
#================================================================
resource "aws_eks_cluster" "eks" {
  name                      = "${var.name_prefix}-eks-cluster"
  role_arn                  = aws_iam_role.eks_role.arn
  version                   = var.eks_version
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  vpc_config {
    subnet_ids              = local.private_subnet_ids
    security_group_ids      = var.security_group_ids
    endpoint_private_access = "true"
    endpoint_public_access  = "false"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_service_attachment_1,
    aws_iam_role_policy_attachment.eks_service_attachment_2,
  ]
  tags = merge(tomap({ "Name" = "${var.name_prefix}-eks-cluster" }), tomap({ "Launch_Month_Year" = formatdate("MMM-YYYY", timestamp()) }), tomap(var.tags))
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags, tags_all,
    ]
  }
}



#IAM role configuration
#================================================================
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}



resource "aws_iam_role_policy_attachment" "eks_service_attachment_1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_role.name
}


resource "aws_iam_role_policy_attachment" "eks_service_attachment_2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}


output "eks_role_arn" {
  value = aws_iam_role.eks_role.arn
}


#eks nodegroup configuration
#================================================================

resource "aws_iam_role" "node-role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}
resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-role.name
}


resource "aws_eks_node_group" "pool" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = each.value.node_group_name
  node_role_arn   = aws_iam_role.node-role.arn
  subnet_ids      = each.value.subnet_ids
  ami_type        = each.value.ami_type
  capacity_type   = each.value.capacity_type
  instance_types  = each.value.instance_types
  disk_size       = each.value.disk_size
  labels          = each.value.labels


  # launch_template {
  #   id      = each.value.launch_template_id
  #   version = each.value.launch_template_version
  # }

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  update_config {
    max_unavailable_percentage = each.value.max_unavailable_percentage
  }

  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = merge(tomap({ "Name" = each.value.node_group_name }), tomap(var.tags))

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, scaling_config desired size
      tags,
      tags_all,
      scaling_config.0.desired_size,
      launch_template.1.version

    ]
  }

}


#eks addons
#================================================================

data "tls_certificate" "tls_cert" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tls_cert.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "ebscsi_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "ebscsi" {
  assume_role_policy = data.aws_iam_policy_document.ebscsi_assume_role_policy.json
  name               = "eks-addon-ebscsi-role"
  lifecycle {
    ignore_changes = [assume_role_policy]
  }
}
resource "aws_iam_role_policy_attachment" "ebscsi" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebscsi.name
}


resource "aws_eks_addon" "vpc-cni" {
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "vpc-cni"
  addon_version               = var.vpc_cni_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  tags = {
    "eks_addon" = "vpc-cni"
    "terraform" = "true"
  }
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = var.ebs_csi_driver_addon_version
  service_account_role_arn    = aws_iam_role.ebscsi.arn
  resolve_conflicts_on_create = "OVERWRITE"
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
  timeouts {
    create = "40m"
    delete = "1h"
  }
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "coredns"
  addon_version               = var.coredns_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  tags = {
    "eks_addon" = "coredns"
    "terraform" = "true"
  }
  timeouts {
    create = "40m"
    delete = "1h"
  }
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "kube-proxy"
  addon_version               = var.kube_proxy_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  tags = {
    "eks_addon" = "kube-proxy"
    "terraform" = "true"
  }
}
