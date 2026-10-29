#Requires AutoHotkey v2.0
#SingleInstance Force

; Vim-like navigation for any window. Every window starts in NORMAL; only the
; keys below are taken there, every other key and app shortcut still works.
;   i             -> click the window centre, then INSERT
;   Esc / F1      -> INSERT for this window (typing works as usual)
;   F1            -> back to NORMAL
;   j / k         -> scroll down / up
;   d / u         -> scroll a page down / up
;   f             -> click hints (Hunt-and-Peck), then INSERT
;   F             -> grid hints over the whole window, for apps Hunt-and-Peck can't read, then INSERT
;   F3            -> grid hints from any mode, then INSERT
;   Ctrl+F1       -> turn vimnav off / on
; Clicking into a window puts it in INSERT. Each window keeps its own mode,
; so switching away and back restores it.

; Apps to skip, e.g. "Code.exe", "WindowsTerminal.exe", "msedge.exe"
ExcludeExe := []
; Shell, input and hint windows where typing must never be taken
SystemExe := ["explorer.exe", "SearchHost.exe", "StartMenuExperienceHost.exe",
    "ShellExperienceHost.exe", "TextInputHost.exe", "LockApp.exe", "hap.exe"]
LineNotches := 2
PageNotches := 16

HapExe := EnvGet("LOCALAPPDATA") "\HuntAndPeck\hap.exe"
A_IconTip := "vimnav"
insertWins := Map()  ; windows in INSERT; all others are NORMAL
shownHwnd := 0       ; window the NORMAL indicator is shown for
hinting := false
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

IsNormal() => !hinting && !A_IsSuspended && !insertWins.Has(WinExist("A")) && !IsExcluded()

; Keep the indicator in sync with the focused window's mode.
Tick() {
    global shownHwnd
    hwnd := WinExist("A")
    show := IsNormal() ? hwnd : 0
    if show = shownHwnd
        return
    shownHwnd := show
    ; Forget windows that have been closed
    for h in [insertWins*]
        if !WinExist(h)
            insertWins.Delete(h)
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

; Scroll at the window centre so the main content moves,
; then put the cursor back where it was.
Scroll(notches) {
    CoordMode("Mouse", "Screen")
    WinGetPos(&x, &y, &w, &h, "A")
    MouseGetPos(&mx, &my)
    MouseMove(x + w // 2, y + h // 2, 0)
    Send("{" (notches > 0 ? "WheelDown" : "WheelUp") " " Abs(notches) "}")
    MouseMove(mx, my, 0)
}

Hint() {
    if !FileExist(HapExe) {
        TrayTip("Hunt-and-Peck not found, run windows\installVimNav.ps1", "vimnav")
        return
    }
    if ProcessExist("hap.exe")
        Send("!;")
    else
        Run('"' HapExe '" /hint')
    ; Once its overlay closes the picked element has focus, so start typing there.
    if WinWaitActive("ahk_exe hap.exe", , 2) && WinWaitNotActive("ahk_exe hap.exe")
        SetTimer(EnterInsert, -50)
}

; Label a grid over the window and click the typed cell. Works where
; Hunt-and-Peck sees nothing (e.g. Zalo chat list, terminal text).
GridHint() {
    global hinting := true
    WinGetPos(&wx, &wy, &ww, &wh, "A")
    keys := "asdfghjklqwertyuiopzxcvbnm"
    cw := 60, ch := 30
    while Ceil(ww / cw) * Ceil(wh / ch) > StrLen(keys) ** 2
        cw += 10, ch += 5

    g := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 -DPIScale")
    g.BackColor := "010101"
    g.SetFont("s9 bold", "Consolas")
    targets := Map()
    n := 0
    Loop Ceil(wh / ch) {
        y := (A_Index - 1) * ch + ch // 2
        Loop Ceil(ww / cw) {
            x := (A_Index - 1) * cw + cw // 2
            label := SubStr(keys, n // 26 + 1, 1) SubStr(keys, Mod(n, 26) + 1, 1)
            g.AddText("x" x - 9 " y" y - 8 " BackgroundFFD54F c000000", label)
            targets[label] := [wx + x, wy + y]
            n++
        }
    }
    g.Show("x" wx " y" wy " w" ww " h" wh " NoActivate")
    WinSetTransColor("010101", g)

    ih := InputHook("L2", "{Esc}")
    ih.Start()
    ih.Wait()
    g.Destroy()
    hinting := false
    if targets.Has(ih.Input) {
        CoordMode("Mouse", "Screen")
        Click(targets[ih.Input]*)
        SetTimer(EnterInsert, -50)
    }
}

; A real click focuses whatever is under it, so treat it as "I want to type here".
~LButton:: SetTimer(EnterInsert, -50)

#HotIf !hinting && !IsExcluded()
F3::GridHint()

#HotIf !hinting && !IsNormal() && !IsExcluded()
F1::EnterNormal()

#HotIf IsNormal()
F1::EnterInsert()
i::ClickCentreInsert()
Esc::EnterInsert()
j::Scroll(LineNotches)
k::Scroll(-LineNotches)
d::Scroll(PageNotches)
u::Scroll(-PageNotches)
f::Hint()
+f::GridHint()
#HotIf

#SuspendExempt
^F1:: {
    Suspend()
    Tick()
    TrayTip(A_IsSuspended ? "off" : "on", "vimnav")
}
