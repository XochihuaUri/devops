#creating a resource group for the network
resource "azurerm_resource_group" "resourceGroup" {
  name = "network-resources"
  location = "East US"
}

# # Create public IPs
# resource "azurerm_public_ip" "my_terraform_public_ip" {
#   name                = "myPublicIP"
#   location            = azurerm_resource_group.groupForNetwork.location
#   resource_group_name = azurerm_resource_group.groupForNetwork.name
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
resource "azurerm_network_interface" "networkInterface" {
  name                = "networkInterface"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}



#creating a security group for the subnet
resource "azurerm_subnet_network_security_group_association" "securitySubnet" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.securityNetwork.id
}