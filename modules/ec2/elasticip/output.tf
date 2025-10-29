output "elastic_ip_resource" {
  value = aws_eip_association.eip_assoc
}


output "public_ip" {
  value = aws_eip.instance_eip.public_ip
}