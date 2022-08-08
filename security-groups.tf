##DYNAMIC SG 
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = ["80", "443", "8080", "2049", "9092", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8",]
  }
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = ["80", "443", "8080", "2049", "9092", "22"] ###THIS IS LIST OF PORT IF YOU WANT CHANGE PORT JUST ADD IT
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    }
  }
}
