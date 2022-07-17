# google cloud storage bucket
resource "google_storage_bucket" "hello_world_function_bucket" {
  name  = "${var.project_id}-hello-world-function"
  location = var.region
}

resource "google_storage_bucket" "hello_world_input_bucket" {
  name = "${var.project_id}-hello-world-input"
  location = var.region
}

#cloud function
data "archive_file" "hello_world_source" {
  type = "zip"
  source_dir = "../src/hello-world"
  output_path = "/tmp/hell-world-function.zip"
}

resource "google_storage_bucket_object" "hello_world_zip" {
  source = data.archive_file.hello_world_source.output_path
  content_type = "application/zip"

  name = "src-${data.archive_file.hello_world_source.output_md5}.zip"
  bucket = google_storage_bucket.hello_world_function_bucket.name

  depends_on = [
    google_storage_bucket.hello_world_function_bucket,
    data.archive_file.hello_world_source
  ]
}

resource "google_cloudfunctions_function" "hello_world" {
  name = "function-test-hello-world"
  description = "testorino hello world"
  runtime = "nodejs16"

  source_archive_bucket = google_storage_bucket.hello_world_function_bucket.name
  source_archive_object = google_storage_bucket_object.hello_world_zip.name

  entry_point = "helloWorld"
  available_memory_mb = 128
  trigger_http = true

  depends_on = [
    google_storage_bucket.hello_world_function_bucket,
    google_storage_bucket_object.hello_world_zip
  ]
}

resource "google_cloudfunctions_function_iam_member" "hello_world_invoker" {
  project        = google_cloudfunctions_function.hello_world.project
  region         = google_cloudfunctions_function.hello_world.region
  cloud_function = google_cloudfunctions_function.hello_world.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}