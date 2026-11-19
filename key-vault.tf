
# --------------------------------------------------
# KEY VAULT - CURRENT AZURE CLIENT
# --------------------------------------------------

data "azurerm_client_config" "current" {}

# --------------------------------------------------
# KEY VAULT - SECURE SECRETS STORE
# --------------------------------------------------

resource "azurerm_key_vault" "nova" {
  name                = "nova-retail-kv-2026"
  location            = azurerm_resource_group.nova.location
  resource_group_name = azurerm_resource_group.nova.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  # Use Azure RBAC for access management
  rbac_authorization_enabled = true

  # Disable public network access
  public_network_access_enabled = false

  # Enable data recovery protection
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    Component   = "Security"
    ManagedBy   = "Terraform"
  }
}



# --------------------------------------------------
# KEY VAULT - PRIVATE DNS ZONE
# --------------------------------------------------

resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.nova.name

  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    Component   = "Security"
    ManagedBy   = "Terraform"
  }
}

# --------------------------------------------------
# KEY VAULT - PRIVATE DNS VNET LINK
# --------------------------------------------------

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "nova-retail-keyvault-dns-link"
  resource_group_name   = azurerm_resource_group.nova.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = azurerm_virtual_network.nova.id

  registration_enabled = false
}



# --------------------------------------------------
# KEY VAULT - PRIVATE ENDPOINT
# --------------------------------------------------

resource "azurerm_private_endpoint" "key_vault" {
  name                = "nova-retail-keyvault-pe"
  location            = azurerm_resource_group.nova.location
  resource_group_name = azurerm_resource_group.nova.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "nova-retail-keyvault-connection"
    private_connection_resource_id = azurerm_key_vault.nova.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "keyvault-dns-zone-group"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.key_vault.id
    ]
  }

  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    Component   = "Security"
    ManagedBy   = "Terraform"
  }
}



# --------------------------------------------------
# KEY VAULT - BACKEND MANAGED IDENTITY ACCESS
# --------------------------------------------------

resource "azurerm_role_assignment" "backend_key_vault_secrets" {
  scope                = azurerm_key_vault.nova.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.backend.identity[0].principal_id
}

