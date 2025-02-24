# Infrastructure variables
variable "dns_prefix" {
    description = "used to create dns prefix"
}

variable "location" {
    description = "Location where to deploy resources"
}

variable "rg_network" {
    description = "Name of the Resource Group where resources will be deployed"
}

variable "computer_name" {
    description = "Name of the computer"
}

variable "subnet_id" {
    description = "Subnet Id where to join the VM"
}

variable "admin_username" {
    description = "The username associated with the local administrator account on the virtual machine"
}

variable "admin_password" {
    description = "The password associated with the local administrator account on the virtual machine"
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

variable "vmcount" {}

# Azure OS definition variables
variable "os" {
    description = "kali OS"
    type = map(string)
    default = {
        publisher = "kali-linux"
        offer = "kali"
        sku = "kali-2023-2"
        version = "2023.2.0"
    }
}
variable "plan" {
    description = "kali OS plan"
    type = map(string)
    default = {
        publisher = "kali-linux"
        product   = "kali"
        name      = "kali-2023-2"
    }
}

variable "data"{
    description = "The location of the config-init file"
}

variable "private_ip_address" {
    description = "The private ip address of the vm"
}