data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.bastion_instance_type
  vpc_security_group_ids      = [var.ssh_security_group_id]
  subnet_id                   = var.public_a_subnet_id
  availability_zone           = var.availability_zone
  key_name                    = var.key_pair_identifier
  associate_public_ip_address = true

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp3"
    volume_size           = 15

    tags = {
        Name = "bigdata-bastion-root-volume"
    }
  }

  tags = {
    Name = "bigdata-bastion-host"
  }
}