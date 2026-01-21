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
  count = 3

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
    endpoint = local.api_endpoint
    timeout = local.timeout_seconds
    retries = local.max_retries
    debug_enabled = local.feature_flags.enable_debug
    cache_enabled = local.feature_flags.use_cache
    worker_count = local.environment_config.dev.workers
    log_level = local.environment_config.dev.log_level
    tags = {
      component = "bufo-printer"
      version = "1.0.0"
      pet_name = var.pet
    }
    metadata = {
      created_by = "terraform"
      timestamp = "2026-01-21"
      instance_count = var.instances
    }
  }
}

output "ids" {
  value = [for n in null_resource.this : n.id]
}
