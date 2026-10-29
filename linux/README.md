# Linux

## vimnav (vim-like keyboard mouse)

Port of `windows/vimnav.ahk` for Wayland (COSMIC on Pop!_OS 24.04, GNOME, ...) and X11.
Run from the repo root:

```bash
bash linux/installVimNav.sh
```

It installs `python3-evdev`, gives the `input` group access to `/dev/uinput`, adds you to that group, and sets up `vimnav.service` as a user service that runs `linux/vimnav.py`.
The first time, reboot afterwards so the new group applies.
After editing `vimnav.py`: `systemctl --user restart vimnav`. Logs: `journalctl --user -u vimnav`.

Insert mode by default (typing works as usual); `F1` switches to normal mode, `i`/`Esc`/`F1` or a left click goes back.
Keys: `h`/`j`/`k`/`l` move the mouse by 1% of the screen and `H`/`J`/`K`/`L` by 10%, `d`/`u` scroll at the mouse, `o` clicks it (staying in normal mode), `O` right clicks it, `Ctrl+F1` turns it all off/on.
Only these keys are taken in normal mode, and never with Ctrl/Alt/Super held.

Differences from Windows, since Wayland doesn't let apps see other windows:

- One mode for all windows, not one per window.
- The point is a fraction of the whole screen, not of the window, and it is the mouse itself (no dot).
- Mode changes show as a short notification.
- Touchpad taps don't switch to typing, only real clicks do.

Being in the `input` group lets your user read every keyboard, which is what vimnav needs; keep that in mind on shared machines.
