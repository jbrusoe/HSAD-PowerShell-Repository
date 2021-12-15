$ADGroup = Get-ADGroup "Office 365 Base Licensing Group"

$UsersToRemove = @(
	"aet00006@hsc.wvu.edu",
	"am10399@hsc.wvu.edu",
	"bhwilliamson@hsc.wvu.edu",
	"bl00003@hsc.wvu.edu",
	"bmateer@hsc.wvu.edu",
	"bmg10030@hsc.wvu.edu",
	"bmongold@hsc.wvu.edu",
	"cn0043@hsc.wvu.edu",
	"ehamilton@hsc.wvu.edu",
	"jmeadow9@hsc.wvu.edu",
	"mkline@hsc.wvu.edu",
	"koshiyoye@hsc.wvu.edu",
	"lmb10076@hsc.wvu.edu",
	"mkb10002@hsc.wvu.edu",
	"mtreese@hsc.wvu.edu",
	"rbowen1@hsc.wvu.edu",
	"rjl10015@hsc.wvu.edu",
	"rnm00001@hsc.wvu.edu",
	"robjones@hsc.wvu.edu",
	"rreyna@hsc.wvu.edu",
	"selliso1@hsc.wvu.edu",
	"sij0002@hsc.wvu.edu",
	"sjafri@hsc.wvu.edu",
	"sm10253@hsc.wvu.edu",
	"sns0044@hsc.wvu.edu",
	"ykwang@hsc.wvu.edu"
)

foreach ($UserToRemove in $UsersToRemove) {
		$SamAccountName = $UserToRemove -Replace "@hsc.wvu.edu",""
		Write-Output "Current User: $UserToRemove"
		
		$ADGroup | Remove-ADGroupMember -Members $SamAccountName -Confirm:$false
		
		Start-Sleep -s 1
		
		Write-Output "*******************************"
}