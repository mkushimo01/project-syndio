variable "project_id" {
  description = "Syndio-test-app project ID"
  type        = string
  default    = "syndio-test-app-project"
}

variable "region" {
  description = "Region for the GKE cluster"
  type        = string
  default     = "us-central1"
}

variable "vpc_name" {
  description = "Name of the VPC "
  type        = string
  default     = "syndio-test-app-vpc"
}

variable "subnet_name" {
  description = "Name of the subnet for GKE"
  type        = string
  default     = "syndio-test-app-subnet"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.10.0.0/24"
}

variable "pods_range_name" {
  description = "Name of the secondary range for Pods"
  type        = string
  default     = "syndio-test-app-pods-range"
}

variable "pods_cidr" {
  description = "CIDR range for Pods"
  type        = string
  default     = "10.20.0.0/16"
}

variable "services_range_name" {
  description = "Name of the secondary range for services"
  type        = string
  default     = "syndio-test-app-services-range"
}

variable "location" {
  description = "Location for the GKE cluster"
  type        = string
  default     = "us-central1"
}

variable "services_cidr" {
  description = "CIDR range for Services"
  type        = string
  default     = "10.30.0.0/20"
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the VPC"
  type        = list(string)
  default     = ["35.235.240.0/20"]
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "syndio-cluster"
}

variable "node_count" {
  description = "Number of nodes in the GKE cluster"
  type        = number
  default     = 2
}

variable "node_machine_type" {
  description = "Machine type for the GKE nodes"
  type        = string
  default     = "e2-medium"
}
variable "node_disk_type" {
  description = "Type of disk to attach to each node (e.g., pd-standard, pd-ssd)"
  type        = string
  default     = "pd-standard" 
}

variable "node_disk_gb" {
  description = "Disk size in GB for the GKE nodes"
  type        = number
  default     = 50
}

variable "node_labels" {
  description = "Labels for the GKE nodes"
  type        = map(string)
  default     = { role = "general" }
}

variable "node_tags" {
  description = "Tags for the GKE nodes"
  type        = list(string)
  default     = []
}
