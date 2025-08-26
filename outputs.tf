#Output that will be printed out.
output "vpc_name" {
  description = "Name of the created VPC"
  value       = google_compute_network.vpc.name
}

output "subnet_self_link" {
  description = "Self link of the created subnet"
  value       = google_compute_subnetwork.subnet.self_link
}

output "cluster_name" {
  description = "Name of the created GKE cluster"
  value       = google_container_cluster.gke_cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint of the created GKE cluster"
  value       = google_container_cluster.gke_cluster.endpoint
}

output "Cluster_ca_certificate" {
  description = "CA certificate of the created GKE cluster"
  value       = google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate
  sensitive = true
}

output "nodes_service_account_email" {
  description = "Email of the service account used by GKE nodes"
  value       = google_service_account.gke_nodes.email
}

