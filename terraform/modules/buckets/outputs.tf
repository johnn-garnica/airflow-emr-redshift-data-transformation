output "buckets_info" {
   value = {
     emr_data_bucket_id  = aws_s3_bucket.emr_data_bucket.id
     emr_data_bucket_arn = aws_s3_bucket.emr_data_bucket.arn
     mwaa_data_bucket_id  = aws_s3_bucket.mwaa_data_bucket.id
     mwaa_data_bucket_arn = aws_s3_bucket.mwaa_data_bucket.arn
   }
 }