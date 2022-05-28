variable "prefix" {
  default = "blockchain-dev"
}

variable "region" {
  default = "us-west-2"
}

// network
variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_2a_cidr_block" {
  default = "10.0.1.0/24"
}

variable "public_2c_cidr_block" {
  default = "10.0.2.0/24"
}

variable "private_2a_cidr_block" {
  default = "10.0.10.0/24"
}

variable "private_2c_cidr_block" {
  default = "10.0.20.0/24"
}

// lb
variable "domain" {
  default = "garianweb.com"
}

variable "wallet_domain" {
  default = "wallet-api.garianweb.com"
}

variable "blockchain_domain" {
  default = "coin-api.garianweb.com"
}

variable "frontend_domain" {
  default = "wallet.garianweb.com"
}

variable "zone_id" {
  default = "Z02830554ETFOUHTXL7A"
}

// ecs
variable "ecr_image_uri" {
  default = "976862162552.dkr.ecr.us-west-2.amazonaws.com/wallet-backend:1.0"
}

// s3
variable "hosted_bucket_name" {
  default = "wallet-frontend-web-bucket"
}

// db
variable "db_master_username" {}

variable "db_master_password" {}
