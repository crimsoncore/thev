resource "azurerm_public_ip" "W2K19_publicip" {
    name                         = "${var.computer_name_Windows}-PublicIP"
    location                     = "${var.location}"
    resource_group_name          = "${var.rg_network}"
    allocation_method            = "Dynamic"
    domain_name_label            = "${format("%s-%s", lower(var.computer_name_Windows), lower(var.dns_prefix))}"

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_security_group" "nsg_rules" {
    name                = "${var.computer_name_Windows}-NetworkSecurityGroup"
    location            = "${var.location}"
    resource_group_name = "${var.rg_network}"
    
    security_rule {
        name                       = "WINRM-HTTPS"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5986"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
/*
    security_rule {
        name                       = "RDP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "WINRM-HTTP"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5985"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
*/
}

resource "azurerm_network_interface" "windows_nic" {
    name = "${var.computer_name_Windows}-NIC"
    location = "${var.location}"
    resource_group_name = "${var.rg_network}"
    ip_configuration {
        name = "ipconfig"
        subnet_id = "${var.subnet_id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "${var.private_ip_address}"
        public_ip_address_id          = "${azurerm_public_ip.W2K19_publicip.id}"
    }
}
resource "azurerm_network_interface_security_group_association" "apply_nsg" {
  network_interface_id      = azurerm_network_interface.windows_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_rules.id
}
resource "azurerm_virtual_machine" "windows_dc" {
    name = "${var.computer_name_Windows}"
    location = "${var.location}"
    resource_group_name = "${var.rg_network}"
    network_interface_ids = ["${azurerm_network_interface.windows_nic.id}"]
    vm_size = "${var.vmsize["medium"]}"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true
    depends_on = [azurerm_network_interface_security_group_association.apply_nsg]

    storage_image_reference {
        publisher = "${var.os_ms["publisher"]}"
        offer = "${var.os_ms["offer"]}"
        sku = "${var.os_ms["sku"]}"
        version = "${var.os_ms["version"]}"
    }

    storage_os_disk {
        name = "${var.computer_name_Windows}-OS"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name = "${var.computer_name_Windows}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
        custom_data    = "${file("${path.module}/files/winrm.ps1")}"
    }

    os_profile_windows_config {
        provision_vm_agent = "true"
        enable_automatic_upgrades = false
        timezone = "Romance Standard Time"
#        winrm {
#            protocol = "http"
#        }

        additional_unattend_config {
        pass         = "oobeSystem"
        component    = "Microsoft-Windows-Shell-Setup"
        setting_name = "AutoLogon"
        content      = "<AutoLogon><Password><Value>${var.admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.admin_username}</Username></AutoLogon>"
        }

    # Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
        additional_unattend_config {
        pass         = "oobeSystem"
        component    = "Microsoft-Windows-Shell-Setup"
        setting_name = "FirstLogonCommands"
        content      = "${file("${path.module}/files/FirstLogonCommands.xml")}"
        }   
    }

}

output "computer_name_Windows" {
    value = "${azurerm_virtual_machine.windows_dc.name}"
}