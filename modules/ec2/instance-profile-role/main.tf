# IAM Role
resource "aws_iam_role" "this" {
  name =    "${var.name_prefix}-${var.component}-${var.service}-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(tomap({ "Name" = "${var.name_prefix}-${var.component}-${var.service}-role" }), tomap({ "Launch_Month_Year" = formatdate("MMM-YYYY", timestamp()) }), tomap(var.tags))
}

# Attach AWS Managed Policies
resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# Create Inline Policies
resource "aws_iam_role_policy" "inline_policies" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}

# Instance Profile
resource "aws_iam_instance_profile" "this" {
  name = "${var.name_prefix}-${var.component}-${var.service}-instance-profile"
  role = aws_iam_role.this.name

  tags = merge(tomap({ "Name" = "${var.name_prefix}-${var.component}-${var.service}-instance-profile" }), tomap({ "Launch_Month_Year" = formatdate("MMM-YYYY", timestamp()) }), tomap(var.tags))
}