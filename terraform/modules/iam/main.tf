resource "aws_iam_policy" "mwaa_policy" {
  name        = "mwaa-policy-${var.vpc_region}-${var.account_id}"
  description = "Execution policy for MWAA environment ${var.environment_name}"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "airflow:PublishMetrics",
        "Resource": "arn:aws:airflow:${var.vpc_region}:${var.account_id}:environment/${var.environment_name}"
      },
      { 
        "Effect": "Deny",
        "Action": "s3:ListAllMyBuckets",
        "Resource": [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject*",
          "s3:GetBucket*",
          "s3:List*"
        ],
        "Resource": [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:GetLogRecord",
        "logs:GetLogGroupFields",
        "logs:GetQueryResults"
        ],
        "Resource": [
          "arn:aws:logs:${var.vpc_region}:${var.account_id}:log-group:airflow-${var.environment_name}-*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "logs:DescribeLogGroups"
        ],
        "Resource": [
          "*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": "cloudwatch:PutMetricData",
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "sqs:ChangeMessageVisibility",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage",
          "sqs:SendMessage"
        ],
        "Resource": "arn:aws:sqs:${var.vpc_region}:*:airflow-celery-*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:Encrypt"
        ],
        "NotResource": "arn:aws:kms:*:${var.account_id}:key/*",
        "Condition": {
          "StringLike": {
            "kms:ViaService": [
              "sqs.${var.vpc_region}.amazonaws.com"
            ]
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": [
          "redshift:ResumeCluster",
          "redshift:PauseCluster",
          "redshift:DeleteCluster",
          "redshift:CreateCluster",
          "redshift:DescribeClusters"
        ],
        "Resource": [
          "arn:aws:redshift:${var.vpc_region}:${var.account_id}:cluster:${var.redshift_cluster_name}"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "elasticmapreduce:RunJobFlow",
          "elasticmapreduce:TerminateJobFlows",
          "elasticmapreduce:DescribeCluster",
          "elasticmapreduce:AddJobFlowSteps",
          "elasticmapreduce:DescribeStep"
        ],
          "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": "iam:PassRole",
        "Resource": [
          "arn:aws:iam::${var.account_id}:role/EMR_DefaultRole",
          "arn:aws:iam::${var.account_id}:role/EMR_EC2_DefaultRole"
        ]
      }
    ]
  })
}


resource "aws_iam_role" "mwaa_role" {
  name = "mwaa-role-${var.vpc_region}-${var.account_id}"
  max_session_duration = 7200

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "airflow-env.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mwaa_policy_attachment" {
  role       = aws_iam_role.mwaa_role.name
  policy_arn = aws_iam_policy.mwaa_policy.arn

  depends_on = [ aws_iam_role.mwaa_role, aws_iam_policy.mwaa_policy ]
}

resource "aws_iam_policy" "redshift_policy" {
  name        = "redshift-policy-${var.vpc_region}-${var.account_id}"
  description = "Ruta en bucket S3 desde donde Redshift realiza el COPY de las tablas"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::${var.redshift_s3_bucket_name}"
        Condition = {
          StringLike = {
            "s3:prefix" = "output/*"
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "arn:aws:s3:::${var.redshift_s3_bucket_name}/output/*"
      }
    ]
  })
}

resource "aws_iam_role" "redshift_role" {
  name = "redshift-role-${var.vpc_region}-${var.account_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "redshift_role_attach" {
  role       = aws_iam_role.redshift_role.name
  policy_arn = aws_iam_policy.redshift_policy.arn
}