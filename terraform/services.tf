resource "google_project_service" "services" {
  for_each           = toset([
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "artifactregistry.googleapis.com",
    # "pubsub.googleapis.com",  # uncomment if using Pub/Sub today
  ])
  service            = each.key
  disable_on_destroy = false
}