<#
.SYNOPSIS
    Configures the network for the Active Directory lab.

.DESCRIPTION
    Updates the virtual network and subnet configurations, associates a NAT Gateway with the subnet, and sets up Network Security Group rules to allow all traffic from the Jumpbox network.

.PARAMETERS
    No parameters accepted. This script dot-sources the parameters from 'lab-activedirectory-01-parameters.ps1'.

.EXAMPLE
    .\lab-activedirectory-02-network.ps1

.NOTES
    Requires Azure PowerShell module and user must be logged into their Azure account.
    Ensure you have the correct permissions on your Azure account to perform these operations.
    Please note that creating or managing resources in Azure may incur costs.
#>

# Dot source parameters file
. .\lab-activedirectory-01-parameters.ps1

# Optional verbose logging
$VerbosePreference = 'Continue' # Change to 'SilentlyContinue' to disable verbose logging

# Validate parameters
if (-not ($lab_SubnetPrefix -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}$')) {
    Write-Error "Invalid subnet prefix: $lab_SubnetPrefix"
    return
}

# Get Virtual Network
try {
    $vnet = Get-AzVirtualNetwork -ResourceGroupName $lab_ResourceGroupName -Name $lab_VNetName
} catch {
    Write-Error "Failed to retrieve virtual network: $($_.Exception.Message). `nPlease make sure the previous scripts were run successfully."
    return
}

# Create or update subnet
$subnetConfig = $vnet.Subnets | Where-Object { $_.Name -eq $lab_SubnetName }
if ($null -eq $subnetConfig) {
    Write-Error "Subnet $lab_SubnetName does not exist. `nPlease make sure the previous scripts were run successfully."
    return
} else {
    $subnetConfig.AddressPrefix = $lab_SubnetPrefix
}

# Get NAT Gateway
try {
    $natGateway = Get-AzNatGateway -ResourceGroupName $vResourceGroupName -Name "$vNetNatName"
} catch {
    Write-Error "Failed to retrieve NAT Gateway: $($_.Exception.Message). `nPlease make sure the previous scripts were run successfully."
    return
}

# Associate NAT Gateway with Subnet
$subnetConfig.NatGateway = $natGateway

# Create or update NSG rules
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $lab_ResourceGroupName -Name "$lab_VNetName-nsg"
if ($null -eq $nsg) {
    $nsg = New-AzNetworkSecurityGroup -ResourceGroupName $lab_ResourceGroupName -Location $lab_Location -Name "$lab_VNetName-nsg"
}
$nsgRule = $nsg.SecurityRules | Where-Object { $_.Name -eq 'NSGRule-AllTraffic' }
if ($null -eq $nsgRule) {
    $nsgRule = New-AzNetworkSecurityRuleConfig `
        -Name 'NSGRule-AllTraffic' `
        -Description "Allow all traffic from Jumpbox Network" `
        -Access Allow -Protocol * `
        -Direction Inbound `
        -Priority 100 `
        -SourceAddressPrefix "$jumpbox_SubnetPrefix" `
        -SourcePortRange * `
        -DestinationAddressPrefix * `
        -DestinationPortRange *
    $nsg.SecurityRules.Add($nsgRule)
}

# Associate NSG to Subnet
$subnetConfig.NetworkSecurityGroup = $nsg

# Apply the changes to the Virtual Network
try {
    Set-AzVirtualNetwork -VirtualNetwork $vnet
} catch {
    Write-Error "Failed to update virtual network: $($_.Exception.Message)"
    return
}
