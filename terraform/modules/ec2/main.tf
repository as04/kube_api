# Create VPC
resource "aws_vpc" "xalts_vpc" {
 cidr_block = "10.0.0.0/16"
}

# Create Subnet within the VPC
resource "aws_subnet" "xalts_subnet" {
 vpc_id            = aws_vpc.xalts_vpc.id
 cidr_block        = "10.0.1.0/24"
 availability_zone = "ap-south-1a"
}

# Create Internet Gateway
resource "aws_internet_gateway" "xalts_igw" {
 vpc_id = aws_vpc.xalts_vpc.id
}

# Create Route Table and associate with VPC
resource "aws_route_table" "xalts_route_table" {
 vpc_id = aws_vpc.xalts_vpc.id

 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.xalts_igw.id
 }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "xalts_route_table_association" {
 subnet_id      = aws_subnet.xalts_subnet.id
 route_table_id = aws_route_table.xalts_route_table.id
}

# Create Security Group
resource "aws_security_group" "xalts_sg" {
 vpc_id = aws_vpc.xalts_vpc.id

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }

 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
}

# Allocate Elastic IP
resource "aws_eip" "xalts_eip" {
 vpc = true
}

# EC2 instance
resource "aws_instance" "myec2" {
 for_each = {for val in var.service_definition["Resources"]["EC2"]: val["Name"] => val["Properties"]}
 ami           = "ami-0a7cf821b91bcccbc"
 instance_type = "t2.micro"
 subnet_id     = aws_subnet.xalts_subnet.id
 associate_public_ip_address = true
 user_data = file("${path.module}/${each.value.UserData}")
 vpc_security_group_ids = [aws_security_group.xalts_sg.id]
 tags = {
    Name = "ec2-created-from-terraform"
 }
}

# Associate Elastic IP with EC2 instance
resource "aws_eip_association" "xalts_eip_association" {
 instance_id   = aws_instance.myec2["api-instance"].id
 allocation_id = aws_eip.xalts_eip.id
}
