resource "google_kms_key_ring_import_job" "main" {
  for_each = var.import_job == null ? {} : { (var.import_job.import_job_id) = var.import_job }

  key_ring         = google_kms_key_ring.main.id
  import_job_id    = each.value.import_job_id
  import_method    = each.value.import_method
  protection_level = each.value.protection_level
}
