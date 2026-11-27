# desc: Import add-on settings (Vimium C, Gesturefy, Simple Translate, Tampermonkey script) from web/
# default: off
# input: yes
# None of these add-ons can take settings from outside, so this opens each one's settings page
# and puts the file path on the clipboard: click Import, press Ctrl+L in the file picker, paste.
prof=""
for root in ~/.mozilla/firefox ~/.config/mozilla/firefox ~/snap/firefox/common/.mozilla/firefox \
    ~/.var/app/org.mozilla.firefox/.mozilla/firefox; do
    for p in "$root"/*.default*; do [ -f "$p/prefs.js" ] && prof="$p" && break 2; done
done
[ -n "$prof" ] || die "no Firefox profile: open Firefox once first"
has firefox || die "firefox not found"
copy() { if has wl-copy && [ -n "${WAYLAND_DISPLAY:-}" ]; then wl-copy "$1"; else printf %s "$1" | xclip -selection clipboard; fi; }
newest() { ls -t "$DOTFILES"/web/$1 2> /dev/null | head -1; }

# add-on id | file in web/ | what to click
items=(
    "vimium-c@gdh1995.cn|$(newest 'vimium_c*.json')|bottom of the page: Import settings"
    "{506e023c-7f2b-40a3-8066-bc5deb40aebe}|$(newest 'Gesturefy*.json')|Settings tab: Import (Backup section)"
    "simple-translate@sienori|$(newest 'SimpleTranslate*.json')|Settings tab: Import settings (at the bottom)"
    "firefox@tampermonkey.net|$(newest 'tampermonkey*.user.js')|the new-script editor: select all, paste over it, Ctrl+S"
)
for item in "${items[@]}"; do
    IFS='|' read -r id file how <<< "$item"
    [ -n "$file" ] || { warn "no settings file for $id in web/"; continue; }
    # moz-extension://<uuid>/<options page>: the uuid is per profile, the page is in the add-on's manifest
    url="$(python3 - "$prof" "$id" <<'PY'
import json, re, sys, zipfile
prof, aid = sys.argv[1], sys.argv[2]
prefs = open(prof + "/prefs.js", encoding="utf8").read()
m = re.search(r'user_pref\("extensions\.webextensions\.uuids", "(.*)"\);', prefs)
uuid = json.loads(json.loads('"' + m.group(1) + '"')).get(aid) if m else None
if not uuid:
    sys.exit(0)
man = json.loads(zipfile.ZipFile(f"{prof}/extensions/{aid}.xpi").read("manifest.json"))
page = (man.get("options_ui") or {}).get("page") or man.get("options_page") or ""
if aid == "firefox@tampermonkey.net":
    page = "options.html#nav=new-user-script"
print(f"moz-extension://{uuid}/{page}")
PY
)" || true
    name="$(basename "$file")"
    if [ -z "$url" ]; then
        warn "$id isn't installed yet (restart Firefox after the firefox module), skipping $name"
        continue
    fi
    if [[ "$file" == *.user.js ]]; then
        copy "$(cat "$file")"
        echo "Tampermonkey: the script is on the clipboard; in $how"
    else
        copy "$file"
        echo "$name: path is on the clipboard; in $how, then Ctrl+L, Ctrl+V, Enter"
    fi
    firefox --new-tab "$url" > /dev/null 2>&1 &
    read -rp "Press Enter when done for the next one (s = stop): " ans
    [ "$ans" = s ] && break
done
ok "add-on settings"
