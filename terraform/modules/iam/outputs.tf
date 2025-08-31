output "roles_policies_arn" {
   value = {
     mwaa_role_arn  = aws_iam_role.mwaa_role.arn
     mwaa_policy_id  = aws_iam_policy.mwaa_policy.id
     redshift_role_arn = aws_iam_role.redshift_role.arn
     redshift_policy_id = aws_iam_policy.redshift_policy.id
   }
 }