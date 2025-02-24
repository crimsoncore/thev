variable "dns_prefix" {
    description = "used to create dns prefix"
}

variable "location" {
    description = "Location where to deploy resources"
}

variable "rg_network" {
    description = "Name of the Resource Group where resources will be deployed"
}

variable "computer_name_Windows" {
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

variable "os_ms" {
    description = "Microsoft Windows 10"
    type = map(string)
    default = {
        publisher = "MicrosoftWindowsDesktop"
        offer = "Windows-10"
        sku = "rs5-enterprise"
        version = "latest"
    }
}

variable "active_directory_domain" {
  description = "The name of the Active Directory domain, for example `consoto.local`"
}

variable "active_directory_username"{}
variable "active_directory_password"{}

variable "vmcount" {}

variable tf_depends_on {
    type = list(string)
    default = []
}

