provider "aws" {
  region = var.region
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
