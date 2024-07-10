terraform {
  backend "azurerm" {
    resource_group_name  = "deployment"
    storage_account_name = "bhasaideploymentstorage"
    container_name       = "terraform"
    key                  = "bhasai/live/dev-k8s"
  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion = true #todo
    }
  }
}