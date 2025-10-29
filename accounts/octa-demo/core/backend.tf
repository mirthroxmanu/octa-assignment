terraform {
  backend "s3" {
    bucket = "octabyte-terraform-state-backend"
    key    = "octabyte/terraform.tfstate"
    region = "ap-south-1" 
  }
}