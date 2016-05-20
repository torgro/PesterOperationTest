#Requires -RunAsAdministrator
#Requires -Modules Pester
#Requires -Version 4.0

<#
.Synopsis
   Operation validation tests (Pester) for Microsoft System Center Virtual Machine Manager (SC VMM)
.DESCRIPTION
   The tests needs adminitrative privileges to run. It requires the powershell Pester module. Also your domain controllers
   need to be configured with Powershell remoting if you want to run the PCNS tests. The account executing these tests
   needs Powershell remoting privileges and local administrative privileges on the SC VMM server. 
.EXAMPLE
   Invoke-Pester
   
   This will invoke the tests if it is located in the current folder or a subfolder it the test file follow the namingstandard of Pester. The FileName should contain Tests.ps1
   .EXAMPLE
   Invoke-Pester -Script .\Microsoft\VirtualMachineManager\VirtualMachineManager.Tests.ps1
.OUTPUTS
   It outputs to the console or to standard output if PassThru parameter is used
.NOTES
   Use at your own risk
.COMPONENT
   Operation validation tests
.FUNCTIONALITY
   Operation validation tests
#>

Describe "Validation of SC VMM" {
    $VMMComputerName = 'DEMOVMM01'
    $Session = New-PSSession -ComputerName $VMMComputerName 
    
    Context "Services" {
    It "The VMM Server service should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name SCVMMService}).status |
        Should be 'Running'
    }
    It "The VMM agent service should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name SCVMMAgent}).status |
        Should be 'Running'
    } 
    }
    
    Context "Ports" {
        $VMMAdminConsolePort = Invoke-Command -ComputerName $VMMComputerName -ScriptBlock {
    (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft System Center Virtual Machine Manager Server\Settings').IndigoTcpPort
    }
    It "Should be listening on Admin Console port $VMMAdminConsolePort" {
        Test-NetConnection -ComputerName $VMMComputerName  -Port $VMMAdminConsolePort -InformationLevel Quiet |
        Should be $true
    }
    }
    
    Context "Basic queries using SC VMM cmdlets" {
    It "Should be able to query information from the VMM Server" {
    (Invoke-Command -Session $Session {Get-SCVMMServer -ComputerName localhost}).IsConnected |
        Should be $true
    }
    }
    
    Remove-PSSession -Session $Session
}

Describe "Validation of SQL Server used by SC VMM" {
    $VMMComputerName = 'DEMOVMM01'
    $VMMDBComputerName = Invoke-Command -ComputerName $VMMComputerName -ScriptBlock {
    (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft System Center Virtual Machine Manager Server\Settings\Sql').InstanceName
    }
    
    $Session = New-PSSession -ComputerName $VMMDBComputerName
    It "The SQL Server service should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name MSSQLSERVER}).status |
        Should be 'Running'
    }
    It "The SQL Server agent service should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name SQLSERVERAGENT}).status  |
        Should be 'Running'
    }
    It "Should be listening on port 1433" {
        Test-NetConnection -ComputerName $VMMDBComputerName -Port 1433 -InformationLevel Quiet |
        Should be $true
    }
    It "Should be able to query information from the SQL Server" {
    (Invoke-Command -Session $Session {Invoke-Sqlcmd -Query "select name from sys.databases where name = 'master'" -ServerInstance $using:VMMDBComputerName -Database master}).Name |
        Should be 'master'
    }
    Remove-PSSession -Session $Session
}