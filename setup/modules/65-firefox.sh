# desc: Firefox: userChrome.css (auto-hide toolbars) + install add-ons from web/firefox-extensions.txt
# default: on
# check: grep -qs addons.mozilla.org /etc/firefox/policies/policies.json && ls ~/snap/firefox/common/.mozilla/firefox/*/chrome/userChrome.css ~/.mozilla/firefox/*/chrome/userChrome.css 2> /dev/null | grep -q .
# Firefox reads /etc/firefox/policies/policies.json at startup (snap and deb alike) and installs
# the listed add-ons from addons.mozilla.org. Add-ons already installed are left alone.
policy=/etc/firefox/policies/policies.json
urls="$(read_list "$DOTFILES/web/firefox-extensions.txt" | awk '{print "https://addons.mozilla.org/firefox/downloads/latest/" $2 "/latest.xpi"}')"
sudo install -d -m 755 "$(dirname "$policy")"
# merge into any existing policies instead of replacing them
sudo python3 - "$policy" "$urls" <<'PY'
import json, os, sys
path, urls = sys.argv[1], [u for u in sys.argv[2].split("\n") if u]
data = json.load(open(path)) if os.path.exists(path) else {}
pol = data.setdefault("policies", {})
ext = pol.setdefault("Extensions", {})
ext["Install"] = sorted(set(ext.get("Install", [])) | set(urls))
# userChrome.css support, as a policy too so a new profile has it from the start
prefs = pol.setdefault("Preferences", {})
prefs["toolkit.legacyUserProfileCustomizations.stylesheets"] = {"Value": True, "Status": "default"}
json.dump(data, open(path, "w"), indent=2)
PY
ok "$(wc -l <<< "$urls") add-ons set to install at Firefox startup ($policy)"

# userChrome.css into every profile (snap, deb and flatpak locations)
found=0
for root in ~/.mozilla/firefox ~/.config/mozilla/firefox ~/snap/firefox/common/.mozilla/firefox \
    ~/.var/app/org.mozilla.firefox/.mozilla/firefox; do
    for prof in "$root"/*.default*; do
        [ -f "$prof/prefs.js" ] || continue
        found=1
        link web/userChrome.css "$prof/chrome/userChrome.css"
        grep -qs legacyUserProfileCustomizations "$prof/user.js" ||
            echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$prof/user.js"
    done
done
if [ "$found" = 1 ]; then
    ok "userChrome.css linked"
else
    warn "no Firefox profile yet: open Firefox once, then rerun ./install.sh firefox"
fi
echo "Restart Firefox: it installs the add-ons and loads the CSS. Then run ./install.sh firefox-import"
