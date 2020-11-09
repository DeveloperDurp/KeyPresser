#region Header

    #Dependencies
    [Reflection.Assembly]::LoadWithPartialName("System.Windows/Forms") | Out-Null
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName PresentationFramework


    #Hide Console Window
    Add-Type -Name Window -Namespace Console -MemberDefinition '
    [DllImport("Kernal32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
    '

    #Talking across runspaces
    $Sync = [Hashtable]::Synchronized(@{})

#endregion Header


#region Functions
    Function Keypress {
        Param ([string]$Keys)

        $script = [Powershell]::Create().AddScript({
            Param ($Keys)

                $sleep = ".5"
                while($X -eq $null){
                    sleep $sleep
                    [System.Windows.Forms.SendKeys]::SendWait("{4}")
                    sleep $sleep
                    [System.Windows.Forms.SendKeys]::SendWait("{3}")
                    sleep $sleep
                    [System.Windows.Forms.SendKeys]::SendWait("{2}")
                    sleep $sleep
                    [System.Windows.Forms.SendKeys]::SendWait("{3}")
                    sleep $sleep
                    [System.Windows.Forms.SendKeys]::SendWait("{1}")
                    sleep $sleep
                    [System.Windows.Forms.SendKeys]::SendWait("{3}")
                    sleep $sleep
                    [System.Windows.Forms.SendKeys]::SendWait("{5}")
                    sleep $sleep
                    [System.Windows.Forms.SendKeys]::SendWait("{3}")
                }
        }).AddArgument($Keys)

        $runsapce = [RunspaceFactory]::CreateRunspace()
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
    $form.text = "Keypresser"
    $Form.Size = "500,500"
    $Form.Add_FormClosing({Get-Process -id $pid | Stop-Process})





#endregion Form