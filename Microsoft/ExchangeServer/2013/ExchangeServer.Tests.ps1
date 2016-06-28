#Requires -RunAsAdministrator
#Requires -Modules Pester
#Requires -Version 4.0

<#
.Synopsis
   Operation validation tests (Pester) for Microsoft Exchange Server
.DESCRIPTION
   The account executing these tests needs minimum the Exchange View-Only Administrators role for reading information about the Exchange organization such as URLs.
   This test-file is tested against Exchange Server 2013 CU13.
.EXAMPLE
   Invoke-Pester
   
   This will invoke the tests if it is located in the current folder or a subfolder it the test file follow the namingstandard of Pester. The FileName should contain Tests.ps1
   .EXAMPLE
   Invoke-Pester -Script .\Microsoft\ExchangeServer\2013\ExchangeServer.Tests.ps1
.OUTPUTS
   It outputs to the console or to standard output if PassThru parameter is used
.NOTES
   Use at your own risk
.COMPONENT
   Operation validation tests
.FUNCTIONALITY
   Operation validation tests
#>


Describe "Simple Validation of Exchange Server" {


  $ExchangeAdminConnectionFQDN =  'mail.domain.com'

  $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$ExchangeAdminConnectionFQDN/PowerShell/" -Authentication Kerberos
  Import-PSSession $Session -DisableNameChecking
  
  $URLs = @()                                                                                   
  $URLs += Get-ActiveSyncVirtualDirectory | Select-Object -Property Identity,InternalUrl,ExternalUrl,InternalHostname,ExternalHostname
  $URLs += Get-AutodiscoverVirtualDirectory | Select-Object -Property Identity,InternalUrl,ExternalUrl,InternalHostname,ExternalHostname
  $URLs += Get-EcpVirtualDirectory | Select-Object -Property Identity,InternalUrl #,ExternalUrl,InternalHostname,ExternalHostname
  
  if ((Get-OrganizationConfig).MapiHttpEnabled) {
  
  $URLs += Get-MapiVirtualDirectory | Select-Object -Property Identity,InternalUrl ,ExternalUrl,InternalHostname,ExternalHostname
  
  }
  
  $URLs += Get-OabVirtualDirectory | Select-Object -Property Identity,InternalUrl #,ExternalUrl,InternalHostname,ExternalHostname
  $URLs += Get-OwaVirtualDirectory | Select-Object -Property Identity,InternalUrl,ExternalUrl,InternalHostname,ExternalHostname
  $URLs += Get-WebServicesVirtualDirectory | Select-Object -Property Identity,InternalUrl #,ExternalUrl,InternalHostname,ExternalHostname
  $URLs += Get-OutlookAnywhere | Select-Object -Property Identity,InternalUrl,ExternalUrl,InternalHostname,ExternalHostname

  foreach ($URL in $URLs) {
  
    if ($URL.InternalUrl) {
  
      $TestUri = $URL.InternalUrl.ToString() + '/healthcheck.htm'

      It "$($URL.Identity) internal health probe URL $TestUri response should be OK" {
        
        $response = Invoke-WebRequest -UseBasicParsing -Uri $TestUri -TimeoutSec 5
        $response.StatusDescription | Should be OK

      }
  
    }

    if ($URL.ExternalUrl) {
  
      $TestUri = $URL.ExternalUrl.ToString() + '/healthcheck.htm'

      It "$($URL.Identity) external health probe URL $TestUri response should be OK" {
        
        $response = Invoke-WebRequest -UseBasicParsing -Uri $TestUri -TimeoutSec 5
        $response.StatusDescription | Should be OK

      }
  
    }
  
  }

  $ExchangeServers = Get-ExchangeServer
  
  foreach ($Server in $ExchangeServers) {
  
  
  It "Exchange server $Server should be listening on SMTP port 25" {
    Test-NetConnection -ComputerName $Server -Port 25 -InformationLevel Quiet |
    Should be $true
  }
  
  
  }

 
  Remove-PSSession $Session

  Get-Module tmp* | Remove-Module
  
  }