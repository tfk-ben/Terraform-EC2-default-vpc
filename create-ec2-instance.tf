provider "aws"{
    region = "eu-west-3"
}

variable env {
    description="deployment env"
}

variable path-ssh-key {

}


data "aws_vpc" "existing_vpc"{
default = true
}

resource "aws_security_group" "my-sg"{
  name = "my-sc"
  description = "my-sc"
  vpc_id = data.aws_vpc.existing_vpc.id

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_key_pair" "sshkey" {
    key_name = "key"
    public_key = "${file("${var.path-ssh-key}")}"
}

resource "aws_instance" "ec2-instance" {
    ami = "ami-0493936afbe820b28"
    instance_type = "t2.micro"
    associate_public_ip_address = true

    vpc_security_group_ids = [
    aws_security_group.my-sg.id
  ]

    key_name = aws_key_pair.sshkey.key_name

      tags = {
      Name : "${var.env}_ec2_instance"
    }
    
}

output "ec2_public_ip"{
    value = aws_instance.ec2-instance.public_ip
}
