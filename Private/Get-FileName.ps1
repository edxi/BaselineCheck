<#
    .SYNOPSIS
    Get a file from GUI.

    .DESCRIPTION
    Show a windows form to select the input file
    Return the filename text with full path.

    .PARAMETER initialDirectory
    The file selection window shows in initial directory.

    .EXAMPLE
    Get-FileName -initialDirectory c:\temp
    The file selection window would start at c:\temp.
#>

Function Get-FileName {
    [CmdletBinding()]
    Param(
        [string]$initialDirectory = '.'
    )
    $null = Add-Type -AssemblyName System.windows.forms

    $OpenFileDialog = New-Object -TypeName System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = 'CSV (*.csv)| *.csv'
    $null = $OpenFileDialog.ShowDialog()
    return $OpenFileDialog.filename
}