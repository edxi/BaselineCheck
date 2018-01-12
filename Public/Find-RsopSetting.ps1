<#
    .SYNOPSIS
    Recursively search the RSOP xml to get the setting item.

    .DESCRIPTION
    Recursively search the RSOP xml to get the setting item.
    Refer the RSOP xml to define parameter '$Where $Is $Return'.
    The return value would has a list if more than one element found.

    .PARAMETER rsopxml
    RSOP xml file name.

    .PARAMETER IsComputerConfiguration
    Identify the namespace which need be searched.

    .PARAMETER Extension
    Identify the extesion namespace.

    .PARAMETER Where
    Element name which looking for.

    .PARAMETER Is
    Element content which looking for.

    .PARAMETER Return
    Element content would be return.

    .EXAMPLE
    $rsopfiles = @('.\Tests\results.xml', 'results2.xml')
    $rsopfiles | Find-RsopSetting -Extension Registry -Where 'Name' -Is 'LockoutDuration' -Return 'SettingNumber'
    It searches the $rsopfiles, and return GP settings one by one.

    .INPUTS
    RSOP xml file name.

    .OUTPUTS
    If $Return defines, function returns the element content.
    If $Return does not define, returns $true if element could be found.

    .LINK
    Find-XmlNodes
#>

function Find-RsopSetting {
    param (
        [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'rsopxml')]
        [bool] $IsComputerConfiguration = $true,
        [Parameter(Mandatory = $true,
            Position = 0,
            ParameterSetName = 'rsopxml',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Path to one or more gpresult xml.')]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $rsopxml,
        [Parameter(Mandatory = $true, HelpMessage = 'Extension name')]
        [ValidateNotNullOrEmpty()]
        [string] $Extension,
        [Parameter(Mandatory = $true, HelpMessage = 'Extension element name which looking for')]
        [ValidateNotNullOrEmpty()]
        [string] $Where,
        [Parameter(Mandatory = $true, HelpMessage = 'Extension element content which looking for')]
        [ValidateNotNullOrEmpty()]
        [string] $Is,
        [string] $Return = $null
    )

    begin {
        $xmlnsGpSettings = 'http://www.microsoft.com/GroupPolicy/Settings'
        $xmlnsGpSettingsBase = 'http://www.microsoft.com/GroupPolicy/Settings/Base'
        $xmlnsGpTypes = 'http://www.microsoft.com/GroupPolicy/Types'
        $xmlnsSchemaInstance = 'http://www.w3.org/2001/XMLSchema-instance'
        $xmlnsSchema = 'http://www.w3.org/2001/XMLSchema'

        $QueryString = '//df:Rsop/df:'

        if ($IsComputerConfiguration) {
            $QueryString += 'ComputerResults/df:ExtensionData/ex:Extension'
        }
        else {
            $QueryString += 'UserResults/df:ExtensionData/ex:Extension'
        }

        $ValueReturn = ''
    }

    process {
        foreach ($onersopxml in $rsopxml) {
            $xmlDoc = [xml] (Get-Content -Path $onersopxml)

            $xmlNameSpaceMgr = New-Object -TypeName System.Xml.XmlNamespaceManager -ArgumentList ($xmlDoc.NameTable)
            $xmlNameSpaceMgr.AddNamespace('df', $xmlDoc.Rsop.xmlns)
            $xmlNameSpaceMgr.AddNamespace('xsi', $xmlnsSchemaInstance)
            $xmlNameSpaceMgr.AddNamespace('xsd', $xmlnsSchema)
            $xmlNameSpaceMgr.AddNamespace('ex', $xmlnsGpSettings)
            $xmlNameSpaceMgr.AddNamespace('base', $xmlnsGpSettingsBase)
            $xmlNameSpaceMgr.AddNamespace('types', $xmlnsGpTypes)

            $extensionNodes = $xmlDoc.DocumentElement.SelectNodes($QueryString, $XmlNameSpaceMgr)

            foreach ($extensionNode in $extensionNodes) {
                if ([String]::Compare(($extensionNode.Attributes.Item(0)).Value,
                        'http://www.microsoft.com/GroupPolicy/Settings/' + $Extension, $true) -eq 0) {
                    # We have found the Extension we are looking for now recursively search
                    # for $Where (the property we are looking for a specific value of).

                    $ValueReturn = (Find-XmlNodes -nodes $extensionNode.ChildNodes -foundWhere $false -Where $Where -Is $Is -Return $Return)
                }
            }
            $ValueReturn
        }
    }

    end {
    }
}