
Start-Sleep -s 30

iex ((New-Object System.Net.WebClient).DownloadString('SCRIPTSC'))

mkdir C:\script-tmp

include part/wu

Remove-Item -Recurse -Force C:\script-tmp

& shutdown /s /c "Setup completed" /t 3
