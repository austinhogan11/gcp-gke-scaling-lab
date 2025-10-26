output "get_credentials_cmd" {
  value       = "gcloud container clusters get-credentials ${var.cluster_name} --zone ${var.zone} --project ${var.project_id}"
  description = "Run this to configure kubectl for the new cluster"
}

output "cluster_endpoint" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE control plane endpoint"
}

output "artifact_registry_repo" {
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
  description = "Container registry URL"
}