resource "aws_instance" "workshop0001-nginx-plus-gateway-1" {
  ami                         = data.aws_ami.north-south-router.id # eu-west-2
  instance_type               = "t2.medium"
  key_name                    = "north-south-router-key-workshop0001"
  security_groups             = [aws_security_group.nginx-web-facing.id]
  subnet_id                   = aws_subnet.main.id
  private_ip                  = "10.0.0.70"
  
  tags = {
    Name = "workshop0001-north-south-router-1"
  }

 

  
  
  
}



resource "null_resource" "north-south-router-connect-to-KIC" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    trigger1 = null_resource.displayk8stoken.id,
	trigger2 = aws_route53_record.k8s-master-workshop0001.ttl
  }

  provisioner "remote-exec" {
  
    connection {
    type     = "ssh"
    user     = "ubuntu"
	private_key = file("~/.ssh/north-south-router-key.pem")
    host     = aws_instance.workshop0001-nginx-plus-gateway-1.public_ip
  }
  
        inline = [
		"#until sudo apt-get update -y; do sleep 10; done",
		"#until sudo apt-get upgrade -y; do sleep 10; done",
		"#sudo sh -c 'echo \" controller.workshop0001.nginxdemo.net\" >>/etc/hosts'",
		"#ansible-playbook connect_nginx_server_to_controller.yaml",
		
		"#mkdir ~/.ssh",
		"cp k8s-key.pem ~/.ssh",
		"chmod 600 ~/.ssh/k8s-key.pem",
		"mkdir .kube",
		"scp -o StrictHostKeyChecking=no -i ~/.ssh/k8s-key.pem centos@10.0.0.30:~/.kube/config ~/.kube/config",
		
		"grep 'client-certificate-data' $HOME/.kube/config | awk '{print $2}' | base64 -d    >k8s_api_server_client_cert.crt.pem",
		"grep 'client-key-data' $HOME/.kube/config | awk '{print $2}' | base64 -d            >k8s_api_server_client_cert.key.pem",
		"grep 'certificate-authority-data' $HOME/.kube/config | awk '{print $2}' | base64 -d >k8s_api_server_client_cert.issuer.pem",
		"sudo systemctl restart nginx"
		

    ]
  }

}