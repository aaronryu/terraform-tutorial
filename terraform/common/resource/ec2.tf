/*
  In this file, following resources are managed:
    - 1 dev ssh gateway (ssh only open to specific ips)
*/
locals {
  bootstrap_ami_id = "ami-0e9bfdb247cc8de84" // official AWS ubuntu 22.04
  dev_ssh_key_name = "bastion-ec2-keypair"   // "bootstrap-base-ssh-key" 기존에 있던 파일의 name convention
}

resource "aws_instance" "dev_ssh_gateway" { // a.k.a bastion host
  ami                         = local.bootstrap_ami_id
  instance_type               = "t3.nano"
  subnet_id                   = data.terraform_remote_state.vpc_dev.outputs.bootstrap_dev_public_subnet_0_id
  vpc_security_group_ids      = [data.terraform_remote_state.vpc_dev.outputs.bootstrap_dev_ssh_sg_id]
  key_name                    = local.dev_ssh_key_name
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }
  user_data = <<EOF
#!/bin/bash -xe
apt -y update
apt -y install build-essential
apt -y install python-simplejson
mkdir -p /tmp
curl https://bootstrap.pypa.io/get-pip.py > /tmp/get-pip.py
python /tmp/get-pip.py
pip install awscli
EOF

  tags = {
    Role      = "bootstrap"
    Profile   = "dev"
    Name      = "bootstrap-dev-ssh-gateway"
    ManagedBy = "terraform"
  }
}

output "dev_ssh_gateway_public_ip" {
  value = aws_instance.dev_ssh_gateway.public_ip
}
