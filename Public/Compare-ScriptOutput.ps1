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
        $allBaselineSettings = @()
    }

    process {
        # Import baseline items from .csv file
        foreach ($acsvfile in $csvfile) {
            $allBaselineSettings += Import-Csv -Path $acsvfile
        }

        if (($allBaselineSettings |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -notcontains 'Actual Value') {
            $allBaselineSettings | Add-Member -Name "Actual Value" -MemberType NoteProperty
        }
        if (($allBaselineSettings |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -notcontains 'Check Result') {
            $allBaselineSettings | Add-Member -Name "Check Result" -MemberType NoteProperty
        }

        $allBaselineSettings | Where-Object {$_.Script -ne '' -and $_.'Baseline Value' -ne ''} | ForEach-Object {
            $ScriptReturn = &([Scriptblock]::Create($_.Script))
            $_.'Actual Value' = $ScriptReturn['Actual Value']
            $_.'Check Result' = $ScriptReturn['Check Result']
        }
    }

    end {
        $allBaselineSettings | Export-Csv -Path "$env:TEMP\$env:COMPUTERNAME-$(Get-Date -UFormat "%Y%m%d-%H%M%S").csv" -NoTypeInformation
    }
}