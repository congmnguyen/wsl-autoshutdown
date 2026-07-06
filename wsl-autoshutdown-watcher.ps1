# Tu tat WSL khi da dong het cua so Windows Terminal.
# Chay nen (an) luc dang nhap Windows. Theo doi tien trinh WindowsTerminal:
# khi no chuyen tu "dang chay" sang "khong con" -> goi `wsl --shutdown`
# de dep sach VmmemWSL (mien nhiem voi pts ma / orphan ben trong WSL).
#
# Truoc khi shutdown: kiem tra VS Code Remote-WSL co con gan vao distro khong
# (tien trinh `vscode-server` ben trong WSL). Neu con -> hoan, de khong giet
# session VS Code khi ban chi dong Windows Terminal.

function Test-WslRunning {
    $out = @(& wsl.exe --list --running --quiet 2>$null)
    if ($LASTEXITCODE -ne 0) {
        throw "Could not query running WSL distros"
    }

    return @($out | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count -gt 0
}

function Test-VSCodeWsl {
    $out = & wsl.exe -e pgrep -f vscode-server 2>$null
    if ($LASTEXITCODE -eq 0) {
        return $true
    }
    if ($LASTEXITCODE -eq 1) {
        return $false
    }

    throw "Could not probe VS Code Remote-WSL"
}

$seen = $false
while ($true) {
    Start-Sleep -Seconds 8
    if (Get-Process WindowsTerminal -ErrorAction SilentlyContinue) {
        $seen = $true
    }
    elseif ($seen) {
        try {
            if (-not (Test-WslRunning)) {
                # WSL da tat san; khong probe de tranh boot lai VM.
                $seen = $false
            }
            elseif (Test-VSCodeWsl) {
                # VS Code van bam WSL -> giu $seen, kiem lai vong sau.
            }
            else {
                & wsl.exe --shutdown
                if ($LASTEXITCODE -eq 0) {
                    $seen = $false
                }
            }
        }
        catch {
            # Khong shutdown khi khong xac dinh duoc trang thai; thu lai vong sau.
        }
    }
}
