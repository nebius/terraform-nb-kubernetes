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
  endpoint = "api.nemax.nebius.cloud:443"
  folder_id = "bjer0eu4okh6vntopouq"
  token = "t1.9euamseVjJKNnZzKi5GLjJabm8fNle3rmprHlYySjZ2cyp3Li5iNmsqSjYzl8_dRJ3RX-e9eUkcL_d3z9xFWcVf5715SRwv9zef165qax5WMko2dnMrJy86Jk4yZxo_G7_zF65qax5WMko2dnMrJy86Jk4yZxo_GveuamseVjJKNnZzKk46JnJCPm8jPlbXrhpzRlp6S0ZCPmpGWm9KMmo2Jmo0.UT1rdTMCTAhp1dJ_XXKrBWwvt-Q3Fk4O8fjxaPNNB8zY59j97EQkXVeCY7Vfbz-4SO90cSuRb3ad5K8ZHMaZDw"
}


provider "local" {}

provider "random" {}
