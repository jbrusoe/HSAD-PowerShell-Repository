# HSC-CommondCodeModule.psm1 - PowerShell Pester Tests
# Written by: Jeff Brusoe
# Last Updated: November 17, 2021

Describe "Get-HSCDepartmentMapPath" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force
        $DepartmentMapDirectory = "2CommonFiles\MappingFiles\"
        $DepartmentMapFullPath = $DepartmentMapDirectory + "DepartmentMap.csv"
    }

    Context "Test Correct Function Operation" {
        It "Everything Working Correctly" {
            Get-HSCDepartmentMapPath |
                Should -BeLike "*$DepartmentMapFullPath*"
        }

        It "Just Get Directory Path" {
            Get-HSCDepartmentMapPath -DirectoryOnly |
                Should -BeLike "*$DepartmentMapDirectory*"
        }

        It "Verify Not Null or Empty" {
            Get-HSCDepartmentMapPath |
                Should -Not -BeNullOrEmpty
        }
        
        It "Verify No Errors are Thrown" {
            { Get-HSCDepartmentMapPath } |
                Should -Not -Throw
        }
    }
}

Describe "Get-HSCEncryptedDirectoryPath" {

    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force
        
        $EncryptedDirectoryPath = 'GitHub\HSC-PowerShell-Repository\2CommonFiles\EncryptedFiles\'
        Write-Verbose "Encrypted Directory Path: $EncryptedDirectoryPath"
    }

    Context "Test Function Working Correctly Code" {
        It "Everthing Working Correctly" {
            Get-HSCEncryptedDirectoryPath |
                Should -BeLike "*$EncryptedDirectoryPath*"
        }
    
        It "Everything Working Correctly with Verbose" {
            Get-HSCEncryptedDirectoryPath -Verbose |
                Should -BeLike "*$EncryptedDirectoryPath*"
        }

        It "Verify Not Null or Empty" {
            Get-HSCEncryptedDirectoryPath |
                Should -Not -BeNullOrEmpty
        }

        It "Verify No Errors are Thrown" {
            { Get-HSCEncryptedDirectoryPath } |
                Should -Not -Throw
        }
    }
}

Describe "Get-HSCEncryptedFilePath" {

    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force
        
        $EncryptedDirectoryPath = 'GitHub\HSC-PowerShell-Repository\2CommonFiles\EncryptedFiles\'
        Write-Verbose "Encrypted Directory Path: $EncryptedDirectoryPath"
    }

    Context "Test Function Working Correctly Code" {
        $ServerNameTestCases = @(
            @{ServerName = "sysscript2"}
            @{ServerName = "sysscript3"}
            @{ServerName = "sysscript4"}
            @{ServerName = "sysscript5"}
            @{ServerName ="DESKTOP-1MQ9DJO"}
        )
        
        It "Everything Working Correctly" {
            Get-HSCEncryptedFilePath |
                Should -BeLike "*$EncryptedDirectoryPath*"
        }
    
        It "Everything Working Correctly with Verbose" {
            Get-HSCEncryptedFilePath -Verbose |
                Should -BeLike "*$EncryptedDirectoryPath*"
        }

        It "Everthing Working Correctly With UseSysscriptDefault" {
            Get-HSCEncryptedFilePath -UseSysscriptDefault|
                Should -BeLike "*$EncryptedDirectoryPath*"
        }

        It "Test Passing Valid Sysscript Server Names" -TestCases $ServerNameTestCases {
            param($ServerName)
            Get-HSCEncryptedFilePath -ServerName $ServerName |
                Should -BeLike "*$EncryptedDirectoryPath*"
        }
    }

    Context "Test Function Validation Code" {
        It "Pass Invalid ServerName Parameter" {
            #Tests if an error is thrown
            Get-HSCEncryptedFilePath -UseSysscriptDefault -ServerName "ABCD" |
                Should -BeNullOrEmpty
        }

        It "Pass Null Server Name" {
            { Get-HSCEncryptedFilePath -ServerName $null } |
                Should -Throw
        }

        It "Pass Null User Name" {
            { Get-HSCEncryptedFilePath -UserName $null } |
                Should -Throw
        }

        It "Pass Null Encrypted Directory Path" {
            { Get-HSCEncryptedFilePath -EncryptedDirectoryPath $null } |
                Should -Throw
        }
    }
}

Describe "Get-HSCGitHubRepoPath" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force

        $HSCGitHubRepoName = "HSC-PowerShell-Repository"

        Write-Verbose "Git Hub Repo Name: $HSCGitHubRepoName"
    }

    Context "Test Cases That Should Work" {
        It "Get Correct Repository Path" {
            Get-HSCGitHubRepoPath |
                Should -BeLike "*$HSCGitHubRepoName*"
        }

        It "Get Correct Repository Path with Verbose" {
            Get-HSCGitHubRepoPath -Verbose |
                Should -BeLike "*$HSCGitHubRepoName*"
        }
    }

    Context "Test Cases That Shouldn't Work" {
        It "Pass Invalid Path Name" {
            Get-HSCGitHubRepoPath -TopLevelPath "abcdefg" |
                Should -BeNullOrEmpty
        }

        It "Pass Null Value For FirstSearchPath Array" {
            { Get-HSCGitHubRepoPath -FirstSearchLocations $null } |
                Should -Throw
        }

        It "Pass Null Value For TopLevelPath" {
            { Get-HSCGitHubRepoPath -TopLevelPath $null } |
                Should -Throw
        }
    }
}

Describe "Get-HSCLastFile" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force
        
        for ($i = 0; $i -lt 5; $i++) {
            Add-Content "TestDrive:\TestFile$i.txt" -Value $i
        }
        
        $i--
    }

    Context "Test Cases That Should Work" {
        It "Test Function Returns a Value" {
            Get-HSCLastFile -DirectoryPath TestDrive:\ |
                Should -Not -BeNullOrEmpty
        }

        It "Test Function Returns Expected Number of Files - 1" {
            Get-HSCLastFile -DirectoryPath TestDrive:\ |
                Should -HaveCount 1
        }

        It "Test Function Returns Expected Number of Files - 2" {
            Get-HSCLastFile -DirectoryPath TestDrive:\ -NumberOfFiles 2 |
                Should -HaveCount 2
        }

        It "Test Function Returns Correct File" {
            Get-HSCLastFile -DirectoryPath TestDrive:\ |
                Should -Be "$TestDrive\TestFile$i.txt"
        }

        It "Test Function Returns Correct File with Verbose" {
            Get-HSCLastFile -DirectoryPath TestDrive:\ -Verbose |
                Should -Be "$TestDrive\TestFile$i.txt"
        }
    }

    Context "Test Cases That Should Cause Errors" {
        It "Pass Invalid Directory" {
            Get-HSCLastFIle -DirectoryPath "ABCDEFG" |
                Should -BeNullOrEmpty
        }
    }
}

Describe "Get-HSCNetworkLogFileName" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force
    }

    Context "Test Cases That Should Work" {
        It "Test Function Returns PSObject" {
            Get-HSCNetworkLogFileName -ProgramName "TestName" |
                Should -BeOfType System.Management.Automation.PSObject
        }

        It "Verifies ProgramName Parameter is Mandatory" {
            ((Get-Command Get-HSCNetworkLogFileName).Parameters['ProgramName'].Attributes |
                Where-Object { $_ -is [parameter] }).Mandatory |
                Should -BeTrue
        }

        It "Verify that one path is returned if a single name is passed in" {
            (Get-HSCNetworkLogFileName -ProgramName "TestName").Count |
                Should -Be 1
        }

        It "Verify that program name is correct in return object" {
            $LogFileObject = Get-HSCNetworkLogFileName -ProgramName "TestName"
            $LogFileObject.ProgramName |
                Should -Be "TestName"
        }

        It "Verify that program name is in log file path" {
            $LogFileObject = Get-HSCNetworkLogFileName -ProgramName "TestName"
            $LogFileObject.LogFilePath |
                Should -BeLike "*TestName*"
        }

        It "Verify that function works with -Verbose parameter" {
            $LogFileObject = Get-HSCNetworkLogFileName -ProgramName "TestName" -Verbose
            $LogFileObject.LogFilePath |
                Should -BeLike "*TestName*"
        }

        It "Verify that network log path is in log file path name" {
            $LogFileObject = Get-HSCNetworkLogFileName -ProgramName "TestName"
            $LogFileObject.LogFilePath |
                Should -BeLike $("*" + (Get-HSCNetworkLogPath) + "*")
        }

        It "Pass 2 file names into function" {
            (Get-HSCNetworkLogFileName -ProgramName "abcd","efgh").Count |
                Should -Be 2
        }

        It "Pass values in with the pipeline" {
            ("abcd","efgh" | Get-HSCNetworkLogFileName).Count |
                Should -Be 2
        }
    }

    Context "Test Cases that should throw an error" {
        It "Send an invalid LogFileType to function" {
            { Get-HSCNetworkLogFileName -ProgramName "TestName" -LogFileType "ABC" } |
                Should -Throw
        }

        It "Send an invalid FileExtension Parameter" {
            { Get-HSCNetworkLogFileName -ProgramName "TestName" -FileExtension "ABC" } |
                Should -Throw
        }
    }
}

Describe "Get-HSCNetworkLogPath" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force

        $NetworkLogPathRoot = "\\hs.wvu-ad.wvu.edu\public\ITS\Network and " +
                            "Voice Services\microsoft\HSC-Logs\"
    }
    
    Context "Tests to verify function is working correctly" {
        It "Verify that a string is returned" {
            Get-HSCNetworkLogPath |
                Should -BeOfType "System.String"
        }

        It "Verify that no errors are thrown" {
            { Get-HSCNetworkLogPath } |
                Should -Not -Throw
        }

        It "Verify that output matches network log path" {
            Get-HSCNetworkLogPath |
                Should -Be $NetworkLogPathRoot
        }

        It "Verify correct output with -Verbose switch" {
            Get-HSCNetworkLogPath -Verbose |
                Should -Be $NetworkLogPathRoot
        }
    }
}

Describe "Get-HSCPasswordFromSecureStringFile" {
    BeforeAll {
        $PasswordFile = Get-HSCEncryptedFilePath
        Write-Verbose "Password File: $PasswordFile"
    }
    
    Context "Tests to Verify Function is Working Correctly" {
        It "Verify that a String is Retured" {
            Get-HSCPasswordFromSecureStringFile |
                Should -BeOfType "System.String"
        }

        It "Make Sure Error isn't Thrown" {
            { Get-HSCPasswordFromSecureStringFile } |
                Should -Not -Throw
        }

        It "Make Sure Null Value isn't Returned" {
            Get-HSCPasswordFromSecureStringFile |
                Should -Not -BeNullOrEmpty
        }

        It "Test Operation with -Verbose" {
            Get-HSCPasswordFromSecureStringFile -Verbose |
                Should -BeOfType "System.String"
        }
    }
}

Describe "Get-HSCPowerShellVersion" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force

        $PSVersion = [string]$PSVersionTable.PSVersion.Major + "." +
            [string]$PSVersionTable.PSVersion.Minor

        Write-Verbose "PS Version: $PSVersion"
    }

    Context "Test Cases That Should Work" {
        It "Ensure Correct Version is Shown" {
            [double](Get-HSCPowerShellVersion) |
                Should -BeOfType double
        }
    
        It "Ensure Correct Vesion is Shown 2" {
            [double](Get-HSCPowerShellVersion) |
                Should -BeGreaterOrEqual 1.0
        }
    
        It "Ensure CorrectVersion is Shown 3" {
            Get-HSCPowerShellVersion |
                Should -Be $PSVersion
        }
    
        It "Test With Verbose" {
            Get-HSCPowerShellVersion -Verbose |
                Should -Be $PSVersion
        }    
    }
}

Describe "Get-HSCRandomPassword" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force

        $MinPasswordLength = 8
        $MaxPasswordLength = 20
    }

    Context "Test Cases to Verify Correct Output" {
        It "Verify Non-Null Value is Returned" {
            Get-HSCRandomPassword |
                Should -Not -BeNullOrEmpty
        }

        It "Verify Correct Length Is Returned" {
            (Get-HSCRandomPassword).Length |
                Should -BeExactly $MaxPasswordLength
        }

        It "Test Function with -Verbose" {
            Get-HSCRandomPassword -Verbose |
                Should -Not -BeNullOrEmpty
        }

        It "Test Function with Minimum Password Length" {
            (Get-HSCRandomPassword -PasswordLength $MinPasswordLength).Length |
                Should -BeExactly $MinPasswordLength

        }
    }

    Context "Test Cases to Try to Break Function" {
        It "Pass Null Valued Password Length" {
            { Get-HSCRandomPassword -PasswordLength $null } |
                Should -Throw
        }

        It "Pass Password Length Outside Allowed Range" {
            { Get-HSCRandomPassword -PasswordLength 0} |
                Should -Throw
        }
    }
}

Describe "Get-HSCServerName" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force

        $SysscriptServers = @(
            "sysscript2",
            "sysscript3",
            "sysscript4",
            "sysscript5",
            "DESKTOP-1MQ9DJO",
            "DESKTOP-DBGBDVF",
            "HSVDIWIN10JB"
	    )
    }

    Context "Test Cases That Should Produce Correct Output" {
        It "Test That JB Surface Name is Returned" {
            Get-HSCServerName |
                Should -BeIn $SysscriptServers
        }
    }
}

Describe "Invoke-HSCExitCommand" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force
    }

    Context "Test Cases That Should Produce Correct Output" {
        It "Test Normal Operation" {
            Invoke-HSCExitCommand -ErrorCount 5 -WhatIf |
                Should -Be "Final Error Count: 5"
        }

        It "Test Normal Operation with Verbose" {
            { Invoke-HSCExitCommand -WhatIf ; Stop-Transcript } |
                Should -Throw
        }
    }

    Context "Test Cases that Should Produce Errors" {
        It "Pass String into ErrorCount Parameter" {
            {Invoke-HSCExitCommand -ErrorCount "abcd" -WhatIf } |
                Should -Throw 
        }
    }
}

Describe "New-HSCSecureStringFile" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force

        Mock -ModuleName "HSC-CommonCodeModule" -CommandName "Read-Host" -MockWith {return (ConvertTo-SecureString -String "ABCDEFG" -AsPlainText -Force )}

        $Result = (New-HSCSecureStringFile -OutputDirectoryPath "TestDrive:\" -Verbose)
    }

    Context "Test Cases That Should Produce Correct Output" {
        It "Verify Result" {
            $Result | Should -BeTrue
        }
    }
}

Describe "Remove-HSCOldLogFile" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force

        for ($i = 0; $i -lt 5; $i++) {
            Add-Content "TestDrive:\TestFile$i.txt" -Value $i
        }
    }

    Context "Cases that Should Work" {
        It "Attempt to Delete .txt Files" {
            Remove-HSCOLDLogFIle -Path "TestDrive:\" -TXT |
                Should -BeExactly 0
        }

        It "Attempt to Delete .csv Files" {
            Remove-HSCOldLogFile -Path "TestDrive:\" -CSV |
                Should -BeExactly 0
        }

        It "Attempt to Delete .txt Files with -Verbose" {
            Remove-HSCOLDLogFIle -Path "TestDrive:\" -TXT -Verbose |
                Should -BeExactly 0
        }

        It "Attempt to Delete .csv Files with -Verbose" {
            Remove-HSCOldLogFile -Path "TestDrive:\" -CSV -Verbose |
                Should -BeExactly 0
        }
    }

    Context "Cases that Attempt to Cause Errors" {
        It "Pass Invalid Path" {
            Remove-HSCOldLogFile -Path "abcd" |
                Should -BeExactly -1
        }

        It "Verify Nothing Deleted if Date Criteria Not Met" {
            #-1 indicates that no file extensions were passed as parameters
            Remove-HSCOldLogFile -Path "TestDrive:\" |
                Should -BeExactly -1
        }
    }
}

Describe "Send-HSCEmail" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force
    }

    Context "Cases that Should Work" {
        It "Test Normal Operation with -WhatIf" {
            Send-HSCEmail -To "jbrusoe@hsc.wvu.edu" -Subject "testing" -MessageBody "asdf" -WhatIf |
                Should -BeTrue
        }

        It "Test Normal Operation with -WhatIf and -Verbose" {
            Send-HSCEmail -To "jbrusoe@hsc.wvu.edu" -Subject "testing" -MessageBody "asdf" -WhatIf -Verbose |
                Should -BeTrue
        }

        It "Test Normal Operation with -WhatIf with Array of Values" {
            Send-HSCEmail -To @("jbrusoe@hsc.wvu.edu","krussell@hsc.wvu.edu") -Subject "testing" -MessageBody "asdf" -WhatIf |
                Should -BeTrue
        }
    }

    Context "Cases that Should Cause Errors" {
        It "Pass Invalid To Field" {
            Send-HSCEmail -To "asdf" -Subject "testing" -MessageBody "asdf" |
                Should -BeFalse
        }

        It "Test Normal Operation with -WhatIf with Invalid Array of Values" {
            Send-HSCEmail -To @("jbrusoe@hsc.wvu.edu","krussell@hsc.wvu.edu","asdfasdf") -Subject "testing" -MessageBody "asdf" -WhatIf |
                Should -BeFalse
        }
    }
}

Describe "Set-HSCEnvironment" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force
        $LogFilePath = Set-HSCEnvironment
    }

    Context "Test Cases that Should Work" {
        It "Verify Error Variable has been Cleared" {
            $Error.Count  |
                Should -Be 0
        }

        It "Verify Correct Location" {
            Get-Location |
                Should -Be $PSScriptRoot
        }

        It "Verify Correct Log File Path" {
            $LogFilePath |
                Should -BeLike "*Logs*"
        }
    }
}

Describe "Set-HSCWindowTitle" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force
    }

    Context "Test Cases That Should Work" {
        It "Verify that Window Title Gets Changed with NUll Value" {
            Set-HSCWindowTitle -WindowTitle $null
            $Host.UI.RawUI.WindowTitle |
                Should -Be "HSC PowerShell"
        }

        It "Verify that Window Title Gets Changed when Passing a String to Function" {
            Set-HSCWindowTitle -WindowTitle "Pester Testing"
            $Host.UI.RawUI.WindowTitle |
                Should -Be "Pester Testing"
        }

        It "Test with -Verbose Parameter" {
            Set-HSCWindowTitle -WindowTitle "Pester Testing" -Verbose
            $Host.UI.RawUI.WindowTitle |
                Should -Be "Pester Testing"
        }

        It "Test with -WhatIf Parameter" {
            Set-HSCWindowTitle -WindowTitle "Pester Testing" -WhatIf |
                Should -Not -Be "Pester Testing"
        }
    }
}

Describe "Start-HSCCountdown" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force
    }

    Context "Tests That Should Work" {
        It "Make sure true value is returned" {
            Start-HSCCountdown -Seconds 1 |
                Should -BeTrue
        }

        It "Test out -WhatIf Parameter" {
            Start-HSCCountdown -WhatIf |
                Should -BeTrue
        }

        It "Test Countdown Timer with -Verbose Switch" {
            Start-HSCCountdown -Seconds 1 -Verbose |
                Should -BeTrue
        }
    }
}

Describe "Test-HSCLogFilePath" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force

        $LogFilePath = "TestDrive:\PesterLogPath"
        mkdir $LogFilePath
    }

    Context "Test Cases that Should Work" {

        It "Verify that a Created Path Returns True" {
            Test-HSCLogFilePath -LogFilePath $LogFilePath |
                Should -BeTrue
        }

        It "Verify correct operation with -Verbose switch" {
            Test-HSCLogFilePath -LogFilePath $LogFilePath -Verbose |
                Should -BeTrue
        }

        It "Verify that a null path is created" {
            Test-HSCLogFilePath -LogFilePath "TestDrive:\PesterLogPath2" -CreatePath |
                Should -BeTrue
        }
    }
}

Describe "Test-HSCPowerShell7" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force
    }

    Context "Test Cases That Should Work" {
        BeforeAll {
            Mock -ModuleName HSC-CommonCodeModule Get-HSCPowerShellVersion { return "7.2" }
        }

        It "Verify that running on PowerShell 7 returns null" {
            Test-HSCPowerShell7 |
                Should -BeNullOrEmpty
        }

        It "Verify that function works with -Verbose switch" {
            Test-HSCPowerShell7 -Verbose |
                Should -BeNullOrEmpty
        }
    }

    Context "Test Cases that should not work" {
        BeforeAll {
            Mock -ModuleName HSC-CommonCodeModule Get-HSCPowerShellVersion { return "5.1" }
        }

        It "Verify that running on PS5.1 throws an error" {
            { Test-HSCPowerShell7 } |
                Should -Throw
        }

        It "Verify that running on PS5.1 with -Verbose throws an error" {
            { Test-HSCPowerShell7 -Verbose } |
                Should -Throw
        }
    }
}

Describe "Test-HSCVerbose" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force
    }

    Context "Test Cases That Should Work" {
        It "Verify Correct Return Type" {
            Test-HSCVerbose |
                Should -BeOfType "bool"
        }
    
        It "Ensure no errors are thrown 2" {
            {Test-HSCVerbose} |
                Should -Not -Throw
        }
    
        It "Test without Verbose Parameter" {
            Test-HSCVerbose |
                Should -BeFalse
        }
    
        It "Test with Verbose Parameter" {
            Test-HSCVerbose -Verbose |
                Should -BeTrue
        }
    }
}

Describe "Update-HSCPowerShelDocumentation" {
    BeforeAll {
        Import-Module HSC-CommonCodeModule -Force

        $RootDocumentationPath = "TestDrive:\"
        $DocumentationPath = "TestDrive:\Documentation\"

        mkdir $DocumentationPath
    }

    Context "Test Correct Documentation Creation" {
        It "Create Documentation" {
            Update-HSCPowerShellDocumentation -RootOutputDirectory $RootDocumentationPath

            (Get-ChildItem $RootDocumentationPath | Measure-Object).Count |
                Should -BeGreaterThan 0
        }
    }

    Context "Test Cases That Should Cause Errors" {
        It "Pass Invalid Output Directory Path" {
            Update-HSCPowerShellDocumentation -RootOutputDirectory "TempDrive:\BadOutputDirectory" |
                Should -BeFalse
        }
    }
}