# NOTE! 

Building cloud labs with PowerShell has many advantages over manual "point-click-next-next-create" steps in web portals.

## BUT ... Infrastructure as Code (IaC) is even better - and even easier!

- [Join the Learning Adventure here...](https://github.com/bentman/TerraformAzure)

## Azure Lab Automation PowerShell Scripts

This repository contains a set of PowerShell scripts designed to automate the creation and management of lab environments in Microsoft Azure. These scripts can create both Windows and Linux VMs and configure them with various services, including an Active Directory server.

The scripts included in this repository are:

1. `00_connect-azure.ps1`: Establishes a connection to your Azure account.
2. `01_jumpbox-parameters.ps1`: Sets up the parameters for creating a jumpbox VM's in Azure.
3. `02_jumpbox-network.ps1`: Creates a virtual network and a security group for the jumpbox VM's.
4. `03_jumpwin-vm.ps1`: Creates a Windows jumpbox VM.
5. `04_jumplin-vm.ps1`: Creates a Linux jumpbox VM.
6. `lab-activedirectory-01-parameters.ps1`: Sets up the parameters for creating an Active Directory lab.
7. `lab-activedirectory-02-network.ps1`: Creates a virtual network and a security group for the Active Directory lab.
8. `lab-activedirectory-03-script.ps1`: Creates an Active Directory server and configures it.

## Getting Started

To use these scripts, you must have the Azure PowerShell module installed and be logged into your Azure account. 

To run the scripts, navigate to the directory containing the scripts and run them in the order listed above. 
Parameters can be modified in the parameter scripts to suit your needs.

## Contributions

Contributions are welcome. Please open an issue or submit a pull request.

### GNU General Public License
This script is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This script is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this script.  If not, see <https://www.gnu.org/licenses/>.
