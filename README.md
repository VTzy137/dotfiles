# dotfiles

My config for editors, terminal, browser and desktop, plus an installer that sets up a new machine.

## New machine (Ubuntu / Pop!_OS)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/VTzy137/dotfiles/main/install.sh)
```

This clones the repo to `~/Documents/code/dotfiles` (change it with `DOTFILES_DIR=...`) and asks about each module, from big ones (zsh, vim, ssh-github) to small ones (shopify):

```
 4/21  zsh       zsh + oh-my-zsh, ... ? [Y/n]
 9/21  shopify   Shopify CLI + theme tools? [y/N]
```

`y`/`n` answers, Enter takes the default (the capital letter), `d` takes the defaults for all the rest, `q` quits.
Then it shows the list, asks once more, and installs in two parts:

1. **PART 1: needs you at the keyboard.** Your sudo password, then the modules marked `[you type]` (git name/email, adding the SSH key on GitHub).
2. **PART 2: automatic.** Everything else; you can leave.

Already have the repo:

```bash
./install.sh                 # ask y/N for each module not installed yet
./install.sh --ask-all       # ask about installed ones too
./install.sh zsh neovim      # just these, no questions
./install.sh --all           # every module marked "on"
./install.sh --list          # show modules and which are installed
./install.sh -n ...          # dry run
```

- Defaults are your answers from last time on this machine (saved in `~/.config/dotfiles/selection`), or the `Default answer` column below on a new one.
- Every module is safe to run again. If one fails, the others still run, and it tells you which to rerun. Logs are in `~/.cache/dotfiles-install.log`.
- Configs are **symlinked**, not copied, so editing `~/.zshrc` edits the repo; commit and push to keep it.
  An existing file is moved to `<file>.bak.<date>` first.
- Git name and email go in `~/.gitconfig.local` (not in the repo); the `git-identity` module asks for them.
- A new module that asks you something gets `# input: yes` in its header, so it runs in part 1.

## Modules

| Module | What it does | Default answer |
| --- | --- | --- |
| base | apt packages in `packages/apt.txt` | on |
| git-identity | `[you type]` git name and email into `~/.gitconfig.local` | on |
| dotfiles | links `.zshrc .bashrc .vimrc .gitconfig .lessfilter .prettierrc .config/nvim`, adds `crontab` lines | on |
| ssh-github | `[you type]` SSH key + `~/.ssh/config`, shows the key, waits until GitHub accepts it, switches this repo's remote to SSH | on |
| zsh | zsh, oh-my-zsh, plugins, pixegami-agnoster theme, GNOME Terminal colours, login shell | on |
| ptyxis | Ptyxis (Ubuntu's own terminal) as the default terminal: pixegami colours (`.config/ptyxis/pixegami.palette`), Roboto Mono for Powerline font; opens in tmux | on |
| tmux | every terminal window opens in tmux (start code in `.zshrc`; not in editor terminals or SSH; `NO_TMUX=1 zsh` for a plain shell). `.tmux.conf`: mouse, `Ctrl+B \|`/`-` split in the current folder, `Alt+h/j/k/l` move, `Alt+Shift+H/J/K/L` split left/down/up/right, vim copy mode | on |
| vim / neovim | editors and their plugins (`lazy-lock.json` pins nvim plugin versions) | on |
| node | nvm, Node LTS, corepack | on |
| codex | OpenAI Codex CLI (`codex`) | on |
| claude | Claude Code CLI (`claude`), official native installer | on |
| shopify | Shopify CLI | off |
| vscode / cursor / antigravity | the editor plus linked settings and keybindings; antigravity also adds the `agy` command (there is no separate agy CLI; it comes with the editor) | cursor and antigravity on |
| fonts | FiraCode Nerd Font | on |
| vietnamese | ibus-unikey | on |
| cursor-theme | Dororo mouse cursors | off |
| vimnav | vim keys to move and click the mouse | off |
| gnome | Extension Manager app; animations off; `Super+1..9` dock hot keys (press again to cycle that app's windows, or minimize it if it has one; `linux/gnome-extensions/dock-minimize@dotfiles`); `Super+D` opens the overview (show-desktop unbound); `Super+Enter` opens the default terminal | on |
| hidetopbar | hides the top bar, shows it when the mouse reaches the top edge | on |
| gtile | gTile tiling grid (GNOME extension, `Super+G`); loads `gnome/gtile.dconf` if present. Save your settings with `dconf dump /org/gnome/shell/extensions/gtile/ > gnome/gtile.dconf` | on |
| firefox | links `web/userChrome.css` (auto-hide toolbars) into Firefox profiles; installs the add-ons in `web/firefox-extensions.txt` through `/etc/firefox/policies` | on |
| firefox-import | `[you type]` opens Vimium C, Gesturefy, Simple Translate and Tampermonkey settings one by one with the file from `web/` on the clipboard (they have no automatic import) | off |
| apps | snaps in `packages/snap.txt` (Discord) | on |
| flutter / dotnet | Flutter SDK + JDK 17 / .NET SDK 10 | off |

### Adding something

- One more apt package or snap: add a line to `packages/apt.txt` or `packages/snap.txt`.
- A new tool: add `setup/modules/NN-name.sh` with this header (NN sets the order):

  ```bash
  # desc: One line shown in the question
  # default: on
  # check: has foo         # optional: succeeds when already set up, so it isn't asked again
  apt_install foo          # helpers: apt_install, link, clone_or_pull, has, info/ok/warn/die
  link foo/config ~/.config/foo/config
  ```

  It is asked about automatically. `default: on` means Enter says yes.

## Windows

See `windows/README.md` (vimnav with AutoHotkey, Dororo cursors).

## Other files

- `web/`: Firefox `userChrome.css`, add-on list, and settings exports. To update an export, export from the add-on into `web/` (newest file of each kind is used).
- `Dark.ron`: COSMIC desktop theme
- `linux/README.md`: details on vimnav and the cursor theme on Linux
