provider "aws" {
    region = "eu-west-3"
}

variable vpc_cidr_block {}
variable subnet_cidr_blocks {
    description = "cidr blocks for subnets"
    type = list(string)
}
variable avail_zones {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}
variable private_key_location {}
instance_type {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_blocks[0]
    availability_zone = var.avail_zones[0]
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
    availability_zone = var.avail_zones[1]
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

//to use default sg use below with rest of the config same :
//resource "aws_defaultsecurity_group" "default-sg" {
resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = var.my_ip
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = [] //not interesting right now 
    }

    tags = {
      Name = "${var.env_prefix}-sg"
    }

}

# Selecting an image for ec2 instance  

# resource "aws_ami" "ayapp-server" {
#     ami = "ami-04a7352d22a23c770" 
# }
// Not recommended
// Define a reference to the latest ami image and query the data for ami code instead of hardcoding 

data "aws_ami" "latest_aws_ami_image" {
    most_recent = true
    owners = ["137112412989"]

    filter {
        name = "name"
        values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

}

# output "aws_ami_id" {
#     value =  data.aws_ami.latest_aws_ami_image
# }

resource "aws_ami" "myapp-server" {
    ami = data.aws_ami.latest_aws_ami_image.id
    instance_type = var.instance_type
}
