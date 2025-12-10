output "vm_public_ip" {
  description = "The public IP address of the deployed VM"
  value       = google_compute_instance.tole_vm.network_interface[0].access_config[0].nat_ip
}

output "vm_ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.vm_username}@${google_compute_instance.tole_vm.network_interface[0].access_config[0].nat_ip}"
}