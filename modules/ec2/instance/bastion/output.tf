output "instnace_id" {
  value = aws_instance.bastion_instance.id
}

output "public_ip" {
  value = aws_eip.instance_eip.public_ip
}