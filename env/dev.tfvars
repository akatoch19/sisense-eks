# Environment
env = "dev"
aws_region = "us-gov-west-1"
cluster_name = "sisense-dev-eks"
k8s_version = "1.33"

instance_type = "t3.micro"

# Nodegroup sizing
instance_types = ["m5.2xlarge"]
disk_size      = 200
min_size       = 1
max_size       = 1
desired_size   = 1

jumphost_role_arn = "arn:aws-us-gov:iam::352667531893:role/eks-jumphost-role"

# FSx Lustre storage
fsx_storage_capacity = 1200

# Networking / DNS
#zone_name = "dev.sisense.myleslie.com"
#namespace = "sisense"

# Userdata bootstrap
extra_userdata = "userdata/bootstrap.sh
