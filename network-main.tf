#creating a resource group for the network
resource "azurerm_resource_group" "resourceGroup" {
  name = "network-resources"
  location = "East US"
}

# # Create public IPs
# resource "azurerm_public_ip" "my_terraform_public_ip" {
#   name                = "myPublicIP"
#   location            = azurerm_resource_group.resourceGroup.location
#   resource_group_name = azurerm_resource_group.resourceGroup.name
#   allocation_method   = "Dynamic"
# }

#creating the virtual network in the resource group
resource "azurerm_virtual_network" "virtualNetwork" {
  name = "network-resources"
  address_space = [ "10.0.0.0/16" ]
  location = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name
}

#Creating a security group for the network
resource "azurerm_network_security_group" "securityNetwork" {
  name                = "securityGroupNetwork"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  security_rule {
    name                       = "test"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#creating the subnet in the network
resource "azurerm_subnet" "subnet" {
  name = "front"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  virtual_network_name = azurerm_virtual_network.virtualNetwork.name
  address_prefixes = [ "10.0.2.0/24" ]
  #azurerm_public_ip = true
}
#creating a security group for the subnet
resource "azurerm_subnet_network_security_group_association" "securitySubnet" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.securityNetwork.id
}

#
resource "azurerm_public_ip" "publicIp" {
  name                    = "ipPublic"
  location                = azurerm_resource_group.resourceGroup.location
  resource_group_name     = azurerm_resource_group.resourceGroup.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

}

resource "azurerm_network_interface" "networkInterface" {
  name                = "networkInterface"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.5"
    public_ip_address_id          = azurerm_public_ip.publicIp.id
  }
}

resource "azurerm_virtual_machine" "virtualMachine" {
  name                  = "example-vm"
  location              = azurerm_resource_group.resourceGroup.location
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  network_interface_ids = [azurerm_network_interface.networkInterface.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "admin"
    admin_password = "1234"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}