Download-File "https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc/file/41459/47/PSWindowsUpdate.zip" "C:\script-tmp\win_ps_update.zip"

cd "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\"
& "C:\Program Files\Git\usr\bin\unzip.exe" "C:\script-tmp\win_ps_update.zip" | Out-Null

Import-Module PSWindowsUpdate
Import-Module PSWindowsUpdate

Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -confirm:$false
Get-WUInstall -MicrosoftUpdate -AcceptAll -AutoReboot -confirm:$false
