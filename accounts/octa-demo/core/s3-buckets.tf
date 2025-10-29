module "loki_logs" {
  source                  = "../../../modules/s3"
  bucket                  = "${local.name_prefix}-loki-logs-bucket"
  force_destroy           = false
  attach_public_policy    = true
  block_public_acls       = true
  block_public_policy     = true  
  ignore_public_acls      = true
  restrict_public_buckets = false
  attach_policy           = false
  bucket_policy           = {}
  tags = {
    Owner = "octabyte"
  }
}


module "mimir_metrics" {
  source                  = "../../../modules/s3"
  bucket                  = "${local.name_prefix}-mimir-backend-bucket"
  force_destroy           = false
  attach_public_policy    = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = false
  attach_policy           = false
  bucket_policy           = {}
  tags = {
    Owner = "octabyte"
  }
}