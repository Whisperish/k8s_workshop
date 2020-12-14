


echo "The running docker processes are....."

sudo docker ps

# Now we will build an NGINX PLUS INGRESS CONTROLLER docker image

cp ~/certs/nginx-repo.* .


sudo dnf install git -y


git clone https://github.com/nginxinc/kubernetes-ingress/

cd kubernetes-ingress/deployments

git checkout v1.9.0

cd ..

cp ~/certs/nginx-repo.* .


#git checkout vlatest

# Make KIC without App Protect

#sudo make DOCKERFILE=DockerfileForPlus                         PREFIX=dockerregistry.workshop0001.nginxdemo.net:443/nginx-plus-ingress

# Make KIC with App protect included

sudo make DOCKERFILE=appprotect/DockerfileWithAppProtectForPlus PREFIX=dockerregistry.workshop0001.nginxdemo.net:443/nginx-plus-ingress



