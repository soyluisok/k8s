#Comentario Numero 1


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
	instance_type = "t2.micro"

  	network_interface {
    	network_interface_id = aws_network_interface.k8s_net.id
    	device_index         = 0
  	}
	tags = {
		Name = "My first EC2 using Terraform"
	}
}
