
# --------------------------------------------------
# FRONTEND - PRIVATE ENDPOINT
# --------------------------------------------------

resource "azurerm_private_endpoint" "frontend" {
  name                = "nova-retail-frontend-pe"
  location            = azurerm_resource_group.nova.location
  resource_group_name = azurerm_resource_group.nova.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "nova-retail-frontend-connection"
    private_connection_resource_id = azurerm_linux_web_app.frontend.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "frontend-dns-zone-group"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.app_service.id
    ]
  }

  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    Component   = "Frontend"
    ManagedBy   = "Terraform"
  }
}



# --------------------------------------------------
# APP SERVICE - PRIVATE DNS ZONE
# --------------------------------------------------

resource "azurerm_private_dns_zone" "app_service" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.nova.name

  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

# --------------------------------------------------
# APP SERVICE - PRIVATE DNS VNET LINK
# --------------------------------------------------

resource "azurerm_private_dns_zone_virtual_network_link" "app_service" {
  name                  = "nova-retail-appservice-dns-link"
  resource_group_name   = azurerm_resource_group.nova.name
  private_dns_zone_name = azurerm_private_dns_zone.app_service.name
  virtual_network_id    = azurerm_virtual_network.nova.id

  registration_enabled = false
}



# --------------------------------------------------
# BACKEND - PRIVATE ENDPOINT
# --------------------------------------------------

resource "azurerm_private_endpoint" "backend" {
  name                = "nova-retail-backend-pe"
  location            = azurerm_resource_group.nova.location
  resource_group_name = azurerm_resource_group.nova.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "nova-retail-backend-connection"
    private_connection_resource_id = azurerm_linux_web_app.backend.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "backend-dns-zone-group"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.app_service.id
    ]
  }

  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    Component   = "Backend"
    ManagedBy   = "Terraform"
  }
}
