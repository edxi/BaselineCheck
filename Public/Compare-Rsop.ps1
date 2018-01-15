<#
    .SYNOPSIS
    Load a pre-defined .csv file to check baseline item with RSOP xml outputs.

    .DESCRIPTION
    Read input from .csv file
    Run gpresult.exe to generate RSOP xml.
    Compare items in .csv file with RSOP xml.
    Output compare results to report csv file with hostname-datetime.

    .PARAMETER csvfile
    Input a .csv file which pre-defined format.

    .EXAMPLE
    Compare-Rsop baselineGP.csv

    .OUTPUTS
    The compare results to report csv file with hostname-datetime.

    .LINK
    Find-RsopSetting

    .NOTES
    Author: Xi ErDe
    Date:   Jan 2, 2018
#>

function Compare-Rsop {
    param (
        [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'csvfile')]
        [Parameter(
            Position = 0,
            ParameterSetName = 'csvfile',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Path to one or more csv file.')]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $csvfile = ''
    )

    begin {
        while ($csvfile[0] -eq '') {$csvfile = Get-FileName}
        & "$env:windir\system32\gpresult.exe" /scope COMPUTER /x $env:TEMP\results.xml /f
        $allGpoSettings = @()
    }

    process {
        # Import GP items from .csv file
        foreach ($acsvfile in $csvfile) {
            $allGpoSettings += Import-Csv -Path $acsvfile
        }

        if (($allGpoSettings |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -notcontains 'Actual Value') {
            $allGpoSettings | Add-Member -Name "Actual Value" -MemberType NoteProperty
        }
        if (($allGpoSettings |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -notcontains 'Check Result') {
            $allGpoSettings | Add-Member -Name "Check Result" -MemberType NoteProperty
        }
        $allGpoSettings | Where-Object {$_.Extension -ne ''-and $_.Where -ne '' -and $_.Is -ne '' -and $_.Return -ne ''} | ForEach-Object {
            $_.'Actual Value' = Find-RsopSetting -rsopxml $env:TEMP\results.xml `
                -Extension $_.Extension `
                -Where $_.Where `
                -Is $_.Is `
                -Return $_.Return
            if ($_.'Actual Value' -eq $_.'Baseline Value'){
                $_.'Check Result' = 'Compliance'
            }
            else {
                $_.'Check Result' = 'Not Compliance'
            }
        }
    }

    end {
        $allGpoSettings | Export-Csv -Path "$env:TEMP\$env:COMPUTERNAME-$(Get-Date -UFormat "%Y%m%d-%H%M%S").csv" -NoTypeInformation
    }
}