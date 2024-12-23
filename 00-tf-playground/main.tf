# ----------------------------------------
#            Main module
# ----------------------------------------

# Shared tfstate
terraform {
  backend "s3" {
    region = "eu-west-3"
    key    = "k8s-tfstate"
    bucket = "a-tfstate-rchir"
  }
}

# Provider config
provider "aws" {
  region = var.region_target
}

# Create key-pair for logging into ec2 instance
resource "aws_key_pair" "this" {
  key_name   = var.key_pair_name
  public_key = file(var.ssh_public_key_path)
  tags = {
    Name        = join("-",["key-pair", var.resource_tags["project"],var.resource_tags["environment"]])
    Project     = var.resource_tags["project"]
    Owner       = var.resource_tags["owner"]
    Environment = var.resource_tags["environment"]
    user        = var.resource_tags["user"]
  }
} 

# Call network module
module "network" {
  source                  = "./modules/network"
  resource_tags           = var.resource_tags
  vpc_cidr_block          = "10.0.0.0/28"
  public_subnet_cidr_block = "10.0.0.0/28"
}

# Call compute module
module "cp-node01" {
  source                 = "./modules/compute"
  depends_on             = [module.network]
  resource_tags          = var.resource_tags
  base_name              = "cp-node01"
  ami_id                 = "ami-045a8ab02aadf4f88"
  instance_type          = "t3.medium"
  user_data_script_path  = "scripts/init.sh"
  user_data_args         = tomap({})
  ssh_public_key_name    = aws_key_pair.this.key_name
  vpc_security_group_ids = module.network.vpc_security_group_ids
  subnet_id              = module.network.subnet_id
}
# Call compute module
module "wk-node01" {
  source                 = "./modules/compute"
  depends_on             = [module.network]
  resource_tags          = var.resource_tags
  base_name              = "wk-node01"
  ami_id                 = "ami-045a8ab02aadf4f88"
  instance_type          = "t3.medium"
  user_data_script_path  = "scripts/init.sh"
  user_data_args         = tomap({})
  ssh_public_key_name    = aws_key_pair.this.key_name
  vpc_security_group_ids = module.network.vpc_security_group_ids
  subnet_id              = module.network.subnet_id
}
# Call compute module
module "wk-node02" {
  source                 = "./modules/compute"
  depends_on             = [module.network]
  resource_tags          = var.resource_tags
  base_name              = "wk-node02"
  ami_id                 = "ami-045a8ab02aadf4f88"
  instance_type          = "t3.medium"
  user_data_script_path  = "scripts/init.sh"
  user_data_args         = tomap({})
  ssh_public_key_name    = aws_key_pair.this.key_name
  vpc_security_group_ids = module.network.vpc_security_group_ids
  subnet_id              = module.network.subnet_id
}
# Call compute module
module "nfs-server" {
  source                 = "./modules/compute"
  depends_on             = [module.network]
  resource_tags          = var.resource_tags
  base_name              = "nfs-server"
  ami_id                 = "ami-045a8ab02aadf4f88"
  instance_type          = "t3.medium"
  user_data_script_path  = "scripts/init.sh"
  user_data_args         = tomap({})
  ssh_public_key_name    = aws_key_pair.this.key_name
  vpc_security_group_ids = module.network.vpc_security_group_ids
  subnet_id              = module.network.subnet_id
}