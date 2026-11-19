
# --------------------------------------------------
# Resource Group
# --------------------------------------------------

resource "azurerm_resource_group" "nova" {
  name     = "nova-retail-rg"
  location = "South Africa North"
}

# --------------------------------------------------
# Virtual Network
# --------------------------------------------------

resource "azurerm_virtual_network" "nova" {
  name                = "nova-retail-vnet"
  address_space       = ["10.30.0.0/16"]
  location            = azurerm_resource_group.nova.location
  resource_group_name = azurerm_resource_group.nova.name
}

# --------------------------------------------------
# Subnet 1 - Application Gateway
# --------------------------------------------------

resource "azurerm_subnet" "appgw" {
  name                 = "snet-appgw"
  resource_group_name  = azurerm_resource_group.nova.name
  virtual_network_name = azurerm_virtual_network.nova.name
  address_prefixes     = ["10.30.1.0/24"]
}

# --------------------------------------------------
# Subnet 2 - Backend App Service VNet Integration
# --------------------------------------------------

resource "azurerm_subnet" "app_integration" {
  name                 = "snet-appsvc-integration"
  resource_group_name  = azurerm_resource_group.nova.name
  virtual_network_name = azurerm_virtual_network.nova.name
  address_prefixes     = ["10.30.10.0/24"]

  delegation {
    name = "app-service-delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

# --------------------------------------------------
# Subnet 3 - MySQL Flexible Server
# --------------------------------------------------

resource "azurerm_subnet" "db" {
  name                 = "snet-mysql-delegated"
  resource_group_name  = azurerm_resource_group.nova.name
  virtual_network_name = azurerm_virtual_network.nova.name
  address_prefixes     = ["10.30.20.0/24"]

  delegation {
    name = "mysql-flexible-server-delegation"

    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# --------------------------------------------------
# Subnet 4 - Private Endpoints
# --------------------------------------------------

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.nova.name
  virtual_network_name = azurerm_virtual_network.nova.name
  address_prefixes     = ["10.30.30.0/24"]

  private_endpoint_network_policies = "Disabled"
}
