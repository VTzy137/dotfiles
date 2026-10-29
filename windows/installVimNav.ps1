# Install vimnav: AutoHotkey v2, run vimnav.ahk now and at logon.
# Usage: powershell -ExecutionPolicy Bypass -File windows\installVimNav.ps1
$ErrorActionPreference = 'Stop'
$script = Join-Path $PSScriptRoot 'vimnav.ahk'

function Find-Ahk {
    @("$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
      "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe") |
        Where-Object { Test-Path $_ } | Select-Object -First 1
}

# 1. AutoHotkey v2
$ahk = Find-Ahk
if (-not $ahk) {
    Write-Host 'Installing AutoHotkey v2...'
    winget install --id AutoHotkey.AutoHotkey -e --accept-source-agreements --accept-package-agreements
    $ahk = Find-Ahk
    if (-not $ahk) { throw 'AutoHotkey v2 not found after install' }
}

# 2. Start at logon; vimnav points at the repo copy so edits apply after a reload
$startup = [Environment]::GetFolderPath('Startup')
Remove-Item (Join-Path $startup 'win-vind.lnk') -ErrorAction SilentlyContinue  # old win-vind version
Get-Process win-vind -ErrorAction SilentlyContinue | Stop-Process -Force
Remove-Item (Join-Path $startup 'HuntAndPeck.lnk') -ErrorAction SilentlyContinue  # no longer used
Get-Process hap -ErrorAction SilentlyContinue | Stop-Process -Force
$shell = New-Object -ComObject WScript.Shell
$sc = $shell.CreateShortcut((Join-Path $startup 'vimnav.lnk'))
$sc.TargetPath = $ahk
$sc.Arguments = "`"$script`""
$sc.WorkingDirectory = $PSScriptRoot
$sc.Save()

# 3. Run now
Start-Process $ahk "`"$script`""
Write-Host 'vimnav is running.'
