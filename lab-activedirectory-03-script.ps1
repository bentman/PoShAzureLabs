<#
.SYNOPSIS
    Creates a Spot Windows Server VM in Azure with Active Directory configured.

.DESCRIPTION
    This script creates a Spot Windows Server VM, configures a static IP, and sets up Active Directory. 
    The VM is designed to host Active Directory services for the lab environment.

.PARAMETERS
    No parameters accepted. This script dot-sources the parameters from '01_lab-parameters.ps1' and 'lab-activedirectory-parameters.ps1'.

.EXAMPLE
    .\06_lab-active-directory.ps1
    This example runs the script and prompts for the required credentials to create a Spot Windows Server VM with Active Directory configured.

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

# Dot source parameters files
. .\lab-activedirectory-01-parameters.ps1

try {
    # Prompt for Domain Administrator and Recovery Mode Credentials
    $creds = Get-Credential -Message "Enter the credentials for the Domain Administrator and Recovery Mode"

    # Define the Active Directory settings
    $adSettings = @{
        "Name" = "Active Directory Config"
        "DomainNetbiosName" = $domainNetBIOSName
        "DomainName" = $domainDNSName
        "SafeModeAdministratorPassword" = $creds.GetNetworkCredential().Password
        "Credentials" = @{
            "Username" = $creds.UserName
            "Password" = $creds.GetNetworkCredential().Password
        }
        "RecoveryCredentials" = @{
            "Username" = $creds.UserName
            "Password" = $creds.GetNetworkCredential().Password
        }
    } | ConvertTo-Json

    # Static IP Configuration
    $ipConfig = New-AzNetworkInterfaceIpConfig `
        -Name "$serverName-ip" `
        -SubnetId $vnet.Subnets[0].Id `
        -PrivateIpAddress "$serverIpAddress" `
        -PrivateIpAllocationMethod Static

    # Create NIC with Static IP Configuration
    $nic = New-AzNetworkInterface `
        -Name "$serverName-nic" `
        -ResourceGroupName $lab_ResourceGroupName `
        -Location $lab_Location `
        -IpConfiguration $ipConfig

    # Get VM Image
    $vmImage = Get-AzVMImage `
        -Location $lab_Location `
        -PublisherName $win_VMPublisherName `
        -Offer $osOffer `
        -Skus "$osSku" `
        -Version "$osVersion"

    # Create VM Configuration
    $vmConfig = New-AzVMConfig `
        -VMName $serverName `
        -VMSize $vmSize `
        -Priority Spot `
        -EvictionPolicy Deallocate `
        -MaxPrice -1

    # Set Windows Configuration
    $vmConfig = Set-AzVMOperatingSystem `
        -VM $vmConfig `
        -Windows `
        -ComputerName $serverName `
        -Credential $creds `
        -ProvisionVMAgent `
        -EnableAutoUpdate

    # Set VM Image
    $vmConfig = Set-AzVMSourceImage `
        -VM $vmConfig `
        -Id $vmImage.Id

    # Add NIC to VM Configuration
    $vmConfig = Add-AzVMNetworkInterface `
        -VM $vmConfig `
        -Id $nic.Id

    # Configure Active Directory
    $vmConfig = Set-AzVMExtension `
        -VM $vmConfig `
        -Name "IaaSDomainExtension" `
        -Publisher "Microsoft.Compute" `
        -Type "JsonADDomainExtension" `
        -TypeHandlerVersion "1.3" `
        -AutoUpgradeMinorVersion $true `
        -SettingString $adSettings

    # Create VM
    New-AzVM `
        -ResourceGroupName $lab_ResourceGroupName `
        -Location $lab_Location `
        -VM $vmConfig

} catch {
    Write-Host "An error occurred: $($_.Exception.Message)"
}
