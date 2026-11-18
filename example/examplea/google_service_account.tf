resource "google_service_account" "app" {
  account_id   = "kms-app"
  display_name = "Example workload that encrypts and decrypts with the module's key"
}
