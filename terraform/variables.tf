# variables
variable "project_id" {
  default = "learn-terraform-355707"
}

variable "region" {
  default = "asia-southeast1"
}

variable "zone" {
  default = "asia-southeast1-c"
}

variable "health_check_url" {
  type = string
  default = "https://dog.ceo/api/breeds/list/all"
}
