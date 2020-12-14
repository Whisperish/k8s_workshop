resource "aws_key_pair" "controller-workshop0001" {
  key_name   = "k8s-server-key-workshop0001"
  public_key = file ("~/.ssh/k8s-key.pub")
}

resource "aws_key_pair" "north-south-router-workshop0001" {
  key_name   = "north-south-router-key-workshop0001"
  public_key = file ("~/.ssh/north-south-router-key.pub")
}