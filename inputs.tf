variable "microservice_name" {}
variable "source_dir" {}

variable "functions" {
  type = list(object({
    name = string
    method = string
    path = string
    handler = string
  }))
}