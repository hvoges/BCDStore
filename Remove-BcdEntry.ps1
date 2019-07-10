Function Remove-BcdEntry
{
<#
    .SYNOPSIS
    Removes a complete BootEntry from the Store

    .DESCRIPTION
    This Function utilizies BCDEdit.exe to 

    .EXAMPLE
    Get-BCDStore -UseCommonIdentifier
    Returns Common Identifieres {Bootmgr}, {Current} instead of their GUIDs

    .NOTES
    Author: Holger Voges
    Version: 2.0
    Date: 2019-04-25

    .OUTPUTS
    System.Object[]

#>
[CmdletBinding(SupportsShouldProcess=$True)]
param(
    [Parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true,
               ValueFromPipeline=$true)]
    [Alias('Bezeichner','GUID')]
    [GUID]$Identifier
)

    Begin
    {
        [RegEx]$guid = '[\dA-Fa-f]{8}-(?:[\dA-Fa-f]{4}-){3}[\dA-Fa-f]{12}'
    }

    process
    {
        Write-Verbose -Message ($Identifier).Guid
        if ( $PSCmdlet.ShouldProcess($Identifier,"Remove"))
        {
            $ReturnMessage = bcdedit.exe /delete ('{{{0}}}' -f ($Identifier).Guid)
        }
    }
}