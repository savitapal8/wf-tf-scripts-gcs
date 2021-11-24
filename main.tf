provider "google" {
 access_token = var.access_token
 project = "airline1-sabre-wolverine"
}


resource "google_storage_bucket" "GCS" {
  name          = "my-dev-appid-strg-demo9-gcsbucket"
  project       = "airline1-sabre-wolverine"
  location      = "us"  
  force_destroy = true
  versioning {
    enabled = true
  }

  encryption {
      #default_kms_key_name = "projects/airline1-sabre-wolverine/locations/us/keyRings/savita-keyring-us/cryptoKeys/savita-key-us" #google_kms_crypto_key_iam_member.gcs_encryption.id
      default_kms_key_name  = google_kms_crypto_key.secret.id
  }

  lifecycle_rule {
    condition {
      age = 3
     
    }
    action {
      type = "Delete"
    }

  }

 labels = {
    owner = "wf"
    application_division = "pci"
    application_name = ""
    application_role = "auth"
    au = ""
  }
  depends_on = [
      google_kms_crypto_key.secret, google_kms_crypto_key_iam_member.gcs_encryption
  ]
}

resource "google_kms_crypto_key" "secret" {
 name     = "my-dev-appid-strg-demo9-key"
 labels = {
    owner = "wf"
    application_division = "pci"
    application_name = ""
    application_role = "auth"
    au = ""
  }
 key_ring = "projects/airline1-sabre-wolverine/locations/us/keyRings/savita-keyring-us"
}

data "google_storage_project_service_account" "gcs_account" {
 project =  "airline1-sabre-wolverine"
}

resource "google_kms_crypto_key_iam_member" "gcs_encryption" {
 crypto_key_id = google_kms_crypto_key.secret.id
 role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
 member        = "serviceAccount:service-680501254856@gs-project-accounts.iam.gserviceaccount.com"
 #member        = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}

/*
resource "google_project_organization_policy" "public_access_prevention" {
  project    =  "airline1-sabre-wolverine"
  constraint = "storage.publicAccessPrevention"
  boolean_policy {
    enforced = true
  }
}*/
