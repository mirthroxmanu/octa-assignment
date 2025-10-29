# VPC Resource
#=================================================
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags                 = merge(tomap({ "Name" = "${var.name_prefix}-vpc" }), tomap(var.tags))

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags["created_by"], tags["created_by_arn"],
    ]
  }
}


# AWS internet gateway  resource
#===================================================

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(tomap({ "Name" = "${var.name_prefix}-igw" }), tomap(var.tags))

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags["created_by"], tags["created_by_arn"],
    ]
  }
}

#Public
#====================================================

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnets[count.index]     #var.public_subnets[count.index].cidr
  availability_zone = var.availability_zones[count.index] #var.public_subnets[count.index].availability_zone

  map_public_ip_on_launch = true

  tags = merge(tomap(
    { "Name" = "${var.name_prefix}-subnet-public-${substr(var.availability_zones[count.index], -2, 2)}" }),
    { "Tier" = "Public" },
    { "kubernetes.io/role/elb" = "1" },
    tomap(var.tags)
  )

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags["created_by"], tags["created_by_arn"],
    ]
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(tomap({ "Name" = "${var.name_prefix}-public-rt" }), tomap(var.tags))

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags["created_by"], tags["created_by_arn"], route
    ]
  }

}

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}


resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#PrivateSubnet
#===============================================================
#subnet
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(tomap(
    { "Name" = "${var.name_prefix}-subnet-private-${substr(var.availability_zones[count.index], -2, 2)}" }),
    { "Tier" = "Private" },
    { 
      "kubernetes.io/role/internal-elb" = 1
     },
    tomap(var.tags),
    tomap(var.private_subnet_additional_tags)
  )
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags["created_by"], tags["created_by_arn"],
    ]
  }
}



# #NAT GATEWAY RESOURCES
# #=======================================================

# Local variables
locals {
  nat_gateway_count = var.single_nat_gateway ? 1 : length(var.private_subnets)
  elastic_ip_count  = var.enable_nat_gateway ? local.nat_gateway_count : 0
}

# Elastic IP resource
resource "aws_eip" "nat" {
  count  = local.elastic_ip_count
  domain = "vpc"
  tags   = merge(tomap({ "Name" = "${var.name_prefix}-eip-${count.index + 1}" }), tomap(var.tags))
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags["created_by"], tags["created_by_arn"],
    ]
  }
}

# NAT Gateway resource
resource "aws_nat_gateway" "nat" {
  count         = local.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.single_nat_gateway ? aws_subnet.public[0].id : element(aws_subnet.public.*.id, count.index)

  tags = merge(tomap({ "Name" = "${var.name_prefix}-nat-gw-${substr(var.availability_zones[count.index], -2, 2)}" }), tomap(var.tags))

  lifecycle {
    ignore_changes = [
      tags["created_by"],
      tags["created_by_arn"],
    ]
  }
}

# Route Table resource
resource "aws_route_table" "private" {
  count = var.single_nat_gateway ? 1 : length(var.private_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(tomap({ "Name" = "${var.name_prefix}-private-rt-${substr(var.availability_zones[count.index], -2, 2)}" }), tomap(var.tags))

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags["created_by"], tags["created_by_arn"]
    ]
  }
}

resource "aws_route" "nat_gw_route" {
  count                  = var.single_nat_gateway ? 1 : length(var.private_subnets)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[var.single_nat_gateway ? 0 : count.index].id
}

# Route Table Association resource
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
}


# #nat gateway per availability zones
# #=======================================================

# resource "aws_eip" "nat" {
#   count = var.pvt_subnet_with_single_nat_gateway ? 0 : length(var.private_subnets)
# }

# resource "aws_nat_gateway" "nat" {
#   count = var.pvt_subnet_with_single_nat_gateway ? 0 : length(var.private_subnets)

#   allocation_id = var.pvt_subnet_with_single_nat_gateway ? null : aws_eip.nat[count.index].id
#   subnet_id     = element(aws_subnet.public.*.id, count.index)


#   tags = merge(tomap({"Name" = "${var.name_prefix}-nat-gw-${substr(var.private_subnets[count.index].availability_zone, -2, 2)}"}), tomap(var.tags))

#   lifecycle {
#     ignore_changes = [
#       # Ignore changes to tags
#       tags["created_by"], tags["created_by_arn"],
#     ]
#   }  
# }

# resource "aws_route_table" "private" {
#   count = var.pvt_subnet_with_single_nat_gateway ? 0 : length(var.private_subnets)

#   vpc_id = aws_vpc.this.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat[count.index].id
#   }

#   tags = {
#     Name = "private-rt-${substr(var.private_subnets[count.index].availability_zone, -2, 2)}"
#   }

#   lifecycle {
#     ignore_changes = [
#       route
#       ]
#   }  
# }

# resource "aws_route_table_association" "private" {
#   count = var.pvt_subnet_with_single_nat_gateway ? 0 : length(var.private_subnets)

#   subnet_id      = aws_subnet.private[count.index].id
#   route_table_id = aws_route_table.private[count.index].id
# }


# #Single nat gateway
# #========================================================

# resource "aws_eip" "single_nat" {
#   count = var.pvt_subnet_with_single_nat_gateway ? 1 : 0
# }

# resource "aws_nat_gateway" "single_nat" {
#   count = var.pvt_subnet_with_single_nat_gateway ? 1 : 0

#   allocation_id = var.pvt_subnet_with_single_nat_gateway ? aws_eip.single_nat[0].id : null
#   subnet_id     = aws_subnet.public[0].id

#   tags = {
#     Name = "nat-gateway-1a"
#   }
# }

# resource "aws_route_table" "single_private" {
#   count = var.pvt_subnet_with_single_nat_gateway ? 1 : 0

#   vpc_id = aws_vpc.this.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.single_nat[0].id
#   }

#   lifecycle {
#     ignore_changes = [route]
#   }  

#   tags = {
#     Name = "private-rt"
#   }
# }

# resource "aws_route_table_association" "single_private" {
#   count = var.pvt_subnet_with_single_nat_gateway ? length(var.private_subnets) : 0

#   subnet_id      = aws_subnet.private[count.index].id
#   route_table_id = aws_route_table.single_private[0].id
# }
