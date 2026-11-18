resource "google_kms_crypto_key_iam_member" "main" {
  for_each = local.key_members

  crypto_key_id = google_kms_crypto_key.main[each.value.key].id
  role          = each.value.role
  member        = each.value.member
}
