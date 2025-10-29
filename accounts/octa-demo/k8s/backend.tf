terraform {
  backend "s3" {
    bucket = "osfin-terraform-state-backend"
    key    = "devtools/k8s/terraform.tfstate"
    region = "ap-south-1" 
  }
}