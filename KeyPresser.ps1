#region Header

    $Version = "1.0.3"

    #Dependencies
    [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName PresentationFramework


    #Hide Console Window
    Add-Type -Name Window -Namespace Console -MemberDefinition '
    [DllImport("Kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
    '

    $consolePtr = [Console.Window]::GetConsoleWindow()
    [Console.Window]::ShowWindow($consolePtr, 0) > $null

    #Talking across runspaces
    $Sync = [Hashtable]::Synchronized(@{})

#endregion Header


#region Functions
    Function Keypress {

        $script = [Powershell]::Create().AddScript({

            Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class UserWindows {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
}
"@                
            $keys = $sync["KeysTextBox"].text -split ","
            $delay = $sync["delayTextBox"].text
            $client = $sync["clienttextbox"].text
               
            while($sync["x"] -eq 1){
                
                    $ActiveHandle = [UserWindows]::GetForegroundWindow()        
                    $Process = Get-Process | ? {$_.MainWindowHandle -eq $activeHandle} | Select-Object -ExpandProperty ProcessName            
                    Write-Output $Process
                    Write-output $delay

                Foreach ($key in $keys){

                    if ($sync["x"] -eq 1 -and $Process -eq $client){                        
                        Start-Sleep -Milliseconds $delay
                        [System.Windows.Forms.SendKeys]::SendWait("{$key}")
                    }
                }
            }
        })

        $runspace = [RunspaceFactory]::CreateRunspace()
        $runspace.ApartmentState = "STA"
        $runspace.Threadoptions = "ReuseThread"
        $runspace.open()
        $runspace.sessionStateProxy.SetVariable("sync", $sync)

        $script.runspace = $runspace
        $script.beginInvoke()

    }
#endregion Functions


#region Form

    $form = New-Object System.Windows.Forms.Form
    $form.text = "Keypresser Version $Version"
    $Form.Size = "450,110"
    $Form.FormBorderStyle = 'FixedDialog' 
    $form.TopMost = $True
    $Form.Add_FormClosing({Get-Process -id $pid | Stop-Process})

    $KeysLabel = New-Object 'System.Windows.Forms.Label'
    $KeysLabel.text = "Enter in the keys you wish to be pressed seperated by a comma `",`""
    $KeysLabel.Width = '425'
    $KeysLabel.Location = New-Object System.Drawing.Point(5,5)
    $form.controls.add($KeysLabel)

    $KeysTextBox = New-Object 'System.Windows.Forms.TextBox'
    $KeysTextBox.Location = New-Object System.Drawing.Point(5,25)
    $KeysTextBox.Width = '425'
    $sync["KeysTextBox"] = $KeysTextBox
    $form.controls.add($KeysTextBox)

    $KeysButton = New-Object 'System.Windows.Forms.Button'
    $KeysButton.Location = New-Object System.Drawing.Point(5,45)
    $KeysButton.text = "Start"
    $KeysButton.add_click({

        if ($KeysButton.text -ne "Stop"){
            $KeysButton.text = "Stop"
            $sync["x"] = 1
            Keypress
        }
        Else{
            $KeysButton.text = "Start"
            $sync["x"] = 0
        }

    })    
    $form.controls.add($KeysButton)

    $delayLabel = New-Object 'System.Windows.Forms.Label'
    $delayLabel.text = "Delay in milliseconds"
    $delayLabel.Width = '110'
    $delayLabel.Location = New-Object System.Drawing.Point(85,50)
    $form.controls.add($delayLabel)

    $delayTextBox = New-Object 'System.Windows.Forms.TextBox'
    $delayTextBox.Location = New-Object System.Drawing.Point(195,45)
    $delayTextBox.Width = '30'
    $delayTextBox.text = "150"
    $sync["delayTextBox"] = $delayTextBox
    $form.controls.add($delayTextBox)

    $clientLabel = New-Object 'System.Windows.Forms.Label'
    $clientLabel.text = "client name"
    $clientLabel.Width = '70'
    $clientLabel.Location = New-Object System.Drawing.Point(235,50)
    $form.controls.add($clientLabel)

    $clientTextBox = New-Object 'System.Windows.Forms.TextBox'
    $clientTextBox.Location = New-Object System.Drawing.Point(305,45)
    $clientTextBox.Width = '100'
    $clientTextBox.text = "sro_client"
    $sync["clienttextbox"] = $clientTextBox
    $form.controls.add($clientTextBox)

#endregion Form

[Windows.Forms.Application]::Run($form)
