Function Get-DnsServer
{
 Begin {Write-Host -ForeGroundColor Cyan "Obtaining local DNS Server information..."}
 Process {
  (Get-WmiObject -Class `
win32_networkadapterconfiguration -filter "ipenabled =   $true").DnsServerSearchOrder[0]
 } #end Process
} #end Get-DnsServer

Function Get-DomainName
{
 Begin {Write-Host -ForeGroundColor DarkCyan "Obtaining local DNS Domain information..."}
 Process {
  (Get-WmiObject -Class win32_networkadapterconfiguration -filter "ipenabled =   $true").DnsDomain
 } #end Process
} #end Get-DnsServer

Function Get-ARecords($DnsServer) 
{
 Begin { Write-Host -ForeGroundColor Yellow "Connecting to $DnsServer ..." }
 Process { Write-Host -ForeGroundColor Green "Retrieving A records ..." 
  Get-WmiObject -Class MicrosoftDNS_AType -NameSpace Root\MicrosoftDNS 
  -ComputerName $DnsServer  -Filter "DomainName = 'hs.wvu-ad.wvu.edu'" |
  Select-Object -property Ownername, ipaddress
 } #end process
} #end Get-ARecords

# *** Entry Point to Script ***

$DnsServer = Get-DnsServer
$DnsDomain = Get-DomainName
Get-ARecords -DnsDomain $DnsDomain -DnsServer $DnsServer
