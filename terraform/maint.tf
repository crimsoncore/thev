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

///////////////////////////////
// Main vm's for infrastructure
///////////////////////////////

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

// Create Ubuntu VM with Traefik, Guacamole, Portainer, Elastik+Kibana

module "ubuntu_traefik_vm" {
    source = "./modules/3-ubuntu_vm"
    computer_name_Ubuntu = "${var.computer_name_Ubuntu-MQ}"
    rg_network = "${azurerm_resource_group.rg_network.name}"
    subnet_id = "${module.create_network.mgmt_sub_id}"
    location = "${azurerm_resource_group.rg_network.location}"
    vmsize = "${var.vmsize}"
    os_ubuntu = "${var.os_ubuntu_1804}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
    data_Ubuntu = "${var.data_Ubuntu-MQ}"
    private_ip_address = "${var.ip_address-MQ}"
    dns_prefix = "${var.dns_prefix}"
}

///////////////////////////////
// Main vm's for infrastructure
///////////////////////////////

// Create windows clients for students (with counter)

module "windows_vm_client" {
    source = "./modules/4-windows_vm"
    computer_name_Windows = "${var.computer_name_Windows10}"
    rg_network = "${azurerm_resource_group.rg_network.name}"
    subnet_id = "${module.create_network.mgmt_sub_id}"
    location = "${var.location}"
    vmsize = "${var.vmsize}"
    os_ms = "${var.os_ms_windows10}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
    active_directory_domain = "${var.active_directory_domain}"
    active_directory_username = "${var.admin_username}"
    active_directory_password = "${var.admin_password}"
    dns_prefix = "${var.dns_prefix}"
    vmcount = "${var.w10_vmcount}"
}

// Create KALI VM for students (with Counter)

module "kali_vm" {
    source = "./modules/6-kali_vm"
    computer_name = "${var.computer_name_kali}"
    rg_network = "${azurerm_resource_group.rg_network.name}"
    subnet_id = "${module.create_network.mgmt_sub_id}"
    location = "${azurerm_resource_group.rg_network.location}"
    vmsize = "${var.vmsize}"
    os = "${var.os_kali}"
    plan = "${var.plan_kali}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
    data = "${var.data_kali}"
    private_ip_address = "${var.ip_address_kali}"
    dns_prefix = "${var.dns_prefix}"
    vmcount = "${var.kali_vmcount}"
}