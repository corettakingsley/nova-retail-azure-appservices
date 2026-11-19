
# --------------------------------------------------
# APPLICATION GATEWAY - PUBLIC IP
# --------------------------------------------------

resource "azurerm_public_ip" "appgw" {
  name                = "nova-retail-appgw-pip"
  resource_group_name = azurerm_resource_group.nova.name
  location            = azurerm_resource_group.nova.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    Component   = "ApplicationGateway"
    ManagedBy   = "Terraform"
  }
}

# --------------------------------------------------
# APPLICATION GATEWAY - WAF V2
# --------------------------------------------------

resource "azurerm_application_gateway" "nova" {
  name                = "nova-retail-appgw"
  resource_group_name = azurerm_resource_group.nova.name
  location            = azurerm_resource_group.nova.location

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 2
  }

  gateway_ip_configuration {
    name      = "nova-gateway-ip-configuration"
    subnet_id = azurerm_subnet.appgw.id
  }

  # --------------------------------------------------
  # FRONTEND LISTENER - HTTP
  # --------------------------------------------------

  frontend_port {
    name = "nova-http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "nova-public-frontend"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  # --------------------------------------------------
  # FRONTEND BACKEND POOL
  # --------------------------------------------------

  backend_address_pool {
    name = "nova-frontend-pool"

    fqdns = [
      "${azurerm_linux_web_app.frontend.name}.azurewebsites.net"
    ]
  }

  # --------------------------------------------------
  # API BACKEND POOL
  # --------------------------------------------------

  backend_address_pool {
    name = "nova-backend-pool"

    fqdns = [
      "${azurerm_linux_web_app.backend.name}.azurewebsites.net"
    ]
  }

  # --------------------------------------------------
  # FRONTEND - HTTPS SETTINGS
  # --------------------------------------------------

  backend_http_settings {
    name                                = "nova-frontend-https-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true
    probe_name                          = "nova-frontend-probe"
  }

  # --------------------------------------------------
  # BACKEND - HTTPS SETTINGS
  # --------------------------------------------------

  backend_http_settings {
    name                                = "nova-backend-https-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true
    probe_name                          = "nova-backend-probe"
  }

  # --------------------------------------------------
  # FRONTEND HEALTH PROBE
  # --------------------------------------------------

  probe {
    name                                      = "nova-frontend-probe"
    protocol                                  = "Https"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true

    match {
      status_code = ["200-399"]
    }
  }

  # --------------------------------------------------
  # BACKEND HEALTH PROBE
  # --------------------------------------------------

  probe {
    name                                      = "nova-backend-probe"
    protocol                                  = "Https"
    path                                      = "/docs"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true

    match {
      status_code = ["200-399"]
    }
  }

  # --------------------------------------------------
  # HTTP LISTENER
  # --------------------------------------------------

  http_listener {
    name                           = "nova-http-listener"
    frontend_ip_configuration_name = "nova-public-frontend"
    frontend_port_name             = "nova-http-port"
    protocol                       = "Http"
  }

  # --------------------------------------------------
  # PATH-BASED ROUTING
  # --------------------------------------------------

  url_path_map {
    name                               = "nova-path-routing"
    default_backend_address_pool_name  = "nova-frontend-pool"
    default_backend_http_settings_name = "nova-frontend-https-settings"

    path_rule {
      name                       = "nova-api-path"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "nova-backend-pool"
      backend_http_settings_name = "nova-backend-https-settings"
    }
  }

  request_routing_rule {
    name               = "nova-path-routing-rule"
    priority           = 100
    rule_type          = "PathBasedRouting"
    http_listener_name = "nova-http-listener"
    url_path_map_name  = "nova-path-routing"
  }

  # --------------------------------------------------
  # WEB APPLICATION FIREWALL
  # --------------------------------------------------

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

  tags = {
    Project     = "Nova-Retail"
    Environment = "Development"
    Component   = "ApplicationGateway"
    ManagedBy   = "Terraform"
  }
}
