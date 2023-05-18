<#
.SYNOPSIS
    Creates an Azure Linux jumpbox VM in the specified virtual network.

.DESCRIPTION
    Sources parameters from '01_jumpbox-parameters.ps1', creates a public IP address and a Network Interface Card (NIC) for the VM.
    Retrieves the specified VM image and sets up the VM configuration, including Linux settings and auto-shutdown.
    Finally, it creates the VM in the Azure.

.PARAMETERS
    No parameters accepted. This script dot-sources the parameters from '01_jumpbox-parameters.ps1'.

.EXAMPLE
    .\04_jumplin-vm.ps1

.NOTES
    Requires Azure PowerShell module and user must be logged into their Azure account.
    Ensure you have the correct permissions on your Azure account to perform these operations.
    Please note that creating or managing resources in Azure may incur costs.
#>

# Dot source parameters file
. .\01_jumpbox-parameters.ps1

# Create a Public IP address
$publicIP = New-AzPublicIpAddress `
    -Name "$lin_VMName-pip" `
    -ResourceGroupName $vResourceGroupName `
    -Location $vLocation `
    -AllocationMethod Dynamic `
    -DomainNameLabel $lin_VMComputerName `
    -Verbose

# Create a NIC
$nic = New-AzNetworkInterface `
    -Name "$lin_VMComputerName-nic" `
    -ResourceGroupName $vResourceGroupName `
    -Location $vLocation `
    -SubnetId $vnet.Subnets[0].Id `
    -PublicIpAddressId $publicIP.Id `
    -PrivateIpAddress $lin_VMIPAddress `
    -NetworkSecurityGroupId $nsg.Id `
    -Verbose

# Get VM Image
$vmImage = Get-AzVMImage `
    -Location $vLocation `
    -PublisherName $lin_VMPublisherName `
    -Offer $lin_VMOffer `
    -Skus $lin_VMSkus `
    -Version $lin_VMVersion `
    -Verbose

# Create VM Configuration
$vmConfig = New-AzVMConfig `
    -VMName $lin_VMName `
    -VMSize $lin_VMSize `
    -Verbose

# Set Linux Configuration
$vmConfig = Set-AzVMOperatingSystem `
    -VM $vmConfig `
    -Linux `
    -ComputerName $lin_VMComputerName `
    -Credential $lin_Creds `
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
