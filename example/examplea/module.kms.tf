# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
module "kms" {
  source   = "../../"
  name     = "example-keyring"
  location = "europe-west2"

  crypto_keys = {
    app-data = {
      rotation_period = "7776000s"
      encrypters      = ["serviceAccount:${google_service_account.app.email}"]
      decrypters      = ["serviceAccount:${google_service_account.app.email}"]
    }
    app-hsm = {
      rotation_period  = "2592000s"
      protection_level = "HSM"
      decrypters       = ["serviceAccount:${google_service_account.app.email}"]
    }
  }

  labels = {
    team = "platform"
  }
}
