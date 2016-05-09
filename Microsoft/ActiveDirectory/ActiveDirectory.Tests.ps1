Import-Module -Name ActiveDirectory -ErrorAction Stop

# ADsnapshot created by 
# Author: I. Strachan (@IrwinStrachan)
# https://gist.github.com/irwins/f0e27525e72cb19f13ec/

$ADSnapshot = @{}

$ADSnapshot.RootDSE = $(Get-ADRootDSE)
$ADSnapshot.ForestInformation = $(Get-ADForest)
$ADSnapshot.DomainInformation = $(Get-ADDomain)
$ADSnapshot.DomainControllers = $(Get-ADDomainController -Filter *)
$ADSnapshot.DomainTrusts = (Get-ADTrust -Filter *)
$ADSnapshot.DefaultPassWordPoLicy = $(Get-ADDefaultDomainPasswordPolicy)
$ADSnapshot.AuthenticationPolicies = $(Get-ADAuthenticationPolicy -LDAPFilter '(name=AuthenticationPolicy*)')
$ADSnapshot.AuthenticationPolicySilos = $(Get-ADAuthenticationPolicySilo -Filter 'Name -like "*AuthenticationPolicySilo*"')
$ADSnapshot.CentralAccessPolicies = $(Get-ADCentralAccessPolicy -Filter *)
$ADSnapshot.CentralAccessRules = $(Get-ADCentralAccessRule -Filter *)
$ADSnapshot.ClaimTransformPolicies = $(Get-ADClaimTransformPolicy -Filter *)
$ADSnapshot.ClaimTypes = $(Get-ADClaimType -Filter *)
$ADSnapshot.DomainAdministrators =$( Get-ADGroup -Identity $('{0}-512' -f (Get-ADDomain).domainSID) | Get-ADGroupMember -Recursive)
$ADSnapshot.OrganizationalUnits = $(Get-ADOrganizationalUnit -Filter *)
$ADSnapshot.OptionalFeatures =  $(Get-ADOptionalFeature -Filter *)
$ADSnapshot.Sites = $(Get-ADReplicationSite -Filter *)
$ADSnapshot.Subnets = $(Get-ADReplicationSubnet -Filter *)
$ADSnapshot.SiteLinks = $(Get-ADReplicationSiteLink -Filter *)
$ADSnapshot.ReplicationMetaData = $(Get-ADReplicationPartnerMetadata -Target (Get-ADDomain).DNSRoot -Scope Domain)

# Tests are also partly from I. Strachan
# https://gist.github.com/irwins/c08f9228a9abf9c6b2e81f03fc78ce8c#file-ad-operations-tests-ps1

$ExpectedConfiguration = @{
    Forest = @{
        FQDN = 'pshirwin.local'
        ForestMode = 'Windows2012R2Forest'
        GlobalCatalogs = @(
            'DC-DSC-01.pshirwin.local'
        )
        SchemaMaster = 'DC-DSC-01.pshirwin.local'
        DomainNamingMaster = 'DC-DSC-01.pshirwin.local'

    }
    Domain = @{
        NetBIOSName = 'PSHIRWIN'
        DomainMode = 'Windows2012R2Domain'
        RIDMaster = 'DC-DSC-01.pshirwin.local'
        PDCEmulator = 'DC-DSC-01.pshirwin.local'
        InfrastructureMaster = 'DC-DSC-01.pshirwin.local'
        DistinguishedName = 'DC=pshirwin,DC=local'
        DNSRoot = 'pshirwin.local'
        DomainControllers = @(
            'DC-DSC-01'
        )
    }
    PasswordPolicy = @{
        PasswordHistoryCount = 24
        LockoutThreshold = 0
        LockoutDuration = '00:30:00'
        LockoutObservationWindow = '00:30:00'
        MaxPasswordAge = '42.00:00:00'
        MinPasswordAge = '1.00:00:00'
        MinPasswordLength = 8
        ComplexityEnabled = $true
    }
    Sites = @('Default-First-Site-Name')
    SiteLinks = @(
       @{
            Name = 'DEFAULTIPSITELINK'
            Cost = 100
            ReplicationFrequencyInMinutes = 180
        }
    )
    SubNets = @()
}

Describe "Active Directory Operational Validation" {
    Context "Forest configuration" {
        it "Forest FQDN should be $($ExpectedConfiguration.Forest.FQDN)" {
            $ADSnapshot.ForestInformation.RootDomain | Should be $ExpectedConfiguration.Forest.FQDN
        }
        it "ForestMode should be $($ExpectedConfiguration.Forest.ForestMode)" {
            $ADSnapshot.ForestInformation.ForestMode.ToString() | Should be $ExpectedConfiguration.Forest.ForestMode
        }
        it "SchemaMaster should be $($ExpectedConfiguration.Forest.SchemaMaster)" {
            $ADSnapshot.ForestInformation.SchemaMaster | Should be $ExpectedConfiguration.Forest.SchemaMaster
        }
        it "DomainNamingMaster should be $($ExpectedConfiguration.Forest.DomainNamingMaster)"{
            $ADSnapshot.ForestInformation.DomainNamingMaster | Should be $ExpectedConfiguration.Forest.DomainNamingMaster
        }
    }
    
    Context 'Verifying GlobalCatalogs' {        
        it "Global Catalog Servers list should match." {
            Compare-Object $ExpectedConfiguration.Forest.GlobalCatalogs $ADSnapshot.ForestInformation.GlobalCatalogs | Should BeNullOrEmpty
        }                   
    }
    
    Context "Verifying Domain Configuration" {
        it "List of domain controllers in the domain should be the same as the configuration list." {
            Compare-Object $ExpectedConfiguration.Domain.DomainControllers $ADSnapshot.DomainControllers.Name | Should BeNullOrEmpty
        }
        
        it "DNSRoot should be $($ExpectedConfiguration.Domain.DNSRoot)" {
            $ExpectedConfiguration.Domain.DNSRoot | Should be $ADSnapshot.DomainInformation.DNSRoot
        }
        it "NetBIOSName should be $($ExpectedConfiguration.Domain.NetBIOSName)" {
            $ExpectedConfiguration.Domain.NetBIOSName | Should be $ADSnapshot.DomainInformation.NetBIOSName
        }
        it "DomainMode should be $($ExpectedConfiguration.Domain.DomainMode)" {
            $ADConfigurExpectedConfigurationation.Domain.DomainMode | Should be $ADSnapshot.DomainInformation.DomainMode.ToString()
        }
        it "DistinguishedName should be $($ExpectedConfiguration.Domain.DistinguishedName)" {
            $ExpectedConfiguration.Domain.DistinguishedName | Should be $ADSnapshot.DomainInformation.DistinguishedName
        }
        it "RIDMaster should be $($ExpectedConfiguration.Domain.RIDMaster)" {
            $ExpectedConfiguration.Domain.RIDMaster | Should be $ADSnapshot.DomainInformation.RIDMaster
        }
        it "PDCEmulator should be $($ExpectedConfiguration.Domain.PDCEmulator)" {
            $ExpectedConfiguration.Domain.PDCEmulator | Should be $ADSnapshot.DomainInformation.PDCEmulator
        }
        it "InfrastructureMaster should be $($ExpectedConfiguration.Domain.InfrastructureMaster)" {
            $ExpectedConfiguration.Domain.InfrastructureMaster | Should be $ADSnapshot.DomainInformation.InfrastructureMaster
        }
    }
    
    #FIXME BELOW:
    Context 'Verifying Default Password Policy'{
        it 'ComplexityEnabled'{
            $ADConfiguration.PasswordPolicy.ComplexityEnabled | Should be $SavedADReport.DefaultPassWordPoLicy.ComplexityEnabled
        }
        it 'Password History count'{
            $ADConfiguration.PasswordPolicy.PasswordHistoryCount | Should be $SavedADReport.DefaultPassWordPoLicy.PasswordHistoryCount
        }
        it "Lockout Threshold equals $($ADConfiguration.PasswordPolicy.LockoutThreshold)"{
            $ADConfiguration.PasswordPolicy.LockoutThreshold | Should be $SavedADReport.DefaultPassWordPoLicy.LockoutThreshold
        }
        it "Lockout duration equals $($ADConfiguration.PasswordPolicy.LockoutDuration)"{
            $ADConfiguration.PasswordPolicy.LockoutDuration | Should be $SavedADReport.DefaultPassWordPoLicy.LockoutDuration.ToString()
        }
        it "Lockout observation window equals $($ADConfiguration.PasswordPolicy.LockoutObservationWindow)"{
            $ADConfiguration.PasswordPolicy.LockoutObservationWindow | Should be $SavedADReport.DefaultPassWordPoLicy.LockoutObservationWindow.ToString()
        }
        it "Min password age equals $($ADConfiguration.PasswordPolicy.MinPasswordAge)"{
            $ADConfiguration.PasswordPolicy.MinPasswordAge | Should be $SavedADReport.DefaultPassWordPoLicy.MinPasswordAge.ToString()
        }
        it "Max password age equals $($ADConfiguration.PasswordPolicy.MaxPasswordAge)"{
            $ADConfiguration.PasswordPolicy.MaxPasswordAge | Should be $SavedADReport.DefaultPassWordPoLicy.MaxPasswordAge.ToString()
        }
    }

    Context 'Verifying Active Directory Sites'{
        $ADConfiguration.Sites | 
        ForEach-Object{
            it "Site $($_)" {
                $SavedADReport.Sites.Name.Contains($_) | Should be $true
            } 
        }
    }

    Context 'Verifying Active Directory Sitelinks'{
        $ADConfiguration.Sitelinks | 
        ForEach-Object{
            it "Sitelink $($_.Name)" {
                $SavedADReport.SiteLinks.Name.Contains($_.Name) | Should be $true
            } 
            it "Sitelink $($_.Name) costs $($_.Cost)" {
                $ADConfiguration.Sitelinks.Cost | Should be $SavedADReport.SiteLinks.Cost
            }
            it "Sitelink $($_.Name) replication interval $($_.ReplicationFrequencyInMinutes)" {
                $ADConfiguration.Sitelinks.ReplicationFrequencyInMinutes | Should be $SavedADReport.SiteLinks.ReplicationFrequencyInMinutes
            }
        }
    }

    Context 'Verifying Active Directory Subnets'{
        $ADConfiguration.Subnets | 
        ForEach-Object{
            it "Subnet $($_)" {
                $SavedADReport.Subnets.Name.Contains($_) | Should be $true
            }
        } 
    }
    
    $SqlServerName = "sqlfimserver.domain.no"
    
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