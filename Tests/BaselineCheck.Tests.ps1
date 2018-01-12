$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

$PSVersion = $PSVersionTable.PSVersion.Major
$ModuleManifestName = 'BaselineCheck.psd1'
Import-Module $PSScriptRoot\..\$ModuleManifestName

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $PSScriptRoot\..\$ModuleManifestName
        $? | Should Be $true
    }
}


# #Integration test example
# Describe "Get-SEObject PS$PSVersion Integrations tests" {

#     Context 'Strict mode' {

#         Set-StrictMode -Version latest

#         It 'should get valid data' {
#             $Output = Get-SEObject -Object sites
#             $Output.count -gt 100 | Should be $True
#             $Output.name -contains 'stack overflow'
#         }
#     }
# }

# #Unit test example
# Describe "Get-SEObject PS$PSVersion Unit tests" {

#     Mock -ModuleName PSStackExchange -CommandName Get-SEData { $Args }
#     Context 'Strict mode' {

#         Set-StrictMode -Version latest

#         It 'should call Get-SEData' {
#             $Output = Get-SEObject -Object sites
#             Assert-MockCalled -CommandName Get-SEData -Scope It -ModuleName PSStackExchange
#         }

#         It 'should pass the right arguments to Get-SEData' {
#             $Output = Get-SEObject -Object sites

#             # Verify Maxresults
#             $Output[3] | Should Be ([int]::MaxValue)

#             # Verify IRMParams
#             # Hard coding this expected value is delicate, will break if default URI or Version parameter values change
#             $Output[1].Uri | Should Be 'https://api.stackexchange.com/2.2/sites'

#             $Output[1].Body.Pagesize | Should Be 30
#         }

#     }
# }

# $WorkspaceRoot = Convert-Path $PSScriptRoot/..
# Set-Location $WorkspaceRoot

# $rsopxml = [xml] (Get-Content -Path $PSScriptRoot\results.xml)
# $rsopxml

# Describe 'Verify Path Processing for Non-existing Paths Allowed Impl' {
#     It 'Processes non-wildcard absolute path to non-existing file via -Path param' {
#         New-File -Path $WorkspaceRoot\ReadmeNew.md | Should Be "$WorkspaceRoot\READMENew.md"
#     }
#     It 'Processes multiple absolute paths via -Path param' {
#         New-File -Path $WorkspaceRoot\Readme.md, $WorkspaceRoot\XYZZY.ps1 |
#             Should Be @("$WorkspaceRoot\README.md", "$WorkspaceRoot\XYZZY.ps1")
#     }
#     It 'Processes relative path via -Path param' {
#         New-File -Path ..\Examples\READMENew.md | Should Be "$WorkspaceRoot\READMENew.md"
#     }
#     It 'Processes multiple relative path via -Path param' {
#         New-File -Path ..\Examples\README.md, XYZZY.ps1 |
#             Should Be @("$WorkspaceRoot\README.md", "$WorkspaceRoot\XYZZY.ps1")
#     }

#     It 'Should accept pipeline input to Path' {
#         Get-ChildItem -LiteralPath "$WorkspaceRoot\Tests\foo[1].txt" | New-File | Should Be "$PSScriptRoot\foo[1].txt"
#     }
# }
