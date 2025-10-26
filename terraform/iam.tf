# Workload Google Service Account
resource "google_service_account" "app_gsa" {
  account_id   = "app-gsa"
  display_name = "App Workload GSA"
}

# Minimal roles for demos
resource "google_project_iam_member" "app_gsa_artifact_read" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.app_gsa.email}"
}
resource "google_project_iam_member" "app_gsa_gcs_view" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.app_gsa.email}"
}

# Add for pub/sub usage later
# resource "google_project_iam_member" "app_gsa_pubsub_sub" {
#   project = var.project_id
#   role    = "roles/pubsub.subscriber"
#   member  = "serviceAccount:${google_service_account.app_gsa.email}"
# }

# Bind KSA (namespace/name) to impersonate GSA via Workload Identity
# Adjust to your namespace and KSA (we’ll use default/app-ksa in the lab)
resource "google_service_account_iam_member" "wi_bind" {
  service_account_id = google_service_account.app_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/app-ksa]"
}