<#
.SYNOPSIS
    Creates an Azure virtual network with a configured subnet to host jumpbox VMs.

.DESCRIPTION
    Sets up the virtual network, subnet configurations, and network security group rules. 
    The subnet is designed to host jumpbox VMs that provide connectivity to labs in other adjacent subnets.

.PARAMETERS
    No parameters accepted. This script dot-sources the parameters from '01_jumpbox-parameters.ps1'.

.EXAMPLE
    .\02_jumpbox-network.ps1

.NOTES
    Requires Azure PowerShell module and user must be logged into their Azure account.
    Ensure you have the correct permissions on your Azure account to perform these operations.
    Please note that creating or managing resources in Azure may incur costs.
#>

# Dot source parameters file
. .\01_jumpbox-parameters.ps1

# Create Public IP Address
$pip = New-AzPublicIpAddress `
    -ResourceGroupName $vResourceGroupName `
    -Location $vLocation `
    -Name "$vNetPipName" `
    -AllocationMethod Dynamic `
    -Verbose

# Create Virtual Network
$vnet = New-AzVirtualNetwork `
    -ResourceGroupName $vResourceGroupName `
    -Location $vLocation `
    -Name $vNetName `
    -AddressPrefix $vNetPrefix `
    -Verbose

# Create NAT Gateway
$natGateway = New-AzNatGateway `
    -ResourceGroupName $vResourceGroupName `
    -Location $vLocation `
    -Name "$vNetNatName" `
    -PublicIpAddress $pip `
    -Verbose

# Create Subnet Configuration with NAT Gateway
$subnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name $jumpbox_VSubnetName `
    -AddressPrefix $jumpbox_SubnetPrefix `
    -Verbose

# Associate NAT Gateway with Subnet
$subnetConfig.NatGateway = $natGateway

# Network Security Group Rules
$nsgRules = @()

# Rule for RDP
$rdpRule = New-AzNetworkSecurityRuleConfig `
    -Name NSGRule-RDP `
    -Description "Allow RDP" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 100 `
    -SourceAddressPrefix Internet `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 3389 `
    -Verbose
$nsgRules += $rdpRule

# Rule for SSH
$sshRule = New-AzNetworkSecurityRuleConfig `
    -Name NSGRule-SSH `
    -Description "Allow SSH" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 200 `
    -SourceAddressPrefix Internet `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 22 `
    -Verbose
$nsgRules += $sshRule

# Rule for HTTP
$httpRule = New-AzNetworkSecurityRuleConfig `
    -Name NSGRule-HTTP `
    -Description "Allow HTTP" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 300 `
    -SourceAddressPrefix Internet `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 80 `
    -Verbose
$nsgRules += $httpRule

# Rule for HTTPS
$httpsRule = New-AzNetworkSecurityRuleConfig `
    -Name NSGRule-HTTPS `
    -Description "Allow HTTPS" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 400 `
    -SourceAddressPrefix Internet `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 443 `
    -Verbose
$nsgRules += $httpsRule

# Create Network Security Group
$nsg = New-AzNetworkSecurityGroup `
    -ResourceGroupName $vResourceGroupName `
    -Location $vLocation `
    -Name "$vNetName-nsg" `
    -SecurityRules $nsgRules `
    -Verbose

# Associate NSG to Subnet
Set-AzVirtualNetworkSubnetConfig `
    -VirtualNetwork $vnet `
    -Name $jumpbox_VSubnetName `
    -AddressPrefix $jumpbox_SubnetPrefix `
    -NetworkSecurityGroup $nsg `
    -Verbose

# Apply the changes to the Virtual Network
Set-AzVirtualNetwork -VirtualNetwork $vnet -Verbose