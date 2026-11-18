resource "google_kms_key_ring" "main" {
  name     = var.name
  location = var.location
}
