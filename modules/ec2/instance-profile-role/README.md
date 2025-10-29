# EC2 IAM Role Terraform Module

This Terraform module creates an IAM role for EC2 instances with an instance profile, supporting both AWS managed policies and inline policies.

## Features

- ✅ Creates IAM role with EC2 assume role policy
- ✅ Creates IAM instance profile
- ✅ Optionally binds instance profile to an existing EC2 instance
- ✅ Supports attaching AWS managed policies
- ✅ Supports creating inline policies
- ✅ Flexible: Use managed policies, inline policies, or both
- ✅ Tagging support for resource management

## Usage

### Basic Example with Managed Policies
```terraform
module "ec2_role" {
  source = "./modules/ec2-iam-role"

  role_name   = "my-ec2-role"
  instance_id = "i-1234567890abcdef0"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]

  tags = {
    Environment = "production"
    Application = "web-server"
  }
}
```

### Example with Inline Policies
```terraform
module "ec2_role" {
  source = "./modules/ec2-iam-role"

  role_name   = "my-ec2-role"
  instance_id = "i-1234567890abcdef0"

  inline_policies = {
    s3_access = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:ListBucket"
          ]
          Resource = [
            "arn:aws:s3:::my-bucket",
            "arn:aws:s3:::my-bucket/*"
          ]
        }
      ]
    })
  }

  tags = {
    Environment = "production"
  }
}
```

### Example with Both Managed and Inline Policies
```terraform
module "ec2_role" {
  source = "./modules/ec2-iam-role"

  role_name   = "my-ec2-role"
  instance_id = "i-1234567890abcdef0"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  inline_policies = {
    custom_s3_access = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject"
          ]
          Resource = "arn:aws:s3:::my-bucket/*"
        }
      ]
    })
    
    custom_dynamodb_access = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "dynamodb:GetItem",
            "dynamodb:Query"
          ]
          Resource = "arn:aws:dynamodb:us-east-1:123456789012:table/my-table"
        }
      ]
    })
  }

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

### Example Without Instance Binding

Create the role and instance profile without immediately binding to an instance:
```terraform
module "ec2_role" {
  source = "./modules/ec2-iam-role"

  role_name = "my-ec2-role"
  # instance_id is omitted (null by default)

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  tags = {
    Environment = "production"
  }
}

# Use the instance profile when launching a new EC2 instance
resource "aws_instance" "example" {
  ami                  = "ami-12345678"
  instance_type        = "t3.micro"
  iam_instance_profile = module.ec2_role.instance_profile_name

  tags = {
    Name = "example-instance"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| role_name | Name of the IAM role | `string` | n/a | yes |
| instance_id | EC2 instance ID to bind the instance profile to | `string` | `null` | no |
| managed_policy_arns | List of AWS managed policy ARNs to attach to the role | `list(string)` | `[]` | no |
| inline_policies | Map of inline policies to create. Key is policy name, value is policy document JSON | `map(string)` | `{}` | no |
| tags | Tags to apply to IAM resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| role_arn | ARN of the IAM role |
| role_name | Name of the IAM role |
| instance_profile_arn | ARN of the instance profile |
| instance_profile_name | Name of the instance profile |

## Common AWS Managed Policies for EC2

Here are some commonly used AWS managed policies for EC2 instances:

| Policy ARN | Description |
|------------|-------------|
| `arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore` | Enables AWS Systems Manager service core functionality |
| `arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy` | Allows CloudWatch agent to send metrics and logs |
| `arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess` | Read-only access to EC2 resources |
| `arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess` | Read-only access to S3 buckets |
| `arn:aws:iam::aws:policy/SecretsManagerReadWrite` | Read and write access to Secrets Manager |

## Inline Policy Examples

### S3 Bucket Access
```terraform
inline_policies = {
  s3_bucket_access = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::my-bucket/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::my-bucket"
      }
    ]
  })
}
```

### DynamoDB Table Access
```terraform
inline_policies = {
  dynamodb_access = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          "arn:aws:dynamodb:us-east-1:123456789012:table/my-table",
          "arn:aws:dynamodb:us-east-1:123456789012:table/my-table/index/*"
        ]
      }
    ]
  })
}
```

### ECR Repository Access
```terraform
inline_policies = {
  ecr_access = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}
```

### Secrets Manager Access
```terraform
inline_policies = {
  secrets_access = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret-*"
      }
    ]
  })
}
```

## Module Structure
```
modules/ec2-iam-role/
├── main.tf           # Main resource definitions
├── variables.tf      # Input variable declarations
├── outputs.tf        # Output value declarations
└── README.md         # This file
```

## Resources Created

This module creates the following AWS resources:

1. **aws_iam_role** - IAM role with EC2 assume role policy
2. **aws_iam_role_policy_attachment** - Attachments for AWS managed policies (if provided)
3. **aws_iam_role_policy** - Inline policies (if provided)
4. **aws_iam_instance_profile** - Instance profile for EC2
5. **aws_ec2_instance_profile_association** - Association between instance profile and EC2 instance (if instance_id provided)

## Important Notes

### Instance Profile Association

- If `instance_id` is provided, the module will automatically associate the instance profile with the EC2 instance
- If `instance_id` is `null` (default), the instance profile is created but not associated with any instance
- You can use the `instance_profile_name` output when launching new EC2 instances

### Policy Limits

- An IAM role can have up to 10 managed policies attached
- An IAM role can have an unlimited number of inline policies, but the total policy size cannot exceed certain limits
- Each inline policy is limited to 10,240 characters

### Best Practices

1. **Least Privilege**: Grant only the permissions necessary for your EC2 instance to perform its tasks
2. **Use Managed Policies**: When possible, use AWS managed policies for common use cases
3. **Inline Policies for Custom Logic**: Use inline policies for application-specific permissions
4. **Descriptive Names**: Use clear, descriptive names for roles and inline policies
5. **Tagging**: Always tag your IAM resources for better organization and cost allocation

## Examples Directory Structure
```
examples/
├── basic/
│   └── main.tf           # Basic example with managed policies
├── inline-only/
│   └── main.tf           # Example with only inline policies
├── combined/
│   └── main.tf           # Example with both managed and inline policies
└── without-instance/
    └── main.tf           # Example without instance binding
```

## Troubleshooting

### Instance Profile Association Fails

If the instance profile association fails, check:
- The EC2 instance exists and is in a valid state
- The instance doesn't already have an instance profile attached
- You have the necessary IAM permissions to modify the instance

### Permission Denied Errors

If your EC2 instance gets permission denied errors:
- Verify the policies are correctly attached using AWS Console or CLI
- Check CloudTrail logs for detailed error messages
- Ensure the trust policy allows EC2 to assume the role

### Policy Syntax Errors

If you encounter policy syntax errors:
- Validate your JSON policy documents using `terraform validate`
- Use the AWS Policy Simulator to test policies before applying
- Check for common issues like missing commas or incorrect resource ARNs

## Contributing

Contributions are welcome! Please ensure:
- Code follows Terraform best practices
- Variables and outputs are properly documented
- Examples are provided for new features

## License

This module is released under the MIT License.

## Authors

Created and maintained by [Your Team/Name]

## Support

For issues and questions:
- Open an issue in the repository
- Contact the platform team at [email]