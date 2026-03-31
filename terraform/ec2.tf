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

# install awscli & cron if not present
dnf install -y awscli cronie

systemctl enable crond
systemctl start crond

aws configure set region eu-west-2

mkdir -p /home/ec2-user/JIL
chown -R ec2-user:ec2-user /home/ec2-user/JIL

cat <<'SCRIPT' > /home/ec2-user/generate_and_upload.sh
#!/bin/bash

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

cat <<EOT > /home/ec2-user/JIL/PROD.jil
/* Generated at: $${TIMESTAMP} */
insert_job: P01_TEST_JOB
job_type: CMD
command: echo hello
machine: localhost
EOT

cat <<EOT > /home/ec2-user/JIL/PPE.jil
/* Generated at: $${TIMESTAMP} */
insert_job: R01_TEST_JOB
job_type: CMD
command: echo hello
machine: localhost
EOT

cat <<EOT > /home/ec2-user/JIL/TEST.jil
/* Generated at: $${TIMESTAMP} */
insert_job: T01_TEST_JOB
job_type: CMD
command: echo hello
machine: localhost
EOT

aws s3 cp /home/ec2-user/JIL/ s3://${local.jil_bucket_name}/jil_files/ \
  --recursive --exclude "*" --include "*.jil"
SCRIPT

chmod +x /home/ec2-user/generate_and_upload.sh
chown ec2-user:ec2-user /home/ec2-user/generate_and_upload.sh

echo "*/5 * * * * ec2-user /home/ec2-user/generate_and_upload.sh" >> /etc/crontab

for i in {1..12}; do
  echo "Attempt $i: testing EventBridge readiness"

  aws events list-targets-by-rule \
    --rule "jil-s3-upload-trigger" \
    --region eu-west-2 >/dev/null 2>&1 && break

  sleep 5
done

sudo -u ec2-user /home/ec2-user/generate_and_upload.sh

EOF
  tags = {
    Name = "jil-ec2"
  }
}
