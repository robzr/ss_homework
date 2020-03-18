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
  /* Packer will always interpolate the following based on var.image default value...
   * this is either a bug, or an unintuitive ordering of locals vs variables interpolation
   * either way, bummer, as we cannot reuse this snippet
   */
  image_os = "${split(":", var.image)[0]}"

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
#    "CMD [\"/usr/sbin/nginx\", \"-g\", \"daemon off;\"]",
    "CMD [\"/usr/sbin/nginx\"]",
    "USER www-data",   // this needs to be set for CentOS
  ]
  commit = true
  image  = var.image
}


build {
  sources = [
    "source.docker.image",
  ]

  provisioner "shell-local" {
    command = "echo Building on `hostname`, image=${var.image} local.image_os=${local.image_os} image_os=${split(":", var.image)[0]}"
  }

  provisioner "shell" {
    inline           = local.shell_inline[split(":", var.image)[0]]
    environment_vars = local.shell_environment_vars[split(":", var.image)[0]]
  }

  post-processor "docker-tag" {
    repository = "homework/nginx-${split(":", var.image)[0]}"
    tag        = [split(":", var.image)[1]]
  }

/*
  post-processor "docker-push" {
    repository     = "robzr/ss_homework"
    login_username = var.docker_hub_username
    login_password = var.docker_hub_password
    tag            = [split(":", var.image)[1]]
  }
*/
}
