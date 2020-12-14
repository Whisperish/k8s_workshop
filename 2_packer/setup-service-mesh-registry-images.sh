echo "The running docker processes are....."

sudo docker ps

# Now we are going to extract the NGINX Service Mesh images from the tarball. We're working with version 0.6.0 currently.

tar -xvf nginx-mesh-images-0.6.0.tar.gz
cd nginx-mesh-images-0.6.0

# Now we are going to load all of the NGINX Service Mesh images into the local Docker Daemon.

for image in $(ls)
do
  sudo docker load < $image
done

# Let's have a look in our local Docker Daemon to see if they are all safely there.

sudo docker images

# Now let's tag each of those images ready to push to our local workshop registry.

sudo docker tag nginx-mesh-api:0.6.0 dockerregistry.workshop0001.nginxdemo.net:443/nginx-mesh-api:0.6.0
sudo docker tag nginx-mesh-init:0.6.0 dockerregistry.workshop0001.nginxdemo.net:443/nginx-mesh-init:0.6.0
sudo docker tag nginx-mesh-metrics:0.6.0 dockerregistry.workshop0001.nginxdemo.net:443/nginx-mesh-metrics:0.6.0
sudo docker tag nginx-mesh-sidecar:0.6.0 dockerregistry.workshop0001.nginxdemo.net:443/nginx-mesh-sidecar:0.6.0


# Finally, we'll push each of those tagged images onto our local workshop registry.

sudo docker push dockerregistry.workshop0001.nginxdemo.net:443/nginx-mesh-api:0.6.0
sudo docker push dockerregistry.workshop0001.nginxdemo.net:443/nginx-mesh-init:0.6.0
sudo docker push dockerregistry.workshop0001.nginxdemo.net:443/nginx-mesh-metrics:0.6.0
sudo docker push dockerregistry.workshop0001.nginxdemo.net:443/nginx-mesh-sidecar:0.6.0

# From there, the service mesh can be deployed using the nginx-meshctl command line utility on the k8s control node.