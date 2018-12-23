##################################################################################
# VARIABLES
##################################################################################

#variable "aws_access_key" {}
#variable "aws_secret_key" {}
variable "private_key_path" {}
variable "public_key" {}
variable "key_name" {
  default = "terraform-key-pair"
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
#  access_key = "${var.aws_access_key}"
#  secret_key = "${var.aws_secret_key}"
#  region     = "us-west-2"
}

##################################################################################
# RESOURCES
##################################################################################
resource "aws_key_pair" "deployer" {
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
}

resource "aws_instance" "nginx" {
  ami           = "ami-076e276d85f524150"
  instance_type = "t2.micro"
  security_groups = ["SSH","open ports"]
  key_name        = "${var.key_name}"

  connection {
    type        = "ssh"
    agent       = "false"
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
  }
}

##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
    value = "${aws_instance.nginx.public_dns}"
}
