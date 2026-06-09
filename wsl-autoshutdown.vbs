' Khoi chay watcher tat WSL theo Windows Terminal, chay an (khong hien cua so).
Set sh = CreateObject("WScript.Shell")
sh.Run "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""C:\Scripts\wsl-autoshutdown-watcher.ps1""", 0, False
