# Count is used to create resources per item in the vmcount variable

resource "azurerm_public_ip" "publicip" {
    name                         = "${var.computer_name}${1 + count.index}-PublicIP"
    location                     = "${var.location}"
    resource_group_name          = "${var.rg_network}"
    allocation_method            = "Static"
    count                        = "${var.vmcount}"
    domain_name_label            = "${format("%s-${1 + count.index}-%s", lower(var.computer_name), lower(var.dns_prefix))}"

    tags = {
        environment = "network"
    }
}
resource "azurerm_network_security_group" "nsg_rules" {
    name                = "${var.computer_name}${1 + count.index}-NetworkSecurityGroup"
    location            = "${var.location}"
    resource_group_name = "${var.rg_network}"
    count               = "${var.vmcount}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefixes      = ["178.117.158.228","84.193.193.2","178.144.24.242","81.241.96.35","81.245.178.181"] # Use source_address_prefix if you only have one IP
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "HTTP"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefixes      = ["178.117.158.228","84.193.193.2","178.144.24.242","81.241.96.35","81.245.178.181"] # Use source_address_prefix if you only have one IP
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "metasploit"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "4444"
        source_address_prefixes      = ["178.117.158.228","84.193.193.2","178.144.24.242","81.241.96.35","81.245.178.181"] # Use source_address_prefix if you only have one IP
        destination_address_prefix = "*"
    }
    
    tags = {
        environment = "network"
    }
}

resource "azurerm_network_interface" "nic" {
    name = "${var.computer_name}${1 + count.index}-NIC"
    location = "${var.location}"
    resource_group_name = "${var.rg_network}"
    count = "${var.vmcount}"
    ip_configuration {
        name = "ipconfig"
        subnet_id = "${var.subnet_id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "10.0.0.${50 + count.index}"
        public_ip_address_id          = "${element(azurerm_public_ip.publicip.*.id, count.index)}"
    }
}

resource "azurerm_network_interface_security_group_association" "apply_nsg" {
  network_interface_id      = "${element(azurerm_network_interface.nic.*.id,count.index)}"
  network_security_group_id = "${element(azurerm_network_security_group.nsg_rules.*.id,count.index)}"
  count  = "${var.vmcount}"
}

resource "azurerm_virtual_machine" "vm" {
    name = "${var.computer_name}${1 + count.index}"
    location = "${var.location}"
    resource_group_name = "${var.rg_network}"
    network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
    vm_size = "${var.vmsize["medium"]}"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true
    count = "${var.vmcount}"
    depends_on = [azurerm_network_interface_security_group_association.apply_nsg]

    storage_image_reference {
        publisher = "${var.os["publisher"]}"
        offer = "${var.os["offer"]}"
        sku = "${var.os["sku"]}"
        version = "${var.os["version"]}"
    }
    plan {
        publisher = "${var.plan["publisher"]}"
        product = "${var.plan["product"]}"
        name = "${var.plan["name"]}"
    }

    storage_os_disk {
        name = "${var.computer_name}-${1 + count.index}"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name = "${var.computer_name}-${1 + count.index}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
 #       custom_data    = "${data.template_file.data.rendered}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

  
}

data "template_file" "data" {
    template = "${file("${path.module}/files/${var.data}")}"
    vars = {
    }
}