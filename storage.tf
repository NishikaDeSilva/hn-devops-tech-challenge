resource "azurerm_storage_account" "az_storage" {
  name                     = module.naming.storage_account.name
  resource_group_name      = azurerm_resource_group.az_resource_group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.az_pvt_subnet.id]
    bypass                     = ["AzureServices"]
  }

  tags = local.tags
}

resource "azurerm_management_lock" "az_storage_lock" {
  name       = "storage-delete-lock"
  lock_level = "CanNotDelete"
  scope      = azurerm_storage_account.az_storage.id
}

resource "azurerm_storage_encryption_scope" "az_storage_encryption" {
  name               = "microsoftmanaged"
  storage_account_id = azurerm_storage_account.az_storage.id
  source             = "Microsoft.Storage"
}

resource "azurerm_storage_share" "az_storage_share" {
  name               = "local"
  storage_account_id = azurerm_storage_account.az_storage.id
  quota              = 1
}

resource "azurerm_storage_management_policy" "az_storage_mgmt_policy" {
  storage_account_id = azurerm_storage_account.az_storage.id
  rule {
    name    = "blobDeletePolicy"
    enabled = true

    filters {
      blob_types = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_archive_after_days_since_modification_greater_than = 7
        delete_after_days_since_modification_greater_than          = 365
      }
    }
  }
}

