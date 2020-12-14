resource "aws_instance" "workshop0001-k8s-master" {
  ami                         = data.aws_ami.k8s-base-machine.id # eu-west-2
  instance_type               = "t2.medium"
  key_name                    = "k8s-server-key-workshop0001"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx-web-facing.id]
  subnet_id                   = aws_subnet.main.id
  private_ip                  = "10.0.0.30"

 
  provisioner "remote-exec" {
  
    connection {
    type     = "ssh"
    user     = "centos"
	private_key = file("~/.ssh/k8s-key.pem")
    host     = self.public_ip
  }
  
        inline = [
  	    "./install-kubernetes-master.sh"
    ]
  }

  tags = {
    Name = "workshop0001-k8s-master"
  }
}


resource "null_resource" "displayk8stoken" {
  triggers = {
    first_trigger  = null_resource.buildimages.id
  }



  provisioner "remote-exec" {
  
    connection {
    type     = "ssh"
    user     = "centos"
	private_key = file("../2_packer/keys/k8s-key.pem")
    host     = aws_instance.workshop0001-k8s-master.public_ip
  }
  
        inline = [
		"kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')"
    ]
  }
}
