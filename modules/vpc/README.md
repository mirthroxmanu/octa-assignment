# VPC Terraform Module

This Terraform module creates a complete AWS VPC (Virtual Private Cloud) infrastructure with public and private subnets, NAT gateways, route tables, and internet gateway. It's designed to provide a secure, scalable network foundation for your AWS resources with support for both single and multi-AZ NAT gateway configurations.

## Features

- **VPC**: Creates a VPC with configurable CIDR block and DNS settings
- **Public Subnets**: Multiple public subnets across availability zones with internet access
- **Private Subnets**: Multiple private subnets for backend resources
- **Internet Gateway**: Provides internet access for public subnets
- **NAT Gateways**: Configurable NAT gateway setup (single or per-AZ)
- **Route Tables**: Automatic routing configuration for public and private traffic
- **Kubernetes Ready**: Includes tags for AWS Load Balancer Controller integration
- **Cost Optimization**: Option for single NAT gateway to reduce costs

## Architecture

### Multi-AZ NAT Gateway (High Availability)
```
Internet Gateway
       |
   Public Subnets (AZ-1a, AZ-1b, AZ-1c)
       |           |           |
   NAT-GW-1a   NAT-GW-1b   NAT-GW-1c
       |           |           |
Private Subnets (AZ-1a, AZ-1b, AZ-1c)
```

### Single NAT Gateway (Cost Optimized)
```
Internet Gateway
       |
   Public Subnets (AZ-1a, AZ-1b, AZ-1c)
       |
   NAT-GW-1a (Single)
       |
Private Subnets (AZ-1a, AZ-1b, AZ-1c)
```

## Usage

### Basic Example - Multi-AZ Setup

```hcl
module "vpc" {
  source = "./path/to/vpc-module"

  # VPC Configuration
  name_prefix      = "my-project"
  vpc_cidr_block   = "10.0.0.0/16"
  
  # DNS Settings
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  # Subnets
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  
  # Availability Zones
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  
  # NAT Gateway Configuration (High Availability)
  enable_nat_gateway  = true
  single_nat_gateway  = false  # One NAT Gateway per AZ
  
  # Tags
  tags = {
    Environment = "production"
    Project     = "my-application"
    Owner       = "devops-team"
  }
}
```

### Cost-Optimized Example - Single NAT Gateway

```hcl
module "vpc_cost_optimized" {
  source = "./path/to/vpc-module"

  name_prefix      = "dev-environment"
  vpc_cidr_block   = "10.1.0.0/16"
  
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  # Smaller subnets for development
  public_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.11.0/24", "10.1.12.0/24"]
  
  availability_zones = ["us-west-2a", "us-west-2b"]
  
  # Single NAT Gateway for cost savings
  enable_nat_gateway  = true
  single_nat_gateway  = true  # Only one NAT Gateway
  
  tags = {
    Environment = "development"
    CostCenter  = "engineering"
  }
}
```

### Production Example - Three-Tier Architecture

```hcl
module "production_vpc" {
  source = "./path/to/vpc-module"

  name_prefix      = "prod-app"
  vpc_cidr_block   = "10.0.0.0/16"
  
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  # Public subnets for load balancers
  public_subnets = [
    "10.0.1.0/24",   # us-east-1a - Web tier
    "10.0.2.0/24",   # us-east-1b - Web tier
    "10.0.3.0/24"    # us-east-1c - Web tier
  ]
  
  # Private subnets for application and database tiers
  private_subnets = [
    "10.0.11.0/24",  # us-east-1a - App tier
    "10.0.12.0/24",  # us-east-1b - App tier
    "10.0.13.0/24",  # us-east-1c - App tier
  ]
  
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  # High availability NAT setup
  enable_nat_gateway  = true
  single_nat_gateway  = false
  
  tags = {
    Environment     = "production"
    Application     = "web-application"
    BusinessUnit    = "customer-facing"
    BackupRequired  = "yes"
    MonitoringLevel = "high"
  }
}
```

### Kubernetes/EKS Optimized Example

```hcl
module "eks_vpc" {
  source = "./path/to/vpc-module"

  name_prefix      = "eks-cluster"
  vpc_cidr_block   = "172.16.0.0/16"
  
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  # Public subnets for load balancers (tagged for ELB)
  public_subnets = [
    "172.16.1.0/24",
    "172.16.2.0/24",
    "172.16.3.0/24"
  ]
  
  # Private subnets for EKS nodes (tagged for internal ELB)
  private_subnets = [
    "172.16.11.0/24",
    "172.16.12.0/24",
    "172.16.13.0/24"
  ]
  
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  
  enable_nat_gateway  = true
  single_nat_gateway  = false  # HA for production EKS
  
  tags = {
    Environment                              = "production"
    "kubernetes.io/cluster/my-eks-cluster"   = "shared"
    "kubernetes.io/role/elb"                 = "1"      # Auto-applied to public subnets
    "kubernetes.io/role/internal-elb"        = "1"      # Auto-applied to private subnets
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
| `aws_vpc` | this | The main VPC |
| `aws_internet_gateway` | this | Internet gateway for public subnets |
| `aws_subnet` | public | Public subnets across AZs |
| `aws_subnet` | private | Private subnets across AZs |
| `aws_eip` | nat | Elastic IPs for NAT gateways |
| `aws_nat_gateway` | nat | NAT gateways for private subnet internet access |
| `aws_route_table` | public | Route table for public subnets |
| `aws_route_table` | private | Route tables for private subnets |
| `aws_route` | igw_route | Route to internet gateway |
| `aws_route` | nat_gw_route | Routes to NAT gateways |
| `aws_route_table_association` | public | Associates public subnets with route table |
| `aws_route_table_association` | private | Associates private subnets with route tables |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for resource names | `string` | n/a | yes |
| vpc_cidr_block | CIDR block for the VPC | `string` | n/a | yes |
| public_subnets | List of public subnet CIDR blocks | `list(string)` | n/a | yes |
| private_subnets | List of private subnet CIDR blocks | `list(string)` | n/a | yes |
| availability_zones | List of availability zones | `list(string)` | n/a | yes |
| single_nat_gateway | Use single NAT gateway for all private subnets | `bool` | n/a | yes |
| tags | Map of tags to apply to resources | `map(string)` | n/a | yes |
| enable_dns_support | Enable DNS support in VPC | `bool` | `true` | no |
| enable_dns_hostnames | Enable DNS hostnames in VPC | `bool` | `true` | no |
| enable_nat_gateway | Enable NAT gateways for private subnets | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| public_subnet_ids | List of IDs of the public subnets |
| private_subnet_ids | List of IDs of the private subnets |
| nat_gateway_ids | List of IDs of the NAT gateways |
| public_route_table_ids | List of IDs of the public route tables |
| private_route_table_ids | List of IDs of the private route tables |

## NAT Gateway Configuration

### High Availability (Recommended for Production)
```hcl
single_nat_gateway = false
```
- Creates one NAT gateway per availability zone
- Higher cost but provides redundancy
- If one AZ fails, private subnets in other AZs maintain internet access
- Recommended for production workloads

### Cost Optimized (Suitable for Development)
```hcl
single_nat_gateway = true
```
- Creates only one NAT gateway in the first public subnet
- Lower cost but single point of failure
- All private subnets route through one NAT gateway
- Suitable for development and testing environments

## Subnet Sizing Guidelines

### Small Environment (< 50 resources per subnet)
```hcl
public_subnets  = ["10.0.1.0/26", "10.0.2.0/26"]    # 62 IPs each
private_subnets = ["10.0.11.0/26", "10.0.12.0/26"]  # 62 IPs each
```

### Medium Environment (< 250 resources per subnet)
```hcl
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]    # 254 IPs each
private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]  # 254 IPs each
```

### Large Environment (< 1000 resources per subnet)
```hcl
public_subnets  = ["10.0.1.0/22", "10.0.5.0/22"]    # 1022 IPs each
private_subnets = ["10.0.11.0/22", "10.0.15.0/22"]  # 1022 IPs each
```

## Kubernetes Integration

The module automatically applies Kubernetes-specific tags:

### Public Subnets
- `kubernetes.io/role/elb = "1"` - For internet-facing load balancers

### Private Subnets  
- `kubernetes.io/role/internal-elb = 1` - For internal load balancers

These tags enable the AWS Load Balancer Controller to automatically discover subnets for load balancer placement.

## Cost Considerations

### NAT Gateway Costs
- **Multi-AZ Setup**: ~$32-45/month per NAT gateway + data transfer
- **Single NAT Gateway**: ~$32-45/month for one NAT gateway + data transfer
- **Development Alternative**: Consider NAT instances for very low-traffic environments

### Data Transfer Costs
- Data transfer through NAT gateways incurs additional charges
- Consider VPC endpoints for AWS services to avoid NAT gateway costs

## Security Best Practices

1. **CIDR Planning**: Use non-overlapping CIDR blocks if you plan to peer VPCs
2. **Subnet Isolation**: Keep public and private subnets properly separated
3. **Security Groups**: Use security groups rather than NACLs for most access control
4. **Flow Logs**: Enable VPC Flow Logs for network monitoring
5. **Route Table Security**: Regularly audit route table configurations

## Common Use Cases

### Web Application Architecture
```
Public Subnets: Load balancers, NAT gateways, bastion hosts
Private Subnets: Application servers, databases, cache layers
```

### EKS/Kubernetes Cluster
```
Public Subnets: Load balancers, NAT gateways
Private Subnets: EKS worker nodes, pods, internal services
```

### Microservices Architecture
```
Public Subnets: API gateways, load balancers
Private Subnets: Microservice containers, databases, message queues
```

## Troubleshooting

### Common Issues

1. **Private Instances Can't Access Internet**:
   - Verify NAT gateway is created and running
   - Check private route table has route to NAT gateway
   - Ensure security groups allow outbound traffic

2. **Public Resources Not Accessible from Internet**:
   - Verify internet gateway is attached
   - Check public route table has route to internet gateway
   - Confirm security groups allow inbound traffic

3. **Cross-AZ Communication Issues**:
   - Verify all subnets are in the same VPC
   - Check security groups allow traffic between subnets
   - Ensure route tables are properly configured

4. **Kubernetes Load Balancer Issues**:
   - Verify subnet tags are applied correctly
   - Check AWS Load Balancer Controller has proper permissions
   - Ensure subnets have available IP addresses

### Validation Commands

```bash
# Check VPC configuration
aws ec2 describe-vpcs --vpc-ids vpc-12345678

# Verify subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-12345678"

# Check NAT gateways
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=vpc-12345678"

# Verify route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-12345678"
```

## Migration and Updates

### Adding New Subnets
When adding new subnets, ensure:
- CIDR blocks don't overlap with existing subnets
- Availability zones are specified correctly
- Route table associations are updated

### Changing NAT Gateway Configuration
**⚠️ Warning**: Changing from single to multi-AZ NAT or vice versa will cause downtime for private resources.

Plan the change during maintenance windows:
1. Update the `single_nat_gateway` variable
2. Apply changes during low-traffic periods
3. Verify connectivity after changes

## Examples

See the `examples/` directory for complete working examples:
- `examples/basic/` - Simple VPC setup
- `examples/production/` - Production-ready configuration
- `examples/eks/` - EKS-optimized VPC
- `examples/cost-optimized/` - Development environment setup

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
- Review AWS VPC documentation
- Consult AWS architecture best practices