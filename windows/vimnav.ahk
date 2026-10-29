#Requires AutoHotkey v2.0
#SingleInstance Force

; Vim-like navigation for any window. Every window starts in NORMAL; only the
; keys below are taken there, every other key and app shortcut still works.
;   i             -> click the window centre, then INSERT
;   Esc / F1      -> INSERT for this window (typing works as usual)
;   F1            -> back to NORMAL
;   h / l         -> move the point left / right 1% (shown as a dot)
;   j / k         -> move the point down / up 1%
;   H / J / K / L -> same, 10% at a time
;   d / u         -> scroll down / up at the point
;   o             -> click the point, then INSERT
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
insertWins := Map()  ; windows in INSERT; all others are NORMAL
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

IsNormal() => !A_IsSuspended && !insertWins.Has(WinExist("A")) && !IsExcluded()

; Keep the indicator in sync with the focused window's mode.
Tick() {
    global shownHwnd
    hwnd := WinExist("A")
    show := IsNormal() ? hwnd : 0
    if show = shownHwnd
        return
    shownHwnd := show
    ; Forget windows that have been closed
    for m in [insertWins, points]
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
    if hwnd := WinExist("A")
        insertWins[hwnd] := true
    Tick()
}

; Click the window centre (usually the conversation / main content) to focus it, then type.
ClickCentreInsert() {
    CoordMode("Mouse", "Screen")
    WinGetPos(&x, &y, &w, &h, "A")
    MouseGetPos(&mx, &my)
    Click(x + w // 2, y + h // 2)
    MouseMove(mx, my, 0)
    EnterInsert()
}

EnterNormal() {
    if insertWins.Has(hwnd := WinExist("A"))
        insertWins.Delete(hwnd)
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

; Click the point, then type there; the cursor goes back where it was.
ClickPoint() {
    CoordMode("Mouse", "Screen")
    HideDot()
    GetPoint(&px, &py)
    MouseGetPos(&mx, &my)
    ; Hover first: some apps (Electron, web) ignore a click with no move before it
    MouseMove(px, py, 0)
    Sleep(30)
    Click()
    Sleep(30)
    MouseMove(mx, my, 0)
    EnterInsert()
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
i::ClickCentreInsert()
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
#HotIf

#SuspendExempt
^F1:: {
    Suspend()
    Tick()
    TrayTip(A_IsSuspended ? "off" : "on", "vimnav")
}
