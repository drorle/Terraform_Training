# INSTANCES #
resource "aws_instance" "instance" {
  count                  = "${var.instance_count}"
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${element(aws_subnet.subnet.*.id,count.index % var.subnet_count)}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}","${aws_security_group.http.id}"]
  key_name               = "${var.key_name}"

  tags {
    Name        = "${var.environment_tag}-nginx-${count.index + 1}"
    Environment = "${var.environment_tag}"
  }

  connection {
    type        = "ssh"
    agent       = "false"
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python",
#      "echo '<html><head><title>Blue Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">Blue Team</span></span></p></body></html>' | sudo tee /var/www/html/index.nginx-debian.html"
    ]
  }
}

##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
  value = "${aws_instance.instance.*.public_ip}"
}


