module "bastion" {
  source        = "./modules/bastion"
  env           = var.env
  vpc_id        = var.vpc_id
  subnet_id     = var.private_subnet_id   # must be private subnet
  ami_id        = var.bastion_ami_id
  instance_type = "t3.medium"
  key_name      = ""                       # optional for SSM
}
