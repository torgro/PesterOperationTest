#Requires -RunAsAdministrator
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

$null = Add-PSSnapin -Name VeeamPSSnapin -ErrorVariable ConnectError

$VeeamSession = Get-VBRServerSession -ErrorAction SilentlyContinue
if (-not $VeeamSession)
{
    $null = Connect-VBRServer -ErrorVariable ConnectError+
    $VeeamSession = Get-VBRServerSession -ErrorVariable ConnectError+
}


Describe "Veeam Cloud Server Validation" -Tags Veeam.Cloud.Server {

    Context "Connection and Powershell" {

        It "Should have the PSsnapin loaded" {
            Get-PSSnapin -Name VeeamPSSnapin | Should not Be $null
        }
        
        It "Should not have any errors on connection" {
            $ConnectError | Should be $null
        }

        It "Shold have a session to the VeeamServer" {
            $VeeamSession | Should not be $null
        }

        $testPort = 9392

        It "Should listen on TCP port $testPort" {
            $assertTCPport = Test-NetConnection -ComputerName localhost -Port $testPort
            $assertTCPport.TcpTestSucceeded | Should be $true
        }
    }
  
    Context "Services running" {
        $ServiceName = "VeeamBackupSvc"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'"

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        $serviceAccount = "FP\veeamcc_svc"
        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be "$serviceAccount"
        }

        $ServiceName = "VeeamBrokerSvc"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'"

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        $serviceAccount = "FP\veeamcc_svc"
        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be "$serviceAccount"
        }

        $serviceAccount = "FP\veeamcc_svc"
        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be "$serviceAccount"
        }

        $ServiceName = "VeeamCloudSvc"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'"

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        $serviceAccount = "FP\veeamcc_svc"
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

        $serviceAccount = "veeamcc_svc@fp.ad"
        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be "$serviceAccount"
        }

        $ServiceName = "VeeamCatalogSvc"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'"

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        $serviceAccount = "FP\veeamcc_svc"
        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be "$serviceAccount"
        }
        
        $ServiceName = "VeeamDeploySvc"
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

        $serviceAccount = "FP\veeamcc_svc"
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

        $serviceAccount = "veeamcc_svc@fp.ad"
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
    }

    Context "Veeam Configuration Tenants" {
        $tenants = Get-VBRCloudTenant

        $tenantCount = 8
        It "Should have $tenantCount tenants" {
            $tenants.Count | Should be $tenantCount
        }

        $Customer = "Oceanteam"
        $tenant = $tenants | Where-Object Name -eq $Customer

        It "Should have a tenant [$Customer]" {
            $tenant.Name | should be $Customer
        }

        It "The tenant should be enabled" {
            $tenant.Enabled | should be $true
        }

        $Customer = "CCB"
        $tenant = $tenants | Where-Object Name -eq $Customer

        It "Should have a tenant [$Customer]" {
            $tenant.Name | should be $Customer
        }

        It "The tenant should be enabled" {
            $tenant.Enabled | should be $true
        }

        $Customer = "ELund"
        $tenant = $tenants | Where-Object Name -eq $Customer

        It "Should have a tenant [$Customer]" {
            $tenant.Name | should be $Customer
        }

        It "The tenant should be enabled" {
            $tenant.Enabled | should be $true
        }

        $Customer = "EgilDanielsenSkoler"
        $tenant = $tenants | Where-Object Name -eq $Customer

        It "Should have a tenant [$Customer]" {
            $tenant.Name | should be $Customer
        }

        It "The tenant should be enabled" {
            $tenant.Enabled | should be $true
        }

        $Customer = "FanaSpareBank"
        $tenant = $tenants | Where-Object Name -eq $Customer

        It "Should have a tenant [$Customer]" {
            $tenant.Name | should be $Customer
        }

        It "The tenant should be enabled" {
            $tenant.Enabled | should be $true
        }

        $Customer = "SwireSeabed"
        $tenant = $tenants | Where-Object Name -eq $Customer

        It "Should have a tenant [$Customer]" {
            $tenant.Name | should be $Customer
        }

        It "The tenant should be enabled" {
            $tenant.Enabled | should be $true
        }

        $Customer = "NordnesVerksteder"
        $tenant = $tenants | Where-Object Name -eq $Customer

        It "Should have a tenant [$Customer]" {
            $tenant.Name | should be $Customer
        }

        It "The tenant should be enabled" {
            $tenant.Enabled | should be $true
        }

        $Customer = "Opus"
        $tenant = $tenants | Where-Object Name -eq $Customer

        It "Should have a tenant [$Customer]" {
            $tenant.Name | should be $Customer
        }

        It "The tenant should be enabled" {
            $tenant.Enabled | should be $true
        }
    }

    Context "Disk" {
        $volume = Get-Volume -DriveLetter D -ErrorAction SilentlyContinue
        It "Should have a D: disk" {            
            $volume | Should not be $null
        }

        It "Should have more than 1TB of free space on the D: disk" {
            $volume.SizeRemaining | Should BeGreaterThan 1TB
        }

        $volume = Get-Volume -DriveLetter E -ErrorAction SilentlyContinue
        It "Should have a E: disk" {
            $volume | Should not be $null
        }

        It "Should have more than 1TB of free space on the E: disk" {
            $volume.SizeRemaining | Should BeGreaterThan 1TB
        }
    }

    Context "Jobs" {
        
    }
}

#Cleanup
Disconnect-VBRServer