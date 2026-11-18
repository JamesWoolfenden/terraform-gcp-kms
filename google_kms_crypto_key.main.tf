resource "google_kms_crypto_key" "main" {
  for_each = var.crypto_keys

  name                       = each.key
  key_ring                   = google_kms_key_ring.main.id
  purpose                    = "ENCRYPT_DECRYPT"
  rotation_period            = each.value.rotation_period
  destroy_scheduled_duration = each.value.destroy_scheduled_duration
  labels                     = merge(var.labels, each.value.labels)

  version_template {
    algorithm        = each.value.algorithm
    protection_level = each.value.protection_level
  }

  lifecycle {
    prevent_destroy = true
  }
}
