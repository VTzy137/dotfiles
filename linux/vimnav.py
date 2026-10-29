#!/usr/bin/env python3
"""Vim-like keyboard mouse for Linux, Wayland (COSMIC, GNOME, ...) or X11.
Linux port of windows/vimnav.ahk.

Starts in INSERT (typing works as usual); in NORMAL only the keys below are
taken, every other key and any shortcut with Ctrl / Alt / Super held still works.
  F1              -> NORMAL
  i / Esc / F1    -> back to INSERT
  h / l           -> move the mouse left / right 1% of the screen
  j / k           -> move the mouse down / up 1%
  H / J / K / L   -> same, 10% at a time
  d / u           -> scroll down / up at the mouse
  o               -> click at the mouse, staying in NORMAL
  O               -> right click at the mouse
  Ctrl+F1         -> turn vimnav off / on
A real left click also switches to INSERT.

Wayland gives apps no global hotkeys or window positions, so unlike Windows
the mode is shared by all windows and the point is a fraction of the screen.
Keyboards are read straight from /dev/input and the mouse is driven through
/dev/uinput, so the user must be in the input group (see installVimNav.sh).
"""
import os
import select
import signal
import struct
import subprocess
import time

import evdev
from evdev import AbsInfo, UInput
from evdev import ecodes as e

# How far h/j/k/l and H/J/K/L move the mouse, as a fraction of the screen
POINT_STEP = 0.01
BIG_POINT_STEP = 0.1
PAGE_NOTCHES = 8
# Pop a short notification when the mode changes
NOTIFY = True

NAME = "vimnav"  # prefix of the virtual devices, so vimnav never grabs its own
ABS_MAX = 10000
EVENT = struct.Struct("llHHi")  # struct input_event

CTRLS = {e.KEY_LEFTCTRL, e.KEY_RIGHTCTRL}
MODS = CTRLS | {e.KEY_LEFTALT, e.KEY_RIGHTALT, e.KEY_LEFTMETA, e.KEY_RIGHTMETA}
SHIFTS = {e.KEY_LEFTSHIFT, e.KEY_RIGHTSHIFT}
MOVES = {e.KEY_H: (-1, 0), e.KEY_L: (1, 0), e.KEY_J: (0, 1), e.KEY_K: (0, -1)}
SCROLLS = {e.KEY_D: PAGE_NOTCHES, e.KEY_U: -PAGE_NOTCHES}


class VimNav:
    def __init__(self):
        self.normal = False
        self.enabled = True
        self.point = [0.5, 0.5]
        self.held = set()       # keys down on the grabbed keyboards
        self.swallowed = set()  # keys whose press was taken, so their repeat / release is too
        self.keyboards = {}     # fd -> (device, virtual copy it is passed through to)
        self.leds = {}          # virtual copy fd -> device, to light Caps Lock etc. on the real one
        self.mice = {}          # fd -> device, only watched for clicks
        # Absolute pointer, like a VM's USB tablet: the compositor maps 0..ABS_MAX to the screen.
        self.pointer = UInput({
            e.EV_KEY: [e.BTN_LEFT, e.BTN_RIGHT, e.BTN_MIDDLE],
            e.EV_REL: [e.REL_WHEEL],
            e.EV_ABS: [(e.ABS_X, AbsInfo(0, 0, ABS_MAX, 0, 0, 0)),
                       (e.ABS_Y, AbsInfo(0, 0, ABS_MAX, 0, 0, 0))],
        }, name=NAME + " pointer")

    # Grab new keyboards and watch new mice; called at start and every few seconds for hotplug.
    def scan(self):
        known = {d.path for d, _ in self.keyboards.values()} | {d.path for d in self.mice.values()}
        for path in evdev.list_devices():
            if path in known:
                continue
            try:
                dev = evdev.InputDevice(path)
                keys = dev.capabilities().get(e.EV_KEY, [])
                if dev.name.startswith(NAME):
                    dev.close()
                elif e.KEY_J in keys and e.KEY_ESC in keys:
                    # Grabbing while a key is down (e.g. Enter that started this) leaves it stuck
                    deadline = time.monotonic() + 3
                    while dev.active_keys() and time.monotonic() < deadline:
                        time.sleep(0.05)
                    ui = UInput.from_device(dev, name=f"{NAME} {dev.name}")
                    dev.grab()
                    self.keyboards[dev.fd] = (dev, ui)
                    self.leds[ui.fd] = dev
                elif e.BTN_LEFT in keys:
                    self.mice[dev.fd] = dev
                else:
                    dev.close()
            except OSError:
                pass

    def drop(self, fd):
        if fd in self.keyboards:
            dev, ui = self.keyboards.pop(fd)
            self.leds.pop(ui.fd, None)
            ui.close()
        else:
            dev = self.mice.pop(fd)
        dev.close()

    def run(self):
        self.scan()
        last_scan = time.monotonic()
        while True:
            ready, _, _ = select.select([*self.keyboards, *self.mice, *self.leds], [], [], 2)
            for fd in ready:
                if fd in self.leds:
                    self.forward_leds(fd)
                    continue
                try:
                    events = list((self.keyboards[fd][0] if fd in self.keyboards else self.mice[fd]).read())
                except OSError:  # unplugged
                    self.drop(fd)
                    continue
                for ev in events:
                    if ev.type == e.EV_KEY and ev.code == e.BTN_LEFT and ev.value == 1:
                        # A real click focuses whatever is under it, so treat it as "I want to type here".
                        self.set_normal(False)
                    if fd in self.keyboards:
                        self.on_key_event(self.keyboards[fd][1], ev)
            if time.monotonic() - last_scan > 2:
                self.scan()
                last_scan = time.monotonic()

    # The compositor sets Caps Lock / Num Lock LEDs on the virtual copy; show them on the real keyboard.
    def forward_leds(self, fd):
        try:
            data = os.read(fd, EVENT.size * 16)
        except OSError:
            return
        for i in range(0, len(data) - EVENT.size + 1, EVENT.size):
            _, _, type_, code, value = EVENT.unpack_from(data, i)
            if type_ == e.EV_LED:
                try:
                    self.leds[fd].set_led(code, value)
                except OSError:
                    pass

    def on_key_event(self, ui, ev):
        if ev.type == e.EV_KEY:
            if ev.value:
                self.held.add(ev.code)
            else:
                self.held.discard(ev.code)
            if self.take(ev.code, ev.value):
                return
        ui.write_event(ev)

    # Handle a key press (1), repeat (2) or release (0); True if vimnav took it.
    # Only the repeat / release of a press that was taken is taken, so apps never see half a key.
    def take(self, code, value):
        if code in self.swallowed:
            if value == 0:
                self.swallowed.discard(code)
            elif code in MOVES or code in SCROLLS:
                self.act(code)  # held h/j/k/l/d/u keep going; held i/o/Esc/F1 act once
            return True
        if value != 1:
            return False
        taken = self.act(code)
        if taken:
            self.swallowed.add(code)
        return taken

    def act(self, code):
        if code == e.KEY_F1 and self.held & CTRLS:
            self.enabled = not self.enabled
            self.notify("vimnav " + ("on" if self.enabled else "off"))
            return True
        if not self.enabled or self.held & MODS:
            return False
        if code == e.KEY_F1:
            self.set_normal(not self.normal)
            return True
        if not self.normal:
            return False
        shift = bool(self.held & SHIFTS)
        if code in MOVES:
            dx, dy = MOVES[code]
            self.move(dx, dy, BIG_POINT_STEP if shift else POINT_STEP)
        elif code == e.KEY_O:
            self.click(e.BTN_RIGHT if shift else e.BTN_LEFT)
        elif shift:
            return False
        elif code in SCROLLS:
            self.scroll(SCROLLS[code])
        elif code in (e.KEY_I, e.KEY_ESC):
            self.set_normal(False)
        else:
            return False
        return True

    def set_normal(self, normal):
        if normal != self.normal and self.enabled:
            self.normal = normal
            self.notify("-- NORMAL --" if normal else "-- INSERT --")

    def notify(self, text):
        if not NOTIFY:
            return
        try:
            subprocess.Popen(["notify-send", "-a", NAME, "-t", "800", "-h", "int:transient:1",
                              "-h", "string:x-canonical-private-synchronous:" + NAME, text])
        except OSError:
            pass

    # Move the point by dx / dy steps of size step, kept on the screen, and put the mouse there.
    def move(self, dx, dy, step):
        clamp = lambda f: max(0.0, min(1.0, round(f, 2)))
        self.point = [clamp(self.point[0] + dx * step), clamp(self.point[1] + dy * step)]
        self.warp()

    def warp(self):
        x, y = (round(f * ABS_MAX) for f in self.point)
        # The kernel drops a value equal to the last one sent, so nudge first;
        # otherwise the mouse wouldn't come back after being moved by hand.
        for nudge in (1, 0):
            self.pointer.write(e.EV_ABS, e.ABS_X, x ^ nudge)
            self.pointer.write(e.EV_ABS, e.ABS_Y, y ^ nudge)
            self.pointer.syn()

    # Click the point with button, staying in NORMAL.
    def click(self, button):
        self.warp()
        time.sleep(0.03)  # hover first: some apps ignore a click with no move before it
        for down in (1, 0):
            self.pointer.write(e.EV_KEY, button, down)
            self.pointer.syn()

    # Scroll at the point (screen centre by default); positive notches scroll down.
    def scroll(self, notches):
        self.warp()
        for _ in range(abs(notches)):
            self.pointer.write(e.EV_REL, e.REL_WHEEL, -1 if notches > 0 else 1)
            self.pointer.syn()


if __name__ == "__main__":
    signal.signal(signal.SIGCHLD, signal.SIG_IGN)  # reap notify-send
    signal.signal(signal.SIGTERM, lambda *_: exit(0))
    try:
        VimNav().run()
    except KeyboardInterrupt:
        pass
