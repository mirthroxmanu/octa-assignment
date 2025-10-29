resource "aws_eip" "instance_eip" {
  tags = merge(tomap({ "Name" = "${var.name_prefix}-${var.name}-eip" }), tomap(var.tags))

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags["created_by"], tags["created_by_arn"],
    ]
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = var.instance_id
  allocation_id = aws_eip.instance_eip.id
}

