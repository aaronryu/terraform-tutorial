resource "aws_s3_bucket" "private_assets_bucket" {
  bucket = "bootstrap-private-assets"

  tags = {
    Role        = "bootstrap-private-assets-bucket"
    Type        = "s3"
    Profile     = "dev"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_ownership_controls" "private_assets_bucket_acl_ownership" {
  bucket = aws_s3_bucket.private_assets_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "private_assets_bucket_acl" {
  bucket = aws_s3_bucket.private_assets_bucket.id
  acl    = "private"
}

output "private_image_s3_bucket_domain_name" {
    value = "${aws_s3_bucket.private_assets_bucket.bucket_domain_name}"
}

output "private_image_s3_bucket_arn" {
    value = "${aws_s3_bucket.private_assets_bucket.arn}"
}
