function Show-CountdownWindow {
    param (
        [int]$CountdownMinutes,
        [string]$Message,
        [string]$Title
    )

    Add-Type -AssemblyName System.Windows.Forms
    $Form = New-Object System.Windows.Forms.Form
    $Form.Text = $Title
    $Label = New-Object System.Windows.Forms.Label
    $Label.Text = $Message
    $Label.AutoSize = $true
    $Label.Location = New-Object System.Drawing.Point(10, 10)
    $Form.Controls.Add($Label)

    $ProgressBar = New-Object System.Windows.Forms.ProgressBar
    $ProgressBar.Maximum = $CountdownMinutes * 60
    $ProgressBar.Value = $CountdownMinutes * 60
    $ProgressBar.Location = New-Object System.Drawing.Point(10, 30)
    $ProgressBar.Width = 200
    $Form.Controls.Add($ProgressBar)

    $Timer = New-Object System.Windows.Forms.Timer
    $Timer.Interval = 1000
    $Timer.Add_Tick({
        if ($ProgressBar.Value -eq 0) {
            $Form.Close()
            $Timer.Stop()
        } else {
            $ProgressBar.Value -= 1
        }
    })
    $Timer.Start()

    $Form.Add_Shown({$Form.Activate()})
    $Form.ShowDialog()
}

function Show-PopupMessage {
    param (
        [string]$Message,
        [string]$Title
    )

    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

# Set study and break times
$studyTime = 45  # Study time in minutes
$breakTime = 15  # Break time in minutes

# Convert minutes to seconds for the countdown window
$studyTimeInSeconds = $studyTime * 60
$breakTimeInSeconds = $breakTime * 60

# Show study countdown window and popup message
Show-CountdownWindow -CountdownMinutes $studyTime -Message "I'm working! Focus for $studyTime minutes!" -Title "Work Countdown"
Show-PopupMessage -Message "Take a break!" -Title "Break Notification"

# Show break countdown window
Show-CountdownWindow -CountdownMinutes $breakTime -Message "Break for $breakTime minutes!" -Title "Break Countdown"
