Function Get-FilepathFromBCDEntry {
<#
.SYNOPSIS
    Extracts the file path from a Windows Boot Configuration Data (BCD) entry.

.DESCRIPTION
    The Get-FilepathFromBCDEntry function takes a BCD entry string and extracts the file path of the device. 
    It is particularly useful for parsing out the file path of a Virtual Hard Disk (VHD) from the BCD entry.

.PARAMETER DeviceString
    The BCD entry string from which the file path is to be extracted. 
    This parameter is mandatory and can be passed either directly or via the pipeline.
    It accepts an alias 'Device'.

.EXAMPLE
    PS> Get-FilepathFromBCDEntry -DeviceString "vhd=[C:]\path\to\file.vhd,"
    This example will extract and return the file path 'C:\path\to\file.vhd' from the provided BCD entry string.

.INPUTS
    String
    You can pipe a string to Get-FilepathFromBCDEntry.

.OUTPUTS
    String
    The function returns the extracted file path as a string.

.NOTES
    Version:        1.0
    Author:         Holger Voges
    Creation Date:  2024-01-18
#>
    Param( 
        [Parameter(mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [Alias('Device')]
        [String]$DeviceString
    )

Process {
    $RegExImageFile = "device\s+vhd=\[(?<Driveletter>\w\:)\](?<Path>.*),"
    If ( $DeviceString -match $RegExImageFile ) {
        Return $Matches.Driveletter + $Matches.Path
    }
}        
}