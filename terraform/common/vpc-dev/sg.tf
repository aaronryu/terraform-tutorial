locals {
  ips_for_dev_purpose = [
    # "58.151.93.98/32",  // Fastfive Gangnam No.3 IP
    # "210.206.68.66/32", // Fastfive Gangnam No.3 IP
    "1.236.34.132/32",  // Aaron Home IP
  ]
}

resource "aws_security_group" "bootstrap_dev_ssh_sg" {
  vpc_id      = aws_vpc.bootstrap_dev_vpc.id
  description = "Allow ssh from specific IP"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks      = local.ips_for_dev_purpose
      description      = "ssh from certain ips"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    }
  ]
  name = "bootstrap_dev_ssh_sg"
  tags = {
    Role      = "bootstrap"
    Profile   = "dev"
    Name      = "bootstrap-dev-ssh-sg"
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "bootstrap_dev_default_sg" {
  vpc_id      = aws_vpc.bootstrap_dev_vpc.id
  description = "Allow http beween peer subnet and ssh from gateway"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "allow ssh from gateway"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks      = []
      description      = "allow http from the same sg"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = true
      to_port          = 80
    },
    {
      cidr_blocks      = []
      description      = "allow https from the same sg"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = true
      to_port          = 443
    },
    {
      cidr_blocks      = []
      description      = "allow ssh from gateway"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = ["${aws_security_group.bootstrap_dev_ssh_sg.id}"]
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks      = []
      description      = "allow tcp from same sg"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = true
      to_port          = 0
    },
  ]
  name = "bootstrap_dev_default_sg"
  tags = {
    Role      = "bootstrap"
    Profile   = "dev"
    Name      = "bootstrap-dev-default-sg"
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "bootstrap_dev_specific_ips_sg" {
  vpc_id      = aws_vpc.bootstrap_dev_vpc.id
  description = "Allow http from specific ips"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "allow ssh from gateway"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks      = local.ips_for_dev_purpose
      description      = "Fastfive Gangnam No.3. IP"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks      = local.ips_for_dev_purpose
      description      = "Fastfive Gangnam No.3. IP"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    }
  ]
  name = "bootstrap_dev_specific_ips_sg"
  tags = {
    Role      = "bootstrap"
    Profile   = "dev"
    Name      = "bootstrap-dev-specific-ips-sg"
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "bootstrap_dev_all_ips_sg" {
  vpc_id      = aws_vpc.bootstrap_dev_vpc.id
  description = "Allow http from all ips"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "allow traffics"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0"
      ]
      description      = "allow http from all ips"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks = [
        "0.0.0.0/0"
      ]
      description      = "allow https from all ips"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    }
  ]
  name = "bootstrap_dev_all_ips_sg"
  tags = {
    Role      = "bootstrap"
    Profile   = "dev"
    Name      = "bootstrap-dev-all-ips-sg"
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "bootstrap_dev_all_ips_https_sg" {
  vpc_id      = aws_vpc.bootstrap_dev_vpc.id
  description = "Allow https from all ips"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "allow traffics"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0"
      ]
      description      = "allow https from all ips"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    }
  ]
  name = "bootstrap_dev_all_ips_https_sg"
  tags = {
    Role      = "bootstrap"
    Profile   = "dev"
    Name      = "bootstrap-dev-all-ips-https-sg"
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "bootstrap_dev_private_sg" {
  vpc_id      = aws_vpc.bootstrap_dev_vpc.id
  description = "Allow all tcp traffics from the same sg"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "allow all outbound traffic"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks      = []
      description      = "allow tcp between private sg"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = true
      to_port          = 0
    },
    {
      cidr_blocks      = []
      description      = "allow tcp from default sg"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = [aws_security_group.bootstrap_dev_default_sg.id]
      self             = false
      to_port          = 60000
    },
  ]
  name = "bootstrap_dev_private_sg"
  tags = {
    Role      = "bootstrap"
    Profile   = "dev"
    Name      = "bootstrap-dev-private-sg"
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "bootstrap_dev_db_sg" {
  vpc_id      = aws_vpc.bootstrap_dev_vpc.id
  description = "Allow tcp db traffic from specific sg"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "allow all outbound traffic"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks      = []
      description      = "allow mysql traffic from bastion"
      from_port        = 5432
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = ["${aws_security_group.bootstrap_dev_ssh_sg.id}"]
      self             = false
      to_port          = 5432
    },
    {
      cidr_blocks      = []
      description      = "allow mysql traffic from instance sg"
      from_port        = 5432
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = ["${aws_security_group.bootstrap_dev_private_sg.id}"]
      self             = false
      to_port          = 5432
    }
  ]
  name = "bootstrap_dev_db_sg"
  tags = {
    Role      = "bootstrap"
    Profile   = "dev"
    Name      = "bootstrap-dev-db-sg"
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "bootstrap_dev_alb_sg" {
  vpc_id      = aws_vpc.bootstrap_dev_vpc.id
  description = "bootstrap-dev-alb-sg"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = []
  name    = "bootstrap-dev-alb-sg"
  tags = {
    Role      = "bootstrap"
    Profile   = "dev"
    Name      = "bootstrap-dev_alb-sg"
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "bootstrap_dev_ecs_dynamic_sg" {
  vpc_id      = aws_vpc.bootstrap_dev_vpc.id
  description = "bootstrap-dev-ecs-dynamic-sg"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups = [
        "${aws_security_group.bootstrap_dev_alb_sg.id}"
      ]
      self    = false
      to_port = 65535
    }
  ]
  name = "bootstrap-dev-ecs-dynamic-sg"
  tags = {
    Role      = "bootstrap"
    Profile   = "dev"
    Name      = "bootstrap-dev-ecs-dynamic-sg"
    ManagedBy = "terraform"
  }
}

output "bootstrap_dev_ssh_sg_id" {
  value = aws_security_group.bootstrap_dev_ssh_sg.id
}

output "bootstrap_dev_default_sg_id" {
  value = aws_security_group.bootstrap_dev_default_sg.id
}

output "bootstrap_dev_specific_ips_sg_id" {
  value = aws_security_group.bootstrap_dev_specific_ips_sg.id
}

output "bootstrap_dev_all_ips_sg_id" {
  value = aws_security_group.bootstrap_dev_all_ips_sg.id
}

output "bootstrap_dev_all_ips_https_sg_id" {
  value = aws_security_group.bootstrap_dev_all_ips_https_sg.id
}

output "bootstrap_dev_private_sg_id" {
  value = aws_security_group.bootstrap_dev_private_sg.id
}

output "bootstrap_dev_db_sg_id" {
  value = aws_security_group.bootstrap_dev_db_sg.id
}

output "bootstrap_dev_alb_sg_id" {
  value = aws_security_group.bootstrap_dev_alb_sg.id
}

output "bootstrap_dev_ecs_dynamic_sg_id" {
  value = aws_security_group.bootstrap_dev_ecs_dynamic_sg.id
}
