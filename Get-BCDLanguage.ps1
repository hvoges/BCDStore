Function Get-BCDLanguage
{
  <#
      .SYNOPSIS
      Returns the language which the BCD-Store uses to show entries. Helper-Function for Get-BCDCurrentEntry
      
      .DESCRIPTION
      Returns Language-Code or "Windows Boot Loader" / "Windows-Startladeprogramm", depending on the used language

      .EXAMPLE
      Get-BCDLanguage -ReturnIdentifierString
      Returns en-us or de-de, depending on the language

      .NOTES
      Author: Holger Voges
      Version: 1.0.0
      Date: 2017-06-24      
  #>
  [cmdLetBinding()]
  param
  (
    [Switch]$ReturnIdentifierString
  )

  $Store = Bcdedit /v

  If ( $ReturnIdentifierString ) 
  {
    Switch ( $Store )
    {
      { $Store.Contains( "Windows Boot Loader" )} { "identifier"; break }
      { $Store.Contains( "Windows-Startladeprogramm")} { "Bezeichner"; break }
    } 
  }
  Else 
  {
    Switch ( $Store )
    {
      { $Store.Contains( "Windows Boot Loader" )} { "en-us"; break }
      { $Store.Contains( "Windows-Startladeprogramm")} { "de-de"; break }
    }
  }
}