<#
    .SYNOPSIS
    Load a pre-defined .csv file to check baseline item with RSOP xml outputs.

    .DESCRIPTION
    Reads input from .csv file
    Runs gpresult.exe to generates RSOP xml.
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
        $csvfile
        while ($csvfile[0] -eq '') {$csvfile = Get-FileName}
        & "$env:windir\system32\gpresult.exe" /x $env:TEMP\results.xml /f
    }

    process {
        # Import GP items from .csv file
        $allGpoSettings = @()
        foreach ($acsvfile in $csvfile) {
            $allGpoSettings += Import-Csv -Path $acsvfile
        }

        $allGpoSettings | Where-Object {$_.Extension -ne ''-and $_.Where -ne '' -and $_.Is -ne ''} | ForEach-Object {
            Find-RsopSetting -rsopxml ..\Tests\results.xml `
                -Extension $_.Extension `
                -Where $_.Where `
                -Is $_.Is `
                -Return $_.Return
            $_.ItemName
        }
    }

    end {
    }
}