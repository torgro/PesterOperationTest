#Requires -RunAsAdministrator
<#
.Synopsis
   Operation validation tests (Pester) for Microsoft Identity Manager (MIM) also know as Forefront Identity Manager (FIM)
.DESCRIPTION
   The tests needs adminitrative privileges to run. It requires the powershell Pester module. Also your domain controllers
   need to be configured with Powershell remoting if you want to run the PCNS tests. The account executing these tests
   needs Powershell remoting privileges and local administrative privileges on the Identity Manager server. 
.EXAMPLE
   Invoke-Pester
   
   This will invoke the tests if it is located in the current folder or a subfolder it the test file follow the namingstandard of Pester. The FileName should contain Tests.ps1
.EXAMPLE
   Invoke-Pester -Script .\tests\IdentityManager.Tests.ps1
   
   This command will run the Pester testfile in the current working directory's subfolder 'tests'.
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
    
    Context "Configuration files" {
        $fileName = "miiserver.exe.config"
        $path = "$env:ProgramFiles\Microsoft Forefront Identity Manager\2010\Synchronization Service\Bin\"
        $ConfigFile = Get-FileHash -Path "$path$fileName" -ErrorAction SilentlyContinue
        
        It "$fileName should not have changed" {
            $ConfigFile.Hash | Should Be "D4B60AF6D525A4CF4132C39D2291C282220ED9CE30018063868848CA2D3D64AC"
        }
                
        $fileName = "Microsoft.ResourceManagement.Service.exe.config"
        $path = "$env:ProgramFiles\Microsoft Forefront Identity Manager\2010\Service\"
        $ConfigFile = Get-FileHash -Path "$path$fileName" -ErrorAction SilentlyContinue
        
        It "$fileName should not have changed" {
            $ConfigFile.Hash | Should Be "1B028C61DF4AD100F606562EAF08E187BD5FE19CDDDBA1B217418B528D3A9147"
        }
    }
    
    Context "Portal Server" {         
        $ServiceName = "IISADMIN"
        $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name like '$ServiceName'"

        It "Service $ServiceName should be running" {
            $CimService.State | Should Be "Running"
        }

        It "Service $ServiceName should start automatically" {
            $CimService.StartMode | Should Be "Auto"
        }

        It "Service $ServiceName should be running as LocalSystem" {
            $CimService.StartName | Should Be "LocalSystem"
        }
    }
    
    Context "Password Synchronization service for Domain Controllers" {
        
        # This test should fail if you introduce a new domain controller and do not install/configure PCNS on it!
        
        $DomainControllers = Get-ADDomainController -Filter * -ErrorAction Stop | Select-Object -ExpandProperty Name
        $ServiceName = "PCNSSVC"

        foreach($domainController in $DomainControllers)
        {            
            $ServiceName = "PCNSSVC"
            $CimService = Get-CimInstance -ClassName win32_Service -Filter "Name = '$ServiceName'" -ComputerName "$domainController" -ErrorAction SilentlyContinue

            if(-not $CimService)
            {
                #fallback to CIM via DCOM
                $sessionOption = New-CimSessionOption -Protocol Dcom
                $Session = New-CimSession -ComputerName $domainController -SessionOption $sessionOption
                $CimService = Get-CimInstance -cimSession $Session -ClassName win32_Service -Filter "Name = '$ServiceName'" -ErrorAction SilentlyContinue
                Remove-CimSession -CimSession $Session -ErrorAction SilentlyContinue
            }

            It "[$domainController] - Service $ServiceName should not be null" {
                $CimService | Should not be $null
            }

            if($CimService)
            {
                It "[$domainController] - Service $ServiceName should be running" {
                    $CimService.State | Should Be "Running"
                }

                It "[$domainController] - Service $ServiceName should start automatically" {
                    $CimService.StartMode | Should Be "Auto"
                }

                It "[$domainController] - Service $ServiceName should be running as LocalSystem" {
                    $CimService.StartName | Should Be "LocalSystem"
                }
            }

            $CimService = $null
        }
    }
    
    Context "Password Synchronization AD configuration" {
        Import-Module -Name ActiveDirectory -ErrorAction Stop
        
        $IdentityServerFQDN = "imserver.domain.com"

        $pcns = Get-ADObject -Filter { ObjectClass -like "MS-MIIS-PCNS-Target" } -Properties *

        It "Target should not be disabled" {
            $pcns.'mS-MIIS-PCNS-TargetDisabled' | Should be $false
        }

        It "Target server should be '$IdentityServerFQDN" {
            $pcns.'mS-MIIS-PCNS-TargetServer' | Should be "$IdentityServerFQDN"
        }

        It "SPN should be 'PCNSCLNT/$IdentityServerFQDN'" {
            $pcns.'mS-MIIS-PCNS-TargetSPN' | Should be "PCNSCLNT/$IdentityServerFQDN"
        }

        Remove-Module ActiveDirectory -ErrorAction SilentlyContinue
    }
}