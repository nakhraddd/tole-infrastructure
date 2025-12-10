# Configure the Google Cloud provider
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

# Provider configuration
# Credentials are authenticated via GOOGLE_APPLICATION_CREDENTIALS in GitHub Actions
provider "google" {
  project = var.gcp_project_id
  region  = var.location
}

# 1. Create a VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = "${var.prefix}-network"
  auto_create_subnetworks = true
}

# 2. Create Firewall Rules (Required for SSH and Web access)
resource "google_compute_firewall" "allow_rules" {
  name    = "${var.prefix}-allow-ssh-web"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8000", "3000", "9090"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# 3. Create the Virtual Machine
resource "google_compute_instance" "tole_vm" {
  name         = "${var.prefix}-vm"
  machine_type = "e2-medium"
  zone         = var.location

  # Boot disk using Debian 12 (Bookworm) to support modern pip
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  # Network Interface
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      # ephemeral public IP
    }
  }

  # Startup script to enable Password Auth for the Terraform provisioner
  metadata_startup_script = "echo '${var.vm_username}:${var.vm_password}' | chpasswd && sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config && systemctl restart ssh"

  # SSH Keys
  metadata = {
    ssh-keys = "${var.vm_username}:${var.ssh_public_key}"
  }

  # Connection info for the remote-exec provisioner
  connection {
    type     = "ssh"
    user     = var.vm_username
    password = var.vm_password
    host     = self.network_interface[0].access_config[0].nat_ip
    timeout  = "5m"
  }

  # Provisioning: Install Ansible and run the Playbook
  provisioner "remote-exec" {
    inline = [
      # Wait for startup script to finish
      "sleep 30",
      "sudo apt-get update -y",
      "sudo apt-get install -y git ansible python3-pip unzip",
      
      # Clone your repo
      "rm -rf /tmp/tole-infrastructure",
      "git clone https://github.com/nakhraddd/tole-infrastructure.git /tmp/tole-infrastructure",
      "cd /tmp/tole-infrastructure",
      
      # Run the Master Playbook locally on the new VM
      "sudo ansible-playbook -c local site.yml"
    ]
  }

  allow_stopping_for_update = true
}