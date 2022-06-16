provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

module "network" {
  source = "../modules/network"

  prefix                = var.prefix
  vpc_cidr_block        = var.vpc_cidr_block
  public_2a_cidr_block  = var.public_2a_cidr_block
  public_2c_cidr_block  = var.public_2c_cidr_block
  private_2a_cidr_block = var.private_2a_cidr_block
  private_2c_cidr_block = var.private_2c_cidr_block
}

module "lb" {
  source = "../modules/lb"

  prefix              = var.prefix
  domain              = var.domain
  zone_id             = var.zone_id
  wallet_domain       = var.wallet_domain
  blockchain_domain   = var.blockchain_domain
  vpc_id              = module.network.vpc_id
  subnet_public_2a_id = module.network.subnet_public_2a_id
  subnet_public_2c_id = module.network.subnet_public_2c_id
}

module "cloudfront" {
  source = "../modules/cloudfront"

  prefix             = var.prefix
  zone_id            = var.zone_id
  domain             = var.domain
  frontend_domain    = var.frontend_domain
  hosted_bucket_name = var.hosted_bucket_name
  providers = {
    aws          = aws
    aws.virginia = aws.virginia
  }
}

module "ecs" {
  source = "../modules/ecs"

  prefix                             = var.prefix
  ecr_wallet_image_uri               = var.ecr_wallet_image_uri
  ecr_blockchain_image_uri           = var.ecr_blockchain_image_uri
  vpc_id                             = module.network.vpc_id
  subnet_private_2a_id               = module.network.subnet_private_2a_id
  subnet_private_2c_id               = module.network.subnet_private_2c_id
  route_table_private_2a_id          = module.network.route_table_private_2a_id
  route_table_private_2c_id          = module.network.route_table_private_2c_id
  aws_lb_wallet_target_group_arn     = module.lb.aws_lb_wallet_target_group_arn
  aws_lb_blockchain_target_group_arn = module.lb.aws_lb_blockchain_target_group_arn
}

module "db" {
  source = "../modules/db"

  prefix                    = var.prefix
  db_master_username        = var.db_master_username
  db_master_password        = var.db_master_password
  vpc_id                    = module.network.vpc_id
  subnet_private_2a_id      = module.network.subnet_private_2a_id
  subnet_private_2c_id      = module.network.subnet_private_2c_id
  allowed_security_group_id = module.ecs.ecs_security_group_id
}
