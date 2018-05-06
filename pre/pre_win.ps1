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
Download-File "https://github.com/interfect/cjdns-installer/releases/download/v0.9-proto20.1/cjdns-installer-0.9-proto20.1.exe" "C:\script-tmp\cjdns.exe"
cpf config/openvpn.cer 'C:\script-tmp\openvpn.cer'

& "E:\vboxadditions\cert\VBoxCertUtil.exe" add-trusted-publisher C:\script-tmp\openvpn.cer --root C:\script-tmp\openvpn.cer | Out-Null
& "C:\script-tmp\cjdns.exe" /S | Out-Null

& cmd /C 'refreshenv && "C:\Program Files\Git\git-bash.exe" "/c/dostuff.sh"' | Out-Null

#exit 0
