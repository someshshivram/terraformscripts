provider "azurerm" {
  features {}
  subscription_id   = "d115ca25-a8e8-4afd-960b-135f53fcd450"
  tenant_id         = "d1bd4750-0901-4d48-a8a0-bf61cbbd3a99"
  client_id         = "c7b7fe63-197b-488f-b59c-bc8c9e819811"
  client_secret     = "etL8Q~NWIjIR7u2d7mBkdtUMfkeqeHx1gKCu4dki"
}
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.26"
    }
	databricks = {
      source = "databricks/databricks"
    }
  }
}

resource "azurerm_resource_group" "data_platform" {
  name = "data_platform"
  location = "westus2"
}

resource "azurerm_storage_account" "data_lake" {
  name = "datalake"
  location = azurerm_resource_group.data_platform.location
  resource_group_name = azurerm_resource_group.data_platform.name
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "data_lake_filesystem" {
  name = "datalakefilesystem"
  storage_account_id = azurerm_storage_account.data_lake.id
}

resource "azurerm_data_factory" "data_factory" {
  name = "datafactory"
  location = azurerm_resource_group.data_platform.location
  resource_group_name = azurerm_resource_group.data_platform.name
}

resource "azurerm_databricks_workspace" "databricks_workspace" {
  name = "databricks_workspace"
  resource_group_name = azurerm_resource_group.data_platform.name
  location = azurerm_resource_group.data_platform.location
  sku = "standard"
}
# Use the latest Databricks Runtime
# Long Term Support (LTS) version.
data "databricks_spark_version" "latest_lts" {
  long_term_support = true
  depends_on = [azurerm_databricks_workspace.databricks_workspace]
}
data "databricks_node_type" "smallest" {
  local_disk = true
}
resource "databricks_cluster" "databricks_cluster" {
  cluster_name = "databricks_cluster"
  spark_version = data.databricks_spark_version.latest_lts.id
  //workspace_resource_id = azurerm_databricks_workspace.databricks_workspace.id
  node_type_id = data.databricks_node_type.smallest.id
  autoscale {
    min_workers = 1
    max_workers = 3
  }
}

output "data_lake_account_name" {
  value = azurerm_storage_account.data_lake.name
}

output "data_lake_filesystem_name" {
  value = azurerm_storage_data_lake_gen2_filesystem.data_lake_filesystem.name
}

output "data_factory_name" {
  value = azurerm_data_factory.data_factory.name
}

output "databricks_workspace_name" {
  value = azurerm_databricks_workspace.databricks_workspace.name
}

output "databricks_cluster_name" {
  value = databricks_cluster.databricks_cluster.cluster_name
}