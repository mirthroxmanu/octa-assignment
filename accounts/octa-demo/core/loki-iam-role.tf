resource "aws_iam_role" "loki_role_s3" {
  name = "${local.name_prefix}-loki-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.account}:oidc-provider/${replace(module.eks_cluster.cluster_oidc_issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks_cluster.cluster_oidc_issuer, "https://", "")}:aud" = "sts.amazonaws.com"
            "${replace(module.eks_cluster.cluster_oidc_issuer, "https://", "")}:sub" = "system:serviceaccount:loki:loki"
          }
        }
      }
    ]
  })
  tags               = merge(tomap({ "Name" = "${local.name_prefix}-loki-s3-backend-bucket-role" }), tomap(local.common_tags))

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags["created_by"], tags["created_by_arn"],
    ]
  }
}



# Create the policy
resource "aws_iam_policy" "loki_s3_policy" {
  name        = "${local.name_prefix}-loki-s3-policy"
  description = "Policy for Loki to access S3 bucket"
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject", 
          "s3:DeleteObject"
        ],
        "Resource": "arn:aws:s3:::octabyte-loki-logs-bucket/*"
      },
      {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": "s3:ListBucket",
        "Resource": "arn:aws:s3:::octabyte-loki-logs-bucket"
      },
      {
        "Sid": "VisualEditor2",
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket", 
          "s3:DeleteObject"
        ],
        "Resource": "arn:aws:s3:::octabyte-loki-logs-bucket"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "loki_s3_policy_attachment" {
  role       = aws_iam_role.loki_role_s3.name
  policy_arn = aws_iam_policy.loki_s3_policy.arn
}

output "loki_backend_role_arn" {
  value = aws_iam_role.loki_role_s3.arn
}