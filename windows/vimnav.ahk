#Requires AutoHotkey v2.0
#SingleInstance Force

; Vim-like navigation for any window. Every window starts in INSERT (typing works
; as usual); in NORMAL only the keys below are taken, every other key and app
; shortcut still works.
;   F1            -> NORMAL for this window
;   i / Esc / F1  -> back to INSERT
;   h / l         -> move the point left / right 1% (shown with DotCursor)
;   j / k         -> move the point down / up 1%
;   H / J / K / L -> same, 10% at a time
;   d / u         -> scroll down / up at the point
;   o             -> click the point, staying in NORMAL
;   O             -> right click the point
;   Ctrl+F1       -> turn vimnav off / on
; Clicking into a window puts it in INSERT. Each window keeps its own mode,
; so switching away and back restores it.

; Apps to skip, e.g. "Code.exe", "WindowsTerminal.exe", "msedge.exe"
ExcludeExe := []
; Shell and input windows where typing must never be taken
SystemExe := ["SearchHost.exe", "StartMenuExperienceHost.exe",
    "ShellExperienceHost.exe", "TextInputHost.exe", "LockApp.exe"]
; Taskbars and desktop, by window class: explorer.exe also runs File Explorer, which vimnav works in
SystemClass := ["Shell_TrayWnd", "Shell_SecondaryTrayWnd", "Progman", "WorkerW"]
; How far d / u scroll, in wheel units: 120 is one mouse wheel notch
ScrollAmount := 160
; Holding a key repeats it every RepeatMs once held past RepeatDelay (ms), faster
; than the keyboard's own repeat. About 16 is the fastest; Windows can't sleep shorter.
RepeatDelay := 100
RepeatMs := 16
; How far h/j/k/l and H/J/K/L move the point, as a fraction of the window size
PointStep := 0.01
BigPointStep := 0.07
; Marker shown at the point: a cursor file (.ani / .cur, animated ones play),
; or if that is "" or missing, any text or symbol (e.g. "●", "+", "✛", "◎", "▲")
; with its colour (hex RGB) and box size in pixels; and how long it stays (ms)
DotCursor := A_ScriptDir "\..\dororo\dororo-alt.ani"
DotCursorScale := 0.45  ; size of DotCursor relative to the normal cursor size
DotText := "●"
DotColor := "E53935"
DotSize := 15
DotMs := 700

A_IconTip := "vimnav"
normalWins := Map()  ; windows in NORMAL; all others are INSERT
points := Map()      ; window -> [fx, fy] point as fractions of its size, centre if unset
; Dot marking the point; click-through so it never takes the click or scroll itself
dot := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 -DPIScale")
dot.BackColor := "010101"
cursorSize := Round(SysGet(13) * DotCursorScale)  ; SM_CXCURSOR, the normal cursor size
; IMAGE_CURSOR, LR_LOADFROMFILE
if FileExist(DotCursor) && hCursor := DllCall("LoadImageW", "Ptr", 0, "Str", DotCursor, "UInt", 2
        , "Int", cursorSize, "Int", cursorSize, "UInt", 0x10, "Ptr") {
    DotSize := cursorSize
    ; An icon-style static control (SS_ICON) plays an animated cursor by itself
    dotPic := dot.AddText("x0 y0 w" DotSize " h" DotSize " +0x3")
    SendMessage(0x172, 2, hCursor, dotPic)  ; STM_SETIMAGE, IMAGE_CURSOR
    ; Put the cursor's hotspot, not its corner, on the point
    info := Buffer(8 + 3 * A_PtrSize, 0)  ; ICONINFO
    DllCall("GetIconInfo", "Ptr", hCursor, "Ptr", info)
    dotHotX := NumGet(info, 4, "UInt"), dotHotY := NumGet(info, 8, "UInt")
    Loop 2
        DllCall("DeleteObject", "Ptr", NumGet(info, 8 + A_Index * A_PtrSize, "Ptr"))
} else {
    dot.SetFont("s" Round(DotSize * 0.7) " bold", "Segoe UI Symbol")
    dot.AddText("x0 y0 w" DotSize " h" DotSize " Center +0x200 c" DotColor " Background010101", DotText)
    dotHotX := dotHotY := DotSize // 2
}
shownHwnd := 0       ; window the NORMAL indicator is shown for
SetTimer(Tick, 200)

IsExcluded() {
    try exe := WinGetProcessName("A"), cls := WinGetClass("A")
    catch
        return true
    for list in [ExcludeExe, SystemExe]
        for e in list
            if exe = e
                return true
    for c in SystemClass
        if cls = c
            return true
    return false
}

IsNormal() => !A_IsSuspended && normalWins.Has(WinExist("A")) && !IsExcluded()

; Keep the indicator in sync with the focused window's mode.
Tick() {
    global shownHwnd
    hwnd := WinExist("A")
    show := IsNormal() ? hwnd : 0
    if show = shownHwnd
        return
    shownHwnd := show
    ; Forget windows that have been closed
    for m in [normalWins, points]
        for h in [m*]
            if !WinExist(h)
                m.Delete(h)
    if show {
        CoordMode("ToolTip", "Screen")
        WinGetPos(&x, &y, &w, &h, show)
        ToolTip("-- NORMAL --", x + 12, y + h - 40)
    } else
        ToolTip()
}

EnterInsert() {
    if normalWins.Has(hwnd := WinExist("A"))
        normalWins.Delete(hwnd)
    Tick()
}

EnterNormal() {
    if hwnd := WinExist("A")
        normalWins[hwnd] := true
    Tick()
}

; The active window's point in screen coordinates.
GetPoint(&px, &py) {
    WinGetPos(&x, &y, &w, &h, "A")
    p := points.Get(WinExist("A"), [0.5, 0.5])
    px := x + Round(w * p[1]), py := y + Round(h * p[2])
}

; Move the point by dx / dy steps of size step, kept inside the window, and flash a dot there.
MovePoint(dx, dy, step := PointStep) {
    hwnd := WinExist("A")
    p := points.Get(hwnd, [0.5, 0.5])
    Clamp(f) => Max(0.01, Min(0.99, Round(f, 2)))
    points[hwnd] := [Clamp(p[1] + dx * step), Clamp(p[2] + dy * step)]
    GetPoint(&px, &py)
    dot.Show("x" px - dotHotX " y" py - dotHotY " w" DotSize " h" DotSize " NoActivate")
    WinSetTransColor("010101", dot)
    SetTimer(HideDot, -DotMs)
}

HideDot() => dot.Hide()

; Click the point with button, staying in NORMAL; the cursor goes back where it was.
ClickPoint(button := "Left") {
    CoordMode("Mouse", "Screen")
    HideDot()
    GetPoint(&px, &py)
    MouseGetPos(&mx, &my)
    ; Hover first: some apps (Electron, web) ignore a click with no move before it
    MouseMove(px, py, 0)
    Sleep(30)
    Click(button)
    Sleep(30)
    MouseMove(mx, my, 0)
}

; Scroll at the point (window centre by default) so that pane moves,
; then put the cursor back where it was.
Scroll(amount) {
    CoordMode("Mouse", "Screen")
    GetPoint(&px, &py)
    MouseGetPos(&mx, &my)
    MouseMove(px, py, 0)
    ; MOUSEEVENTF_WHEEL; positive is up, and amounts below a notch still scroll in most apps
    DllCall("mouse_event", "UInt", 0x800, "Int", 0, "Int", 0, "Int", -amount, "Ptr", 0)
    MouseMove(mx, my, 0)
}

; Run fn now, then again every RepeatMs while the hotkey's key stays held.
; The keyboard's own repeats are dropped while this runs (one thread per hotkey).
; The hook is what lets GetKeyState see a held key that the hotkey blocks;
; without it the key reads as up and only the keyboard's repeats scroll.
InstallKeybdHook()
Hold(fn) {
    key := LTrim(A_ThisHotkey, "~*$+^!#")
    fn()
    start := A_TickCount
    while GetKeyState(key, "P") {
        if A_TickCount - start < RepeatDelay {
            Sleep(10)
            continue
        }
        fn()
        Sleep(RepeatMs)
    }
}

; A real click focuses whatever is under it, so treat it as "I want to type here".
~LButton:: SetTimer(EnterInsert, -50)

#HotIf !IsNormal() && !IsExcluded()
F1::EnterNormal()

#HotIf IsNormal()
F1::EnterInsert()
i::EnterInsert()
Esc::EnterInsert()
h::Hold(() => MovePoint(-1, 0))
l::Hold(() => MovePoint(1, 0))
j::Hold(() => MovePoint(0, 1))
k::Hold(() => MovePoint(0, -1))
+h::Hold(() => MovePoint(-1, 0, BigPointStep))
+l::Hold(() => MovePoint(1, 0, BigPointStep))
+j::Hold(() => MovePoint(0, 1, BigPointStep))
+k::Hold(() => MovePoint(0, -1, BigPointStep))
d::Hold(() => Scroll(ScrollAmount))
u::Hold(() => Scroll(-ScrollAmount))
o::ClickPoint()
+o::ClickPoint("Right")
#HotIf

#SuspendExempt
^F1:: {
    Suspend()
    Tick()
    TrayTip(A_IsSuspended ? "off" : "on", "vimnav")
}
