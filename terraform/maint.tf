// Create Resource Group

resource "azurerm_resource_group" "rg_network" {
    name = "${var.rg_network}"
    location = "${var.location}"
}

// Create Network

module "create_network" {
    source = "./modules/1-network"
    location = "${azurerm_resource_group.rg_network.location}"
    rg_network = "${azurerm_resource_group.rg_network.name}"
}

// Create Windows VM DomainController

module "windows_vm_dc" {
    source = "./modules/2-windows_dc"
    computer_name_Windows = "${var.computer_name_Windows_DC}"
    rg_network = "${azurerm_resource_group.rg_network.name}"
    subnet_id = "${module.create_network.mgmt_sub_id}"
    location = "${azurerm_resource_group.rg_network.location}"
    vmsize = "${var.vmsize}"
    os_ms = "${var.os_ms_server2019}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
    active_directory_domain = "${var.active_directory_domain}"
    active_directory_netbios_name = "${var.active_directory_netbios_name}"
    private_ip_address = "${var.ip_address-DC01}"
    dns_prefix = "${var.dns_prefix}"
}

