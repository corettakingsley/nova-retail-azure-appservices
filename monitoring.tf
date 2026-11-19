
# --------------------------------------------------
# LOG ANALYTICS WORKSPACE
# --------------------------------------------------

resource "azurerm_log_analytics_workspace" "nova" {
  name                = "nova-retail-log-analytics"
  location            = azurerm_resource_group.nova.location
  resource_group_name = azurerm_resource_group.nova.name

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    Component   = "Monitoring"
    ManagedBy   = "Terraform"
  }
}


# --------------------------------------------------
# APPLICATION INSIGHTS
# --------------------------------------------------

resource "azurerm_application_insights" "nova" {
  name                = "nova-retail-app-insights"
  location            = azurerm_resource_group.nova.location
  resource_group_name = azurerm_resource_group.nova.name

  application_type = "web"
  workspace_id     = azurerm_log_analytics_workspace.nova.id

  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    Component   = "Monitoring"
    ManagedBy   = "Terraform"
  }
}



# --------------------------------------------------
# APPLICATION GATEWAY - DIAGNOSTIC SETTINGS
# --------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "appgw" {
  name                       = "nova-retail-appgw-diagnostics"
  target_resource_id         = azurerm_application_gateway.nova.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.nova.id

  log_analytics_destination_type = "Dedicated"

  # Capture incoming HTTP requests
  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  # Capture WAF security events
  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  # Capture Azure Monitor metrics
  enabled_metric {
    category = "AllMetrics"
  }
}


# --------------------------------------------------
# KEY VAULT - DIAGNOSTIC SETTINGS
# --------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  name                       = "nova-retail-keyvault-diagnostics"
  target_resource_id         = azurerm_key_vault.nova.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.nova.id

  log_analytics_destination_type = "Dedicated"

  # Capture Key Vault audit events
  enabled_log {
    category = "AuditEvent"
  }

  # Capture platform metrics
  enabled_metric {
    category = "AllMetrics"
  }
}



# --------------------------------------------------
# FRONTEND APP SERVICE - DIAGNOSTIC SETTINGS
# --------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "frontend" {
  name                       = "nova-retail-frontend-diagnostics"
  target_resource_id         = azurerm_linux_web_app.frontend.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.nova.id

  log_analytics_destination_type = "Dedicated"

  # Incoming HTTP requests
  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  # Application standard output and errors
  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  # App Service platform activity
  enabled_log {
    category = "AppServicePlatformLogs"
  }

  # Platform metrics
  enabled_metric {
    category = "AllMetrics"
  }
}



# --------------------------------------------------
# BACKEND APP SERVICE - DIAGNOSTIC SETTINGS
# --------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "backend" {
  name                       = "nova-retail-backend-diagnostics"
  target_resource_id         = azurerm_linux_web_app.backend.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.nova.id

  log_analytics_destination_type = "Dedicated"

  # Incoming HTTP requests
  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  # Application standard output and errors
  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  # App Service platform activity
  enabled_log {
    category = "AppServicePlatformLogs"
  }

  # Platform metrics
  enabled_metric {
    category = "AllMetrics"
  }
}



# --------------------------------------------------
# MYSQL - DIAGNOSTIC SETTINGS
# --------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "mysql" {
  name                       = "nova-retail-mysql-diagnostics"
  target_resource_id         = azurerm_mysql_flexible_server.nova.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.nova.id

  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "MySqlAuditLogs"
  }

  enabled_log {
    category = "MySqlSlowLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
