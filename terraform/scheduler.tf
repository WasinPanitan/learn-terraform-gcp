resource "google_cloud_scheduler_job" "job" {
  name = "health-check"
  description = "health-check http caller"
  schedule = "*/5 * * * *"
  time_zone = "America/New_York"
  attempt_deadline = "320s"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri = google_cloudfunctions_function.health_check.https_trigger_url 
  }
}