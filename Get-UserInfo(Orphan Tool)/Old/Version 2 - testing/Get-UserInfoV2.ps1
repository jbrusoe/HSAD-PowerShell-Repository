
. "\\hs\public\tools\Scripts\Get-UserInfo\Version 2 - testing\Get-HSUserInfo.ps1"
. "\\hs\public\tools\Scripts\Get-UserInfo\Version 2 - testing\Get-WVUUserInfo.ps1"
. "\\hs\public\tools\Scripts\Get-UserInfo\Version 2 - testing\Get-WVUHUserInfo.ps1"
. "\\hs\public\tools\Scripts\Get-UserInfo\Version 2 - testing\Get-AccountStatus.ps1"

Do 
{
    $username = Read-Host "`nEnter the username you want to lookup"
    
    Get-HSUserInfo $username    
      
}
While($true)