function Get-BCDStore
{
  <#
      .SYNOPSIS
      Returns the BCD-Store

      .DESCRIPTION
      This Function utilizies BCDEdit.exe to read the BCD-Store and Returns it as Objects.
      The First Element in the Array contains the Bootmanager-Settings. If you call Get-BCDStore without
      Parameter, it returns the verbose Output using the GUIDs for each Boot-Entry. The
      Parameter -UseCommonIdentifier returns the common Identifiers {Bootmgr} and {current}
      instead of GUIDs.

      .EXAMPLE
      Get-BCDStore -UseCommonIdentifier
      Returns Common Identifieres {Bootmgr}, {Current} instead of their GUIDs

      .NOTES
      Author: Holger Voges
      Version: 2.0.1
      Date: 2019-05-09

      .OUTPUTS
      System.Object[]

  #>

  [cmdletbinding(DefaultParameterSetName='NoBootmanager')]
  param(
    # Uses well known Identifieres like {current}
    [switch]$UseCommonIdentifier,

    # Shows the BootManager Boot Entry
    [Parameter(ParameterSetName='NoBootmanager')]
    [switch]$NoBootManagerData,
    
    [Parameter(ParameterSetName='BootManagerOnly')]
    # Shows the BootManager Boot Entry
    [switch]$ShowBootManagerOnly
  )

    $BcdEntryPattern = '^(?!Windows)(\w+)\s+(.*)'
    $SeparatorPattern = "-{3,}"
    If ( $UseCommonIdentifier )
    {
        $Bcd = bcdedit
    }
    Else 
    {
        $Bcd = bcdedit /v
    }

    [array]$BcdStore = for ( $i = 0; $i -lt $Bcd.Length; $i++ )
    {
      If ( $Bcd[$i] -match $BcdEntryPattern )
      {
        If ( $matches[1] -eq 'Bezeichner' )
        {
            $BCDEntry["Identifier"] = $matches[2]
        }
        Else {
            $BCDEntry[$matches[1]] = $matches[2]
        }
      }
      ElseIf (( $Bcd[$i] -match $SeparatorPattern ))
      {
        If ( $BcdEntry ) { [PSCustomObject]$BcdEntry }
        $BCDentry = [ordered]@{}
      }
    }
    $BcdStore += [PSCustomObject]$BCDEntry

    Switch ( $NoBootManagerData )
    {
        { $NoBootManagerData } { $BcdStore | Where-Object { $_.Identifier -ne '{9dea862c-5cdd-4e70-acc1-f32b344d4795}' }  }
        { $ShowBootManagerOnly } { $BcdStore | Where-Object { $_.Identifier -eq '{9dea862c-5cdd-4e70-acc1-f32b344d4795}' }  }
        default { $BcdStore }
    }
}