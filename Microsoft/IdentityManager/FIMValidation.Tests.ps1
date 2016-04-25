Describe "FIM Validation" {
    Context "Powershell modules" {
        It "Should have PowerFIM module installed" {
            { Import-Module -Name d:\PowerFIM } | Should Not throw
        }

        if(Get-Module -Name PowerFIM -ErrorAction SilentlyContinue)
        {
            Remove-Module -Name PowerFIM
        }
    }

    Context "Files and Folders" {       
        $FolderName = "D:\Data\MA\HomeDrive"
        It "Should have a [$FolderName] folder" {
            Test-Path -Path "$FolderName" | Should Be $true
        }
        
        $FolderName = "D:\Data\FIMPowershellWorkflows"
        It "Should have a [$FolderName] folder" {
            Test-Path -Path "$FolderName" | Should Be $true
        }

        $FolderName = "D:\Data\FIMPowershellWorkflows\ExchangeProvisioning"
        It "Should have a [$FolderName] folder" {
            Test-Path -Path "$FolderName" | Should Be $true
        }
                
        $FolderName = "D:\Aditro"
        It "Should have a [$FolderName] folder" {
            Test-Path -Path "$FolderName" | Should Be $true
        }

        $FolderName = "D:\FIMsync"
        It "Should have a [$FolderName] folder" {
            Test-Path -Path "$FolderName" | Should Be $true
        }
               
        $fileName = "export.ps1"
        $FolderName = "D:\Data\MA\HomeDrive\"
        It "$FolderName$fileName should exists" {
            Test-Path -Path "$FolderName$fileName" | Should Be $true
        }

        $fileName = "import.ps1"
        $FolderName = "D:\Data\MA\HomeDrive\"
        It "$FolderName$fileName should exists" {
            Test-Path -Path "$FolderName$fileName" | Should Be $true
        }

        $fileName = "schema.ps1"
        $FolderName = "D:\Data\MA\HomeDrive\"
        It "$FolderName$fileName should exists" {
            Test-Path -Path "$FolderName$fileName" | Should Be $true
        }

        $fileName = "RegisterEndPoint.ps1"
        $FolderName = "D:\Data\FIMPowershellWorkflows\ExchangeProvisioning\"
        It "$FolderName$fileName  should exists" {
            Test-Path -Path "$FolderName$fileName" | Should Be $true
        }

        $fileName = "RunWF.ps1"
        $FolderName = "D:\Data\FIMPowershellWorkflows\ExchangeProvisioning\"
        It "$FolderName$fileName should exists" {
            Test-Path -Path "$FolderName$fileName" | Should Be $true
        }

        $fileName = "Startup.ps1"
        $FolderName = "D:\Data\FIMPowershellWorkflows\ExchangeProvisioning\"
        It "$FolderName$fileName should exists" {
            Test-Path -Path "$FolderName$fileName" | Should Be $true
        }
        
        $fileName = "SyncScheduled.ps1"
        $FolderName = "D:\FIMsync\RunScripts\"
        It "$FolderName$fileName should exists" {
            Test-Path -Path "$$FolderName$fileName" | Should Be $true
        }
        
        $fileName = "SyncScheduledNight.ps1"
        $FolderName = "D:\FIMsync\RunScripts\"
        It "$FolderName$fileName should exists" {
            Test-Path -Path "$$FolderName$fileName" | Should Be $true
        }
                
    }

    Context "Services running" {
        $ServiceName = "FIMService"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'"

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        $serviceAccount = "domain\FIMService"
        It "Service $ServiceName should be running as $serviceAccount" {
            $CimService.StartName | Should Be "$serviceAccount"
        }

        $ServiceName = "FIMSynchronizationService"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'"

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        $serviceAccount = "domain\Fimsync"
        It "Service $ServiceName should be running as domain\Fimsync" {
            $CimService.StartName | Should Be "$serviceAccount"
        }
        
    }

    Context "Scheduled tasks" {
        $taskName = "FIMSync - DayJob"
        $task = Get-ScheduledTask -TaskName "$taskName" -ErrorAction SilentlyContinue

        It "$taskName should exists" {
            $task | Should Not Be $null
        }

        It "$taskName should not be disabled" {
            $task.State | Should not Be "Disabled"
        }

        It "$taskName should run with highest privileges" {
            $task.Principal.RunLevel | Should Be "Highest"
        }

        $RunAs = "Domain\FIMRunScriptSchedule"
        It "$taskName should run as $RunAs" {
            $task.Principal.UserId | Should Be "$RunAs"
        }

        $taskName = "FIMSync - EarlyNightJob"
        $task = Get-ScheduledTask -TaskName "$taskName" -ErrorAction SilentlyContinue

        It "$taskName should exists" {
            $task | Should Not Be $null
        }

        It "$taskName should not be disabled" {
            $task.State | Should not Be "Disabled"
        }

        It "$taskName should run with highest privileges" {
            $task.Principal.RunLevel | Should Be "Highest"
        }

        $RunAs = "Domain\FIMRunScriptSchedule"
        It "$taskName should run as $RunAs" {
            $task.Principal.UserId | Should Be "$RunAs"
        }

        $taskName = "FIMSync - LateNightJob"
        $task = Get-ScheduledTask -TaskName "$taskName" -ErrorAction SilentlyContinue

        It "$taskName should exists" {
            $task | Should Not Be $null
        }

        It "$taskName should not be disabled" {
            $task.State | Should not Be "Disabled"
        }

        It "$taskName should run with highest privileges" {
            $task.Principal.RunLevel | Should Be "Highest"
        }

        $RunAs = "Domain\FIMRunScriptSchedule"
        It "$taskName should run as $RunAs" {
            $task.Principal.UserId | Should Be "$RunAs"
        }
    }
}