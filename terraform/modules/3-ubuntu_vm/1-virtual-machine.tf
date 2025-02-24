resource "azurerm_public_ip" "ubuntu_publicip" {
    name                         = "${var.computer_name_Ubuntu}-PublicIP"
    location                     = "${var.location}"
    resource_group_name          = "${var.rg_network}"
    allocation_method            = "Dynamic"
    domain_name_label            = "${format("%s-%s", lower(var.computer_name_Ubuntu), lower(var.dns_prefix))}"

    tags = {
        environment = "TH-network"
    }
}
resource "azurerm_network_security_group" "nsg_rules" {
    name                = "${var.computer_name_Ubuntu}-NetworkSecurityGroup"
    location            = "${var.location}"
    resource_group_name = "${var.rg_network}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "RABBITMQ-FEED"
        priority                   = 1005
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5672"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "HTTPS"
        priority                   = 1006
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "Guacamole-HTTP"
        priority                   = 1007
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "Portainer-MQ"
        priority                   = 1008
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "9000"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "RABBITMQ-MGMT"
        priority                   = 1009
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "15672"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    tags = {
        environment = "TH-network"
    }
}
resource "azurerm_network_interface" "ubuntu_nic" {
    name = "${var.computer_name_Ubuntu}-NIC"
    location = "${var.location}"
    resource_group_name = "${var.rg_network}"
#    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"
    ip_configuration {
        name = "ipconfig"
        subnet_id = "${var.subnet_id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "${var.private_ip_address}"
        public_ip_address_id          = "${azurerm_public_ip.ubuntu_publicip.id}"
    }
}
resource "azurerm_network_interface_security_group_association" "apply_nsg" {
  network_interface_id      = azurerm_network_interface.ubuntu_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_rules.id
}
resource "azurerm_virtual_machine" "ubuntu_vm" {
    name = "${var.computer_name_Ubuntu}"
    location = "${var.location}"
    resource_group_name = "${var.rg_network}"
    network_interface_ids = ["${azurerm_network_interface.ubuntu_nic.id}"]
    vm_size = "${var.vmsize["medium"]}"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true
    depends_on = [azurerm_network_interface_security_group_association.apply_nsg]

    storage_image_reference {
        publisher = "${var.os_ubuntu["publisher"]}"
        offer = "${var.os_ubuntu["offer"]}"
        sku = "${var.os_ubuntu["sku"]}"
        version = "${var.os_ubuntu["version"]}"
    }

    storage_os_disk {
        name = "${var.computer_name_Ubuntu}-OS"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name = "${var.computer_name_Ubuntu}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
#        custom_data    = "${data.template_file.ubuntu_elk_data.rendered}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

}

data "template_file" "ubuntu_elk_data" {
    template = "${file("${path.module}/files/${var.data_Ubuntu}")}"
    vars = {
    }
}
output "computer_name_Ubuntu" {
    value = "${azurerm_virtual_machine.ubuntu_vm.name}"
}