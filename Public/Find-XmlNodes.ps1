<#
    .SYNOPSIS
    Recursively search the property we are looking for a specific value of.

    .DESCRIPTION
    Recursively search the property we are looking for a specific value of.
    Regardless the xml is RSOP results or others.

    .PARAMETER nodes
    xmlnode which need be searched.

    .PARAMETER foundWhere
    Use this parameter to control search for element or return value.

    .PARAMETER Where
    Element name which looking for.

    .PARAMETER Is
    Element content which looking for.

    .PARAMETER Return
    Element content would be return.

    .EXAMPLE
    $xmlnodes = $xmlDoc.DocumentElement.SelectNodes($QueryString, $XmlNameSpaceMgr)
    Find-XmlNodes -nodes $xmlnodes[0] -Where 'Name' -Is 'BatMan' -Return 'Vehicle'
    It searches the xmlnode, and referes the global variables '$Where $Is $Return'.
    Since the example defines $Return, it would return the 'Vehicle' element content.

   .INPUTS
    xmlnode which need be searched.

    .OUTPUTS
    If $Return defines, function returns the element content.
    If $Return does not define, returns $true if element could be found.
#>

function Find-XmlNodes {
    [CmdletBinding(DefaultParameterSetName = 'nodes')]
    [Alias()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            HelpMessage = 'xmlnode which need be searched')]
        $nodes,
        [bool] $foundWhere = $false,
        [Parameter(Mandatory = $true, HelpMessage = 'Extension element name which looking for')]
        [ValidateNotNullOrEmpty()]
        [string] $Where,
        [Parameter(Mandatory = $true, HelpMessage = 'Extension element content which looking for')]
        [ValidateNotNullOrEmpty()]
        [string] $Is,
        [string] $Return = $null
    )

    begin {
    }

    process	{
        $thePropertyWeWant = $Where

        # If we already found the $Where then we are looking for our $Return value now.
        if ($foundWhere) {
            $thePropertyWeWant = $Return
        }

        foreach ($node in $nodes) {
            $valueWeFound = $null

            #Here we are checking siblings
            $lookingFor = Get-Member -InputObject $node -Name $thePropertyWeWant

            if ($lookingFor -ne $null) {
                $valueWeFound = $node.($lookingFor.Name)
            }
            else {
                #Here we are checking attributes.
                if ($node.Attributes -ne $null) {
                    $lookingFor = $node.Attributes.GetNamedItem($thePropertyWeWant)


                    if ( $lookingFor -ne $null) {
                        $valueWeFound = $lookingFor
                    }
                }
            }

            if ( $lookingFor -ne $null) {
                #If we haven't found the $Where yet, then we may have found it now.
                if (! $foundWhere) {
                    # We have found the $Where if it has the value we want.
                    if ( [String]::Compare($valueWeFound, $Is, $true) -eq 0 ) {
                        # Ok it has the value we want too.  Now, are we looking for a specific
                        # sibling or child of this node or are we done here?
                        if ($Return -eq $null -or $Return -eq '') {
                            #we are done, there is no $Return to look for
                            return $true
                        }
                        else {
                            # Now lets look for $Return in the siblings and then if no go, the children.
                            Find-XmlNodes -nodes $node -foundWhere $true -Where $Where -Is $Is -Return $Return
                        }
                    }

                }
                else {
                    #we are done.  We already found the $Where, and now we have found the $Return.
                    if (! [String]::IsNullOrEmpty($node.InnerXml)) {
                        Find-XmlNodes -nodes $node.ChildNodes -foundWhere $foundWhere -Where $Where -Is $Is -Return $Return
                    }
                    else {
                        return $valueWeFound
                    }
                }
            }

            if (! [String]::IsNullOrEmpty($node.InnerXml)) {
                Find-XmlNodes -nodes $node.ChildNodes -foundWhere $foundWhere -Where $Where -Is $Is -Return $Return
            }
        }
    }

    end {
    }
}