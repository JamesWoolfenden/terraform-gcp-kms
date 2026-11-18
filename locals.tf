locals {
  key_roles = {
    encrypters = "roles/cloudkms.cryptoKeyEncrypter"
    decrypters = "roles/cloudkms.cryptoKeyDecrypter"
  }

  # One entry per key and role that has at least one member. Keys are static
  # (key name and role), so for_each never depends on member values.
  key_bindings = merge([
    for key_name, key in var.crypto_keys : {
      for field, role in local.key_roles : "${key_name}/${field}" => {
        key     = key_name
        role    = role
        members = key[field]
      } if length(key[field]) > 0
    }
  ]...)
}
