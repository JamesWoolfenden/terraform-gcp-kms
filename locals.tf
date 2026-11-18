locals {
  # Flatten per-key encrypter/decrypter member lists so each grant is an
  # individually-addressable, non-authoritative IAM member. Keys use the list
  # index rather than the member string so members only known after apply
  # (e.g. a new service account's email) still work with for_each.
  encrypter_grants = flatten([
    for key_name, key in var.crypto_keys : [
      for i, m in key.encrypters : { id = "${key_name}/encrypter/${i}", key = key_name, role = "roles/cloudkms.cryptoKeyEncrypter", member = m }
    ]
  ])

  decrypter_grants = flatten([
    for key_name, key in var.crypto_keys : [
      for i, m in key.decrypters : { id = "${key_name}/decrypter/${i}", key = key_name, role = "roles/cloudkms.cryptoKeyDecrypter", member = m }
    ]
  ])

  key_members = { for g in concat(local.encrypter_grants, local.decrypter_grants) : g.id => g }
}
