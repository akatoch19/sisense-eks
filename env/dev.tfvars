# Environment
env = "dev"
aws_region = "us-east-1"
cluster_name = "sisense-dev-eks"
k8s_version = "1.31"

# Nodegroup sizing
instance_types = ["m5.2xlarge"]
disk_size      = 200
min_size       = 2
max_size       = 3
desired_size   = 2

# FSx Lustre storage
fsx_storage_capacity = 1200

# Networking / DNS
zone_name = "dev.sisense.example.com"
namespace = "sisense"

# Userdata bootstrap
extra_userdata = "userdata/bootstrap.sh"
