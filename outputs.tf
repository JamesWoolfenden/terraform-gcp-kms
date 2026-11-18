output "key_ring_id" {
  value       = google_kms_key_ring.main.id
  description = "ID of the KMS key ring"
}

output "crypto_key_ids" {
  value       = { for k, v in google_kms_crypto_key.main : k => v.id }
  description = "Map of crypto key name to crypto key ID, for use as CMEK key references"
}

output "import_job_id" {
  value       = try(one(values(google_kms_key_ring_import_job.main)).id, null)
  description = "ID of the key ring import job, or null when no import job was requested"
}
