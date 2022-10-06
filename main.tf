#Terraform

variable "my_access_key" {
  description = "Access-key-for-AWS"
  default = "no_access_key_value_found"
}

variable "my_secret_key" {
  description = "Secret-key-for-AWS"
  default = "no_secret_key_value_found"
}

output "access_key_is" {
  value = var.my_access_key
}

output "secret_key_is" {
  value = var.my_secret_key
}

provider "aws" {
  shared_config_files      = ["/Users/dguevara/.aws/config"]
  shared_credentials_files = ["/Users/dguevara/.aws/credentials"]
  profile                  = "default"
}

resource "aws_vpc" "k8s_vpc" {
  cidr_block = "10.101.0.0/16"
}
resource "aws_internet_gateway" "k8s_ig" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name = "k8s_ig"
  }
}

resource "aws_route_table" "k8s_rt" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_ig.id
  }

  tags = {
    Name = "k8s_rt"
  }
}

resource "aws_route_table_association" "route_subnet" {
  subnet_id      = aws_subnet.k8s_subnet.id
  route_table_id = aws_route_table.k8s_rt.id
}

resource "aws_security_group" "k8s_sg" {
  name        = "k8s_seg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.k8s_vpc.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
ingress {
    description      = "https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


resource "aws_subnet" "k8s_subnet" {
  vpc_id     = aws_vpc.k8s_vpc.id
  cidr_block = "10.101.5.0/24"

}

resource "aws_network_interface" "k8s_net" {
  subnet_id   = aws_subnet.k8s_subnet.id

  tags = {
    Name = "primary_network_interface"
  }
}


resource "aws_instance" "k8s" {
        ami = "ami-05fa00d4c63e32376"
        instance_type = "t2.medium"
        network_interface {
        network_interface_id = aws_network_interface.k8s_net.id
        device_index         = 0
        }
        user_data = "${file("minikube.sh")}"
        tags = {
                Name = "k8s"
        }


}

resource "aws_network_interface_sg_attachment" "sg_attach" {
  security_group_id    = aws_security_group.k8s_sg.id
  network_interface_id = aws_instance.k8s.primary_network_interface_id
}

resource "aws_eip" "k8s_eip" {
  instance = aws_instance.k8s.id
  vpc      = true
}

