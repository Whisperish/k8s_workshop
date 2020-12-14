# Add the host IP into the openssl config. This is so we can generate our self-signed certs for the docker registry.

#sudo sh -c 'echo "subjectAltName=IP:10.0.0.60">>/etc/ssl/openssl.cnf'
 
#mkdir -p certs
#mkdir -p certs/private

#export SSLSAN="email:copy,DNS:www.example.org"

#openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -x509 -days 365 -out certs/domain.crt



#openssl genrsa -out certs/dockerregistry.key 2048
#openssl req -new -key certs/dockerregistry.key -subj /CN=dockerregistry/ -out certs/dockerregistry.csr
#openssl x509 -req -days 3650 -in certs/dockerregistry.csr -signkey certs/dockerregistry.key -out certs/dockerregistry.crt


#openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout certs/key.pem -out certs/cert.pem -config sslreq.conf -extensions 'v3_req'

# Trust the newly generated registry certificate

#sudo  sh -c 'cat certs/cert.pem >>/etc/pki/tls/certs/ca-bundle.crt'

