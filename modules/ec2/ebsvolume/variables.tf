variable "availability_zone" {
  description = "should be the same availability zone same as the resource."
}

variable "volume_size" {
  description = "size of the disk in GB."
}

variable "final_snapshot" {
  description = "Snapshot will be created before volume deletion. Any tags on the volume will be migrated to the snapshot."
}

variable "type" {
  description = " The type of EBS volume. Can be standard, gp2, gp3, io1, io2, sc1 or st1 (Default: gp2)."
}


variable "throughput" {
  description = "The throughput that the volume supports, in MiB/s. Only valid for type of gp3"
}

variable "iops" {
  description = "The amount of IOPS to provision for the disk. Only valid for type of io1, io2 or gp3."
}

variable "ebs_volume_name" {
  description = "Name tag for the ebs volume"
}

variable "device_name" {
  description = "The ebs volume device name eg: /dev/sda1"
}

variable "instance_id" {
  description = "The  ID of the Instance to attach to"
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
}
