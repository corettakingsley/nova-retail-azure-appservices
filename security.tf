
# --------------------------------------------------
# APPLICATION GATEWAY - NETWORK SECURITY GROUP
# --------------------------------------------------

resource "azurerm_network_security_group" "appgw" {
  name                = "nova-retail-appgw-nsg"
  location            = azurerm_resource_group.nova.location
  resource_group_name = azurerm_resource_group.nova.name

  # Allow Azure Application Gateway management traffic
  security_rule {
    name                       = "Allow-GatewayManager"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  # Allow public HTTP traffic
  security_rule {
    name                       = "Allow-HTTP-Internet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    Component   = "ApplicationGateway"
    ManagedBy   = "Terraform"
  }
}

# --------------------------------------------------
# APPLICATION GATEWAY - NSG SUBNET ASSOCIATION
# --------------------------------------------------

resource "azurerm_subnet_network_security_group_association" "appgw" {
  subnet_id                 = azurerm_subnet.appgw.id
  network_security_group_id = azurerm_network_security_group.appgw.id
}
