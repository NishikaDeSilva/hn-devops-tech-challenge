resource "random_password" "pass" {
  for_each = toset(var.entra_id_users)
  length   = 12
}

resource "local_sensitive_file" "passwords" {
  for_each = toset(var.entra_id_users)
  content  = "${each.key}=${random_password.pass["${each.key}"].result}"
  filename = "keys/${each.key}/pass.txt"
}

resource "azuread_user" "entra_users" {
  for_each = var.entra_ssh_enabled ? toset(var.entra_id_users) : toset([])

  user_principal_name   = "${each.key}@${local.domain}"
  display_name          = title(each.key)
  password              = random_password.pass["${each.key}"].result
  force_password_change = true
}

resource "azuread_group" "vm_ssh_login" {
  count            = var.entra_ssh_enabled ? 1 : 0
  display_name     = "vm_ssh_login"
  security_enabled = true
}

resource "azuread_group_member" "vm_ssh_login_member" {
  for_each         = var.entra_ssh_enabled ? azuread_user.entra_users : {}
  group_object_id  = azuread_group.vm_ssh_login.0.object_id
  member_object_id = each.value.object_id
}

resource "azurerm_role_assignment" "vm_user_login" {
  count                = var.entra_ssh_enabled ? 1 : 0
  principal_id         = azuread_group.vm_ssh_login.0.object_id
  role_definition_name = "Virtual Machine User Login"
  scope                = azurerm_resource_group.az_resource_group.id

  depends_on = [azuread_group_member.vm_ssh_login_member]
}
