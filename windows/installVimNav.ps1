# Install vimnav: AutoHotkey v2 + Hunt-and-Peck, run vimnav.ahk now and at logon.
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

# 2. Hunt-and-Peck, used by `f` for click hints
$hap = Join-Path $env:LOCALAPPDATA 'HuntAndPeck\hap.exe'
if (-not (Test-Path $hap)) {
    Write-Host 'Installing Hunt-and-Peck...'
    $zip = Join-Path $env:TEMP 'HuntAndPeck.zip'
    Invoke-WebRequest 'https://github.com/zsims/hunt-and-peck/releases/download/release%2F1.7/HuntAndPeck-1.7.zip' -OutFile $zip -UseBasicParsing
    Expand-Archive $zip (Split-Path $hap) -Force
    Remove-Item $zip
}

# 3. Start both at logon; vimnav points at the repo copy so edits apply after a reload
$startup = [Environment]::GetFolderPath('Startup')
Remove-Item (Join-Path $startup 'win-vind.lnk') -ErrorAction SilentlyContinue  # old win-vind version
Get-Process win-vind -ErrorAction SilentlyContinue | Stop-Process -Force
$shell = New-Object -ComObject WScript.Shell
$sc = $shell.CreateShortcut((Join-Path $startup 'vimnav.lnk'))
$sc.TargetPath = $ahk
$sc.Arguments = "`"$script`""
$sc.WorkingDirectory = $PSScriptRoot
$sc.Save()
$sc = $shell.CreateShortcut((Join-Path $startup 'HuntAndPeck.lnk'))
$sc.TargetPath = $hap
$sc.WorkingDirectory = Split-Path $hap
$sc.Save()

# 4. Run now
if (-not (Get-Process hap -ErrorAction SilentlyContinue)) { Start-Process $hap -WorkingDirectory (Split-Path $hap) }
Start-Process $ahk "`"$script`""
Write-Host 'vimnav and Hunt-and-Peck are running.'
