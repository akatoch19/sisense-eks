# Environment
env = "prod"
aws_region = "us-east-1"
cluster_name = "sisense-prod-eks"
k8s_version = "1.31"

# Nodegroup sizing
instance_types = ["m5.8xlarge"]
disk_size      = 400
min_size       = 4
max_size       = 8
desired_size   = 4

# FSx Lustre storage
fsx_storage_capacity = 6144

# Networking / DNS
zone_name = "sisense.example.com"
namespace = "sisense"

# Userdata bootstrap
extra_userdata = "userdata/bootstrap.sh"

# IAM / CNI
use_custom_cni_policy = true
eks_cni_govcloud_arn  = ""  # leave blank to use custom CNI

tags = { 
  cst_backup_policy = "none"
  cst_tenant = "multiple" 
  cst_tenancy = "multiple" 
  cst_environment = "prod" 
  cst_product_line = "foundation" 
  cst_compliance_domain = "cjis" 
  cst_cost_center = "centralsquare_cloud_infrastructure" 
  cst_application = "eks-platform" 
  cst_name = "rms-prod-gov" 
}
