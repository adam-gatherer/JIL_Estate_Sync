# output EC2 public IP
output "ec2_public_ip" {
  value = aws_instance.jil_ec2.public_ip
}