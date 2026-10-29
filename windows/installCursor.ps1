# Use the Dororo cursor set (dororo/ in the repo) as the Windows mouse cursors.
# Usage: powershell -ExecutionPolicy Bypass -File windows\installCursor.ps1
# Back to normal: Settings > Bluetooth & devices > Mouse > Mouse pointer > Default scheme.
$ErrorActionPreference = 'Stop'
$src = Join-Path $PSScriptRoot '..\dororo'
$dest = Join-Path $env:LOCALAPPDATA 'Cursors\dororo'

# 1. Copy the cursors out of the repo so moving or deleting it doesn't break them
New-Item -ItemType Directory -Force $dest | Out-Null
Copy-Item (Join-Path $src '*.ani') $dest -Force

# 2. Cursor role -> file, as in dororo\dororo-assasin.crs, in the order Windows lists schemes
$roles = [ordered]@{
    Arrow = 'dororo-normal'; Help = 'dororo-help'; AppStarting = 'dororo-work'; Wait = 'dororo-busy'
    Crosshair = 'dororo-prec'; IBeam = 'dororo-text'; NWPen = 'dororo-handW'; No = 'dororo-unavailable'
    SizeNS = 'dororo-vertic'; SizeWE = 'dororo-horizon'; SizeNWSE = 'dororo-d1'; SizeNESW = 'dororo-d2'
    SizeAll = 'dororo-move'; UpArrow = 'dororo-alt'; Hand = 'dororo-link'
}
$key = 'HKCU:\Control Panel\Cursors'
$paths = foreach ($role in $roles.Keys) {
    $path = Join-Path $dest "$($roles[$role]).ani"
    Set-ItemProperty $key $role $path
    $path
}
Set-ItemProperty $key '(default)' 'Dororo'
Set-ItemProperty $key 'Scheme Source' 1 -Type DWord
# Also list it as a scheme in the Mouse pointer settings
if (-not (Test-Path "$key\Schemes")) { New-Item "$key\Schemes" | Out-Null }
Set-ItemProperty "$key\Schemes" 'Dororo' ($paths -join ',')

# 3. Apply now
Add-Type -Namespace Win32 -Name Cursors -MemberDefinition '[DllImport("user32.dll")] public static extern bool SystemParametersInfo(uint action, uint param, System.IntPtr vparam, uint flags);'
[Win32.Cursors]::SystemParametersInfo(0x57, 0, [IntPtr]::Zero, 3) | Out-Null  # SPI_SETCURSORS, save + broadcast
Write-Host 'Dororo cursors are on.'
