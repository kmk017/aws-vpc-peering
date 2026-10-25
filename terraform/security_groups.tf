resource "aws_security_group" "sg_bastion" {
  name        = "ewb-sg-bastion"
  description = "SSH from the student's current public IPv4 only"
  vpc_id      = aws_vpc.vpc_a.id

  ingress {
    description = "SSH from student workstation"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.student_public_ip}/32"]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ewb-sg-bastion" }
}

resource "aws_security_group" "sg_app_a" {
  name        = "ewb-sg-app-a"
  description = "Private App-A access"
  vpc_id      = aws_vpc.vpc_a.id

  ingress {
    description = "SSH from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.1.10/32"]
  }

  ingress {
    description = "ICMP echo request from App-B"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["10.20.1.10/32"]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ewb-sg-app-a" }
}

resource "aws_security_group" "sg_app_b" {
  name        = "ewb-sg-app-b"
  description = "Private App-B access"
  vpc_id      = aws_vpc.vpc_b.id

  ingress {
    description = "SSH from bastion private IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.1.10/32"]
  }

  ingress {
    description = "ICMP echo request from App-A"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["10.10.2.10/32"]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ewb-sg-app-b" }
}
