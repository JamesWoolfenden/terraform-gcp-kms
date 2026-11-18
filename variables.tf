variable "name" {
  type        = string
  description = "Name of the KMS key ring"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,63}$", var.name))
    error_message = "var.name must be 1-63 characters of letters, digits, underscores or hyphens"
  }
}

variable "location" {
  type        = string
  description = "Location of the key ring, e.g. europe-west2, europe or global. Must match the location of the resources that use the keys"

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "var.location must be a non-empty string"
  }
}

# holden:ignore:HLD_TF_050 — holds key configuration (names, rotation periods, IAM members), not key material;
# marking it sensitive would make it unusable in for_each and hide the rotation settings from plan review.
variable "crypto_keys" {
  type = map(object({
    rotation_period            = string
    destroy_scheduled_duration = optional(string, "2592000s")
    protection_level           = optional(string, "SOFTWARE")
    algorithm                  = optional(string, "GOOGLE_SYMMETRIC_ENCRYPTION")
    labels                     = optional(map(string), {})
    encrypters                 = optional(list(string), [])
    decrypters                 = optional(list(string), [])
  }))
  description = "Map of symmetric ENCRYPT_DECRYPT crypto keys to create, keyed by key name. rotation_period is required (at most 90 days), and encrypters/decrypters are IAM members granted roles/cloudkms.cryptoKeyEncrypter and roles/cloudkms.cryptoKeyDecrypter on that key"

  validation {
    condition     = length(var.crypto_keys) > 0
    error_message = "var.crypto_keys must define at least one crypto key"
  }

  validation {
    condition     = alltrue([for k, v in var.crypto_keys : can(regex("^[a-zA-Z0-9_-]{1,63}$", k))])
    error_message = "var.crypto_keys names must be 1-63 characters of letters, digits, underscores or hyphens"
  }

  validation {
    condition = alltrue([
      for k, v in var.crypto_keys : can(regex("^[0-9]+s$", v.rotation_period)) &&
      tonumber(trimsuffix(v.rotation_period, "s")) >= 86400 &&
      tonumber(trimsuffix(v.rotation_period, "s")) <= 7776000
    ])
    error_message = "Each key's rotation_period must be a duration in seconds (e.g. \"7776000s\") between 1 day (86400s) and 90 days (7776000s)"
  }

  validation {
    condition = alltrue([
      for k, v in var.crypto_keys : can(regex("^[0-9]+s$", v.destroy_scheduled_duration)) &&
      tonumber(trimsuffix(v.destroy_scheduled_duration, "s")) >= 86400 &&
      tonumber(trimsuffix(v.destroy_scheduled_duration, "s")) <= 10368000
    ])
    error_message = "Each key's destroy_scheduled_duration must be a duration in seconds between 1 day (86400s) and 120 days (10368000s)"
  }

  validation {
    condition     = alltrue([for k, v in var.crypto_keys : contains(["SOFTWARE", "HSM"], v.protection_level)])
    error_message = "Each key's protection_level must be SOFTWARE or HSM"
  }

  validation {
    condition     = alltrue([for k, v in var.crypto_keys : contains(["GOOGLE_SYMMETRIC_ENCRYPTION"], v.algorithm)])
    error_message = "Each key's algorithm must be GOOGLE_SYMMETRIC_ENCRYPTION — the module creates rotatable ENCRYPT_DECRYPT keys only (asymmetric keys cannot auto-rotate)"
  }

  validation {
    condition = alltrue([
      for k, v in var.crypto_keys : alltrue([for lk, lv in v.labels : can(regex("^[a-z][a-z0-9_-]{0,62}$", lk)) && can(regex("^[a-z0-9_-]{0,63}$", lv))])
    ])
    error_message = "Each key's labels must follow GCP label constraints (lowercase alphanumerics, underscores or hyphens, keys starting with a letter, 1-63 characters)"
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.crypto_keys : [
        for m in concat(v.encrypters, v.decrypters) : length(trimspace(m)) > 0 && !contains(["allUsers", "allAuthenticatedUsers"], m)
      ]
    ]))
    error_message = "Key encrypters/decrypters must be non-empty IAM members and must not be allUsers or allAuthenticatedUsers"
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.crypto_keys : [
        for m in concat(v.encrypters, v.decrypters) : can(regex("^(user|serviceAccount|group|domain|principal|principalSet):.+", m))
      ]
    ]))
    error_message = "Key encrypters/decrypters must be IAM member strings such as serviceAccount:x@y.iam.gserviceaccount.com or group:team@example.com"
  }
}

variable "import_job" {
  type = object({
    import_job_id    = string
    import_method    = optional(string, "RSA_OAEP_4096_SHA256_AES_256")
    protection_level = optional(string, "HSM")
  })
  description = "Optional key-ring import job for bringing externally generated key material into Cloud KMS. Leave null to skip"
  default     = null

  validation {
    condition     = var.import_job == null || can(regex("^[a-zA-Z0-9_-]{1,63}$", var.import_job.import_job_id))
    error_message = "var.import_job.import_job_id must be 1-63 characters of letters, digits, underscores or hyphens"
  }

  validation {
    condition = var.import_job == null || contains([
      "RSA_OAEP_3072_SHA1_AES_256", "RSA_OAEP_4096_SHA1_AES_256",
      "RSA_OAEP_3072_SHA256_AES_256", "RSA_OAEP_4096_SHA256_AES_256",
      "RSA_OAEP_3072_SHA256", "RSA_OAEP_4096_SHA256",
    ], var.import_job.import_method)
    error_message = "var.import_job.import_method must be one of the RSA_OAEP_* import methods supported by Cloud KMS"
  }

  validation {
    condition     = var.import_job == null || contains(["SOFTWARE", "HSM"], var.import_job.protection_level)
    error_message = "var.import_job.protection_level must be SOFTWARE or HSM"
  }
}

variable "labels" {
  type        = map(string)
  description = "Labels applied to every crypto key, for cost allocation and ownership tracking (merged with per-key labels)"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.labels : can(regex("^[a-z][a-z0-9_-]{0,62}$", k)) && can(regex("^[a-z0-9_-]{0,63}$", v))])
    error_message = "var.labels keys and values must be lowercase alphanumerics, underscores, or hyphens, 1-63 characters, keys starting with a letter (GCP label constraints)"
  }
}
