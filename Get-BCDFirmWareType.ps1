function Get-BCDFirmWareType
{
  <#
      .SYNOPSIS
      Determines kind of Firmwaretype. 

      .DESCRIPTION
      This functions works only on Windows PE and determines the Type of Bios from the the Registry. Return-Values are Legacy 
      or UEFI or $true/$false if $ReturnUEFI was chosen

      .EXAMPLE
      Get-BCDFirmWareType
      Returns UEFI or Legacy

      .EXAMPLE
      Get-BCDFirmWareType -UEFI
      Returns $true if Firmwaretype is UEFI or $false for Legacy-Bios


      .NOTES
      Author: Holger Voges
      Version: 1.0.1
      Date: 2019-05-06
  #>
  [cmdletbinding()]
  param(
    # Returns $true instead of 'UEFI' or $false instead of 'BIOS'
    [Switch]$Silent
  )
  
    If ( $FirmWareType = ( Get-ItemProperty -Path "Registry::Hkey_Local_machine\System\CurrentControlSet\Control\" -Name PEFirmwareType -ErrorAction SilentlyContinue ).PEFirmwareType )
    {
        Switch ( $FirmWareType )
        {
            1 { If ( $Silent ) { $False } Else { "BIOS" } }
            2 { If ( $Silent ) { $true } Else { "UEFI" } }
        }
    }
    Else    
    {
        If (( Get-BCDCurrentEntry ).path -like "*.efi")
        {
            If ( $Silent ) { $true } Else { "UEFI" } 
        }
        Else
        {
            If ( $Silent ) { $False } Else { "BIOS" }
        }
    }
}