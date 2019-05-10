#Requires -RunAsAdministrator
#Requires -Modules Pester
#Requires -Version 4.0

<#
.Synopsis
   Operation validation tests (Pester) for Veeam Backup and Replication

.DESCRIPTION
   The tests needs adminitrative privileges to run. It requires the powershell Pester module. 

.EXAMPLE
   Invoke-Pester
   
   This will invoke the tests if it is located in the current folder or a subfolder it the test file follow the namingstandard of Pester. The FileName should contain Tests.ps1

.EXAMPLE
   $TestResult = Invoke-Pester -PassThru
   
   This will run all tests recursivly and save the output in the variable Testresult

.OUTPUTS
   It outputs to the console or to standard output if PassThru parameter is used

.NOTES
   Use at your own Risk!

.COMPONENT
   Operation validation tests

.FUNCTIONALITY
   Operation validation tests
#>

Describe "Veeam Cloud Gateway Service Validation" -Tags Veeam.Cloud.Gateway {

    Context "Files and Folders" {
        $FolderName = "C:\Program Files (x86)\Veeam\Backup Gate"
        It "Should have a folder [$FolderName]" {
            Test-Path -Path "$FolderName" | Should Be $false
        }

        $FolderName = "C:\Program Files (x86)\Veeam\Backup Transport\VeeamTransportSvc.exe"
        It "Should have a folder [$FolderName]" {
            Test-Path -Path "$FolderName" | Should Be $true
        }

        $FolderName = "C:\Windows\Veeam\Backup"
        It "Should have a folder [$FolderName]" {
            Test-Path -Path "$FolderName" | Should Be $true
        }
                
        $FolderName = "C:\Program Files\Common Files\Veeam\Backup and Replication\Mount Service"
        It "Should have a folder [$FolderName]" {
            Test-Path -Path "$FolderName" | Should Be $true
        }
        
        $FolderName = "C:\Program Files (x86)\Veeam\vPowerNFS"
        It "Should have a folder [$FolderName]" {
            Test-Path -Path "$FolderName" | Should Be $true
        }


        $FileName = "C:\Program Files (x86)\Veeam\Backup Gate\VeeamGateSvc.exe" 
        It "Should have a file [$FileName]" {
            Test-Path -Path "$FileName" | Should be $true
        }

        $FileName = "C:\Program Files (x86)\Veeam\Backup Transport\VeeamTransportSvc.exe" 
        It "Should have a file [$FileName]" {
            Test-Path -Path "$FileName" | Should be $true
        }

        $FileName = "C:\Windows\Veeam\Backup\VeeamDeploymentSvc.exe" 
        It "Should have a file [$FileName]" {
            Test-Path -Path "$FileName" | Should be $true
        }

        $FileName = "C:\Program Files\Common Files\Veeam\Backup and Replication\Mount Service\Veeam.Backup.MountService.exe"
        It "Should have a file [$FileName]" {
            Test-Path -Path "$FileName" | Should be $true
        }

        $FileName = "C:\Program Files (x86)\Veeam\vPowerNFS\VeeamNFSSvc.exe"
        It "Should have a file [$FileName]" {
            Test-Path -Path "$FileName" | Should be $true
        }
    }

    Context "Services running" {
        $ServiceName = "VeeamGateSvc"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'"

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        $serviceAccount = "LocalSystem"
        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be "$serviceAccount"
        }

        $ServiceName = "VeeamTransportSvc"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'"

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        $serviceAccount = "LocalSystem"
        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be "$serviceAccount"
        }

        $ServiceName = "VeeamDeploymentService"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'"

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        $serviceAccount = "LocalSystem"
        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be "$serviceAccount"
        }

        $ServiceName = "VeeamMountSvc"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'"

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        $serviceAccount = "LocalSystem"
        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be "$serviceAccount"
        }

        $ServiceName = "VeeamNFSSvc"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'"

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        $serviceAccount = "LocalSystem"
        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be "$serviceAccount"
        }

        
        $ServiceName = "VGAuthService"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'"

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        $serviceAccount = "LocalSystem"
        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be "$serviceAccount"
        }
                
        $ServiceName = 'MSSQL$VEEAMSQL2012'
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'"

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        $serviceAccount = "LocalSystem"
        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be "$serviceAccount"
        }
                
        $ServiceName = 'SQLBrowser'
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'"

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        $serviceAccount = "NT AUTHORITY\LOCALSERVICE"
        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be "$serviceAccount"
        }
    }
}