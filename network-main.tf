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
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

############################################################
#CREATING PUBLIC SUBNET PLUS VM

#creating the subnet in the network
resource "azurerm_subnet" "subnetPublic" {
  name = "netPublic"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  virtual_network_name = azurerm_virtual_network.virtualNetwork.name
  address_prefixes = [ "10.0.2.0/24" ]
  #azurerm_public_ip = true
}
#creating a security group for the subnet
resource "azurerm_subnet_network_security_group_association" "securitySubnetPublic" {
  subnet_id                 = azurerm_subnet.subnetPublic.id
  network_security_group_id = azurerm_network_security_group.securityNetwork.id
}

#Creating a public ip
resource "azurerm_public_ip" "publicIp" {
  name                    = "ipPublic"
  location                = azurerm_resource_group.resourceGroup.location
  resource_group_name     = azurerm_resource_group.resourceGroup.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

}

#Creating an interface for the VM
resource "azurerm_network_interface" "networkInterfacePublic" {
  name                = "networkInterface"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetPublic.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.5"
    public_ip_address_id          = azurerm_public_ip.publicIp.id
  }
}

#Creating the VM
resource "azurerm_virtual_machine" "virtualMachinePublic" {
  name                  = "example-vm"
  location              = azurerm_resource_group.resourceGroup.location
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  network_interface_ids = [azurerm_network_interface.networkInterfacePublic.id]
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


############################################################
############################################################
#CREATING PRIVATE SUBNET PLUS VM

#creating the subnet in the network
resource "azurerm_subnet" "subnetPrivate" {
  name = "netPrivate"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  virtual_network_name = azurerm_virtual_network.virtualNetwork.name
  address_prefixes = [ "10.0.2.0/24" ]
  #azurerm_public_ip = true
}

#create securiry group private
resource "azurerm_network_security_group" "securityPrivate" {
  name                = "securityPrivate"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  security_rule {
    name                       = "private"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
#creating a security group for the subnet
resource "azurerm_subnet_network_security_group_association" "securitySubnetPrivate" {
  subnet_id                 = azurerm_subnet.subnetPrivate.id
  network_security_group_id = azurerm_network_security_group.securityPrivate.id
}

#Creating a public ip
resource "azurerm_public_ip" "privateIp" {
  name                    = "ipPrivate"
  location                = azurerm_resource_group.resourceGroup.location
  resource_group_name     = azurerm_resource_group.resourceGroup.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

}

#Creating an interface for the VM
resource "azurerm_network_interface" "networkInterfacePrivate" {
  name                = "networkInterfacePrivate"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetPrivate.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.6"
    public_ip_address_id          = azurerm_public_ip.privateIp.id
  }
}

#Creating the VM
resource "azurerm_virtual_machine" "virtualMachinePrivate" {
  name                  = "private-vm"
  location              = azurerm_resource_group.resourceGroup.location
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  network_interface_ids = [azurerm_network_interface.networkInterfacePrivate.id]
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
