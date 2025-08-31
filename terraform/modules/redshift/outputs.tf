output "redshift_cluster_info" {
   value = {
     redshift_cluster_endpoint  = aws_redshift_cluster.redshift_cluster.endpoint
     redshift_cluster_id  = aws_redshift_cluster.redshift_cluster.id
     redshift_cluster_arn  = aws_redshift_cluster.redshift_cluster.arn
   }
 }