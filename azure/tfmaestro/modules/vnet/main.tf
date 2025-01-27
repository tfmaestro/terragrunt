resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name}-vnet"
  address_space       = var.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_subnet" "private_subnet" {
  for_each             = var.private_subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]

  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet" "public_subnet" {
  for_each             = var.public_subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]

  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet" "public_database_subnet" {
  for_each             = var.public_database_subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]

  delegation {
    name = "mysql-delegation"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }

  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_nat_gateway" "prod_nat_gateway" {
  name                = "${var.name}-nat-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    environment = "prod"
  }
}

resource "azurerm_subnet_nat_gateway_association" "private_subnet_nat_association" {
  for_each      = azurerm_subnet.private_subnet
  subnet_id     = each.value.id
  nat_gateway_id = azurerm_nat_gateway.prod_nat_gateway.id
}

resource "azurerm_route_table" "prod_route_table" {
  for_each            = var.private_subnets
  name                = "${each.key}-route-table"
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name               = "internet-route"
    address_prefix     = "0.0.0.0/0"
    next_hop_type      = "VirtualAppliance"
    next_hop_in_ip_address = cidrhost(each.value.address_prefix, 1)
  }

  tags = {
    environment = "prod"
  }

  depends_on = [azurerm_nat_gateway.prod_nat_gateway]
}

resource "azurerm_subnet_route_table_association" "private_subnet_association" {
  for_each      = azurerm_subnet.private_subnet
  subnet_id     = each.value.id
  route_table_id = azurerm_route_table.prod_route_table[each.key].id
}
