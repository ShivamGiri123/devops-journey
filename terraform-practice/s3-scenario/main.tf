#provider
provider "aws" {
region = "us-east-1"
}
#random suffix for unique bucket name
resource "random_id" "bucket_suffix" {
byte_length = 4
}
#S3 bucket
resource "aws_s3_bucket" "data" {
bucket = "my-data-bucket-${random_id.bucket_suffix.hex}"

tags = {
	name = "Data Bucket"
	enviroment = "production"
}
}
#enable versioning
resource "aws_s3_bucket_versioning" "data" {
bucket = aws_s3_bucket.data.id

versioning_configuration{
status = enable
}
}
#lifestyle policy
resource "aws_s3_bucket_lifestyle_configuration" "data" {
bucket = aws_s3_bucket.data.id

rule {
id = "archive-old-logs"
status = "enabled"
 
   transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# Output
output "bucket_name" {
  value = aws_s3_bucket.data.id
}

output "bucket_arn" {
  value = aws_s3_bucket.data.arn
}


