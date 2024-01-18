function New-BCDEntry
{
  <#
      .SYNOPSIS
      Add a New OS-Entry to the BCD-Store.

      .DESCRIPTION
      For new OS-Entries, this function can be used. It adds new OS-Entrys to the 
      bcd-Store using the bcdedit /create command and adding the missing values.   

      .EXAMPLE
      Add-BCDEntry -VHDPath c:\vhd\winpe.vhdx 
      Returns the GUID of the Currently Running OS. 

      .NOTES
      Author: Holger Voges
      Version: 1.0.1
      Date: 2019-05-06

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Get-BCDCurrentOSGuid

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>
  [cmdletBinding()]
  param(
    # Determines wether to boot winload.efi or winload.exe
    # If booted from Windows PE, the Firmware-Type can be determined from Registry
    [String]
    [ValidateSet('UEFI','BIOS')]
    $FirmwareType,
    
    # Path to the bootable vhd
    [Parameter(mandatory = $true,
        ParameterSetName = 'VHD',
        ValueFromPipelineByPropertyName = $true
    )]
    [validatescript({
          Test-Path $_ -Type leaf 
    })]
    $vhdPath,
    
    # Driveletter of Operating-System Partition
    [Parameter(mandatory = $true,
        ParameterSetName = 'OSDrive',
        ValueFromPipelineByPropertyName = $true
    )]
    [ValidatePattern('^([C-Zc-z]:?)$')]
    [String]$OSDriveLetter,
  
    # Description for the bootmenu
    [Parameter()]
    $description,

    # Sets the new Boot-Entry as the Default OS to Boot
    [switch]$MakeDefault,

    # Has to be set if the new OS is Windows PE
    [Switch]$WinPE,

    # If you want to disable Hyper-V for any reason
    [switch]$disableHyperV,
    
    # Forces Detection of Hardware Abstraction Layer on Bootup
    [switch]
    $detecthal,
    
    # Switches back to legacy Boot Menu which is displayed before OS Bootup
    [switch]
    $LegacyBootMenu,
    
    # Set the No Execution Features
    [string]
    [ValidateSet('OptIn','OptOut','AlwaysOn','AlwaysOff')]
    $NoExecuteSetting = 'OptOut',
    
    # Add the new Boot-Entry at the Beginning of the OS-List. Default is to put it at the end
    [switch]
    $FirstBootEntry
  )

  process 
  {
    # Deklarationsblock
    [regex]$guidpattern = '(\{[\dabcdef]{8}-[\dabcdef]{4}-[\dabcdef]{4}-[\dabcdef]{4}-[\dabcdef]{12}\})'          
    if ( -not $description )
    {
      $description = ( Get-ChildItem -Path $vhdPath ).BaseName 
    }
    If ( -not $FirmwareType )
    {
      $FirmwareType = Get-BCDFirmWareType
    }

    If ( $PsCmdlet.ParameterSetName -eq 'OsDrive' )
    {
      If ( $OSdriveLetter.Length -eq 1 )
      {
        $OSdriveLetter += ':'
      }
      if (-not ( Test-Path $OSdriveLetter ))
      {
        Throw 'Das Bootlaufwerk konnte nicht gefunden werden'
      }
      Else
      {
        $OSDrive = 'partition={0}' -f $OSDriveLetter
      }
    }
      
    # Anlegen eines neuen Betriebssystem-Eintrags und speichern der neuen GUID
    $NewBcd = bcdedit.exe /create /d $description /application osloader             
    $null = $NewBcd -match $guidpattern
    $NewBcdGuid = $Matches[0]
    
    if ( $PsCmdlet.ParameterSetName -eq 'vhd' )
    {
      $driveletter = $vhdPath.substring(0,2)
      $vhd = 'vhd=' + '[' + $driveletter + ']' + $vhdPath.Substring(2)
      $null = bcdedit.exe /set $NewBcdGuid OSDevice $vhd
      $null = bcdedit.exe /set $NewBcdGuid Device $vhd
    }
    Elseif ( $PsCmdlet.ParameterSetName -eq 'OSDrive' )
    {
      $null = bcdedit.exe /set $NewBcdGuid OSDevice $OSDrive
      $null = bcdedit.exe /set $NewBcdGuid Device $OSDrive
    }
        
    if ( $FirmwareType -eq 'UEFI' ) 
    {
      $null = bcdedit.exe /set $NewBcdGuid Path '\Windows\system32\winload.efi'
    }
    Else 
    {
      $null = bcdedit.exe /set $NewBcdGuid Path '\Windows\system32\winload.exe'
    }
    
    $null = bcdedit.exe /set $NewBcdGuid Description $description
    $null = bcdedit.exe /set $NewBcdGuid systemroot '\windows'
    $null = bcdedit.exe /set $NewBcdGuid inherit '{6efb52bf-1766-41db-a6b3-0ee5eff72bd7}'
    $null = bcdedit.exe /set $NewBcdGuid nx $NoExecuteSetting

    foreach ( $param in $PSBoundParameters )
    {
      switch ( $param.keys )
      {
        'WinPE' { 
                  $null = bcdedit.exe /set $NewBcdGuid winpe yes
                  $null = bcdedit.exe /set $NewBcdGuid detecthal yes 
                }
        'detectHal' { $null = bcdedit.exe /set $NewBcdGuid detecthal yes } 
        'LegacyBootMenu' { $null = bcdedit.exe /set $NewBcdGuid bootmenupolicy Legacy }
        'MakeDefault' { $null = bcdedit.exe /default $NewBcdGuid }
      }
    }

    If ( $DisableHyperVisor)
    { 
      $null = bcdedit.exe /set $NewBcdGuid hypervisorlaunchtype off 
    }
    Else 
    {
      $null = bcdedit.exe /set $NewBcdGuid hypervisorlaunchtype Auto
    }
    
    If ( $FirstBootEntry )    
    { $null = bcdedit.exe /displayorder $NewBcdGuid /addfirst }
    Else
    {
      $null = bcdedit.exe /displayorder $NewBcdGuid /addlast
    }
    [PSCustomObject][ordered]@{
      Identifier = $NewBcdGuid
    }
  }
}