<#
.SYNOPSIS
    Sets parameters required for the Active Directory lab environment.

.DESCRIPTION
    This script sets the necessary parameters for creating an Active Directory environment in Azure. 
    It dot-sources '01_lab-parameters.ps1' to inherit previously set parameters and then sets additional parameters specific to the Active Directory setup.

.PARAMETERS
    No parameters accepted. This script dot-sources the parameters from '01_lab-parameters.ps1' and sets additional parameters for Active Directory.

.EXAMPLE
    .\lab-activedirectory-01-parameters.ps1
    This example runs the script and sets the parameters required for the Active Directory environment.

.NOTES
    Ensure '01_lab-parameters.ps1' has been executed prior to this script to ensure all necessary parameters are available.
    Variables set in this script will be available in the current PowerShell session and can be used by other scripts that are run in the same session.

.NOTES
    Version: 2.0
    Creation Date: 2023-05-15
    Copyright (c) 2023 https://github.com/bentman
    https://github.com/bentman/PoShAzureLabs
#>

# Dot source parameters file
. .\01_jumpbox-parameters.ps1

# Lab Network parameters
$lab_Function = "activedirectory"
$lab_Location = "$vLocation"
$lab_ResourceGroupName = "rg-$lab_Location-$lab_Function"
$lab_VNetName  = "$lab_Location-$lab_Function-network"
$lab_VNetPrefix = "10.0.0.0/16"
$lab_VNetDNS = "1.1.1.1"
$lab_SubnetName = "$lab_Location-$lab_Function-subnet"
$lab_SubnetPrefix = "10.0.2.0/24"

# VM Configuration
$vmSize = "Standard_D2s_v3"

# Server OS Configuration
$osOffer = "WindowsServer"
$osSku = "2019-Datacenter"
$osVersion = "latest"

# Server Details
$srv_NamePrefix = "DC"
$srv_NameSuffix = "010"
$srv_IPAddress = "10.0.2.10"
$srv_ComputerName = "$srv_NamePrefix$srv_NameSuffix"
$srv_VMName = "$lab_Location-$lab_Function-$srv_ComputerName-vm"

#### Lab detail parameters
# Active Directory
$domainNetBIOSName = "CONTOSO"
$domainDNSName = "CONTOSO.local"
