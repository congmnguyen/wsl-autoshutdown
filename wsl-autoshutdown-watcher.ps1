# Tu tat WSL khi da dong het cua so Windows Terminal.
# Chay nen (an) luc dang nhap Windows. Theo doi tien trinh WindowsTerminal:
# khi no chuyen tu "dang chay" sang "khong con" -> goi `wsl --shutdown`
# de dep sach VmmemWSL (mien nhiem voi pts ma / orphan ben trong WSL).
#
# Truoc khi shutdown: kiem tra VS Code Remote-WSL co con gan vao distro khong
# (tien trinh `vscode-server` ben trong WSL). Neu con -> hoan, de khong giet
# session VS Code khi ban chi dong Windows Terminal.

function Test-VSCodeWsl {
    # $true neu VS Code Remote-WSL dang gan vao distro.
    # CHI goi khi VM dang chay (sau khi WT vua dong) -> wsl.exe -e se BOOT lai
    # VM neu no da tat, nen tuyet doi khong probe trong vong lap thuong.
    $out = & wsl.exe -e pgrep -f vscode-server 2>$null
    return -not [string]::IsNullOrWhiteSpace($out)
}

$seen = $false
while ($true) {
    Start-Sleep -Seconds 8
    if (Get-Process WindowsTerminal -ErrorAction SilentlyContinue) {
        $seen = $true
    }
    elseif ($seen) {
        # Vua dong het Windows Terminal. VM con song -> probe an toan.
        if (Test-VSCodeWsl) {
            # VS Code van bam WSL -> giu $seen, kiem lai vong sau.
        }
        else {
            & wsl.exe --shutdown
            $seen = $false
        }
    }
}
