Add-pssnapin Microsoft.SharePoint.Powershell
$site=Get-SPSite("https://hsccommons.hsc.wvu.edu/sites/SON")
$web = $site.OpenWeb()
$list = $web.GetList("https://hsccommons.hsc.wvu.edu/sites/SON/AN_BSN_Ad/Shared Documents");
$list.Title
$list.browserfilehandling
$list.browserfilehandling = "Permissive" ; $list.Update()
$list.browserfilehandling
