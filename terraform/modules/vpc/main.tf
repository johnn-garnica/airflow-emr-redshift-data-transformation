resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name           = "bigdata-vpc-${var.vpc_region}"
  }
}

resource "aws_internet_gateway" "igw" {
  tags = {
    Name = "bigdata-igw"
  }

  depends_on = [ aws_vpc.vpc ]
}

resource "aws_internet_gateway_attachment" "igw_attachment" {
  internet_gateway_id = aws_internet_gateway.igw.id
  vpc_id              = aws_vpc.vpc.id

  depends_on = [ aws_internet_gateway.igw, aws_vpc.vpc ]
}

resource "aws_eip" "eip_nat1" {
  domain = "vpc"

  tags = {
    Name = "bigdata-eip-nat1"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gateway1" {
  allocation_id = aws_eip.eip_nat1.id
  subnet_id     = aws_subnet.sn_public2.id

  tags = {
    Name = "bigdata-nat-gateway-1a"
  }

  depends_on = [ aws_eip.eip_nat1, aws_subnet.sn_public2, aws_internet_gateway.igw]
}

resource "aws_subnet" "sn_public1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.vpc_cidr}.0.0/24"
  availability_zone = "${var.vpc_region}a"

  tags = {
    Name            = "bigdata-public-a"
  }

  depends_on = [ aws_vpc.vpc ]
}

resource "aws_subnet" "sn_public2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.vpc_cidr}.1.0/24"
  availability_zone = "${var.vpc_region}b"

  tags = {
    Name            = "bigdata-public-b"
  }

  depends_on = [ aws_vpc.vpc ]
}

resource "aws_subnet" "sn_emr_private1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.vpc_cidr}.2.0/24"
  availability_zone = "${var.vpc_region}a"

  tags = {
    Name            = "bigdata-emr-private-a"
  }

  depends_on = [ aws_vpc.vpc ]
}

resource "aws_subnet" "sn_emr_private2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.vpc_cidr}.3.0/24"
  availability_zone = "${var.vpc_region}b"

  tags = {
    Name            = "bigdata-emr-private-b"
  }

  depends_on = [ aws_vpc.vpc ]
}

resource "aws_subnet" "sn_airflow_private1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.vpc_cidr}.4.0/24"
  availability_zone = "${var.vpc_region}a"

  tags = {
    Name            = "bigdata-airflow-private-a"
  }

  depends_on = [ aws_vpc.vpc ]
}

resource "aws_subnet" "sn_airflow_private2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.vpc_cidr}.5.0/24"
  availability_zone = "${var.vpc_region}b"

  tags = {
    Name            = "bigdata-airflow-private-b"
  }

  depends_on = [ aws_vpc.vpc ]
}

resource "aws_subnet" "sn_redshift_private1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.vpc_cidr}.6.0/24"
  availability_zone = "${var.vpc_region}a"

  tags = {
    Name            = "bigdata-redshift-private-a"
  }

  depends_on = [ aws_vpc.vpc ]
}

resource "aws_subnet" "sn_redshift_private2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.vpc_cidr}.7.0/24"
  availability_zone = "${var.vpc_region}b"

  tags = {
    Name            = "bigdata-redshift-private-b"
  }

  depends_on = [ aws_vpc.vpc ]
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name       = "bigdata-public-rt"
  }

  depends_on   = [ aws_vpc.vpc, aws_internet_gateway.igw ]
}

resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway1.id
  }

  tags = {
    Name       = "bigdata-private-rt"
  }

  depends_on   = [ aws_vpc.vpc, aws_nat_gateway.nat_gateway1 ]
}

resource "aws_route_table_association" "rta_public1" {
  subnet_id      = aws_subnet.sn_public1.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "rta_public2" {
  subnet_id      = aws_subnet.sn_public2.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "rta_emr_private1" {
  subnet_id      = aws_subnet.sn_emr_private1.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "rta_emr_private2" {
  subnet_id      = aws_subnet.sn_emr_private2.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "rta_airflow_private1" {
  subnet_id      = aws_subnet.sn_airflow_private1.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "rta_airflow_private2" {
  subnet_id      = aws_subnet.sn_airflow_private2.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "rta_redshift_private1" {
  subnet_id      = aws_subnet.sn_redshift_private1.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "rta_redshift_private2" {
  subnet_id      = aws_subnet.sn_redshift_private2.id
  route_table_id = aws_route_table.rt_private.id
}