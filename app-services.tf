
# --------------------------------------------------
# FRONTEND - APP SERVICE PLAN
# --------------------------------------------------

resource "azurerm_service_plan" "frontend" {
  name                = "nova-retail-frontend-plan"
  resource_group_name = azurerm_resource_group.nova.name
  location            = azurerm_resource_group.nova.location

  os_type  = "Linux"
  sku_name = "B1"

  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    Component   = "Frontend"
    ManagedBy   = "Terraform"
  }
}

# --------------------------------------------------
# FRONTEND - LINUX WEB APP
# --------------------------------------------------

resource "azurerm_linux_web_app" "frontend" {
  name                = "nova-retail-frontend"
  resource_group_name = azurerm_resource_group.nova.name
  location            = azurerm_service_plan.frontend.location
  service_plan_id     = azurerm_service_plan.frontend.id
  identity {
    type = "SystemAssigned"
  }



  https_only                    = true
  public_network_access_enabled = false

  site_config {
    always_on = false

    app_command_line = "pm2 serve /home/site/wwwroot 8080 --spa --no-daemon"

    application_stack {
      node_version = "22-lts"
    }
  }

  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    Component   = "Frontend"
    ManagedBy   = "Terraform"
  }
}

# --------------------------------------------------
# BACKEND - APP SERVICE PLAN
# --------------------------------------------------

resource "azurerm_service_plan" "backend" {
  name                = "nova-retail-backend-plan"
  resource_group_name = azurerm_resource_group.nova.name
  location            = azurerm_resource_group.nova.location

  os_type  = "Linux"
  sku_name = "B1"

  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    Component   = "Backend"
    ManagedBy   = "Terraform"
  }
}

# --------------------------------------------------
# BACKEND - LINUX WEB APP
# --------------------------------------------------

resource "azurerm_linux_web_app" "backend" {
  name                = "nova-retail-backend"
  resource_group_name = azurerm_resource_group.nova.name
  location            = azurerm_service_plan.backend.location
  service_plan_id     = azurerm_service_plan.backend.id
  identity {
    type = "SystemAssigned"
  }

  virtual_network_subnet_id = azurerm_subnet.app_integration.id

  https_only                    = true
  public_network_access_enabled = false

  site_config {
    always_on = false

    app_command_line = "python -m uvicorn app.main:app --host 0.0.0.0 --port 8000"

    application_stack {
      python_version = "3.12"
    }
  }
  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    Component   = "Backend"
    ManagedBy   = "Terraform"
  }
}
