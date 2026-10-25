data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.subnet_a_public.id
  private_ip                  = "10.10.1.10"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg_bastion.id]

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = { Name = "ewb-bastion" }
}

resource "aws_instance" "app_a" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.subnet_a_private.id
  private_ip                  = "10.10.2.10"
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.sg_app_a.id]

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = { Name = "ewb-app-a" }
}

resource "aws_instance" "app_b" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.subnet_b_private.id
  private_ip                  = "10.20.1.10"
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.sg_app_b.id]

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = { Name = "ewb-app-b" }
}
