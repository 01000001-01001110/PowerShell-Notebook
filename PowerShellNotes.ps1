
<#
PowerShell Notebook
By: Alan Newingham
Date: 11/10/2020

Initial Commit 
- RichTextbox functioning correctly
- Close WPF button working
- Click and Drag window working
- Minimize Window Working
- Maximize Window Working
- Snap Back on Maximize Window Working
- Was not able to get transparancy mapped to slider.
- Menu shell built out, not functional yet.

Second Commit
- Changed RichTextBox to TextBox as RichTextbox performace was less than optimal. 
- Changed transparancy.
- Added a save button.
    - Saves first copy as .txt, if only one copy exsist it will save that copy as .old and save a new .txt
- Modified the maximize button to dock to the top left of the screen. 
- Maximize now only takes up 720x1280 not the entire screen. 
- Copy and Paste work correctly now.
- Right click and Menu button (windows keyboard) work correctly now. 
- Changing name slightly from PowerShell Notebook to PowerShell Notes.

PowerShell Notes - Notebook written in PowerShell Using WPF
Copyright (C) 2020 - Alan Newingham

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/gpl-3.0.html>.
#>

$path = "C:\Scripts\PowerShellNote"
Add-Type -AssemblyName PresentationCore, PresentationFramework
$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:TofuApp"
        Title="MainWindow"
        Height="450"
        Width="800"
        WindowStyle="None"
        ResizeMode="CanResize"
        AllowsTransparency="True"
        WindowStartupLocation="CenterScreen"
        Background="Transparent"
        Foreground="Azure"
        FontFamily="Century Gothic"
        FontSize="12"
        MaxHeight="720"
        MaxWidth="1280"
        Left="0"
        Top="0"
        Opacity="0.9" 
        >
    <Window.Resources>
        <Style x:Key="MyButton" TargetType="Button">
            <Setter Property="OverridesDefaultStyle" Value="True" />
            <Setter Property="Cursor" Value="Hand" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="border" BorderThickness="0" BorderBrush="Black" Background="{TemplateBinding Background}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" />
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Opacity" Value="0.8" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    <Grid HorizontalAlignment="Stretch" VerticalAlignment="Stretch">
        <Grid Height="30" HorizontalAlignment="Stretch" VerticalAlignment="Bottom" Background="#FF68217A">
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" Width="29">
                <Button Name="save_btn" Height="20" Width="20" Background="Transparent" FontFamily="ArialNarrow" Content="S" FontSize="16" Margin="5" FontWeight="Bold" Style="{StaticResource MyButton}"/>
            </StackPanel>
            <TextBlock HorizontalAlignment="Center" Text="By: iNet" Foreground="Azure" VerticalAlignment="Center" FontSize="12" Margin="379,7,377,5" Height="18"/>
        </Grid>
        <Grid Height="30" HorizontalAlignment="Stretch" VerticalAlignment="Top" Background="#FF68217A">
            <StackPanel Orientation="Horizontal">
                <Button Name="close_btn" Height="20" Width="20" Background="Transparent" Content="X" FontSize="14" Margin="10,0,0,0" FontWeight="Bold" Style="{StaticResource MyButton}"/>
                <Button Name="minimize_btn" Height="20" Width="20" Background="Transparent" Content="-" FontSize="14" Margin="2 0 0 0" FontWeight="Bold" Style="{StaticResource MyButton}"/>
                <Button Name="maximize_btn" Height="20" Width="20" Background="Transparent" Content="#" FontSize="14" Margin="2,0,0,0" FontWeight="Bold" Style="{StaticResource MyButton}"/>
                <TextBlock Text="PowerShell Notes" Foreground="Azure" VerticalAlignment="Center" Margin="600,8,0,7"/>
            </StackPanel>
        </Grid>
        <Grid HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Margin="0 30 0 30" >
            <Border BorderBrush="Black">
                <TextBox Name="tx_bx" AcceptsReturn="True" Opacity="0.5" AcceptsTab="True" AllowDrop="True" FontFamily="Consolas" FontStyle="Normal" Background="#FF1E1E1E" Foreground="Azure" HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Auto" AutoWordSelection="True" TextWrapping="NoWrap" SpellCheck.IsEnabled="True"/>
            </Border>
        </Grid>
    </Grid>
</Window>

"@

#-------------------------------------------------------------#
$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }




#Click and Drag WPF window without title bar (ChromeTab or whatever it is called)
$Window.Add_MouseLeftButtonDown({
    $Window.DragMove()
})

#Custom Close Button
$close_btn.add_Click({
    $Window.Close();
})
#Custom Minimize Button
$minimize_btn.Add_Click({
    $Window.WindowState = 'Minimized'
})
#Custom Maximize Button
$maximize_btn.Add_Click({
    If ($Window.WindowState -eq 'Normal') {
        #Maximize the window
        $Window.WindowState = 'Maximized'
    } Else {
        #Put window back to its normal size if maximized already
        $Window.WindowState = 'Normal'
    }
})
$save_btn.Add_Click({
    if (!Test-Path "C:\scripts"){
        mkdir "C:\scripts"
    }
    if (Test-path $path".txt"){
        Rename-Item -Path $path".txt" -NewName $path".old"
    } 
    $tx_bx.Text | Out-File $path".txt"
    $tx_bx.Text = "Saved file $path.txt"
})

$tx_bx.Add_Drop({

    [System.Object]$script:sender = $args[0]
    [System.Windows.DragEventArgs]$e = $args[1]

    If($e.Data.GetDataPresent([System.Windows.DataFormats]::FileDrop)){

        $Script:Files =  $e.Data.GetData([System.Windows.DataFormats]::FileDrop)
        #Write-Host $Files.Count

        Foreach($file in $Files){

            $userControl = NewUserControl -Path $file
            $WrapPanel.Children.Add($userControl) | Out-Null

        }

    }

    

})


#Show Window, without this, the script will never initialize the OSD of the WPF elements.
$Window.ShowDialog()