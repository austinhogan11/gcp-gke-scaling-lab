resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = "sr-eng-docker"
  description   = "Docker images for sr-eng labs"
  format        = "DOCKER"
  depends_on    = [google_project_service.services]
}