<#
.SYNOPSIS
    Creates an Azure Windows jumpbox VM in the specified virtual network.

.DESCRIPTION
    Sources parameters from '01_jumpbox-parameters.ps1', creates a public IP address and a Network Interface Card (NIC) for the VM.
    Retrieves the specified VM image and sets up the VM configuration, including Windows settings and auto-shutdown.
    Finally, it creates the VM in the Azure.

.PARAMETERS
    No parameters accepted. This script dot-sources the parameters from '01_jumpbox-parameters.ps1'.

.EXAMPLE
    .\03_vm-jumpwin.ps1

.NOTES
    Requires Azure PowerShell module and user must be logged into their Azure account.
    Ensure you have the correct permissions on your Azure account to perform these operations.
    Please note that creating or managing resources in Azure may incur costs.

.NOTES
    Version: 2.0
    Creation Date: 2023-05-15
    Copyright (c) 2023 https://github.com/bentman
    https://github.com/bentman/PoShAzureLabs
#>

# Dot source parameters file
. .\01_jumpbox-parameters.ps1

# Create a Public IP address
$publicIP = New-AzPublicIpAddress `
    -Name "$win_VMName-pip" `
    -ResourceGroupName $vResourceGroupName `
    -Location $vLocation `
    -AllocationMethod Dynamic `
    -DomainNameLabel $win_VMComputerName `
    -Verbose

# Create a NIC
$nic = New-AzNetworkInterface `
    -Name "$win_VMComputerName-nic" `
    -ResourceGroupName $vResourceGroupName `
    -Location $vLocation `
    -SubnetId $vnet.Subnets[0].Id `
    -PublicIpAddressId $publicIP.Id `
    -PrivateIpAddress $win_VMIPAddress `
    -NetworkSecurityGroupId $nsg.Id `
    -Verbose

# Get VM Image
$vmImage = Get-AzVMImage `
    -Location $vLocation `
    -PublisherName $win_VMPublisherName `
    -Offer $win_VMOffer `
    -Skus $win_VMSkus `
    -Version $win_VMVersion `
    -Verbose

# Create VM Configuration
$vmConfig = New-AzVMConfig `
    -VMName $win_VMName `
    -VMSize $win_VMSize `
    -Verbose

# Set Windows Configuration
$vmConfig = Set-AzVMOperatingSystem `
    -VM $vmConfig `
    -Windows `
    -ComputerName $win_VMComputerName `
    -Credential $win_Creds `
    -ProvisionVMAgent `
    -EnableAutoUpdate `
    -Verbose

# Set VM Image
$vmConfig = Set-AzVMSourceImage `
    -VM $vmConfig `
    -Id $vmImage.Id `
    -Verbose

# Add NIC to VM Configuration
$vmConfig = Add-AzVMNetworkInterface `
    -VM $vmConfig `
    -Id $nic.Id `
    -Verbose

# Set auto-shutdown time zone
$AutoShutdownTZ = (Get-AzLocation | Where-Object {$_.DisplayName -eq $vLocation}).TimeZoneId

if ($AutoShutdownTZ) {
    # Auto-shutdown configuration
    $vmConfig = Set-AzVMScheduledAutoShutdown `
        -VM $vmConfig `
        -TimeZoneId "$AutoShutdownTZ" `
        -AutoShutdownTime "22:00" `
        -Verbose
}

# Create VM
New-AzVM `
    -ResourceGroupName $vResourceGroupName `
    -Location $vLocation `
    -VM $vmConfig `
    -Verbose
