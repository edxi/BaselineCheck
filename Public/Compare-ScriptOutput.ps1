<#
    .SYNOPSIS
    Load a pre-defined .csv file to check baseline item with Script outputs.

    .DESCRIPTION
    Read input from .csv file
    Run script block which defined in .csf file, to generate outputs.
    Compare items in .csv file with script outputs.
    Output compare results to report csv file with hostname-datetime.

    .PARAMETER csvfile
    Input a .csv file which pre-defined format.

    .EXAMPLE
    Compare-ScriptOutput baselineGP.csv

    .OUTPUTS
    The compare results to report .csv file with hostname-datetime.

    .NOTES
    Author: Xi ErDe
    Date:   Jan 14, 2018
#>

function Compare-ScriptOutput {
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
    }

    process {
        # Import baseline items from .csv file
        $allBaselineSettings = @()
        foreach ($acsvfile in $csvfile) {
            $allBaselineSettings += Import-Csv -Path $acsvfile
        }

        $allBaselineSettings | Where-Object {$_.ScriptBlock -ne ''} | ForEach-Object {
            $_.ItemName
        }
    }

    end {
    }
}