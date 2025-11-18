# Environment
env               = "staging"
aws_region        = "us-east-1"
aws_account_id    = ""
cluster_name      = "sisense-staging-eks"
k8s_version       = "1.33"
instance_type     =  "t2.micro"
account_vpc_name  = "cva-stg-eks"
cloud_admin_entrypoint_role_arn = "
################################################
# database
################################################
#db_subnets =     []
#db_name          = "cstcrimeviewm2022"
#db_username      = "cstsqladmin"
#db_instance_class = "db.m6i.xlarge"
#ad_directory_id = "d-9067b7e12e"      # replace with your directory ID
##############################################
# Nodegroup sizing
##############################################
node_groups = {
  "sisense-application" = {
    desired_size   = 3
    min_size       = 3
    max_size       = 4
    instance_types = ["m6i.2xlarge"]
    disk_size     = 400
    capacity_type = "ON_DEMAND"
  }
  "sisense-query" = {
    desired_size   = 0
    min_size       = 0
    max_size       = 1
    instance_types = ["r6i.2xlarge"]
    disk_size     = 400
    capacity_type = "ON_DEMAND"
  }
  "sisense-build" = {
    desired_size   = 0
    min_size       = 0
    max_size       = 1
    instance_types = ["m6i.2xlarge"]
    disk_size     = 400
    capacity_type = "ON_DEMAND"
  }
}
ami_type       = "AL2_X86_64"

####################################
# FSx Lustre storage
###################################
fsx_storage_capacity = 1200
fsx_version = "2.15"

tags = { 
  cst_environment                   = "stg"
  cst_backup_policy                 = "none" 
  cst_product_line                  = "foundation" 
  cst_tenant                        = "foundation" 
  cst_cost_center                   = "infrastructure"
  cst_name                          = "psj_crimeanalytics"
  cst_compliance_domain             = "cjis"
  cst_tenancy                       = "multiple"
  cst_application                   = "psj_crimeanalytics"
}
