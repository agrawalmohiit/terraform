provider "aws" {
    region = "eu-west-3"
}

variable vpc_cidr_block {}
variable subnet_cidr_blocks {
    description = "cidr blocks for subnets"
    type = list(string)
}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}
variable private_key_location {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_blocks[0]
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}

# data "aws_vpc" "existing_vpc" {
#     tags = {
#         Name = "${var.env_prefix}-vpc"
#     }
# }

resource "aws_subnet" "myapp-subnet-2" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_blocks[1]
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet-2"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
     vpc_id = aws_vpc.myapp-vpc.id
     tags = {
        Name : "${var.env_prefix}-igw"
     }
}

resource "aws_route_table" "myapp_route_table" {
    vpc_id = aws_vpc.myapp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }

    tags = {
      Name = "${var.env_prefix}-rtb"
    }
}

resource "aws_route_table_association" "rtb-subnet1-asso" {
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp_route_table.id
}

resource "aws_route_table_association" "rtb-subnet2-asso" {
    subnet_id = aws_subnet.myapp-subnet-2.id
    route_table_id = aws_route_table.myapp_route_table.id
}

