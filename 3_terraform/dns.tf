# Set some defaults for AWS like region.
#provider "aws" {
# profile = "default"
# region  = "eu-west-2"
#}





resource "aws_route53_record" "dockerregistry-workshop0001" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "dockerregistry.workshop0001.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "60"
# records = ["${chomp(http.myip.body)}"]
  records = [ aws_instance.workshop0001-docker-registry.public_ip ]

}

resource "aws_route53_record" "kubernetes-workshop0001" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "kubernetes.workshop0001.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "60"
# records = ["${chomp(http.myip.body)}"]
  records = [ aws_instance.workshop0001-nginx-plus-gateway-1.public_ip ]

}

resource "aws_route53_record" "k8s-master-workshop0001" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "k8s-master.workshop0001.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "60"
# records = ["${chomp(http.myip.body)}"]
  records = [ aws_instance.workshop0001-k8s-master.public_ip ]

}

resource "aws_route53_record" "worker-node-1-workshop0001" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "worker-node-1.workshop0001.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "60"
# records = ["${chomp(http.myip.body)}"]
  records = [ aws_instance.workshop0001-worker-node-1.public_ip ]

}


resource "aws_route53_record" "worker-node-2-workshop0001" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "worker-node-2.workshop0001.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "60"
# records = ["${chomp(http.myip.body)}"]
  records = [ aws_instance.workshop0001-worker-node-2.public_ip ]

}

resource "aws_route53_record" "k8sdashboard-workshop0001" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "k8sdashboard.workshop0001.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "60"
# records = ["${chomp(http.myip.body)}"]
  records = [ aws_instance.workshop0001-k8s-master.public_ip ]

}

resource "aws_route53_record" "ingressdashboard-workshop0001" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "ingressdashboard.workshop0001.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "60"
# records = ["${chomp(http.myip.body)}"]
  records = [ aws_instance.workshop0001-k8s-master.public_ip ]

}

resource "aws_route53_record" "cafe-workshop0001" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "cafe.workshop0001.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "60"
# records = ["${chomp(http.myip.body)}"]
  records = [ aws_instance.workshop0001-nginx-plus-gateway-1.public_ip ]

}

resource "aws_route53_record" "cafe2-workshop0001" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "cafe2.workshop0001.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "60"
# records = ["${chomp(http.myip.body)}"]
  records = [ aws_instance.workshop0001-nginx-plus-gateway-1.public_ip ]

}