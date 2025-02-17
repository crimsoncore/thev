# Infrastructure variables
variable "dns_prefix" {
    description = "used to create dns prefix"
}
variable "location" {
    default = "westeurope"
}
variable "admin_username" {
    default = "thadmin"
}
variable "admin_password" {
    default = "Password1234!"
}
variable "rg_network" {
    default = "TH-network"
}
variable "vmsize" {
    description = "VM Size for the Production Environment"
    type = map(string)
    default = {
        small = "Standard_DS1_v2"
        medium = "Standard_D2s_v3"
        large = "Standard_D4s_v3"
        extralarge = "Standard_D8s_v3"
    }
}
variable "w10_vmcount" {
    default = 0
}
variable "kali_vmcount" {
    default = 0
}

# Azure OS definition variables
variable "os_ms_server2019" {
    description = "Operating System for Database (MSSQL) on the Production Environment"
    type = map(string)
    default = {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2019-Datacenter"
        version = "17763.1457.2009030514"
    }
}

# Active directory variables
variable "active_directory_domain" {
  default = "acme.local"
}
variable "active_directory_netbios_name" {
  default = "acme"
}

# DC machine variables
variable "computer_name_Windows_DC" {
    default = "DC01"
}
variable "ip_address-DC01"{
    default = "10.0.0.4"
}
