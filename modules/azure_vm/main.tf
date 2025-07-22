resource "azurerm_public_ip" "az_pip" {
  count               = var.enable_public_access ? 1 : 0
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"

  tags = var.tags
}


resource "azurerm_network_interface" "az_nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet_id
    public_ip_address_id          = var.enable_public_access ? azurerm_public_ip.az_pip.0.id : null
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "az_linux_vm" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.vm_admin_user

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = var.vm_admin_user
    public_key = var.rsa_public_key
  }

  network_interface_ids = [
    azurerm_network_interface.az_nic.id
  ]

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = var.tags
}

# Inbound/Outbount traffic control for VM
resource "azurerm_network_security_group" "az_linux_vm_ngs" {
  name                = "${var.vm_name}-nic-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "22"
    direction                  = "Inbound"
    name                       = "AllowCidrBlockSSHInbound"
    priority                   = 100
    protocol                   = "Tcp"
    source_address_prefixes    = var.nsg_source_address_prefix
    source_port_range          = "*"
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "vm_nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.az_nic.id
  network_security_group_id = azurerm_network_security_group.az_linux_vm_ngs.id
}
