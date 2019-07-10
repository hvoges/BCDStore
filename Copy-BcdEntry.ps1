Function Copy-BcdEntry
{
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true,
               ValueFromPipeline=$true)]
    [Alias('Bezeichner','GUID')]
    [GUID]$Identifier, 

    # The Description for the new BCD-Entry
    [string]$Description,

    # Returns the New Entries
    [switch]$PassThru
)

Begin
{
    [RegEx]$guid = '[\dA-Fa-f]{8}-(?:[\dA-Fa-f]{4}-){3}[\dA-Fa-f]{12}'
}

process
{
    If (-not $Description )
    {
        $Description = (Get-BCDStore -Identifier ( $Identifier )).Device.split(",")[0]
    }
    $NewEntryIdentifier = $Guid.Matches(( bcdedit /copy ('{{{0}}}' -f $Identifier) /d $Description )).Value
    Write-Verbose -Message $NewEntryIdentifier
    If ( $PassThru )
    {
        Get-BCDStore -Identifier $NewEntryIdentifier
    }
}
}