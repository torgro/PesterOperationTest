#Requires -RunAsAdministrator
#Requires -Modules ActiveDirectory
#Requires -Modules Pester
#Requires -Version 4.0

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
            $ADSnapshot.DomainInformation.DNSRoot | Should be $ExpectedConfiguration.Domain.DNSRoot
        }
        it "NetBIOSName should be $($ExpectedConfiguration.Domain.NetBIOSName)" {
            $ADSnapshot.DomainInformation.NetBIOSName | Should be $ExpectedConfiguration.Domain.NetBIOSName
        }
        it "DomainMode should be $($ExpectedConfiguration.Domain.DomainMode)" {
            $ADSnapshot.DomainInformation.DomainMode.ToString() | Should be $ExpectedConfiguration.Domain.DomainMode
        }
        it "DistinguishedName should be $($ExpectedConfiguration.Domain.DistinguishedName)" {
            $ADSnapshot.DomainInformation.DistinguishedName | Should be $ExpectedConfiguration.Domain.DistinguishedName
        }
        it "RIDMaster should be $($ExpectedConfiguration.Domain.RIDMaster)" {
            $ADSnapshot.DomainInformation.RIDMaster | Should be $ExpectedConfiguration.Domain.RIDMaster
        }
        it "PDCEmulator should be $($ExpectedConfiguration.Domain.PDCEmulator)" {
            $ADSnapshot.DomainInformation.PDCEmulator | Should be $ExpectedConfiguration.Domain.PDCEmulator
        }
        it "InfrastructureMaster should be $($ExpectedConfiguration.Domain.InfrastructureMaster)" {
            $ADSnapshot.DomainInformation.InfrastructureMaster | Should be $ExpectedConfiguration.Domain.InfrastructureMaster
        }
    }
    
    #FIXME BELOW:
    Context 'Verifying Default Password Policy'{
        it 'ComplexityEnabled'{
            $ADSnapshot.DefaultPassWordPoLicy.ComplexityEnabled | Should be $ExpectedConfiguration.PasswordPolicy.ComplexityEnabled
        }
        it 'Password History count'{
            $ADSnapshot.DefaultPassWordPoLicy.PasswordHistoryCount | Should be $ExpectedConfiguration.PasswordPolicy.PasswordHistoryCount
        }
        it "Lockout Threshold equals $($ExpectedConfiguration.PasswordPolicy.LockoutThreshold)"{
            $ADSnapshot.DefaultPassWordPoLicy.LockoutThreshold | Should be $ExpectedConfiguration.PasswordPolicy.LockoutThreshold
        }
        it "Lockout duration equals $($ExpectedConfiguration.PasswordPolicy.LockoutDuration)"{
            $ADSnapshot.DefaultPassWordPoLicy.LockoutDuration.ToString() | Should be $ExpectedConfiguration.PasswordPolicy.LockoutDuration
        }
        it "Lockout observation window equals $($ExpectedConfiguration.PasswordPolicy.LockoutObservationWindow)"{
            $ADSnapshot.DefaultPassWordPoLicy.LockoutObservationWindow.ToString() | Should be $ExpectedConfiguration.PasswordPolicy.LockoutObservationWindow
        }
        it "Min password age equals $($ExpectedConfiguration.PasswordPolicy.MinPasswordAge)"{
            $ADSnapshot.DefaultPassWordPoLicy.MinPasswordAge.ToString() | Should be $ExpectedConfiguration.PasswordPolicy.MinPasswordAge
        }
        it "Max password age equals $($ExpectedConfiguration.PasswordPolicy.MaxPasswordAge)"{
            $ADSnapshot.DefaultPassWordPoLicy.MaxPasswordAge.ToString() | Should be $ExpectedConfiguration.PasswordPolicy.MaxPasswordAge
        }
    }

    Context 'Verifying Active Directory Sites'{
        $ADConfiguration.Sites | 
        ForEach-Object{
            it "Site $($_)" {
                $ADSnapshot.Sites.Name.Contains($_) | Should be $true
            } 
        }
    }

    Context 'Verifying Active Directory Sitelinks'{
        $ADConfiguration.Sitelinks | 
        ForEach-Object{
            it "Sitelink $($_.Name)" {
                $ADSnapshot.SiteLinks.Name.Contains($_.Name) | Should be $true
            } 
            it "Sitelink $($_.Name) costs $($_.Cost)" {
                $ADConfiguration.Sitelinks.Cost | Should be $ADSnapshot.SiteLinks.Cost
            }
            it "Sitelink $($_.Name) replication interval $($_.ReplicationFrequencyInMinutes)" {
                $ADConfiguration.Sitelinks.ReplicationFrequencyInMinutes | Should be $ADSnapshot.SiteLinks.ReplicationFrequencyInMinutes
            }
        }
    }

    Context 'Verifying Active Directory Subnets'{
        $ADConfiguration.Subnets | 
        ForEach-Object{
            it "Subnet $($_)" {
                $ADSnapshot.Subnets.Name.Contains($_) | Should be $true
            }
        } 
    }
}