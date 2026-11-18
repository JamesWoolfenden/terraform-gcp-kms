# terraform-gcp-kms

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-kms/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-gcp-kms/actions)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-gcp-kms.svg)](https://github.com/JamesWoolfenden/terraform-gcp-kms/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-kms.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-kms/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for Cloud KMS. Creates a key ring and a map of symmetric `ENCRYPT_DECRYPT` crypto keys for use as CMEK, each with mandatory automatic rotation (at most 90 days), a scheduled-destruction window, a `SOFTWARE` (default) or `HSM` protection level, labels and `prevent_destroy`. Per-key encrypter and decrypter IAM members are granted non-authoritatively (`allUsers`/`allAuthenticatedUsers` are rejected), and an optional key-ring import job can be created for bringing in externally generated key material.

## Usage

Add **module.kms.tf** to your code:-

```terraform
module "kms" {
  source   = "jameswoolfenden/kms/gcp"
  name     = "example-keyring"
  location = "europe-west2"

  crypto_keys = {
    app-data = {
      rotation_period = "7776000s"
      encrypters      = ["serviceAccount:${google_service_account.app.email}"]
      decrypters      = ["serviceAccount:${google_service_account.app.email}"]
    }
  }
}
```

See [example/examplea](example/examplea) for a complete working example.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_kms_crypto_key.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key_iam_binding.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_binding) | resource |
| [google_kms_key_ring.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring) | resource |
| [google_kms_key_ring_import_job.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring_import_job) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_crypto_keys"></a> [crypto\_keys](#input\_crypto\_keys) | Map of symmetric ENCRYPT\_DECRYPT crypto keys to create, keyed by key name. rotation\_period is required (at most 90 days), and encrypters/decrypters are the complete (authoritative) member lists for roles/cloudkms.cryptoKeyEncrypter and roles/cloudkms.cryptoKeyDecrypter on that key | <pre>map(object({<br/>    rotation_period            = string<br/>    destroy_scheduled_duration = optional(string, "2592000s")<br/>    protection_level           = optional(string, "SOFTWARE")<br/>    algorithm                  = optional(string, "GOOGLE_SYMMETRIC_ENCRYPTION")<br/>    labels                     = optional(map(string), {})<br/>    encrypters                 = optional(list(string), [])<br/>    decrypters                 = optional(list(string), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_import_job"></a> [import\_job](#input\_import\_job) | Optional key-ring import job for bringing externally generated key material into Cloud KMS. Leave null to skip | <pre>object({<br/>    import_job_id    = string<br/>    import_method    = optional(string, "RSA_OAEP_4096_SHA256_AES_256")<br/>    protection_level = optional(string, "HSM")<br/>  })</pre> | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels applied to every crypto key, for cost allocation and ownership tracking (merged with per-key labels) | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of the key ring, e.g. europe-west2, europe or global. Must match the location of the resources that use the keys | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the KMS key ring | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_crypto_key_ids"></a> [crypto\_key\_ids](#output\_crypto\_key\_ids) | Map of crypto key name to crypto key ID, for use as CMEK key references |
| <a name="output_import_job_id"></a> [import\_job\_id](#output\_import\_job\_id) | ID of the key ring import job, or null when no import job was requested |
| <a name="output_key_ring_id"></a> [key\_ring\_id](#output\_key\_ring\_id) | ID of the KMS key ring |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Role and Permissions

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "cloudkms.cryptoKeyVersions.destroy",
    "cloudkms.cryptoKeyVersions.list",
    "cloudkms.cryptoKeys.create",
    "cloudkms.cryptoKeys.get",
    "cloudkms.cryptoKeys.getIamPolicy",
    "cloudkms.cryptoKeys.setIamPolicy",
    "cloudkms.cryptoKeys.update",
    "cloudkms.importJobs.create",
    "cloudkms.importJobs.get",
    "cloudkms.keyRings.create",
    "cloudkms.keyRings.get"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "cloudkms.cryptoKeyVersions.list",
    "cloudkms.cryptoKeys.get",
    "cloudkms.cryptoKeys.getIamPolicy",
    "cloudkms.importJobs.get",
    "cloudkms.keyRings.get"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Help

**Got a question?**

File a GitHub [issue](https://github.com/jameswoolfenden/terraform-gcp-kms/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/jameswoolfenden/terraform-gcp-kms/issues) to report any bugs or file feature requests.

## Copyrights

Copyright © 2026 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
