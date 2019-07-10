function Set-BCDDefaultOS
{
  <#
      .SYNOPSIS
      Sets the Default-OS in the BCD-Manager
      
      .DESCRIPTION
      Sets the Default-OS in the BCD-Manager

      .EXAMPLE
      Set-BCDDEfaultOS -GUID <GUID>
      Sets the Boot-Entry with <GUID> as the default

      .EXAMPLE
      Get-BCDStore | where-object { $_.description -like "*windows 10*" } | set-BCDDefaultOS

      .NOTES
      Author: Holger Voges
      Version: 1.0.1
      Date: 2019-05-06
  #>
  [cmdletBinding(DefaultParameterSetName='Console')]
  param
  (
    [Parameter(Mandatory=$true,
        ParametersetName='Console',
        ValueFromPipelinebyPropertyName=$true,
        ValueFromPipeline=$true,
    Position=0)]
    [Alias('Bezeichner','GUID')]
    [GUID]$Identifier,
    
    [Parameter(ParametersetName='GUI')]
    [Switch]$ShowGui
  )


  process {
    if ( $PSBoundParameters.ContainsKey('Identifier'))
    {
      $null = bcdedit /default ("{{{0}}}" -f ( $Identifier ).Guid)
    }
  }
  
  End
  {
    If ( $PSBoundParameters.ContainsKey('ShowGui') )
    {
        [xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Startmenü-Editor" Height="152.616" Width="525" Cursor="Arrow">
    <Grid HorizontalAlignment="Left" Height="96" Margin="10,10,0,0" VerticalAlignment="Top" Width="505">
        <Label Content="Wählen Sie das Standard-Betriebssystem aus:" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top"/>
        <ComboBox x:Name="Cmb_OSList" HorizontalAlignment="Left" Margin="10,36,0,0" VerticalAlignment="Top" Width="485" RenderTransformOrigin="0.43,0.613"/>
        <Button x:Name="btn_OK" Content="Ändern" HorizontalAlignment="Left" Margin="420,76,0,0" VerticalAlignment="Top" Width="75"/>
        <CheckBox x:Name="chkbox_Reboot" HorizontalAlignment="Left" VerticalAlignment="Bottom" Margin="10,36,0,0" IsChecked="True">Reboot</CheckBox>
    </Grid>
</Window>
'@
    
      $BootEntries = Get-BCDEntry 
      $null = Add-Type -AssemblyName PresentationCore,PresentationFramework # ,WindowsBase,system.windows.forms
      $reader = ( New-Object System.Xml.XmlNodeReader $xaml )
      $Window = [Windows.Markup.XamlReader]::Load( $reader )
      $button = $window.FindName('btn_OK')
      $ChkBox = $window.FindName('chkbox_Reboot')
      $ComboBox = $window.FindName('Cmb_OSList')
      $button.Add_Click({
            Set-BCDDefaultOS -Identifier ($BootEntries[$ComboBox.SelectedIndex]).Identifier
            $window.close()
      })
      $BootEntries| ForEach-Object { $ComboBox.Items.Add( $_.description )}
      $ComboBox.SelectedIndex = 0
      $null = $Window.ShowDialog()
      # $BootEntries[$ComboBox.SelectedIndex]
      Set-BCDDefaultOS -Identifier ($BootEntries[$ComboBox.SelectedIndex]).Identifier
      If ( $ChkBox.IsChecked )
      { 
        Restart-Computer -force 
      }
    }
  }
}