# Environment
env = "dev"
aws_region = "us-gov-west-1"
cluster_name = "sisense-dev-eks"
k8s_version = "1.32"

# Nodegroup sizing
instance_types = ["m5.2xlarge"]
disk_size      = 200
min_size       = 1
max_size       = 1
desired_size   = 1

# FSx Lustre storage
fsx_storage_capacity = 1200

# Networking / DNS
#zone_name = "dev.sisense.myleslie.com"
#namespace = "sisense"

# Userdata bootstrap
extra_userdata = "userdata/bootstrap.sh
