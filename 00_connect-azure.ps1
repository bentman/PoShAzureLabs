<#
.SYNOPSIS
    Script ensures Azure CLI is installed and prompts the user to connect to Azure.
.DESCRIPTION
    Checks for Azure CLI, verifies internet connection, downloads and installs Azure CLI if needed. 
    Validates the installation, checks and adjusts trust level of PowerShell Gallery if necessary. 
    Prompts for Azure login.
.EXAMPLE
    .\00_connect-azure.ps1
.NOTES
    Requires internet access. 
    May modify PowerShell Gallery installation policy and install Azure CLI.
.NOTES
    Version: 2.0
    Creation Date: 2023-05-15
    Copyright (c) 2023 https://github.com/bentman
    https://github.com/bentman/PoShAzureLabs
#>

# Define Azure CLI download URL
$AzureCliInstallerUrl = "https://aka.ms/installazurecliwindows"

# Check if Azure CLI is installed
if (!(Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "`nAzure CLI is not installed. Installing now..."
    # Check internet connection before downloading
    try {
        $internetTest = Test-NetConnection -ComputerName www.microsoft.com -InformationLevel Quiet
        if (!$internetTest) {
            Write-Host "`nNo internet connection. Can't download Azure CLI."
            Exit
        }
    } catch {
        Write-Host "`nFailed to check internet connection."
        Exit
    }
    # Download the installer
    try {
        Start-BitsTransfer -Source $AzureCliInstallerUrl -Destination .\AzureCLI.msi
    } catch {
        Write-Host "`nFailed to download Azure CLI."
        Exit
    }
    # Install Azure CLI
    try {
        Start-Process msiexec.exe -Wait -ArgumentList "/I .\AzureCLI.msi /quiet"
    } catch {
        Write-Host "`nFailed to install Azure CLI."
        Exit
    }
    # Remove the installer if it exists
    if (Test-Path .\AzureCLI.msi) {
        Remove-Item -Path .\AzureCLI.msi
    }

    # Check if Azure CLI is now installed
    if (!(Get-Command az -ErrorAction SilentlyContinue)) {
        Write-Host "`nAzure CLI installation failed. Attempting to install from PowerShell Gallery..."
        # Check if PowerShell Gallery is trusted
        if ((Get-PSRepository -Name "PSGallery").InstallationPolicy -ne "Trusted") {
            Write-Host "`nPowerShell Gallery is not trusted. You may need to trust it to install modules from it."
            # Ask user for confirmation
            $userConfirmation = Read-Host "`nDo you want to trust PowerShell Gallery? (y/n)"
            if ($userConfirmation -eq "y") {
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
            } else {
                Write-Host "`nCannot install Azure CLI without trusting PowerShell Gallery."
                Exit
            }
        }
        # Install Azure CLI from PowerShell Gallery
        Install-Module -Name Az -AllowClobber -Scope CurrentUser
    }

    # Validate Azure CLI installation
    try {
        az --version | Out-Null
        Write-Host "`nAzure CLI is installed successfully."
    } catch {
        Write-Host "`nFailed to verify Azure CLI installation."
        Exit
    }
} else {
    Write-Host "`nAzure CLI is already installed."
}

# Prompt user to connect to Azure
Write-Host "`nPlease log in to your Azure account."
az login
