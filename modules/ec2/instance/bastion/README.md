# Bastion Host Terraform Module

This Terraform module creates a secure bastion host (jump server) in AWS with an Elastic IP address. A bastion host provides secure access to private resources in your VPC by acting as a gateway that you can SSH into from the internet.

## Features

- **EC2 Instance**: Creates a bastion host using Ubuntu 22.04 LTS
- **Elastic IP**: Assigns a static public IP address
- **Security Group**: Configurable ingress rules with secure egress
- **Encrypted Storage**: Root volume is encrypted by default
- **Flexible AMI**: Option to use custom AMI or latest Ubuntu image
- **Customizable**: Support for custom instance types, storage, and security rules

## Architecture

```
Internet → Elastic IP → Bastion Host (Public Subnet) → Private Resources
```

The bastion host sits in a public subnet and allows secure SSH access to resources in private subnets.

## Usage

### Basic Example

```hcl
module "bastion" {
  source = "./path/to/bastion-module"

  # Required variables
  name              = "my-project"
  vpc_id           = "vpc-12345678"
  public_subnet_id = "subnet-12345678"
  ssh_key_name     = "my-key-pair"
  
  # Instance configuration
  bastion_instance_type     = "t3.micro"
  bastion_root_volume_size  = 20
  achitecture              = "amd64"
  bastion_use_explicit_ami = false
  bastion_explicit_ami_id  = ""

  # Security group rules
  bastion_sg_ingress_rules = [
    {
      description = "SSH access from office"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["203.0.113.0/24"]  # Replace with your office IP
    }
  ]

  # Tags
  instance_tags = {
    Name        = "my-project-bastion"
    Environment = "production"
    Role        = "bastion"
  }

  sg_tags = {
    Name        = "my-project-bastion-sg"
    Environment = "production"
  }

  eip_tags = {
    Name        = "my-project-bastion-eip"
    Environment = "production"
  }

  volume_tags = {
    Name        = "my-project-bastion-volume"
    Environment = "production"
  }
}
```

### Advanced Example with Custom AMI

```hcl
module "bastion" {
  source = "./path/to/bastion-module"

  name              = "secure-bastion"
  vpc_id           = var.vpc_id
  public_subnet_id = var.public_subnet_id
  ssh_key_name     = var.key_pair_name
  
  # Use custom AMI
  bastion_use_explicit_ami = true
  bastion_explicit_ami_id  = "ami-0abcdef1234567890"
  bastion_instance_type    = "t3.small"
  bastion_root_volume_size = 30
  achitecture             = "amd64"

  # Multiple ingress rules
  bastion_sg_ingress_rules = [
    {
      description = "SSH from office network"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    },
    {
      description = "SSH from VPN"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["192.168.1.0/24"]
    }
  ]

  instance_tags = {
    Name         = "secure-bastion-host"
    Environment  = "production"
    Owner        = "devops-team"
    CostCenter   = "infrastructure"
  }

  sg_tags = {
    Name = "secure-bastion-security-group"
  }

  eip_tags = {
    Name = "secure-bastion-elastic-ip"
  }

  volume_tags = {
    Name = "secure-bastion-root-volume"
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
| `aws_instance` | bastion_instance | The bastion host EC2 instance |
| `aws_security_group` | bastion_sg | Security group for the bastion host |
| `aws_eip` | instance_eip | Elastic IP address for the bastion host |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Base name for resources | `string` | n/a | yes |
| vpc_id | VPC ID where the bastion will be created | `string` | n/a | yes |
| public_subnet_id | Public subnet ID for the bastion host | `string` | n/a | yes |
| ssh_key_name | Name of the AWS key pair for SSH access | `string` | n/a | yes |
| bastion_instance_type | EC2 instance type for the bastion host | `string` | n/a | yes |
| achitecture | CPU architecture (amd64 or arm64) | `string` | n/a | yes |
| bastion_root_volume_size | Size of the root volume in GB | `number` | n/a | yes |
| bastion_use_explicit_ami | Whether to use a specific AMI ID | `bool` | n/a | yes |
| bastion_explicit_ami_id | Specific AMI ID to use (when bastion_use_explicit_ami is true) | `string` | n/a | yes |
| bastion_sg_ingress_rules | List of ingress rules for the security group | `list(object)` | n/a | yes |
| instance_tags | Tags to apply to the EC2 instance | `map(string)` | n/a | yes |
| sg_tags | Tags to apply to the security group | `map(string)` | n/a | yes |
| eip_tags | Tags to apply to the Elastic IP | `map(string)` | n/a | yes |
| volume_tags | Tags to apply to the EBS volumes | `map(string)` | n/a | yes |

### Security Group Rules Format

The `bastion_sg_ingress_rules` variable expects a list of objects with the following structure:

```hcl
bastion_sg_ingress_rules = [
  {
    description = "Description of the rule"
    from_port   = 22                    # Starting port number
    to_port     = 22                    # Ending port number
    protocol    = "tcp"                 # Protocol (tcp, udp, icmp, etc.)
    cidr_blocks = ["10.0.0.0/8"]       # List of CIDR blocks
  }
]
```

## Outputs

| Name | Description |
|------|-------------|
| instnace_id | The instance ID of the bastion host |
| public_ip | The public IP address of the bastion host |

## Security Considerations

1. **Restrict SSH Access**: Always limit SSH access to specific IP ranges or VPN networks
2. **Use Strong Key Pairs**: Ensure you're using strong SSH key pairs
3. **Regular Updates**: Keep the bastion host updated with latest security patches
4. **Monitoring**: Enable CloudWatch monitoring and logging
5. **Backup**: Consider regular backups of the instance if it contains important configuration

## AMI Management and Instance Stability

### Understanding the AMI Lifecycle

The module uses a data source to fetch the latest Ubuntu 22.04 AMI by default. However, **AWS updates these AMIs weekly**, which can cause Terraform to detect changes and attempt to recreate your bastion host during the next `terraform plan`.

### Problem: Automatic Instance Recreation

When using the default AMI data source:
```hcl
bastion_use_explicit_ami = false
bastion_explicit_ami_id  = ""
```

After a week, when AWS releases a new Ubuntu AMI, Terraform will show:
```
# aws_instance.bastion_instance must be replaced
-/+ resource "aws_instance" "bastion_instance" {
    ~ ami           = "ami-old123456" -> "ami-new789012" # forces replacement
    # ... other attributes
}
```

**⚠️ Don't panic!** This is expected behavior, not a configuration error. However, recreating your bastion host will change its Elastic IP and potentially disrupt access to your private resources.

### Solution: Pin to Explicit AMI

To maintain bastion stability and prevent unwanted recreations:

#### Method 1: Immediate Pinning (Recommended)
Right after provisioning your bastion host, update your configuration:

```hcl
module "bastion" {
  source = "./path/to/bastion-module"
  
  # ... other configuration
  
  # Pin to the current AMI immediately after deployment
  bastion_use_explicit_ami = true
  bastion_explicit_ami_id  = "ami-0abcdef1234567890"  # Current bastion AMI ID
}
```

#### Method 2: Reactive Pinning
If you see AMI changes in your plan after a week:

1. **Don't apply the plan immediately**
2. Check your current bastion AMI ID in AWS Console or CLI:
   ```bash
   aws ec2 describe-instances --instance-ids i-1234567890abcdef0 \
     --query 'Reservations[0].Instances[0].ImageId' --output text
   ```
3. Update your Terraform configuration:
   ```hcl
   bastion_use_explicit_ami = true
   bastion_explicit_ami_id  = "ami-0abcdef1234567890"  # Your current AMI ID
   ```
4. Run `terraform plan` again - the replacement should be gone

### Complete Example with AMI Pinning

```hcl
module "stable_bastion" {
  source = "./path/to/bastion-module"

  name              = "secure-bastion"
  vpc_id           = var.vpc_id
  public_subnet_id = var.public_subnet_id
  ssh_key_name     = var.key_pair_name
  
  # Instance configuration
  bastion_instance_type     = "t3.micro"
  bastion_root_volume_size  = 20
  achitecture              = "amd64"
  
  # AMI Stability Configuration
  bastion_use_explicit_ami = true
  bastion_explicit_ami_id  = "ami-0a634ae95e11c6f91"  # Fixed AMI ID
  
  # Security group rules
  bastion_sg_ingress_rules = [
    {
      description = "SSH from office"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["203.0.113.0/24"]
    }
  ]

  # ... rest of configuration
}
```

### Why AMI Stability is Critical for Bastion Hosts

Bastion hosts are particularly sensitive to recreation because:
- **IP Address Changes**: New Elastic IP affects firewall rules and DNS records
- **Access Disruption**: Teams lose access to private resources during recreation
- **Security Risk**: Temporary loss of secure access point
- **Operational Impact**: All private instance access depends on the bastion

### When to Update AMIs

Only update the bastion AMI when you intentionally want to:
- Apply critical security patches
- Upgrade to a newer Ubuntu version
- Update pre-installed security tools

### AMI Update Process for Bastion Hosts

When you do want to update the bastion AMI:

1. **Schedule maintenance window** (coordinate with team)
2. **Notify users** of temporary access disruption
3. **Document current Elastic IP** for reference
4. **Update the AMI ID** in your configuration:
   ```hcl
   bastion_explicit_ami_id = "ami-new123456789"  # New AMI ID
   ```
5. **Apply changes** during maintenance window
6. **Verify SSH access** works correctly
7. **Update documentation** with any IP changes
8. **Notify team** when access is restored

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

# Current bastion instance AMI
aws ec2 describe-instances --instance-ids YOUR_BASTION_INSTANCE_ID \
  --query 'Reservations[0].Instances[0].ImageId' --output text
```

## Best Practices

1. **Minimal Access**: Only allow SSH (port 22) inbound traffic
2. **IP Whitelisting**: Restrict access to known IP ranges
3. **Instance Size**: Use appropriately sized instances (t3.micro is often sufficient)
4. **Regular Maintenance**: Schedule regular maintenance windows for updates
5. **Session Management**: Consider using AWS Systems Manager Session Manager for additional security
6. **AMI Management**: Pin to explicit AMI IDs immediately after deployment for stability
7. **Monitoring**: Set up CloudWatch alarms for bastion host availability

## Troubleshooting

### Common Issues

1. **Cannot SSH to Bastion**: 
   - Check security group rules
   - Verify the correct key pair is being used
   - Ensure the source IP is whitelisted

2. **Instance Not Starting**:
   - Check if the specified AMI exists in your region
   - Verify subnet and VPC configuration
   - Check IAM permissions

3. **Elastic IP Not Attaching**:
   - Ensure the instance is in running state
   - Check for EIP limits in your account

## Examples

See the `examples/` directory for complete working examples:
- `examples/basic/` - Basic bastion setup
- `examples/advanced/` - Advanced configuration with custom settings

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