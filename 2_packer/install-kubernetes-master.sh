# Please insert your username and password for NoIP.com in the line below, and also any domain name you have reserved there that you would like to use (mandatory). Also change any controller login parameters you wish to (optional)


#export NOIP_HOSTNAME=nginxk8s.ddns.net
#export NOIP_USERNAME=workshop0001
#export NOIP_PASSWORD=ToiletRoll\!30174

#export CTR_APIGW_CERT=nginxk8s.crt
#export CTR_APIGW_KEY=nginxk8s.key

# Update the NoIP dynamic DNS record for NOIP_HOSTNAME

#export AWS_PUBLIC_IP=`dig +short myip.opendns.com @resolver1.opendns.com`

#curl -vv http://$NOIP_USERNAME:$NOIP_PASSWORD@dynupdate.no-ip.com/nic/update?hostname=$NOIP_HOSTNAME&myip=$AWS_PUBLIC_IP

# Wait a bit until our domain name is resolving to the public IP of this new amazon controller machine.

#export CURRENT_RESOLVING_PUBLIC_IP=`dig +short $NOIP_HOSTNAME`

#until [ $CURRENT_RESOLVING_PUBLIC_IP = $AWS_PUBLIC_IP ]
#do
#  export CURRENT_RESOLVING_PUBLIC_IP=`dig +short $NOIP_HOSTNAME`
#  echo DNS lookup for $NOIP_HOSTNAME reveals $CURRENT_RESOLVING_PUBLIC_IP but our AWS public IP is $AWS_PUBLIC_IP
#  echo 'Waiting another ten seconds, then trying the DNS query again....';
#  sleep 10
#done

# Fetch a certificate from Let's Encrypt for the Controller using acme.sh ............

# We will use acme.sh and socat. The tool socat allows acme to stand up a temporary server on port 80 to pass the acme check, and prove we own our domain name.

# Install acme.sh to fetch the cert for us

#curl https://get.acme.sh | sh


# Fetch the certificate and store it in place - NOTE this will issue an ownership challenge to port 80 on the Controller

#sudo -H ~/.acme.sh/acme.sh --issue --standalone --force -d $NOIP_HOSTNAME -w ~/controller_cert.crt
#mkdir ~/certs
#sudo cp /root/.acme.sh/$NOIP_HOSTNAME/fullchain.cer ~/certs/$CTR_APIGW_CERT
#sudo cp /root/.acme.sh/$NOIP_HOSTNAME/$NOIP_HOSTNAME.key ~/certs/$CTR_APIGW_KEY




# Set the master node hostname.

sudo hostnamectl set-hostname k8s-master

# Ensure IPtables is set to activate br_netfilter

sudo sh -c 'echo "1" > /proc/sys/net/bridge/bridge-nf-call-iptables'

# Install this K8s machine as the Master Node

sudo kubeadm init --config kubeadm.config | tee k8s_master_initiation_log.txt

# Setup the 'centos' user for kubectl command line access

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


# Add the k8s overlay network so that the pods can talk to each other between the nodes

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# Extract the 'join' command from the k8s initiation log, and make sure the switch to skip ca verification is set.

cat k8s_master_initiation_log.txt | grep 'kubeadm join' | tr -d '\n'  | sed 's/.$//'>worker_node_join_command.sh

echo -n " --discovery-token-unsafe-skip-ca-verification">>worker_node_join_command.sh
export JOIN_COMMAND="sudo `cat worker_node_join_command.sh`"
echo "--------------------------------------------------"
echo "----- This is the generated join command: --------"
echo "--------------------------------------------------"
cat worker_node_join_command.sh
echo "--------------------------------------------------"


# Ensure the ssh key that enables logging on to the worker nodes is correctly protected via linux permissions

chmod 600 /tmp/sshkey*

# Now we have the master installed, we can instruct the two worker nodes to join. NOTE: We have to wait for terraform to bring them up first.

until ssh -i /tmp/sshkey -o "StrictHostKeyChecking no" centos@worker-node-1 'sudo hostnamectl set-hostname worker-node-1' ; do sleep 10; done
until ssh -i /tmp/sshkey -o "StrictHostKeyChecking no" centos@worker-node-2 'sudo hostnamectl set-hostname worker-node-2' ; do sleep 10; done

until ssh -i /tmp/sshkey -o "StrictHostKeyChecking no" centos@worker-node-1 'sudo sh -c "echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables"'; do sleep 10; done
until ssh -i /tmp/sshkey -o "StrictHostKeyChecking no" centos@worker-node-2 'sudo sh -c "echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables"'; do sleep 10; done


until ssh -i /tmp/sshkey -o "StrictHostKeyChecking no" centos@worker-node-1 `echo $JOIN_COMMAND` ; do sleep 10; done
until ssh -i /tmp/sshkey -o "StrictHostKeyChecking no" centos@worker-node-2 `echo $JOIN_COMMAND` ; do sleep 10; done


# Add the k8s overlay network so that the pods can talk to each other between the nodes

#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml

# Install the k8s dashboard

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc7/aio/deploy/recommended.yaml

# Apply all the files in the user config directory to k8s

kubectl apply -f k8s_configuration/*

# And finally, print out the dashboard login token

kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

# We also need to create the default TLS secret for the ingress controller. We use our *.workshop0001.nginxdemo.net cert/key pair here.

cat ~/certs/workshop0001.nginxdemo.net.crt.pem ~/certs/workshop0001.nginxdemo.net.issuer.pem >~/certs/workshop0001.nginxdemo.net.fullchain.pem

kubectl create secret tls default-server-secret --key=certs/workshop0001.nginxdemo.net.key.pem --cert=certs/workshop0001.nginxdemo.net.fullchain.pem




