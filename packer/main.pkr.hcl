variable "docker_hub_password" {
  default     = ""
  description = "Docker Hub password"
}

variable "docker_hub_username" {
  default     = "robzr"
  description = "Docker Hub username"
}

variable "image" {
  default     = "ubuntu:latest"
  description = "Base Docker image, tested with ubuntu:latest and centos:latest"
}


locals {
  # This local does not interpolate properly; submitted https://github.com/hashicorp/packer/issues/8898
  image_os  = split(":", var.image)[0]
  image_tag = split(":", var.image)[1]

  shell_environment_vars = {
    centos = []
    ubuntu = [
      "DEBIAN_FRONTEND=noninteractive",
    ]
  }

  shell_inline = {
    centos = [
      "yum makecache",
      "yum install -y nginx",
      "mkdir /html",
      "sed -i -e 's/root .*;/root \\/html;/' /etc/nginx/nginx.conf",
    ]
    ubuntu = [
      "apt-get update",
      "apt-get install -y nginx-light",
      "mkdir /html",
      "sed -i -e 's/root .*;/root \\/html;/' /etc/nginx/sites-available/default",
    ]
  }
}


source "docker" "image" {
  changes = [
    "CMD [\"-g\", \"daemon off;\"]",
    "ENTRYPOINT [\"/usr/sbin/nginx\"]",
  ]
  commit = true
  image  = var.image
}


build {
  sources = [
    "source.docker.image",
  ]

  provisioner "shell-local" {
    command = "echo local.image_os=\\\"${local.image_os}\\\" local.image_tag=\\\"${local.image_tag}\\\""
  }

  provisioner "shell" {
    inline           = local.shell_inline[local.image_os]
    environment_vars = local.shell_environment_vars[local.image_os]
  }

  post-processor "docker-tag" {
    repository = "${var.docker_hub_username}/${local.image_os}-nginx"
    tag        = [local.image_tag]
  }

  post-processor "docker-push" {
    login          = true
    login_username = var.docker_hub_username
    login_password = var.docker_hub_password
  }

  post-processor "docker-tag" {
    repository = "homework/nginx-${local.image_os}"
    tag        = [local.image_tag]
  }
}
