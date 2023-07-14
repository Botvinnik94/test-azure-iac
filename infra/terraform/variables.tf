variable "resource_group_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "storage_container_name" {
  type = string
}

variable "storage_account_replication" {
  default = "LRS"
  type    = string
}

variable "storage_account_tier" {
  default = "Standard"
  type    = string
}

variable "service_plan_name" {
  type = string
}

variable "service_plan_sku" {
  type = string
}

variable "function_app_name" {
  type = string
}

variable "function_app_always_on" {
  type = bool
  default = false
}