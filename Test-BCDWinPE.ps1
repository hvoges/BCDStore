Function Test-BCDWinPE
{
  <#
      .SYNOPSIS
      Determines if OS is Windows PE 

      .DESCRIPTION
      Returns $true if OperatingSystem is Windows PE and $false if not

      .EXAMPLE
      Test-BCDWinPE

      .NOTES
      Author: Holger Voges
      Version: 1.0.0
      Date: 2017-09-23      
  #>

  [cmdletbinding()]
  param()

  If (( Get-WmiObject -Class Win32_OperatingSystem ).caption )
  {
    $false
  }
  Else
  {
    $true
  } 
}