# todo
 terraform {
  backend "azurerm" {
    resource_group_name  = "deployment"
    storage_account_name = "bhasai01dl9"
    container_name       = "terraform"
    key                  = "terraform-k8s-v1/terraform.tfstate"
  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.0"
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