// Ubuntu Dock add-on: Super+N / click on the focused app minimizes it when it has one window.
// With several windows the dock's own "cycle-windows" action runs (next window each press).
// It wraps the dock's AppIcon.activate; importing the dock's module by the same file URI
// GNOME Shell used gives the same, already-loaded module, so the patch hits the live dock.
import Clutter from 'gi://Clutter';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const DOCKS = ['ubuntu-dock@ubuntu.com', 'dash-to-dock@micxgx.gmail.com'];

export default class DockMinimize extends Extension {
    enable() {
        this._patched = [];
        this._stateId = Main.extensionManager.connect('extension-state-changed', () => this._patch());
        this._patch();
    }

    async _patch() {
        for (const uuid of DOCKS) {
            const dock = Main.extensionManager.lookup(uuid);
            if (!dock?.dir || this._patched.some(p => p.uuid === uuid))
                continue;
            const file = dock.dir.get_child('appIcons.js');
            if (!file.query_exists(null))
                continue;
            let mod;
            try {
                mod = await import(file.get_uri());
            } catch (e) {
                console.warn(`dock-minimize: can't load ${uuid}: ${e}`);
                continue;
            }
            const proto = mod.DockAbstractAppIcon?.prototype;
            if (!proto || !this._stateId || this._patched.some(p => p.uuid === uuid))
                continue;
            const orig = proto.activate;
            proto.activate = function (button) {
                const event = Clutter.get_current_event();
                const mods = (event ? event.get_state() : 0) &
                    (Clutter.ModifierType.SHIFT_MASK | Clutter.ModifierType.CONTROL_MASK);
                if ((button ?? 1) === 1 && !mods && !Main.overview.visible &&
                    this.running && this.focused && !this._urgentWindows?.size) {
                    const windows = this.getInterestingWindows();
                    if (windows.length === 1) {
                        windows[0].minimize();
                        return;
                    }
                }
                orig.call(this, button);
            };
            this._patched.push({uuid, proto, orig});
        }
    }

    disable() {
        Main.extensionManager.disconnect(this._stateId);
        this._stateId = 0;
        for (const {proto, orig} of this._patched)
            proto.activate = orig;
        this._patched = [];
    }
}
