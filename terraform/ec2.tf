# security group for EC2
resource "aws_security_group" "ec2_sg" {
  name = "jil-ec2-sg"

  # NO INGRESS

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# EC2 instance & script to generate placeholder JIL
resource "aws_instance" "jil_ec2" {
  ami           = "ami-0c76bd4bd302b30ec"
  instance_type = "t3.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
#!/bin/bash

# install awscli if not present
dnf install -y awscli
aws configure set region eu-west-2

cat <<EOT > /home/ec2-user/PROD.jil
/* -------- P01_TEST_JOB -------- */
insert_job: P01_TEST_JOB
job_type: CMD
command: echo hello
machine: localhost
EOT

chown ec2-user:ec2-user /home/ec2-user/PROD.jil

EOF
  tags = {
    Name = "jil-ec2"
  }
}


