output "sg_id" {
  value = aws_security_group.default.id
}

output "rds_sg_id" {
  value = aws_security_group.rds-sg.id
}

output "bastion_id" {
  value = aws_security_group.bastion.id
}