variable "target_path" {
  type        = string
  description = "Relative path to the Git repository root where the sync manifests are committed."
}

variable "repo_owner" {
  type        = string
  description = "repo_url"
}

variable "repo_name" {
  type        = string
  description = "repo_url"
}

variable "branch" {
  type        = string
  default = "main"
  description = "branch"
}

variable "ssh_private_key_pem" {
  type        = string
  description = "ssh_private_key_pem"
}

variable "ssh_public_key" {
  type        = string
  description = "ssh_public_key"
}

variable "flux_namespace" {
  type        = string
  default     = "flux-system"
  description = "the flux namespace"
}

variable "gserviceaccount" {
  type        = string
  description = "service account for sops decryption"
}

variable "cluster_ca_certificate" {
  type        = string
  description = "cluster ca certificate"
}

variable "cluster_host" {
  type        = string
  description = "cluster host"
}

variable "cluster_token" {
  type        = string
  description = "cluster token"
}

## IMAGE REFLECTOR
variable "image_reflector_enabled" {
  type = bool
  default = false
  description = "enable image-reflector controller"
}

variable "image_reflector_gserviceaccount" {
  type        = string
  description = "service account for image reflector"
}

## IMAGE AUTOMATION
variable "image_automation_enabled" {
  type = bool
  default = false
  description = "enable image-automation controller"
}