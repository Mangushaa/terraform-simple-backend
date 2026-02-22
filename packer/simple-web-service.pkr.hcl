packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.0"
    }
  }
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "app_name" {
  type    = string
  default = "simple-web-server"
}

variable "app_version" {
  type = string
}

# Path to the jar built by Maven (provided by CI)
variable "jar_path" {
  type = string
}

# Optional: VPC/subnet for the temporary builder instance
variable "subnet_id" {
  type    = string
  default = ""
}

# Base AMI: Amazon Linux 2023 (recommended to reference via SSM in CI, but shown here as filter)
source "amazon-ebs" "al2023" {
  region        = var.region
  instance_type = "t4g.nano"
  ssh_username  = "ec2-user"

  source_ami_filter {
    owners      = ["amazon"]
    most_recent = true
    filters = {
      name                = "al2023-ami-*-x86_64"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
  }

  ami_name        = "${var.app_name}-${var.app_version}-{{timestamp}}"
  ami_description = "Baked AMI for ${var.app_name} version ${var.app_version}"

  # Helpful tags on AMI + snapshots
  tags = {
    Name        = "${var.app_name}-${var.app_version}"
    App         = var.app_name
    AppVersion  = var.app_version
    BuiltBy     = "packer"
  }

  run_tags = {
    Name = "packer-builder-${var.app_name}-${var.app_version}"
  }

  dynamic "subnet_id" {
    for_each = var.subnet_id == "" ? [] : [1]
    content  = var.subnet_id
  }
}

build {
  sources = ["source.amazon-ebs.al2023"]

  # Copy jar to instance
  provisioner "file" {
    source      = var.jar_path
    destination = "/tmp/app.jar"
  }

  # Install java + app + systemd unit
  provisioner "shell" {
    scripts = [
      "${path.root}/scripts/install_java.sh",
      "${path.root}/scripts/install_app.sh",
      "${path.root}/scripts/systemd_service.sh",
    ]

    environment_vars = [
      "APP_NAME=${var.app_name}",
      "APP_VERSION=${var.app_version}",
    ]
  }
}