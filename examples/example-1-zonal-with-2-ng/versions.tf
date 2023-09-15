terraform {
  required_version = ">= 1.0.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "> 0.8"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "> 3.3"
    }
  }
}

provider "yandex" {
  #endpoint = "api.nemax.nebius.cloud:443"
  endpoint = "api.il.nebius.cloud:443"
  folder_id = "b486jia0s4d3r67rcjfa"
  token = "t1.9euZz8eQm8jGm8yTyMyXj8mLk8vHiu3rmc_HmZ6dk47JmMqcls6JkYyWlIvl8_d5R29X-e8yN3VE_d3z9zl2bFf57zI3dUT9zef165nPx43NiZOSycucy5qalY6LycaQ7_zF65nPx43NiZOSycucy5qalY6LycaQveuZz8eUyZWcjpOKnJiUnI3KlZmOy7XrhpzRlp6S0ZCPmpGWm9KMmo2Jmo0.5oAQu0AlEvRy4igT019y3J2qmwhw1vbwK1NCeEdYDX9GjRniD6MRU2DNetV7faX3M-qsDlR7vku9cV74PtH3CA"
}


provider "local" {}

provider "random" {}
