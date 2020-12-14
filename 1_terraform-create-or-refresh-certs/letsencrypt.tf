provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}
 
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "d.luke@f5.com"
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = "*.workshop0001.nginxdemo.net"
 
  dns_challenge {
    provider = "route53"
  }
}

resource "local_file" "crt" {
    content     = acme_certificate.certificate.certificate_pem
    filename = "../certs/workshop0001.nginxdemo.net.crt.pem"
}

resource "local_file" "key" {
    content     = acme_certificate.certificate.private_key_pem
    filename = "../certs/workshop0001.nginxdemo.net.key.pem"
}

resource "local_file" "issuer" {
    content     = acme_certificate.certificate.issuer_pem
    filename = "../certs/workshop0001.nginxdemo.net.issuer.pem"
}