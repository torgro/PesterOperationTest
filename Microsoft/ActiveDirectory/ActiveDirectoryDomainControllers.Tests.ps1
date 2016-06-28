#Requires -RunAsAdministrator
#Requires -Modules ActiveDirectory
#Requires -Modules Pester
#Requires -Version 4.0

<#
.Synopsis
   Operation validation tests (Pester) for Active Directory domain controllers
.DESCRIPTION
   The tests needs adminitrative privileges to run. All domain controllers
   need to be configured with PowerShell remoting enabled.
   The Active Directory PowerShell module is used to discover the domain controllers is the current domain.
   In it`s current state it supports only a single domain Active Directory forest, but it shouldn`t be much effort needed to discover domain controllers in other domains as well.
.EXAMPLE
   Invoke-Pester
   
   This will invoke the tests if it is located in the current folder or a subfolder it the test file follow the namingstandard of Pester. The FileName should contain Tests.ps1
   .EXAMPLE
   Invoke-Pester -Script .\Microsoft\ActiveDirectory\ActiveDirectoryDomainControllers.Tests.ps1
.OUTPUTS
   It outputs to the console or to standard output if PassThru parameter is used
.NOTES
   Use at your own risk
.COMPONENT
   Operation validation tests
.FUNCTIONALITY
   Operation validation tests
#>

Describe "Simple Validation of Active Directory domain controllers" {
    $DomainControllers = (Get-ADDomain).ReplicaDirectoryServers

    foreach ($ComputerName in $DomainControllers) {

      $Session = New-PSSession -ComputerName $ComputerName

      It "The Active Directory Web Services service on $ComputerName should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name ADWS}).status |
        Should be 'Running'
      }

      It "The DNS Server service on $ComputerName should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name DNS}).status  |
        Should be 'Running'
      }

      It "The DFS Namespace service on $ComputerName should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name Dfs}).status  |
        Should be 'Running'
      }

      It "The DFS Replication service on $ComputerName should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name DFSR}).status  |
        Should be 'Running'
      }

      It "The Kerberos Key Distribution Center service on $ComputerName should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name Kdc}).status  |
        Should be 'Running'
      }

      It "The Netlogon service on $ComputerName should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name Netlogon}).status  |
        Should be 'Running'
      }

      It "The Active Directory Domain Services service on $ComputerName should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name NTDS}).status  |
        Should be 'Running'
      }

      It "$ComputerName should be listening on LDAP port 389" {
        Test-NetConnection -ComputerName $ComputerName -Port 389 -InformationLevel Quiet |
        Should be $true
      }
      
      It "$ComputerName should be listening on Global Catalog port 3268" {
        Test-NetConnection -ComputerName $ComputerName -Port 3268 -InformationLevel Quiet |
        Should be $true
      }

      It "$ComputerName should be listening on DNS port 53" {
        Test-NetConnection -ComputerName $ComputerName -Port 53 -InformationLevel Quiet |
        Should be $true
      }

      Remove-PSSession -Session $Session

    }
}