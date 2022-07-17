# cloud function
data "archive_file" "source" {
  type = "zip"
  source_dir = "../src"
  output_path = "/tmp/function.zip"
}

resource "google_storage_bucket_object" "zip" {
  source = data.archive_file.source.output_path
  content_type = "application/zip"

  name = "src-${data.archive_file.source.output_md5}.zip"
  bucket = google_storage_bucket.function_bucket.name

  depends_on = [
     google_storage_bucket.function_bucket,
     data.archive_file.source
  ]
}

resource "google_cloudfunctions_function" "function" {
  name = "function-test-health-check"
  description = "testorino function description"
  runtime = "nodejs16"

  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.zip.name

  entry_point = "healthCheck"
  available_memory_mb = 128
  trigger_http = true
  environment_variables = {
    url = "https://dog.ceo/api/breeds/list/all"
  }

  depends_on = [
    google_storage_bucket.function_bucket,
    google_storage_bucket_object.zip
  ]
}
