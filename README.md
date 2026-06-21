# wsl-autoshutdown

Automatically shut down WSL2 (free the `VmmemWSL` memory) when you close
**Windows Terminal**.

WSL2 keeps its lightweight VM — and the RAM it holds — alive long after you close
your terminal. If you enable `systemd` in WSL, the VM **never** shuts down on its
own, because systemd keeps the distro permanently "busy" so WSL's idle-shutdown
never fires. This little watcher fixes that.

## How it works

A hidden PowerShell process runs in the background (started at logon). Every few
seconds it checks whether `WindowsTerminal.exe` is running. The moment the last
Windows Terminal window closes, it runs `wsl --shutdown`, which tears down the
whole VM and returns all of its memory to Windows.

Because the trigger lives on the **Windows** side and keys off the Windows
Terminal process, it is immune to anything happening inside WSL.

## Why not a hook inside WSL?

The obvious approach — a `zsh`/`bash` exit hook that counts open pseudo-terminals
(`/dev/pts`) and shuts down on the last one — is **unreliable when systemd is
enabled**:

- systemd leaves orphaned `login`/shell sessions (reparented to PID 1/2) that keep
  holding a pts, so the count never drops to 1.
- Killed ptys can leave lingering `/dev/pts/N` nodes, inflating the count further.

The hook fires fine; the *count* is the broken signal. Driving the decision from
the Windows side (`WindowsTerminal.exe` lifecycle) avoids all of it.

## Install

1. Copy `wsl-autoshutdown-watcher.ps1` to `C:\Scripts\` (or anywhere — just keep
   the path in sync with the launcher below).
2. Copy `wsl-autoshutdown.vbs` into your Startup folder so it runs at logon:
   `%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\`
   (open it quickly with `Win+R` → `shell:startup`).
3. Log off / restart once so Windows launches the watcher as an independent
   background process. (Launching it manually from inside WSL won't survive,
   because WSL kills interop-spawned processes when the session ends.)

The `.vbs` launches the script hidden, so no console window flashes on screen.

## Verify

After logging back in — **before opening any terminal** — open Task Manager →
Details and confirm a `powershell.exe` is running in the background. Then open
Windows Terminal, close it again, and watch `VmmemWSL` drop to zero within a few
seconds.

## Notes & trade-offs

- **Polling interval** is 8 s (edit `Start-Sleep -Seconds 8` in the `.ps1`). That's
  the maximum delay between closing Windows Terminal and the VM shutting down.
- **VS Code Remote-WSL is protected.** Before shutting down, the watcher probes
  the distro for a running `vscode-server` process; if VS Code is still attached,
  it skips the shutdown and re-checks on the next loop. So closing Windows
  Terminal won't drop your VS Code session — the VM only dies once *both* are
  gone. (The probe only runs in the moment right after Windows Terminal closes,
  while the VM is still up, so it never boots a stopped VM back to life.)
- If you run WSL **only** from VS Code and never open Windows Terminal, the
  watcher never triggers (it keys off the Windows Terminal close). Closing VS
  Code alone won't shut the VM down; run `wsl --shutdown` manually, or widen the
  trigger to also treat `vscode-server` as a primary entry point.
- Other non-Terminal entry points (`wsl` from PowerShell/CMD) are **not**
  protected — closing Windows Terminal will still shut the VM down under them.
- **Disable** by deleting the `.vbs` from your Startup folder and rebooting (or end
  the `powershell.exe` watcher in Task Manager).
- **Manual shutdown** any time: `wsl --shutdown`.

## Files

| File | Purpose |
|------|---------|
| `wsl-autoshutdown-watcher.ps1` | Background loop: watches Windows Terminal, runs `wsl --shutdown` on close. |
| `wsl-autoshutdown.vbs` | Launches the watcher hidden at logon (drop in Startup folder). |
