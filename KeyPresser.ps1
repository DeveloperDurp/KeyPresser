#region Header

    $Version = "1.0.0"

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
        Param ([string]$Keys)

        $script = [Powershell]::Create().AddScript({
            Param ($Keys)
               
                while($sync["x"] -eq 1){
                    $keys = $keys -split ","
                    Foreach ($key in $keys){
                        if ($sync["x"] -eq 1){                        
                            Start-Sleep -Milliseconds 500
                            [System.Windows.Forms.SendKeys]::SendWait("{$key}")
                        }
                    }
                }
        }).AddArgument($Keys)

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
    $form.controls.add($KeysTextBox)

    $KeysButton = New-Object 'System.Windows.Forms.Button'
    $KeysButton.Location = New-Object System.Drawing.Point(5,45)
    $KeysButton.text = "Start"
    $KeysButton.add_click({

        if ($KeysButton.text -ne "Stop"){
            $KeysButton.text = "Stop"
            $sync["x"] = 1
            $Keys = $KeysTextBox.text
            Keypress $Keys
        }
        Else{
            $KeysButton.text = "Start"
            $sync["x"] = 0
        }

    })
    $form.controls.add($KeysButton)

#endregion Form

[Windows.Forms.Application]::Run($form)