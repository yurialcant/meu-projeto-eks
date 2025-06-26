variable "app_name" {
  type    = string
  default = "hello-world-app"
}
variable "app_image_uri" {
  type = string
}
variable "namespace" {
  type    = string
  default = "default"
}
variable "replicas" {
  type    = number
  default = 2
}
variable "container_port" {
  type    = number
  default = 80
}