output "mwaa_environment_info" {
   value = {
     mwaa_environment_arn  = aws_mwaa_environment.mwaa_environment.arn
     mwaa_environment_url  = aws_mwaa_environment.mwaa_environment.webserver_url
   }
 }