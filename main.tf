resource "aws_vpc" "vpc_createad" {
  cidr_block = var.cidr_vpc

  tags = {
    Name = "lm_vpc"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id                  = aws_vpc.vpc_createad.id
  cidr_block              = var.cidr_subnet_1
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet-name1
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id                  = aws_vpc.vpc_createad.id
  cidr_block              = var.cidr_subnet_2
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet-name2
  }
}

resource "aws_internet_gateway" "lm_igw" {
  vpc_id = aws_vpc.vpc_createad.id
  tags = {
    Name = var.internet_gateway
  }
}

resource "aws_route_table" "route-table-1" {
  vpc_id = aws_vpc.vpc_createad.id

  tags = {
    Name = var.route_table
  }
}

resource "aws_route" "route_igw" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.route-table-1.id
  gateway_id             = aws_internet_gateway.lm_igw.id
}

resource "aws_route_table_association" "association-subnet-1" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.route-table-1.id
}

resource "aws_route_table_association" "association-subnet-2" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.route-table-1.id
}

resource "aws_security_group" "allow_traffic" {
  name        = "web security group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc_createad.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = "Outbound rule"
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]
}

resource "aws_s3_bucket" "my-bucket" {
  bucket = "this-bucket-is-for-infra-purpose"
  //acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_instance" "instance-1" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"
  //key_name = var.key_name
  subnet_id = aws_subnet.subnet-1.id
  //availability_zone = "us-east-1a"
  //associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_traffic.id]
  user_data              = file("userdata.sh")

  tags = {
    Name = var.instance-1
  }
}

resource "aws_instance" "instance-2" {
  ami = "ami-0e86e20dae9224db8"
  //key_name = var.key_name
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet-2.id
  //availability_zone = "us-east-1b"
  //associate_public_ip_address = true
  security_groups = [aws_security_group.allow_traffic.id]
  user_data       = file("userdata1.sh")

  tags = {
    Name = var.instance-2
  }
}

# Implementation of Load balancer

resource "aws_lb" "mylb" {
  tags = {
    Name = var.load_balancer
  }
  load_balancer_type = var.load_balancer_type
  internal           = false
  security_groups    = [aws_security_group.allow_traffic.id]
  subnets            = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]
}

# Creation of target group

resource "aws_lb_target_group" "mytg" {
  tags = {
    target_group = var.target_gp
  }
  vpc_id   = aws_vpc.vpc_createad.id
  port     = 80
  protocol = "HTTP"

  health_check {
    path = "/"
    port = "traffic-port"
  }

}

# AWS instaces attatchament with target group

resource "aws_lb_target_group_attachment" "attatchament1" {
  target_group_arn = aws_lb_target_group.mytg.id
  target_id        = aws_instance.instance-1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attatchament2" {
  target_group_arn = aws_lb_target_group.mytg.id
  target_id        = aws_instance.instance-2.id
  port             = 80
}

resource "aws_lb_listener" "listner" {
  load_balancer_arn = aws_lb.mylb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.mytg.arn
    type             = "forward"
  }
}

output "load_balancer" {
  value = aws_lb.mylb.dns_name
}