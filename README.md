# Azure Lab Automation Scripts

This repository contains a set of PowerShell scripts designed to automate the creation and management of lab environments in Microsoft Azure. These scripts can create both Windows and Linux VMs and configure them with various services, including an Active Directory server.

The scripts included in this repository are:

1. `00_connect-azure.ps1`: Establishes a connection to your Azure account.
2. `01_jumpbox-parameters.ps1`: Sets up the parameters for creating a jump box VM in Azure.
3. `02_jumpbox-network.ps1`: Creates a virtual network and a security group for the jump box VM.
4. `03_jumpwin-vm.ps1`: Creates a Windows jump box VM.
5. `04_jumplin-vm.ps1`: Creates a Linux jump box VM.
6. `lab-activedirectory-01-parameters.ps1`: Sets up the parameters for creating an Active Directory server.
7. `lab-activedirectory-02-network.ps1`: Creates a virtual network and a security group for the Active Directory server.
8. `lab-activedirectory-03-script.ps1`: Creates an Active Directory server and configures it.

## Getting Started

To use these scripts, you must have the Azure PowerShell module installed and be logged into your Azure account. 

To run the scripts, navigate to the directory containing the scripts and run them in the order listed above. Parameters can be modified in the parameter scripts to suit your needs.

## License

This project is licensed under the terms of the GNU General Public License v3.0.

## Contributions

Contributions are welcome. Please open an issue or submit a pull request.
