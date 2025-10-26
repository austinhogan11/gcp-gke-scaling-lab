resource "google_container_cluster" "primary" {
  name                      = var.cluster_name
  # Zonal cluster to avoid regional SSD quota issues
  location                  = var.zone

  network                   = google_compute_network.vpc.self_link
  subnetwork                = google_compute_subnetwork.subnet.self_link
  remove_default_node_pool  = true
  initial_node_count        = 1

  release_channel { channel = "REGULAR" }

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
  # Must match cluster location (zonal)
  location = var.zone
  cluster  = google_container_cluster.primary.name

  node_config {
    machine_type  = var.node_machine_type

    # Keep the footprint low on free trial
    disk_type     = "pd-standard"
    disk_size_gb  = 50

    oauth_scopes  = ["https://www.googleapis.com/auth/cloud-platform"]

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    labels   = { role = "app" }
    metadata = { disable-legacy-endpoints = "true" }
    tags     = ["gke", var.cluster_name]
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