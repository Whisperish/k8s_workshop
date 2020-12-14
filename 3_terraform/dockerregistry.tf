resource "aws_instance" "workshop0001-docker-registry" {
  ami                         = data.aws_ami.k8s-base-machine.id # eu-west-2
  instance_type               = "t2.small"
  key_name                    = "k8s-server-key-workshop0001"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx-web-facing.id]
  subnet_id                   = aws_subnet.main.id
  private_ip                  = "10.0.0.60"





  tags = {
    Name = "workshop0001-docker-registry"
  }
}




resource "null_resource" "buildimages" {
  triggers = {
    first_trigger  = aws_route53_record.dockerregistry-workshop0001.ttl
	second_trigger = aws_instance.workshop0001-docker-registry.public_ip
  }



  provisioner "remote-exec" {
  
    connection {
    type     = "ssh"
    user     = "centos"
	private_key = file("~/.ssh/k8s-key.pem")
    host     = aws_instance.workshop0001-docker-registry.public_ip
  }
  
        inline = [
		"./build_nginx_plus_images.sh",
		"./build_nginx_plus_ingress_controller_image.sh",
		"./setup-service-mesh-registry-images.sh"

    ]
  }
}