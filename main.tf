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
  key_name        = "halo"
  vpc_security_group_ids = ["${aws_security_group.test.id}"]
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
    private_key = "${file("halo.pem")}"
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

  resource "aws_security_group" "test" {
  name        = "test"
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

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
}
