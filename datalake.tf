provider "azurerm" {
   features {}
  subscription_id   = "d115ca25-a8e8-4afd-960b-135f53fcd450"
  tenant_id         = "d1bd4750-0901-4d48-a8a0-bf61cbbd3a99"
  client_id         = "c7b7fe63-197b-488f-b59c-bc8c9e819811"
  client_secret     = "etL8Q~NWIjIR7u2d7mBkdtUMfkeqeHx1gKCu4dki"
}

resource "azurerm_resource_group" "example" {
  name     = "pocdatalakestorageAZscripts"
  location = "East US"  # Change to your desired region
}

resource "azurerm_storage_account" "example" {
  name                     = "datalakestorageAZscripts"  # Change to your desired storage account name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  features {
    hierarchical_namespace = true
  }
}

resource "azurerm_storage_container" "example" {
  name                  = "pocdatalakestoragecontainer"  # Change to your desired container name
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}
