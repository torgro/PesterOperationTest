#Requires -RunAsAdministrator
#Requires -Modules ActiveDirectory
#Requires -Modules Pester
#Requires -Version 4.0

$SqlServerName = "sqlserver.domain.no"

Describe "Sql server [$SqlServerName]" {
    
    Context "Database tier $SqlServerName" {
    
        It "$SqlServerName should be online" {
            Test-Connection -ComputerName $SqlServerName -Quiet -Count 1 | Should be $true
        }

        $serviceName = "MSSQLSERVER"
        $serviceAccount = "domain\sqlservice"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'" -ComputerName $SqlServerName

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be $serviceAccount
        }

        $serviceName = "SQLSERVERAGENT"
        $serviceAccount = "domain\sqlservice"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'" -ComputerName $SqlServerName

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be $serviceAccount
        }     

        $serviceName = "MSSQLServerOLAPService"
        $serviceAccount = "domain\sqlservice"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'" -ComputerName $SqlServerName

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be $serviceAccount
        }    
        
        $serviceName = "MsDtsServer110"
        $serviceAccount = "domain\sqlservice"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'" -ComputerName $SqlServerName

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be $serviceAccount
        }    
        
        $serviceName = "ReportServer"
        $serviceAccount = "domain\sqlservice"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'" -ComputerName $SqlServerName

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be $serviceAccount
        }
    }

}