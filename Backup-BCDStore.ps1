function Backup-BCDStore
{
param(
    [ValidateScript({ switch ( $_)
                      {
                         {!(Test-Path -path ( split-path -Path $_ -Parent ) -PathType Container )}
                            { Throw "Please enter a valid target-folder" }
                         {(Test-Path -path $_ -pathtype leaf )} 
                            { Throw "The File already exists" }
                         {(Test-Path -path $_ -pathtype Container )} 
                            { Throw "You only entered a folder, but Backup needs a filename" }
                      }
                      $true
                    })]
    [Parameter(Mandatory=$true)]
    [string]$path
)
    $null = bcdedit.exe /Export $path
    Write-Verbose -Message "Backup $Path angelegt"
}