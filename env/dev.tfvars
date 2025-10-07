# Environment
env               = "staging"
aws_region        = "us-east-1"
cluster_name      = "sisense-staging-eks"
k8s_version       = "1.33"
instance_type = "t3.micro"
################################################
# ✅ Existing VPC + Subnets
################################################
vpc_id          = "vpc-069b89b9b7e34fda1"
private_subnets = ["subnet-06e67684de6f297e6", "subnet-04a89427e7493986d", "subnet-07b9b67491137739d"]
db_subnets = ["subnet-00f9d9f9f9506f90d", "subnet-0290c5022418e0247"]
db_name          = "sisense"
db_username      = "cstsqladmin"
db_instance_class = "db.m6i.xlarge"
#db_password     = "StrongP@ssw0rd!"   # ideally store in AWS Secrets Manager
#ad_directory_id = "d-9067b7e12e"      # replace with your directory ID
##############################################
# Nodegroup sizing
##############################################
#instance_types = ["m5.xlarge"]
disk_size      = 400
min_size       = 3
max_size       = 3
desired_size   = 3
ami_type       = "AL2_X86_64"
sa_namespace = "kube-system"
sa_name      = "cluster-autoscaler"

# Userdata bootstrap
#xtra_userdata = "userdata/bootstrap.sh"
####################################
# FSx Lustre storage
###################################
fsx_storage_capacity = 1200

 #Networking / DNS
zone_name = "centralsquarecloud-stage.com"

tags = { 
  cst_environment                   = "dev"
  cst_backup_policy                 = "none" 
  cst_product_line                  = "foundation" 
  cst_tenant                        = "foundation" 
  cst_cost_center                   = "infrastructure"
  cst_name                          = "psj_crimeanalytics"
  cst_compliance_domain             = "cjis"
  cst_tenancy                       = "multiple"
  cst_application                   = "psj_crimeanalytics"
}

