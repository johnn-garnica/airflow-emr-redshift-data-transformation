output "bastion_host_info" {
  value = {
    public_ip      = aws_instance.bastion.public_ip
    public_dns     = aws_instance.bastion.public_dns
  }
}