variable "prefix" {}

variable "ecr_wallet_image_uri" {}

variable "ecr_blockchain_image_uri" {}

variable "vpc_id" {}

variable "subnet_private_2a_id" {}

variable "subnet_private_2c_id" {}

variable "route_table_private_2a_id" {}

variable "route_table_private_2c_id" {}

variable "aws_lb_wallet_target_group_arn" {}

variable "aws_lb_blockchain_target_group_arn" {}
