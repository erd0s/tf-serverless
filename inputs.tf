variable "microservice_name" {}

variable "functions" {
  type = list(object({
    name = string
    method = string
    path = string
    handler = string
  }))
}