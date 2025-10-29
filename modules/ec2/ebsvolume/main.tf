resource "aws_ebs_volume" "this" {

  availability_zone = var.availability_zone
  size              = var.volume_size
  final_snapshot    = var.final_snapshot
  type              = var.type
  throughput        = var.throughput
  iops              = var.iops

  tags = merge(tomap({ "Name" = "${var.ebs_volume_name}" }), tomap({ "Launch_Month_Year" = formatdate("MMM-YYYY", timestamp()) }), tomap(var.tags))
  lifecycle {
    ignore_changes = [tags, tags_all]
  }
}

resource "aws_volume_attachment" "this" {
  device_name = var.device_name
  volume_id   = aws_ebs_volume.this.id
  instance_id = var.instance_id
}
