# Tu tat WSL khi da dong het cua so Windows Terminal.
# Chay nen (an) luc dang nhap Windows. Theo doi tien trinh WindowsTerminal:
# khi no chuyen tu "dang chay" sang "khong con" -> goi `wsl --shutdown`
# de dep sach VmmemWSL (mien nhiem voi pts ma / orphan ben trong WSL).
$seen = $false
while ($true) {
    Start-Sleep -Seconds 8
    if (Get-Process WindowsTerminal -ErrorAction SilentlyContinue) {
        $seen = $true
    }
    elseif ($seen) {
        # Vua dong het Windows Terminal -> tat VM (vo hai neu khong co gi chay)
        & wsl.exe --shutdown
        $seen = $false
    }
}
