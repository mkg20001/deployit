Set-ExecutionPolicy Bypass

echo "Deploying..."

include mod/dl_func.ps1

Set-PSDebug -trace 1

# include part/net

Set-PSDebug -off

Set-ExecutionPolicy Bypass; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) #install choco

Set-PSDebug -trace 1

include part/pkg_win

mkdir C:\script-tmp
cd C:\script-tmp

Download-File "SCRIPTSC" "C:\dostuff.sh"

& cmd /C 'refreshenv && "C:\Program Files\Git\git-bash.exe" "/c/dostuff.sh"' | Out-Null

#exit 0
