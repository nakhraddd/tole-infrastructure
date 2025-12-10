variable "prefix" {
  description = "A prefix for all resource names"
  type        = string
  default     = "tole-sis-project"
}

variable "location" {
  description = "The GC region where resources will be deployed"
  type        = string
  default     = "europe-central2-c"
}

variable "vm_username" {
  description = "Username for the VM"
  type        = string
  default     = "automation_bot"
}

variable "vm_password" {
  description = "Password for the VM"
  type        = string
  default     = "MySecurePassword123!"
}

variable "gcp_project_id" {
  description = "Your Google Cloud Project ID"
  type        = string
  sensitive   = true 
}

variable "gcp_service_account_key" {
  description = "The JSON content of the GCP Service Account Key for authentication."
  type        = string
  sensitive   = true 
}

variable "ssh_public_key" {
  description = "Your public SSH key for the VM (e.g., ~/.ssh/id_rsa.pub content)"
  type        = string
  sensitive   = true
}