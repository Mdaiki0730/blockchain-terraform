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
