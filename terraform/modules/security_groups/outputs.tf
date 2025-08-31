output "security_group_ids" {
   value = {
     public_ssh  = aws_security_group.public_ssh.id
     private_ssh  = aws_security_group.private_ssh.id
     private_https = aws_security_group.private_https.id
     private_redshift = aws_security_group.private_redshift.id
     mwaa_env = aws_security_group.mwaa_env.id
   }
 }