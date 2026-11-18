# One authoritative binding per key and role. The module owns these keys, so
# authoritative is safe here, and it avoids the problem a list-indexed
# google_kms_crypto_key_iam_member had: removing an earlier member shifted every
# later index, and the destroy/create pairs for the same (key, role, member)
# could race and drop a workload's access mid-apply. A binding also takes
# members that are only known after apply (e.g. a new service account's email).
resource "google_kms_crypto_key_iam_binding" "main" {
  for_each = local.key_bindings

  crypto_key_id = google_kms_crypto_key.main[each.value.key].id
  role          = each.value.role
  members       = each.value.members
}
