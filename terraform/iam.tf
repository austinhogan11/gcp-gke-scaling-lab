resource "google_service_account" "app_gsa" {
  account_id   = "app-gsa"
  display_name = "App Workload GSA"
}

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

resource "google_service_account_iam_member" "wi_bind" {
  service_account_id = google_service_account.app_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/app-ksa]"

  # Wait for cluster to create the WI pool first
  depends_on = [google_container_cluster.primary]
}