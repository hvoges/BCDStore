Function Get-BCDEntry 
{
  <#
      .SYNOPSIS
      Helper-Function for Get-BCDStore. Returns a Hash-Array for each 
      entry in the given Text-Array. 

      .DESCRIPTION
      This function can split an array of Key-Value-Pairs into an Hash-Array.

      .EXAMPLE
      Get-BCDEntry -StartLine 3 -bcdstore $BcdStoreArray
      Describe what this call does

      .NOTES
      Author: Holger Voges
      Version: 1.0
      Date: 2017-05-01

      .OUTPUTS
      System.Collections.Specialized.OrderedDictionary
  #>

  [cmdletbinding(DefaultParameterSetName='Filter')]
  param(  
    # Returns only the given Identifier
    [Parameter(Mandatory=$true,
        ParameterSetName='Identifier',
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true
    )]
    [Alias('Bezeichner','GUID')]
    [GUID[]]$Identifier,
    
    # Filter the Description-Property for the given RegEx-Pattern
    [Parameter(ParameterSetName='Filter')]
    [string]$Description,
    
    # Filter the Device-Property for the given RegEx-Pattern 
    [Parameter(ParameterSetName='Filter')]
    $Device,
    
    <#    # Returns the OS which is set to Default
        [switch]$DefaultOS, 
    #>
    # Returns the Entry which is currently booted 
    [Parameter(Mandatory=$true,
    ParameterSetName='Current')]
    [Switch]$Current,
    
    # Only Return Boot-Entries for Windows PE
    [Parameter(ParameterSetName='Filter')]    
    [switch]$WinPe
  )
  
  Begin 
  {
    $BcdStore = Get-BCDStore -NoBootManagerData
  }
  
  Process 
  {
    Switch ( $PSBoundParameters )
    {
      { $_.ContainsKey('Identifier') } { $BcdStore = $BcdStore | Where-Object { ( $_.Identifier -replace '{|}','' ) -contains ($Identifier).Guid }}
      { $_.ContainsKey('Current') }    { 
        If ( $DefaultGuid = (Get-BCDStore -ShowBootManagerOnly).default )
        {
          $null = Bcdedit /deletevalue "{bootmgr}" default
        }
        $BcdGuids = [GUID[]]($BcdStore).Identifier
        $BcdGuidsExcludeCurrent = ( Get-BCDStore -UseCommonIdentifier ).identifier | ForEach-Object { $_ -as [GUID] }
        $BcdStore = $BcdGuids | Where-Object { $_.GUID -notin $BcdGuidsExcludeCurrent.Guid } | Get-BCDEntry 
        If ( $DefaultGuid )
        {
          $null = Bcdedit /Default $DefaultGuid
        }
        break
      }
      { $_.ContainsKey('Description')} { $BcdStore = $BcdStore | Where-Object { $_.Description -match $Description }}
      { $_.ContainsKey('Device') }     { $BcdStore = $BcdStore | Where-Object { $_.Device -match $Device }}
      { $_.ContainsKey('WinPe') }      { $BcdStore = $BcdStore | Where-Object { $_.WinPe -eq "Yes" }}
    }
  }
  
  End
  {
    $BcdStore
  }
}