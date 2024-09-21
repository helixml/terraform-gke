variable "project_id" {
  description = "the gcp_name_short project where GKE creates the cluster"
}

variable "region" {
  description = "the gcp_name_short region where GKE creates the cluster"
}

variable "zone" {
  description = "the GPU nodes zone"
}

variable "cluster_name" {
  description = "the name of the cluster"
}

variable "gpu_type" {
  description = "the GPU accelerator type"
}

variable "gpu_driver_version" {
  description = "the NVIDIA driver version to install"
}

variable "machine_type" {
  description = "The Compute Engine machine type for the VM"
}