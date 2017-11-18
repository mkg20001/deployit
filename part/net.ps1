$dotnet = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full').Install

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
