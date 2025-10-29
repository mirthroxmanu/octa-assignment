# Private Instance Terraform Module

This Terraform module creates secure private EC2 instances in AWS, designed for applications that require private network access such as MarkLogic databases, application servers, and other backend services. The instances are deployed in private subnets without direct internet access, ensuring enhanced security.

## Features

- **Private EC2 Instance**: Deploys instances in private subnets without public IP addresses
- **Enhanced Security**: No direct internet access, accessible only through bastion hosts or VPN
- **IAM Integration**: Supports IAM instance profiles for AWS service access
- **Encrypted Storage**: Root volume is encrypted by default
- **Flexible AMI**: Option to use custom AMI or latest Ubuntu image
- **Configurable Security**: Dynamic security group rules for fine-grained access control
- **MarkLogic Ready**: Optimized for database and application server workloads

## Architecture

```
Internet → NAT Gateway → Private Instance (Private Subnet) → AWS Services
            ↑
    Bastion Host (Public Subnet) → SSH Access → Private Instance
```

Private instances can access the internet through NAT Gateway for updates and downloads, while inbound access is restricted to internal networks or bastion hosts.

## Usage

### Basic Example - MarkLogic Database

```hcl
module "marklogic_instance" {
  source = "./path/to/private-instance-module"

  # Required variables
  name           = "marklogic-prod"
  vpc_id         = "vpc-12345678"
  pvt_subnet_id  = "subnet-87654321"  # Private subnet
  ssh_key_name   = "my-key-pair"
  
  # Instance configuration
  pvt_instance_type        = "r5.xlarge"  # Memory optimized for MarkLogic
  pvt_root_volume_size     = 100
  achitecture             = "amd64"
  pvt_use_explicit_ami    = false
  pvt_explicit_ami_id     = ""
  iam_instance_profile    = "marklogic-instance-profile"

  # Security group rules for MarkLogic
  pvt_sg_ingress_rules = [
    {
      description = "SSH from bastion"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.1.0/24"]  # Bastion subnet
    },
    {
      description = "MarkLogic Admin Interface"
      from_port   = 8001
      to_port     = 8001
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]  # VPC CIDR
    },
    {
      description = "MarkLogic App Server"
      from_port   = 8000
      to_port     = 8010
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]

  # Tags
  instance_tags = {
    Name         = "marklogic-prod-server"
    Environment  = "production"
    Application  = "marklogic"
    Role         = "database"
  }

  sg_tags = {
    Name         = "marklogic-prod-sg"
    Environment  = "production"
    Application  = "marklogic"
  }

  volume_tags = {
    Name         = "marklogic-prod-volume"
    Environment  = "production"
    Application  = "marklogic"
  }
}
```

### Advanced Example - Application Server with Custom AMI

```hcl
module "app_server" {
  source = "./path/to/private-instance-module"

  name           = "app-server"
  vpc_id         = var.vpc_id
  pvt_subnet_id  = var.private_subnet_id
  ssh_key_name   = var.key_pair_name
  
  # Use custom AMI with pre-installed software
  pvt_use_explicit_ami = true
  pvt_explicit_ami_id  = "ami-0abcdef1234567890"
  pvt_instance_type    = "c5.large"
  pvt_root_volume_size = 50
  achitecture         = "amd64"
  iam_instance_profile = aws_iam_instance_profile.app_profile.name

  # Application-specific security rules
  pvt_sg_ingress_rules = [
    {
      description = "SSH from bastion host"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.1.0/24"]
    },
    {
      description = "HTTP from load balancer"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["10.0.2.0/24"]
    },
    {
      description = "HTTPS from load balancer"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.0.2.0/24"]
    },
    {
      description = "Custom app port"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]

  instance_tags = {
    Name        = "app-server-prod"
    Environment = "production"
    Tier        = "application"
    Owner       = "backend-team"
  }

  sg_tags = {
    Name = "app-server-security-group"
  }

  volume_tags = {
    Name = "app-server-root-volume"
  }
}
```

### Multiple Private Instances Example

```hcl
# MarkLogic Cluster
module "marklogic_nodes" {
  source = "./path/to/private-instance-module"
  count  = 3

  name           = "marklogic-node-${count.index + 1}"
  vpc_id         = var.vpc_id
  pvt_subnet_id  = var.private_subnet_ids[count.index]
  ssh_key_name   = var.key_pair_name
  
  pvt_instance_type        = "r5.2xlarge"
  pvt_root_volume_size     = 200
  achitecture             = "amd64"
  pvt_use_explicit_ami    = true
  pvt_explicit_ami_id     = var.marklogic_ami_id
  iam_instance_profile    = aws_iam_instance_profile.marklogic_profile.name

  pvt_sg_ingress_rules = [
    {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.1.0/24"]
    },
    {
      description = "MarkLogic cluster communication"
      from_port   = 7999
      to_port     = 8010
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]

  instance_tags = {
    Name         = "marklogic-cluster-node-${count.index + 1}"
    Environment  = "production"
    Application  = "marklogic"
    ClusterRole  = count.index == 0 ? "master" : "worker"
  }

  sg_tags = {
    Name = "marklogic-cluster-sg-${count.index + 1}"
  }

  volume_tags = {
    Name = "marklogic-cluster-volume-${count.index + 1}"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.0 |

## Resources Created

| Type | Name | Description |
|------|------|-------------|
| `aws_instance` | pvt_instance | The private EC2 instance |
| `aws_security_group` | pvt_sg | Security group for the private instance |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Base name for resources | `string` | n/a | yes |
| vpc_id | VPC ID where the instance will be created | `string` | n/a | yes |
| pvt_subnet_id | Private subnet ID for the instance | `string` | n/a | yes |
| ssh_key_name | Name of the AWS key pair for SSH access | `string` | n/a | yes |
| pvt_instance_type | EC2 instance type | `string` | n/a | yes |
| achitecture | CPU architecture (amd64 or arm64) | `string` | n/a | yes |
| pvt_root_volume_size | Size of the root volume in GB | `number` | n/a | yes |
| pvt_use_explicit_ami | Whether to use a specific AMI ID | `bool` | n/a | yes |
| pvt_explicit_ami_id | Specific AMI ID to use (when pvt_use_explicit_ami is true) | `string` | n/a | yes |
| iam_instance_profile | IAM instance profile name for the EC2 instance | `string` | n/a | yes |
| pvt_sg_ingress_rules | List of ingress rules for the security group | `list(object)` | n/a | yes |
| instance_tags | Tags to apply to the EC2 instance | `map(string)` | n/a | yes |
| sg_tags | Tags to apply to the security group | `map(string)` | n/a | yes |
| volume_tags | Tags to apply to the EBS volumes | `any` | n/a | yes |

### Security Group Rules Format

The `pvt_sg_ingress_rules` variable expects a list of objects with the following structure:

```hcl
pvt_sg_ingress_rules = [
  {
    description = "Description of the rule"
    from_port   = 8000                  # Starting port number
    to_port     = 8010                  # Ending port number
    protocol    = "tcp"                 # Protocol (tcp, udp, icmp, etc.)
    cidr_blocks = ["10.0.0.0/16"]       # List of CIDR blocks
  }
]
```

## Outputs

This module currently does not export any outputs. Consider adding outputs for:
- Instance ID
- Private IP address
- Security Group ID

## Common Use Cases

### MarkLogic Database Server
- **Instance Type**: r5.xlarge or larger (memory-optimized)
- **Ports**: 8000-8010 (app servers), 8001 (admin), 7999 (cluster)
- **Storage**: 100GB+ depending on data requirements
- **IAM**: Permissions for S3, CloudWatch, Systems Manager

### Application Server
- **Instance Type**: c5.large or m5.large (balanced compute)
- **Ports**: 80, 443, 8080 (application specific)
- **Storage**: 50GB+ for application and logs
- **IAM**: Application-specific AWS service permissions

### Microservices Backend
- **Instance Type**: t3.medium (burstable performance)
- **Ports**: Custom application ports
- **Storage**: 20-50GB depending on requirements
- **IAM**: Minimal permissions for specific services

## Security Considerations

1. **No Public IP**: Instances have no direct internet access
2. **Restricted Access**: Only accessible from bastion hosts or VPN
3. **IAM Roles**: Use least-privilege IAM instance profiles
4. **Security Groups**: Limit ingress to specific ports and CIDR blocks
5. **Encryption**: Root volumes are encrypted by default
6. **Network Segmentation**: Deploy in private subnets with proper routing

## AMI Management and Instance Stability

### Understanding the AMI Lifecycle

The module uses a data source to fetch the latest Ubuntu 22.04 AMI by default. However, **AWS updates these AMIs weekly**, which can cause Terraform to detect changes and attempt to recreate your instances during the next `terraform plan`.

### Problem: Automatic Instance Recreation

When using the default AMI data source:
```hcl
pvt_use_explicit_ami = false
pvt_explicit_ami_id  = ""
```

After a week, when AWS releases a new Ubuntu AMI, Terraform will show:
```
# aws_instance.pvt_instance must be replaced
-/+ resource "aws_instance" "pvt_instance" {
    ~ ami           = "ami-old123456" -> "ami-new789012" # forces replacement
    # ... other attributes
}
```

**⚠️ Don't panic!** This is expected behavior, not a configuration error.

### Solution: Pin to Explicit AMI

To maintain instance stability and prevent unwanted recreations:

#### Method 1: Immediate Pinning (Recommended)
Right after provisioning your instance, update your configuration:

```hcl
module "marklogic_instance" {
  source = "./path/to/private-instance-module"
  
  # ... other configuration
  
  # Pin to the current AMI immediately after deployment
  pvt_use_explicit_ami = true
  pvt_explicit_ami_id  = "ami-0abcdef1234567890"  # Current instance AMI ID
}
```

#### Method 2: Reactive Pinning
If you see AMI changes in your plan after a week:

1. **Don't apply the plan immediately**
2. Check your current instance AMI ID in AWS Console or CLI:
   ```bash
   aws ec2 describe-instances --instance-ids i-1234567890abcdef0 \
     --query 'Reservations[0].Instances[0].ImageId' --output text
   ```
3. Update your Terraform configuration:
   ```hcl
   pvt_use_explicit_ami = true
   pvt_explicit_ami_id  = "ami-0abcdef1234567890"  # Your current AMI ID
   ```
4. Run `terraform plan` again - the replacement should be gone

### Complete Example with AMI Pinning

```hcl
module "stable_marklogic" {
  source = "./path/to/private-instance-module"

  name           = "marklogic-stable"
  vpc_id         = var.vpc_id
  pvt_subnet_id  = var.private_subnet_id
  ssh_key_name   = var.key_pair_name
  
  # Instance configuration
  pvt_instance_type     = "r5.xlarge"
  pvt_root_volume_size  = 100
  achitecture          = "amd64"
  
  # AMI Stability Configuration
  pvt_use_explicit_ami = true
  pvt_explicit_ami_id  = "ami-0a634ae95e11c6f91"  # Fixed AMI ID
  
  iam_instance_profile = "marklogic-instance-profile"

  # ... rest of configuration
}
```

### When to Update AMIs

Only update the AMI ID when you intentionally want to:
- Apply security patches
- Upgrade to a newer Ubuntu version
- Update pre-installed software

### AMI Update Process

When you do want to update the AMI:

1. **Plan the maintenance window**
2. **Backup your data** (if applicable)
3. **Update the AMI ID** in your configuration:
   ```hcl
   pvt_explicit_ami_id = "ami-new123456789"  # New AMI ID
   ```
4. **Apply the changes** during maintenance window
5. **Verify the application** works correctly
6. **Update any dependent services** if needed

### Finding the Right AMI ID

To find current Ubuntu AMI IDs:

```bash
# Latest Ubuntu 22.04 AMI
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
            "Name=state,Values=available" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text

# Current instance AMI
aws ec2 describe-instances --instance-ids YOUR_INSTANCE_ID \
  --query 'Reservations[0].Instances[0].ImageId' --output text
```

## Best Practices

1. **Instance Sizing**: Choose appropriate instance types for your workload
2. **Monitoring**: Enable CloudWatch monitoring and logging
3. **Backup Strategy**: Implement regular backup procedures
4. **Updates**: Use Systems Manager for patching without internet access
5. **High Availability**: Deploy across multiple AZs for critical workloads
6. **Cost Optimization**: Use appropriate instance types and consider Reserved Instances
7. **AMI Management**: Pin to explicit AMI IDs immediately after deployment for stability

## Troubleshooting

### Common Issues

1. **Cannot SSH to Instance**:
   - Verify bastion host connectivity
   - Check security group rules allow SSH from bastion subnet
   - Ensure correct key pair is configured

2. **Instance Cannot Access Internet**:
   - Verify NAT Gateway is configured in route table
   - Check route table associations for private subnet
   - Confirm security group allows outbound traffic

3. **Application Not Accessible**:
   - Check security group ingress rules
   - Verify application is running and listening on correct ports
   - Check NACLs for additional restrictions

4. **IAM Permission Issues**:
   - Verify IAM instance profile is attached
   - Check IAM role has necessary permissions
   - Review CloudTrail logs for permission denials

### MarkLogic Specific Issues

1. **MarkLogic Won't Start**:
   - Check instance memory (minimum 4GB recommended)
   - Verify disk space availability
   - Check MarkLogic logs in `/var/opt/MarkLogic/Logs/`

2. **Cluster Communication Issues**:
   - Ensure ports 7999-8010 are open between cluster nodes
   - Verify DNS resolution between instances
   - Check network connectivity between subnets

## Integration Examples

### With Bastion Host
```hcl
# First create bastion
module "bastion" {
  source = "../bastion-module"
  # ... bastion configuration
}

# Then create private instance with bastion subnet access
module "private_app" {
  source = "./private-instance-module"
  
  pvt_sg_ingress_rules = [
    {
      description = "SSH from bastion"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.bastion_subnet_cidr]
    }
  ]
  # ... other configuration
}
```

### With Application Load Balancer
```hcl
module "private_app" {
  source = "./private-instance-module"
  
  pvt_sg_ingress_rules = [
    {
      description = "HTTP from ALB"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [var.alb_subnet_cidr]
    }
  ]
  # ... other configuration
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the MIT License. See LICENSE file for details.

## Support

For issues and questions:
- Create an issue in the repository
- Check existing documentation
- Review AWS documentation for underlying resources
- For MarkLogic specific issues, consult MarkLogic documentation