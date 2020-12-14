#First off, we will unzip the nginx-meshctl command so that we can run it

gunzip  nginx-meshctl_linux.gz

# We will rename this executable to make it easier to use

mv nginx-meshctl_linux nginx-meshctl

# Give executable permissions to the nginx-meshctl binary.

chmod +x nginx-meshctl

# Now we will add it to the PATH string 

export PATH=$PATH:$PWD

# Now we will deploy NGINX Service mesh

./nginx-meshctl deploy --nginx-mesh-api-image="dockerregistry.workshop0001.nginxdemo.net:443/nginx-mesh-api:0.6.0" --nginx-mesh-metrics-image="dockerregistry.workshop0001.nginxdemo.net:443/nginx-mesh-metrics:0.6.0" --nginx-mesh-sidecar-image="dockerregistry.workshop0001.nginxdemo.net:443/nginx-mesh-sidecar:0.6.0" --nginx-mesh-init-image="dockerregistry.workshop0001.nginxdemo.net:443/nginx-mesh-init:0.6.0"

# Having deployed the Mesh, let's pull the nginx web server deployment manifest from Kubernetes into a file

kubectl get deployment nginx -o yaml >nginx_deployment.yaml

# We will now inject the service mesh into the manifest we just pulled. A new manifest will be created.

nginx-meshctl inject -f nginx_deployment.yaml > nginx_deployment_injected.yaml

# We can now delete the original deployment from Kubernetes

kubectl delete deployment nginx

# Then we can replace it with the 'injected' deployment manifest

kubectl apply -f nginx_deployment_injected.yaml

