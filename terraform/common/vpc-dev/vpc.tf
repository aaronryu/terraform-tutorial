/*
  In this file, following resources are managed:
    - 1 vpc
    - 2 public subnets 0, 1
    - 2 private subnets 0, 1
    - 1 internet gatway
    - 1 nat gatway + public ip
    - route tables for subnets
    - network interface configurations
*/
resource "aws_vpc" "bootstrap_dev_vpc" {
  cidr_block           = "172.16.0.0/16" # 16bit 여유
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name                = "bootstrap-dev-vpc"
    Profile             = "dev"
    Role                = "bootstrap"
    ManagedBy           = "terraform"
  }
}

resource "aws_subnet" "bootstrap_dev_public_subnet_0" {
    vpc_id                  = "${aws_vpc.bootstrap_dev_vpc.id}"
    cidr_block              = "172.16.0.0/24" # 8bit 여유 (Subnet Private/Public 각 2개)
    availability_zone       = "ap-northeast-2a"
    map_public_ip_on_launch = false

    tags = {
        Name                = "bootstrap-dev-public-subnet-0"
        Profile             = "dev"
        Role                = "bootstrap"
        ManagedBy           = "terraform"
    }
}

resource "aws_subnet" "bootstrap_dev_private_subnet_0" {
    vpc_id                  = "${aws_vpc.bootstrap_dev_vpc.id}"
    cidr_block              = "172.16.1.0/24" # 8bit 여유 (Subnet Private/Public 각 2개)
    availability_zone       = "ap-northeast-2a"
    map_public_ip_on_launch = false

    tags = {
        Name                = "bootstrap-dev-private-subnet-0"
        Profile             = "dev"
        Role                = "bootstrap"
        ManagedBy           = "terraform"
    }
}

resource "aws_subnet" "bootstrap_dev_public_subnet_1" {
    vpc_id                  = "${aws_vpc.bootstrap_dev_vpc.id}"
    cidr_block              = "172.16.2.0/24" # 8bit 여유 (Subnet Private/Public 각 2개)
    availability_zone       = "ap-northeast-2c"
    map_public_ip_on_launch = false

    tags = {
        Name                = "bootstrap-dev-public-subnet-1"
        Profile             = "dev"
        Role                = "bootstrap"
        ManagedBy           = "terraform"
    }
}

resource "aws_subnet" "bootstrap_dev_private_subnet_1" {
    vpc_id                  = "${aws_vpc.bootstrap_dev_vpc.id}"
    cidr_block              = "172.16.3.0/24" # 8bit 여유 (Subnet Private/Public 각 2개)
    availability_zone       = "ap-northeast-2c"
    map_public_ip_on_launch = false

    tags = {
        Name                = "bootstrap-dev-private-subnet-1"
        Profile             = "dev"
        Role                = "bootstrap"
        ManagedBy           = "terraform"
    }
}

resource "aws_internet_gateway" "bootstrap_dev_igw" {
    vpc_id   = "${aws_vpc.bootstrap_dev_vpc.id}"

    tags = {
        Name                = "bootstrap-dev-igw"
        Profile             = "dev"
        Role                = "bootstrap"
        ManagedBy           = "terraform"
    }
}

resource "aws_eip" "bootstrap_dev_nat_eip" {
    vpc  = true

    tags = {
        Name                = "bootstrap-dev-nat-eip"
        Profile             = "dev"
        Role                = "common"
        ManagedBy           = "terraform"
    }
}

resource "aws_nat_gateway" "bootstrap_dev_nat" {
    allocation_id   = "${aws_eip.bootstrap_dev_nat_eip.id}"
    subnet_id       = "${aws_subnet.bootstrap_dev_public_subnet_0.id}"
    tags = {
        Name                = "bootstrap-dev-nat"
        Profile             = "dev"
        Role                = "common"
        ManagedBy           = "terraform"
    }
}

resource "aws_route_table" "bootstrap_dev_public_route_table" {
    vpc_id = "${aws_vpc.bootstrap_dev_vpc.id}"

    route {
      cidr_block        = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.bootstrap_dev_igw.id}"
    }

    tags = {
        Name                = "bootstrap-dev-public-route-table"
        Profile             = "dev"
        Role                = "bootstrap"
        ManagedBy           = "terraform"
    }
}

resource "aws_route_table" "bootstrap_dev_private_route_table" {
    vpc_id = "${aws_vpc.bootstrap_dev_vpc.id}"

    route {
      cidr_block        = "0.0.0.0/0"
      nat_gateway_id = "${aws_nat_gateway.bootstrap_dev_nat.id}"
    }

    tags = {
        Name                = "bootstrap-dev-private-route-table"
        Profile             = "dev"
        Role                = "bootstrap"
        ManagedBy           = "terraform"
    }
    
}

resource "aws_route_table_association" "bootstrap_dev_public_subnet_0_rt_association" {
  subnet_id      = "${aws_subnet.bootstrap_dev_public_subnet_0.id}"
  route_table_id = "${aws_route_table.bootstrap_dev_public_route_table.id}"
}

resource "aws_route_table_association" "bootstrap_dev_private_subnet_0_rt_association" {
  subnet_id      = "${aws_subnet.bootstrap_dev_private_subnet_0.id}"
  route_table_id = "${aws_route_table.bootstrap_dev_private_route_table.id}"
}

resource "aws_route_table_association" "bootstrap_dev_public_subnet_1_rt_association" {
  subnet_id      = "${aws_subnet.bootstrap_dev_public_subnet_1.id}"
  route_table_id = "${aws_route_table.bootstrap_dev_public_route_table.id}"
}

resource "aws_route_table_association" "bootstrap_dev_private_subnet_1_rt_association" {
  subnet_id      = "${aws_subnet.bootstrap_dev_private_subnet_1.id}"
  route_table_id = "${aws_route_table.bootstrap_dev_private_route_table.id}"
}

output "bootstrap_dev_public_subnet_0_id" {
  value = "${aws_subnet.bootstrap_dev_public_subnet_0.id}"
}

output "bootstrap_dev_private_subnet_0_id" {
  value = "${aws_subnet.bootstrap_dev_private_subnet_0.id}"
}

output "bootstrap_dev_public_subnet_1_id" {
  value = "${aws_subnet.bootstrap_dev_public_subnet_1.id}"
}

output "bootstrap_dev_private_subnet_1_id" {
  value = "${aws_subnet.bootstrap_dev_private_subnet_1.id}"
}

output "bootstrap_dev_vpc_id" {
  value = "${aws_vpc.bootstrap_dev_vpc.id}"
}

output "bootstrap_dev_nat_network_interface_id" {
  value = "${aws_nat_gateway.bootstrap_dev_nat.network_interface_id}"
}
