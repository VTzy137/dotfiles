# Windows

## vimnav (vim-like navigation)

Run from the repo root in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File windows\installVimNav.ps1
```

It installs AutoHotkey v2 (winget, asks for UAC) and Hunt-and-Peck (click hints for `f`), adds `windows/vimnav.ahk` and Hunt-and-Peck to Startup and starts them.
Re-run any time; after editing `vimnav.ahk`, run it again (or Reload from its tray icon).

Every window starts in normal mode; clicking into it (or `i`/`Esc`/`F1`) switches to typing, `F1` goes back. Each window remembers its own mode.
Keys: `j`/`k` scroll, `d`/`u` page, `f` click hints, `F` grid hints (for apps like Zalo where `f` finds nothing), `F3` grid hints from any mode, `Ctrl+F1` turns it all off/on.
Only these keys are taken in normal mode; other shortcuts keep working.
Skip apps by adding them to `ExcludeExe` at the top of `vimnav.ahk`.
