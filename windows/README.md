# Windows

## vimnav (vim-like navigation)

Run from the repo root in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File windows\installVimNav.ps1
```

It installs AutoHotkey v2 (winget, asks for UAC), adds `windows/vimnav.ahk` to Startup and starts it.
Re-run any time; after editing `vimnav.ahk`, run it again (or Reload from its tray icon).

Every window starts in insert mode (typing works as usual); `F1` switches it to normal mode, `i`/`Esc`/`F1` or clicking into it goes back. Each window remembers its own mode.
Keys: `h`/`j`/`k`/`l` move a point (shown as a dot) by 1% of the window and `H`/`J`/`K`/`L` by 10%, `d`/`u` scroll at that point, `o` clicks it (staying in normal mode), `O` right clicks it, `Ctrl+F1` turns it all off/on.
Only these keys are taken in normal mode; other shortcuts keep working.
Skip apps by adding them to `ExcludeExe` at the top of `vimnav.ahk`.
