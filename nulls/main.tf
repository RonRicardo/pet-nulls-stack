# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }

    bufo = {
      source  = "austinvalle/bufo"
      version = "2.1.0"
    }
  }
}

variable "pet" {
  type = string
}

variable "instances" {
  type = number
}

resource "null_resource" "this" {
  count = 2

  lifecycle {
    action_trigger {
      events  = [after_create, after_update]
      actions = [action.bufo_print.success]
    }
  }

  triggers = {
    pet = var.pet
  }
}

locals {
  secret_name = sensitive("bufo-the-builder")
  api_endpoint = "https://api.example.com"
  timeout_seconds = 30
  max_retries = 3
  feature_flags = {
    enable_debug = true
    use_cache = false
    experimental_mode = var.instances > 2
  }
  environment_config = {
    dev = {
      log_level = "debug"
      workers = 2
    }
    prod = {
      log_level = "info"
      workers = 10
    }
  }
}

action "bufo_print" "success" {
  config {
    name = local.secret_name
    color = local.feature_flags.enable_debug
  }
}

output "ids" {
  value = [for n in null_resource.this : n.id]
}
