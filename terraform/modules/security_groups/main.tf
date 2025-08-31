resource "aws_security_group" "public_ssh" {
  name        = "bigdata-public-ssh"
  description = "Allow SSH inbound traffic and all outbound traffic in public subnets"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bigdata-public-ssh"
  }
}

resource "aws_security_group_rule" "public_ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.public_ssh.id
}

resource "aws_security_group_rule" "public_ssh_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.public_ssh.id
}

resource "aws_security_group" "private_ssh" {
  name        = "bigdata-private-ssh"
  description = "Allow SSH inbound traffic and all outbound traffic in private subnets"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bigdata-private-ssh"
  }
}

resource "aws_security_group_rule" "private_ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.private_ssh.id
}

resource "aws_security_group_rule" "private_ssh_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private_ssh.id
}

resource "aws_security_group" "private_https" {
  name        = "bigdata-private-hhtps"
  description = "Allow HTTPS inbound traffic and all outbound traffic in private subnets"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bigdata-private-https"
  }
}

resource "aws_security_group_rule" "private_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.private_https.id
}

resource "aws_security_group_rule" "private_https_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private_https.id
}

resource "aws_security_group" "private_redshift" {
  name        = "bigdata-private-redshift"
  description = "Allow REDSHIFT inbound traffic and all outbound traffic in private subnets"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bigdata-private-redshift"
  }
}

resource "aws_security_group_rule" "private_redshift_ingress" {
  type              = "ingress"
  from_port         = 5439
  to_port           = 5439
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.private_redshift.id
}

resource "aws_security_group_rule" "private_redshift_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private_redshift.id
}

resource "aws_security_group" "mwaa_env" {
  name        = "bigdata-mwaa"
  description = "Security Group for MWAA environment"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bigdata-mwaa"
  }
}

resource "aws_security_group_rule" "mwaa_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.mwaa_env.id
  source_security_group_id = aws_security_group.mwaa_env.id
}

resource "aws_security_group_rule" "mwaa_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mwaa_env.id
}