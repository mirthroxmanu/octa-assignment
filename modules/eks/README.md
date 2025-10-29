This module provisions an eks cluster with a nodegroup 


##usage
```hcl
module "eks" {

  source              = "../eks"
  eks_name            = "eks-stage"
  eks_version         = "1.28"
  node_group_name     = "pool1"
  node_ami_type       = "AL2_x86_64"
  node_capacity_type  = "ON_DEMAND"
  node_disk_size      = "20"
  node_instance_types = "t3.medium"
  desired_size        = "2"
  max_size            = "5"
  min_size            = "2"
}
```

Variables

```txt
vpc_id = "vpc id"
vpc_cidr_block = "vpc cidr block"
pvt_subnet_id_1 = "private1 subnet id"
pvt_subnet_id_2 = "private2 subnet id" 
eks_name  = "eks cluster name"
eks_version = "eks cluster version" 
node_group_name = "node group name"
node_ami_type = "node group instance ami type"
node_capacity_type = "capacity type whether OD or SPOT"
node_disk_size = "nodegroup disk size"
node_instance_types = "instance type"
desired_size = "desired number of instances"
max_size = "maximum number of instances"
min_size = "minimum number of instances"

```
Outputs :

```txt
eks_cluster_id = "eks cluster id"
eks_cluster_name = "provisioned eks cluster name"
eks_cluster_endpoint = "eks cluster endpoint"
eks_oidc_provider_url = "eks oidc provider url"

```





