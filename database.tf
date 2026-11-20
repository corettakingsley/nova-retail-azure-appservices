
# --------------------------------------------------
# MYSQL - PRIVATE DNS ZONE
# --------------------------------------------------

resource "azurerm_private_dns_zone" "mysql" {
  name                = "nova-retail.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.nova.name

  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    Component   = "Database"
    ManagedBy   = "Terraform"
  }
}

# --------------------------------------------------
# MYSQL - PRIVATE DNS VNET LINK
# --------------------------------------------------

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "nova-retail-mysql-dns-link"
  resource_group_name   = azurerm_resource_group.nova.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.nova.id

  registration_enabled = false
}



# --------------------------------------------------
# MYSQL - FLEXIBLE SERVER
# --------------------------------------------------

resource "azurerm_mysql_flexible_server" "nova" {
  name                = "nova-retail-mysql"
  resource_group_name = azurerm_resource_group.nova.name
  location            = azurerm_resource_group.nova.location

  administrator_login    = "novaadmin"
  administrator_password = var.mysql_admin_password

  version                      = "8.0.21"
  sku_name                     = "B_Standard_B1ms"
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  delegated_subnet_id = azurerm_subnet.db.id
  private_dns_zone_id = azurerm_private_dns_zone.mysql.id

  public_network_access = "Disabled"

  storage {
    size_gb = 32
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.mysql
  ]

  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    Component   = "Database"
    ManagedBy   = "Terraform"
  }
}


# --------------------------------------------------
# MYSQL - SLOW QUERY LOGGING
# --------------------------------------------------

resource "azurerm_mysql_flexible_server_configuration" "slow_query_log" {
  name                = "slow_query_log"
  resource_group_name = azurerm_resource_group.nova.name
  server_name         = azurerm_mysql_flexible_server.nova.name
  value               = "ON"
}

resource "azurerm_mysql_flexible_server_configuration" "long_query_time" {
  name                = "long_query_time"
  resource_group_name = azurerm_resource_group.nova.name
  server_name         = azurerm_mysql_flexible_server.nova.name
  value               = "10"
}


# --------------------------------------------------
# MYSQL - AUDIT LOGGING
# --------------------------------------------------

resource "azurerm_mysql_flexible_server_configuration" "audit_log_enabled" {
  name                = "audit_log_enabled"
  resource_group_name = azurerm_resource_group.nova.name
  server_name         = azurerm_mysql_flexible_server.nova.name
  value               = "ON"
}

resource "azurerm_mysql_flexible_server_configuration" "audit_log_events" {
  name                = "audit_log_events"
  resource_group_name = azurerm_resource_group.nova.name
  server_name         = azurerm_mysql_flexible_server.nova.name
  value               = "CONNECTION,ADMIN,DDL"
}

# --------------------------------------------------
# MYSQL - APPLICATION DATABASE
# --------------------------------------------------

resource "azurerm_mysql_flexible_database" "nova" {
  name                = "nova_retail"
  resource_group_name = azurerm_resource_group.nova.name
  server_name         = azurerm_mysql_flexible_server.nova.name

  charset   = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}
