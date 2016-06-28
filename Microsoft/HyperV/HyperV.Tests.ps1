#Requires -RunAsAdministrator
#Requires -Modules Pester
#Requires -Version 4.0

<#
.Synopsis
   Operation validation tests (Pester) for Microsoft Hyper-V
.DESCRIPTION
   The account executing these tests needs local administrative privileges on the specified Hyper-V servers. 
.EXAMPLE
   Invoke-Pester
   
   This will invoke the tests if it is located in the current folder or a subfolder it the test file follow the namingstandard of Pester. The FileName should contain Tests.ps1
   .EXAMPLE
   Invoke-Pester -Script .\Microsoft\HyperV\HyperV.Tests.ps1
.OUTPUTS
   It outputs to the console or to standard output if PassThru parameter is used
.NOTES
   Use at your own risk
.COMPONENT
   Operation validation tests
.FUNCTIONALITY
   Operation validation tests
#>

Describe "Simple Validation of Hyper-V servers" {
    $Servers = @('HPV-01','HPV-02')

    foreach ($ComputerName in $Servers) {

    $Session = New-PSSession -ComputerName $ComputerName
                  
    It "The Hyper-V Virtual Machine Management service on $ComputerName should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name  vmms}).status |
        Should be 'Running'
    }
                
    It "The Windows Management Instrumentation service on $ComputerName should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name winmgmt}).status  |
        Should be 'Running'
    }

    It "The Get-VMHost cmdlet on $ComputerName should not throw any errors" {
        {Invoke-Command -Session $Session {Get-VMHost}} |
        Should Not Throw
    }

    It "The Get-VM cmdlet on $ComputerName should not throw any errors" {
        {Invoke-Command -Session $Session {Get-VM}} |
        Should Not Throw
    }


    Remove-PSSession -Session $Session

    }
}