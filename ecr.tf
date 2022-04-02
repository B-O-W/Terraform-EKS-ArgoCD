resource "aws_ecr_repository" "foo" {
  name                 = "netjs"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "kubernetes_secret" "docker-registry" {
  metadata {
    name = "regsecret"
  }

  data = {
    ".dockerconfigjson" = "${file("${path.module}/config.json")}"
  }

  type = "kubernetes.io/dockerconfigjson"
}