data "azuread_users" "users" {
  count      = var.entra_ssh_enabled ? 1 : 0
  return_all = true # returning all for this exercise
}

resource "azuread_group" "vm_ssh_login" {
  count            = var.entra_ssh_enabled ? 1 : 0
  display_name     = "vm_ssh_login"
  security_enabled = true
}

resource "azuread_group_member" "vm_ssh_login_member" {
  for_each         = var.entra_ssh_enabled ? toset(data.azuread_users.users.0.object_ids) : toset([])
  group_object_id  = azuread_group.vm_ssh_login.0.object_id
  member_object_id = each.value
}

resource "azurerm_role_assignment" "vm_user_login" {
  count                = var.entra_ssh_enabled ? 1 : 0
  principal_id         = azuread_group.vm_ssh_login.0.object_id
  role_definition_name = "Virtual Machine User Login"
  scope                = azurerm_resource_group.az_resource_group.id
}
