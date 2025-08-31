output "subnet_ids" {
   value = {
     public_a  = aws_subnet.sn_public1.id
     public_b  = aws_subnet.sn_public2.id
     emr_private_a = aws_subnet.sn_emr_private1.id
     emr_private_b = aws_subnet.sn_emr_private2.id
     airflow_private_a = aws_subnet.sn_airflow_private1.id
     airflow_private_b = aws_subnet.sn_airflow_private2.id
     redshift_private_a = aws_subnet.sn_redshift_private1.id
     redshift_private_b = aws_subnet.sn_redshift_private2.id
   }
 }

 output "vpc_id" {
   value = aws_vpc.vpc.id
 }

 output "vpc_cidr_block" {
   value = aws_vpc.vpc.cidr_block
 }

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}