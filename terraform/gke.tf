resource "google_container_cluster" "primary" {
  name                     = var.cluster_name
  location                 = var.region
  network                  = google_compute_network.vpc.self_link
  subnetwork               = google_compute_subnetwork.subnet.self_link
  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "REGULAR" 
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods-range"
    services_secondary_range_name = "services-range"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS","WORKLOADS","APISERVER","SCHEDULER","CONTROLLER_MANAGER"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS","APISERVER","SCHEDULER","CONTROLLER_MANAGER"]
  }

  depends_on = [google_project_service.services]
}

resource "google_container_node_pool" "primary_nodes" {
  name     = "${var.cluster_name}-pool"
  location = var.region
  cluster  = google_container_cluster.primary.name

  node_config {
    machine_type = var.node_machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    labels = { 
        role = "app" 
    }
    metadata = {
        disable-legacy-endpoints = "true" 
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = var.min_nodes
    max_node_count = var.max_nodes
  }
}