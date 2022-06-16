output "aws_lb_wallet_target_group_arn" {
  value = aws_lb_target_group.wallet.arn
}

output "aws_lb_blockchain_target_group_arn" {
  value = aws_lb_target_group.blockchain.arn
}
