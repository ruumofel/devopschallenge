terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}

resource "aws_instance" "app_iprice" {
  ami             = "ami-073998ba87e205747"
  instance_type   = "t2.micro"
  key_name        = "mykey"
  vpc_security_group_ids = ["${aws_security_group.devopschallenge.id}"]
  tags = {
    Name = "ExampleAppServerInstance"
  }
  provisioner "file" {
    source      = "coba.sh"
    destination = "/tmp/coba.sh"
  }
  provisioner "file" {
    source      = "docker-compose.yml"
    destination = "/tmp/docker-compose.yml"
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.devopskey.private_key_pem
    host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/coba.sh",
      "/tmp/coba.sh args",
      "echo terraform deployed"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "docker-compose -f /tmp/docker-compose.yml up -d",
      "echo app installed"
    ]
  }
}
resource "tls_private_key" "devopskey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "generatekey" {
  key_name = "mykey"
  public_key = tls_private_key.devopskey.public_key_openssh
  provisioner "local-exec" {
    command = <<EOF
    echo '${tls_private_key.devopskey.private_key_pem}' > mykey.pem
    chmod 400 ./mykey.pem
    EOF
  }  
}
  resource "aws_security_group" "devopschallenge" {
  name        = "devopschallenge"
  description = "Allow ssh  inbound traffic"

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

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
}
