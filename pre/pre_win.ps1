Set-ExecutionPolicy Bypass

echo "Deploying..."

include mod/dl_func.ps1

Set-PSDebug -trace 1

echo ".NET installed?"

If ($dotnet -eq "1")
{
  echo "YES..."
}

ElseIf ($dotnet -ne "1")
{
  echo "NO..."

  echo "Download (50mb)..."

  Download-File "https://download.microsoft.com/download/F/9/4/F942F07D-F26F-4F30-B4E3-EBD54FABA377/NDP462-KB3151800-x86-x64-AllOS-ENU.exe" "C:/dotnet.exe"
  #win8+ Download-File "https://download.microsoft.com/download/D/D/3/DD35CC25-6E9C-484B-A746-C5BE0C923290/NDP47-KB3186497-x86-x64-AllOS-ENU.exe" "C:/dotnet.exe"

  echo "Install..."

  & "C:/dotnet.exe" /Q | Out-Null #headless install, wait
}

Set-PSDebug -off

Set-ExecutionPolicy Bypass; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) #install choco

Set-PSDebug -trace 1

#all the apps
choco install atom nodejs git filezilla go-ipfs firefox php make ruby -y --accept-licenses

#keep confirmed
choco feature enable -n allowGlobalConfirmation

echo "Postinstall..."

cd C:/
Download-File "SCRIPTSC" "C:\dostuff.sh"
Start-Job -ScriptBlock {
  & cmd /C 'refreshenv && "C:\Program Files\Git\git-bash.exe" "/c/dostuff.sh"' | Out-Null
}

#exit 0
