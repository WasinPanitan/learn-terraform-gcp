# google cloud storage bucket
resource "google_storage_bucket" "health_check_function_bucket" {
  name  = "${var.project_id}-function"
  location = var.region
}

resource "google_storage_bucket" "health_check_input_bucket" {
  name = "${var.project_id}-input"
  location = var.region
}

# cloud function
data "archive_file" "health_check_source" {
  type = "zip"
  source_dir = "../src/health-check"
  output_path = "/tmp/health-check-function.zip"
}

resource "google_storage_bucket_object" "health_check_zip" {
  source = data.archive_file.health_check_source.output_path
  content_type = "application/zip"

  name = "src-${data.archive_file.health_check_source.output_md5}.zip"
  bucket = google_storage_bucket.health_check_function_bucket.name

  depends_on = [
     google_storage_bucket.health_check_function_bucket,
     data.archive_file.health_check_source
  ]
}

resource "google_cloudfunctions_function" "health_check" {
  name = "function-test-health-check"
  description = "testorino function description"
  runtime = "nodejs16"

  source_archive_bucket = google_storage_bucket.health_check_function_bucket.name
  source_archive_object = google_storage_bucket_object.health_check_zip.name

  entry_point = "healthCheck"
  available_memory_mb = 128
  trigger_http = true
  environment_variables = {
    url = "https://dog.ceo/api/breeds/list/all"
  }

  depends_on = [
    google_storage_bucket.health_check_function_bucket,
    google_storage_bucket_object.health_check_zip
  ]
}

# google cloud iam
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.health_check.project
  region         = google_cloudfunctions_function.health_check.region
  cloud_function = google_cloudfunctions_function.health_check.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
