$intname=Read-Host "enter interface name"
$show_password=Netsh wlan show profile name=$intname key=clear
Write-Host $show_password
Read-Host "Press Enter to exit"