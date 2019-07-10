Function Get-BCDCurrentOSGuid
{
  <#
      .SYNOPSIS
      Returns the GUID of the currently running OS.

      .DESCRIPTION
      This function takes the output from Get-BCDStore and returns the GUID 
      of the currently running OS.

      .EXAMPLE
      Get-BCDCurrentOSGuid
      Returns the GUID of the Currently Running OS. 

      .NOTES
      Author: Holger Voges
      Version: 1.0
      Date: 2017-05-01      

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Get-BCDCurrentOSGuid

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>

  [cmdletbinding()]
  param()

  $WellKnownGUIDs = '{9dea862c-5cdd-4e70-acc1-f32b344d4795}'
  $BCDStoreAsCommonIdentifier = Get-BCDStore -UseCommonIdentifier
    
  $BCDStoreCommonIdentifier = @( $BCDStoreAsCommonIdentifier.( Get-BCDLanguage -ReturnIdentifierString ) )
  $BCDStoreCommonIdentifier += $WellKnownGUIDs
  $BCDStoreAsGUID = Get-BCDStore
    
  [array]$ResultingBCDGuids = ($BCDStoreAsGUID).( Get-BCDLanguage -ReturnIdentifierString ) | Where-Object { $_ -notin $BCDStoreCommonIdentifier }
  If ( $ResultingBCDGuids.Length -eq 2 )
  {
    $ResultingBCDGuids | Where-Object { $_ -ne $BCDStoreAsGUID.default }
  }
  Else 
  {
    $ResultingBCDGuids
  }
}