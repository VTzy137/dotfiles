#Requires AutoHotkey v2.0
#SingleInstance Force

; Vim-like navigation for any window. Every window starts in INSERT (typing works
; as usual); in NORMAL only the keys below are taken, every other key and app
; shortcut still works.
;   F1            -> NORMAL for this window
;   i / Esc / F1  -> back to INSERT
;   h / l         -> move the point left / right 1% (shown as a dot)
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
SystemExe := ["explorer.exe", "SearchHost.exe", "StartMenuExperienceHost.exe",
    "ShellExperienceHost.exe", "TextInputHost.exe", "LockApp.exe"]
PageNotches := 8
; How far h/j/k/l and H/J/K/L move the point, as a fraction of the window size
PointStep := 0.01
BigPointStep := 0.1

A_IconTip := "vimnav"
normalWins := Map()  ; windows in NORMAL; all others are INSERT
points := Map()      ; window -> [fx, fy] point as fractions of its size, centre if unset
; Dot marking the point; click-through so it never takes the click or scroll itself
dot := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 -DPIScale")
dot.BackColor := "010101"
dot.SetFont("s14 bold", "Segoe UI")
dot.AddText("x0 y0 w20 h20 Center cE53935 Background010101", "●")
shownHwnd := 0       ; window the NORMAL indicator is shown for
SetTimer(Tick, 200)

IsExcluded() {
    try exe := WinGetProcessName("A")
    catch
        return true
    for list in [ExcludeExe, SystemExe]
        for e in list
            if exe = e
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
    dot.Show("x" px - 10 " y" py - 10 " w20 h20 NoActivate")
    WinSetTransColor("010101", dot)
    SetTimer(HideDot, -700)
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
Scroll(notches) {
    CoordMode("Mouse", "Screen")
    GetPoint(&px, &py)
    MouseGetPos(&mx, &my)
    MouseMove(px, py, 0)
    Send("{" (notches > 0 ? "WheelDown" : "WheelUp") " " Abs(notches) "}")
    MouseMove(mx, my, 0)
}

; A real click focuses whatever is under it, so treat it as "I want to type here".
~LButton:: SetTimer(EnterInsert, -50)

#HotIf !IsNormal() && !IsExcluded()
F1::EnterNormal()

#HotIf IsNormal()
F1::EnterInsert()
i::EnterInsert()
Esc::EnterInsert()
h::MovePoint(-1, 0)
l::MovePoint(1, 0)
j::MovePoint(0, 1)
k::MovePoint(0, -1)
+h::MovePoint(-1, 0, BigPointStep)
+l::MovePoint(1, 0, BigPointStep)
+j::MovePoint(0, 1, BigPointStep)
+k::MovePoint(0, -1, BigPointStep)
d::Scroll(PageNotches)
u::Scroll(-PageNotches)
o::ClickPoint()
+o::ClickPoint("Right")
#HotIf

#SuspendExempt
^F1:: {
    Suspend()
    Tick()
    TrayTip(A_IsSuspended ? "off" : "on", "vimnav")
}
