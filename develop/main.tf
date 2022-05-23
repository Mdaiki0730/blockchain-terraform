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
