variable "test" {
  default = "default value"
}

locals {
  test = var.test
}

source "null" "null" {
  communicator = "none"
}

build {
  sources = ["source.null.null"]

  provisioner "shell-local" {
    command = "echo var.test=\\\"${var.test}\\\" local.test=\\\"${local.test}\\\""
  }
}
