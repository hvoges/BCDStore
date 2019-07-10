function New-BCDStore
{
  <#
      .SYNOPSIS
      Creates a Windows BCD-Store from Scratch. 

      .DESCRIPTION
      Use New-BCDStore to create a new BCD-Store for Windows. 

      .EXAMPLE
      New-BCDStore -bootdriveLetter c: 

      .NOTES
      Author: Holger Voges
      Version: 1.0.0
      Date: 2017-09-23      
  #>
  param
  (
    # Defines which Type of Start-Partition shall be created. If no Firmwaretype is set, the Firmwaretype 
    # will be determined automatically by the Host-Firmware
    [String]
    [Parameter()]
    [ValidateSet('UEFI','BIOS')]
    $FirmwareType,
        
    [String]
    [ValidatePattern('^([C-Zc-z]:?)$')]
    $BootdriveLetter,
    
    [int]
    $BootmanagerTimeout = 30
  )

  If (-not $FirmwareType)
  { 
    $FirmwareType = Get-BCDFirmWareType
  }
  
  $EfiBootmgrPath = '\efi\microsoft\boot'
  If ( $BootdriveLetter.Length -eq 1 )
  {
    $BootdriveLetter += ':'
  }
  if (-not ( Test-Path $BootdriveLetter ))
  {
    Throw 'Das Bootlaufwerk konnte nicht gefunden werden'
  }
  
  bcdedit /createstore bcdTemplate
  bcdedit /import bcdTemplate
  Remove-Item bcdTemplate -Force
  bcdedit /create '{bootmgr}'
  bcdedit /set '{bootmgr}' device partition=$BootdriveLetter
  bcdedit /timeout $BootmanagerTimeout
  bcdedit /set '{bootmgr}' description "Windows Boot Manager"
  
  If ( $FirmwareType -eq 'UEFI' )
  {
    bcdedit /set "{bootmgr}" path ('{0}\bootmgfw.efi' -f $EfiBootmgrPath)
    Copy-Item -Path "$env:windir\boot\EFI\*" -Destination ( Join-Path  -Path $BootdriveLetter -ChildPath $EfiBootmgrPath ) -Force 
  }
  Else 
  {
    Copy-Item -Path "$env:windir\boot\PCAT\*" -Destination ( Join-Path -path $BootdriveLetter -ChildPath \boot\ ) -Force
  }
}