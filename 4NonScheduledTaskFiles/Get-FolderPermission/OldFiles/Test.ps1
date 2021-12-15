Function Get-UserOrGroup {
    [CmdletBinding()]
    param(
        $UserName 
    )

    $GroupOrUser = ""
    $searcher = [adsisearcher]"(SamAccountName=$UserName)"
    $null = $searcher.PropertiesToLoad.Add('objectClass')

    $result = $searcher.FindOne()

    if ($result) {
        Write-Output ([object[]] $result.Properties['objectClass'])[-1]
        $GroupOrUser = ([object[]] $result.Properties['objectClass'])[-1]
    }
    else {
        Write-Warning "There was a problem finding information for $UserName"
    }
}