Function Set-BcdEntry
{
[CmdletBinding()]
param(
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true)]
        [Alias('Bezeichner','GUID')]
        [GUID]$Identifier,

        [ValidateSet('device','path','description','locale','systemRoot','bootmenupolicy','hypervisorlaunchtype','bootmenupolicy')]
        $BootOption,

        [string]$Value
    )

    process
    {
        bcdedit /set ("{{{0}}}" -f ( $Identifier ).Guid) $BootOption $Value
    }
}