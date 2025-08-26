terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
        source  = "hashicorp/google"
        version = "~> 5.4" # recent provider version 
           
        }
} 
# Remote state backend (GCS)
   backend "gcs" {
    bucket = "syndio-test-app-bucket"  # bucket where state file is stored.
    prefix = "terraform/state"
  }
}


provider "google" {
    project = var.project_id
    region  = var.region
    }
  
  # Enabling the necessary APIs for the cluster.
  resource "google_project_service" "services" {
    for_each = toset([
        "compute.googleapis.com",
        "container.googleapis.com",
        "servicenetworking.googleapis.com",
        "iam.googleapis.com",
        "cloudresourcemanager.googleapis.com",
        "serviceusage.googleapis.com",
    ]
    )
    project = var.project_id
    service = each.key

    disable_dependent_services = true
    disable_on_destroy         = false
  }

  # Network configuration
  resource "google_compute_network" "vpc" {
    name                    = var.vpc_name
    auto_create_subnetworks = false
    routing_mode           = "REGIONAL"

    depends_on = [google_project_service.services]
  }

  resource "google_compute_subnetwork" "subnet" {
    name          = var.subnet_name
    ip_cidr_range = var.subnet_cidr
    region        = var.region
    network       = google_compute_network.vpc.id
    private_ip_google_access = true
  

  # Secondary range for VPC GKE clusters
  secondary_ip_range {
    range_name    = var.pods_range_name
    ip_cidr_range = var.pods_cidr
   }
    secondary_ip_range {
        range_name    = var.services_range_name
        ip_cidr_range = var.services_cidr
    }
   }

  # Firewall rules
  # Allowing internal communication within the VPC
  resource "google_compute_firewall" "allow_ssh" {
    name    = "${var.vpc_name}-allow-ssh"
    network = google_compute_network.vpc.name

    allow {
      protocol = "tcp"
      ports    = ["22"]
    }

    source_ranges = var.allowed_cidr_blocks
    target_tags  =  ["ssh-allowed"]
  }

  # Service account for GKE
  resource "google_service_account" "gke_nodes" {
    account_id   = "gke-nodes"
    display_name = "syndio-test-app node service account"
  }

  resource "google_service_account" "app" {
    account_id   = "app-runtime-sa"
    display_name = "syndio-test-app service account"
  }

  # basic roles for Nodes SA ( Ensure least privilege )
  resource "google_project_iam_member" "nodes_log_writer" {
    project = var.project_id
    role    = "roles/logging.logWriter"
    member  = "serviceAccount:${google_service_account.gke_nodes.email}"
  }

  resource "google_project_iam_member" "nodes_metric_writer" {
    project = var.project_id
    role    = "roles/monitoring.metricWriter"
    member  = "serviceAccount:${google_service_account.gke_nodes.email}"
  }

  #GKE cluster creation
  resource "google_container_cluster" "gke_cluster" {
    name               = var.cluster_name
    location           = var.location
    network           = google_compute_network.vpc.id
    subnetwork       = google_compute_subnetwork.subnet.id
    remove_default_node_pool = true
    deletion_protection =  false
    initial_node_count = 1

    release_channel {
        channel = "REGULAR" # Use the regular release channel
    }

    ip_allocation_policy {
        cluster_secondary_range_name = var.pods_range_name
        services_secondary_range_name = var.services_range_name
    }

    networking_mode = "VPC_NATIVE"

    logging_service = "logging.googleapis.com/kubernetes"
    monitoring_service = "monitoring.googleapis.com/kubernetes"

    addons_config {
        http_load_balancing {
            disabled = false
        }
        horizontal_pod_autoscaling {
            disabled = false
        }
    } 
        depends_on = [
            google_project_service.services,
            google_compute_subnetwork.subnet,
            google_service_account.gke_nodes
        ]
    }
resource "time_sleep" "wait_for_cluster" {
  depends_on = [google_container_cluster.gke_cluster]

  create_duration = "240s"  # Wait 4 minutes after cluster creation

 # Create resource after cluster has been created.
  triggers = {
      cluster_id = google_container_cluster.gke_cluster.id
    }

}

resource "google_container_node_pool" "dev" {
    name       = "${var.cluster_name}-dev-nodepool"
    location   = var.location
    cluster    = google_container_cluster.gke_cluster.name
    node_count = var.node_count

    depends_on = [
        google_container_cluster.gke_cluster,
        time_sleep.wait_for_cluster
      ]

    node_config {
        machine_type = var.node_machine_type
        disk_size_gb = var.node_disk_gb
        disk_type = var.node_disk_type
        service_account = google_service_account.gke_nodes.email
        oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
        labels       = var.node_labels
        tags         = concat(["ssh-allowed"], var.node_tags)
        metadata = {"disable-legacy-endpoints" = "true"}
    }
    management {
        auto_repair = true
        auto_upgrade = true
    }
}
    