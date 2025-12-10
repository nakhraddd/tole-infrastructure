# Configure the Google Cloud provider
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

# Load credentials from the GITHUB_SERVICE_ACCOUNT_KEY secret (JSON content)
provider "google" {
  project = var.gcp_project_id
  region  = var.location
  credentials = var.gcp_service_account_key 
}

# 1. Create a network for the VM
resource "google_compute_network" "vpc_network" {
  name = "${var.prefix}-network"
  auto_create_subnetworks = true
}

# 2. Define the Virtual Machine Instance
resource "google_compute_instance" "tole_vm" {
  name         = "${var.prefix}-vm"
  machine_type = "e2-medium" 
  zone         = var.location
  metadata_startup_script = "echo '${var.vm_username}:${var.vm_password}' | chpasswd && sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config && systemctl restart ssh"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Network interface (connects to the VPC network created above)
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      # This block creates an ephemeral public IP for SSH access
    }
  }

  # Add SSH keys for the automation_bot user
  metadata = {
    ssh-keys = "${var.vm_username}:${var.ssh_public_key}"
  }

  # Set up the credentials for the automation_bot user
  connection {
    type        = "ssh"
    user        = var.vm_username
    password    = var.vm_password 
    host        = self.network_interface[0].access_config[0].nat_ip
    timeout     = "5m"
  }

  # Provisioning step: Execute the Ansible playbook immediately after creation
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      # Wait for cloud-init/SSH to be fully ready before proceeding
      "sleep 60", 
      "sudo apt-get install -y git ansible python3-pip",
      # Clone the repository containing the Ansible playbook
      "git clone https://github.com/nakhraddd/tole-infrastructure.git /tmp/tole-infrastructure",
      "cd /tmp/tole-infrastructure",
      
      # The Ansible playbook itself relies on the VM being fully up to date.
      # Run the master Ansible playbook using the local connection
      "sudo ansible-playbook -c local site.yml"
    ]
  }

  # Enable the created user for SSH authentication
  allow_stopping_for_update = true
}

# 3. Create a Firewall Rule to allow SSH and Web traffic
resource "google_compute_firewall" "allow_rules" {
  name    = "${var.prefix}-allow-ssh-web"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8000", "3000", "9090"]
  }

  source_ranges = ["0.0.0.0/0"]
}