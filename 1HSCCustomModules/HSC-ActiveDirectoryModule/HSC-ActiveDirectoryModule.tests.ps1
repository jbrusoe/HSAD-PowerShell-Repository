# HSC Active Directory Module - Pester Tests
# Written by: Jeff Brusoe
# Last Updated: July 7 2021

BeforeAll {
    $DefaultSAM = "DefaultSAM"
    
    $ADUserObject = [PSCustomObject]@{
        SamAccountName = $DefaultSAM
        LastName = "Microsoft"
        Enabled = $true
        UserPrincipalName = "$DefaultSAM@hsc.wvu.edu"
        DistinguishedName = "CN=$DefaultSAM,OU=SOM,OU=HSC,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU"
    }

    function Get-ADUser {
        param (
            [string]$LDAPFilter,
            [string[]]$Properties,
            [string]$Filter
        )

        $ADUserObject 
    }

    Mock -CommandName "Get-ADUser" -ParameterFilter {$Properties -OR $LDAPFilter} -MockWith {
        foreach ($Property in $Properties) {
            if ($Property -eq "proxyAddresses") {
                $ProxyAddresses = @(
                    "$DefaultSAM@hsc.wvu.edu"
                    "$DefaultSAM.Microsoft@hsc.wvu.edu"
                    "$DefaultSAM@wvuhsc.onmicrosoft.com"
                )
    
                $ADUserObject += @{proxyAddresses = $ProxyAddresses}
            }

            if ($Property -eq "mail") {
                $ADUserObject += @{mail="$DefaultSAM@hsc.wvu.edu"}
            }
        }

        if (![string]::IsNullOrEmpty($LDAPFilter)) {
            $ADUserObject += @{LDAPFilter=$LDAPFilter}
        }

        $ADUserObject
    }
}

Describe "ActiveDirectoryFunctionMocks" {
    BeforeAll {
        Import-Module HSC-ActiveDirectoryModule -Force
    }

    Context "Tests Cases That Should Work" {
        It "Test Get-ADUser" {
            $ADUser = Get-ADUser

            $ADUser.SamAccountName |
                Should -Be $DefaultSAM
        }

        It "Test Get-ADUser with LDAPFilter" {
            $LDAPFilterTest = "(samAccountName=$DefaultSAM)"

            $ADUser = Get-ADUser -LDAPFilter $LDAPFilterTest
            
            $ADUser.LDAPFilter |
                Should -Be $LDAPFilterTest
        }

        It "Test Get-ADUser with ProxyAddresses" {
            $ADUser = Get-ADUser -Properties "proxyAddresses"

            $ADUser.proxyAddresses |
                Should -HaveCount 3
        }

        It "Test Get-ADUser with mail Attribute" {
            $ADUser = Get-ADUser -Properties "mail"

            $ADUser.mail |
                Should -Be "$DefaultSAM@hsc.wvu.edu"
        }
    }
}

Describe "Get-ADUserParentContainer" {
    Context "Test Cases That Should Pass" {
        It 
    }
}