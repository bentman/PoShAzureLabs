<#
.SYNOPSIS
    Defines parameters for managing Azure lab jumpbox resources.
.DESCRIPTION
    Sets up parameters specific to the lab jumpbox, including resource group, virtual network, subnet, and VM details. 
    These parameters are dot-sourced by other scripts to manage the Azure lab jumpbox.
.EXAMPLE
    .\01_jumpbox-parameters.ps1
.NOTES
    Running this script alone won't have any effect. It's meant to be dot-sourced by other scripts.
    Ensure that the parameters defined in this script align with your Azure account and desired infrastructure configuration.
    Please note that creating or managing resources in Azure may incur costs.
.NOTES
    Version: 2.0
    Creation Date: 2023-05-15
    Copyright (c) 2023 https://github.com/bentman
    https://github.com/bentman/PoShAzureLabs
#>

# Virtual Lab Network parameters
$vFunction = "lab"
$vLocation = "southcentralus"
$vResourceGroupName = "rg-$vLocation-$vFunction"
$vNetName  = "$vLocation-$vFunction-network"
$vNetPipName = "$vNetName-pip"
$vNetNatName = "$vNetName-natgw"
$vNetPrefix = "10.0.0.0/16"
$vNetDNS = "1.1.1.1"

# Jumpbox Network parameters
$jumpbox_Function = "jumpbox"
$jumpbox_VSubnetName = "$vLocation-$jumpbox_Function-subnet"
$jumpbox_SubnetPrefix = "10.0.1.0/24"

# Windows VM Jumpbox parameters
$win_VMNamePrefix = "tacocat"
$win_VMNameSuffix = "007"
$win_VMIPAddress = "10.0.1.7"
$win_VMComputerName = "$win_VMNamePrefix$win_VMNameSuffix"
$win_VMName = "$vLocation-$jumpbox_Function-$win_VMComputerName-vm"
$win_VMSize = "Standard_D2s_v3"
$win_VMPublisherName = "MicrosoftWindowsDesktop"
$win_VMOffer = "Windows-11"
$win_VMSkus = "win11-22h2-pro"
$win_VMVersion = "latest"

# Linux VM Jumpbox parameters
$lin_VMNamePrefix = "tacocat"
$lin_VMNameSuffix = "008"
$lin_VMIPAddress = "10.0.1.8"
$lin_VMComputerName = "$lin_VMNamePrefix$lin_VMNameSuffix"
$lin_VMName = "$vLocation-$jumpbox_Function-$lin_VMComputerName-vm"
$lin_VMSize = "Standard_D2s_v3"
$lin_VMPublisherName = "Canonical"
$lin_VMOffer = "Ubuntu"
$lin_VMSkus = "22_04-lts"
$lin_VMVersion = "latest"
