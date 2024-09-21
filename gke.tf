resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  node_locations = [var.zone]

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

resource "google_container_node_pool" "gpu_pool" {
  name       = google_container_cluster.primary.name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  autoscaling {
    total_min_node_count = "1"
    total_max_node_count = "1"
  }

  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
    ]

    labels = {
      env = var.project_id
    }

    guest_accelerator {
      type  = var.gpu_type
      count = 1
      gpu_driver_installation_config {
        gpu_driver_version = var.gpu_driver_version
      }
    }

    image_type   = "cos_containerd"
    machine_type = var.machine_type
    tags         = ["gke-node", "${var.project_id}-gke"]

    disk_size_gb = "500"

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}