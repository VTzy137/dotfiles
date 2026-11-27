#!/usr/bin/env bash
# Pick what to set up on this machine (Ubuntu / Debian / Pop!_OS).
#
#   ./install.sh                  asks y/N for each module not installed yet, then installs the yes ones
#   ./install.sh --ask-all        same, but also asks about modules already installed
#   ./install.sh zsh neovim       install just these, no questions
#   ./install.sh --all            everything marked "default: on"
#   ./install.sh --list           show the modules
#   ./install.sh -n ...           dry run: show what would run
#
# On a brand-new machine, without the repo yet:
#   bash <(curl -fsSL https://raw.githubusercontent.com/VTzy137/dotfiles/main/install.sh)
#
# Each module is setup/modules/NN-name.sh and is safe to run again.
set -uo pipefail

REPO_URL="${DOTFILES_REPO:-https://github.com/VTzy137/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Documents/code/dotfiles}"
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2> /dev/null && pwd)"

# Bootstrap: run from curl (or outside the repo), so clone the repo and hand over to its copy
if [ ! -f "$SELF_DIR/setup/lib.sh" ]; then
    command -v git > /dev/null || { sudo apt-get update -q && sudo apt-get install -y git; }
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        echo "Cloning $REPO_URL into $DOTFILES_DIR"
        mkdir -p "$(dirname "$DOTFILES_DIR")"
        git clone "$REPO_URL" "$DOTFILES_DIR" || exit 1
    fi
    exec bash "$DOTFILES_DIR/install.sh" "$@"
fi

export DOTFILES="$SELF_DIR"
# shellcheck source=setup/lib.sh
. "$DOTFILES/setup/lib.sh"

MODULE_DIR="$DOTFILES/setup/modules"
STATE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/selection"
LOG_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-install.log"

# ---- discover modules -------------------------------------------------------
NAMES=() DESCS=() DEFAULTS=() FILES=() INPUT=() CHECKS=()
for f in "$MODULE_DIR"/[0-9]*.sh; do
    n="$(basename "$f" .sh)"
    NAMES+=("${n#*-}")
    FILES+=("$f")
    DESCS+=("$(sed -n 's/^# desc: //p' "$f" | head -1)")
    DEFAULTS+=("$(sed -n 's/^# default: //p' "$f" | head -1)")
    # "# input: yes" = the module needs you to type or paste something
    INPUT+=("$(sed -n 's/^# input: //p' "$f" | head -1)")
    # "# check: <shell test>" = succeeds when the module is already set up
    CHECKS+=("$(sed -n 's/^# check: //p' "$f" | head -1)")
done
TYPE_TAG="[you type]"

index_of() {
    local i
    for i in "${!NAMES[@]}"; do [ "${NAMES[$i]}" = "$1" ] && echo "$i" && return 0; done
    return 1
}

usage() { sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; }

# Is module i already set up? (runs its "# check:" line; no check = never counts as installed)
is_installed() {
    [ -n "${CHECKS[$1]}" ] &&
        bash -c '. "$DOTFILES/setup/lib.sh"; eval "$1"' _ "${CHECKS[$1]}" > /dev/null 2>&1 < /dev/null
}
INSTALLED=()
for i in "${!NAMES[@]}"; do
    if is_installed "$i"; then INSTALLED[i]=1; else INSTALLED[i]=0; fi
done

list_modules() {
    local i
    printf '  %-14s %-4s %-10s %-10s %s\n' MODULE DEF INPUT STATUS DESCRIPTION
    for i in "${!NAMES[@]}"; do
        printf '  %-14s %-4s %-10s %-10s %s\n' "${NAMES[$i]}" "${DEFAULTS[$i]:-off}" \
            "$([ "${INPUT[$i]}" = yes ] && echo "$TYPE_TAG")" \
            "$([ "${INSTALLED[$i]}" = 1 ] && echo installed)" "${DESCS[$i]}"
    done
}

# Default answers: last run's choice on this machine, else each module's default
preselected() {
    # State file: "name y" / "name n" per module (an old file with bare names counts as y).
    # A module you've never answered (e.g. added later) uses its "# default:".
    local i ans
    for i in "${!NAMES[@]}"; do
        ans="$(awk -v n="${NAMES[$i]}" '$1 == n { print ($2 == "" ? "y" : $2) }' "$STATE_FILE" 2> /dev/null | tail -1)"
        if [ -z "$ans" ] && [ -s "$STATE_FILE" ] && ! grep -q ' [yn]$' "$STATE_FILE"; then
            # old format listed only the yes ones; for the rest go by the module default
            [ "${DEFAULTS[$i]}" = on ] && ans=y
        fi
        [ -z "$ans" ] && { [ "${DEFAULTS[$i]}" = on ] && ans=y || ans=n; }
        [ "$ans" = y ] && echo "${NAMES[$i]}"
    done
}

# Ask y/N for each module, in order. Enter takes the default shown in capitals.
# Prompts go to stderr; chosen names go to stdout.
ask_each() {
    local pre i ans def hint rest=0 todo=() done_names=() n=0
    pre=" $(preselected | tr '\n' ' ') "
    for i in "${!NAMES[@]}"; do
        if [ "$ASK_ALL" = 0 ] && [ "${INSTALLED[$i]}" = 1 ]; then done_names+=("${NAMES[$i]}"); else todo+=("$i"); fi
    done
    if [ ${#done_names[@]} -gt 0 ]; then
        printf '%sAlready installed (not asked):%s %s\n' "$c_green" "$c_off" "${done_names[*]}" >&2
        echo "  (rerun one with ./install.sh <name>, or ask about all with --ask-all)" >&2
    fi
    if [ ${#todo[@]} -eq 0 ]; then
        echo "Everything is installed." >&2
        return 0
    fi
    echo "Answer y/n for each (Enter = default in capitals, d = defaults for the rest, q = quit)" >&2
    for i in "${todo[@]}"; do
        n=$((n + 1))
        def=n hint="y/N"
        [[ "$pre" == *" ${NAMES[$i]} "* ]] && def=y hint="Y/n"
        if [ "$rest" = 1 ]; then
            ans=$def
        else
            local tag=""
            [ "${INPUT[$i]}" = yes ] && tag="$c_yellow$TYPE_TAG$c_off "
            read -rp "$(printf '%2d/%d  %-13s %s%s? [%s] ' $n ${#todo[@]} "${NAMES[$i]}" "$tag" "${DESCS[$i]}" "$hint")" ans < /dev/tty
            # drop stray keys (Esc, arrows...) so "^[y" still counts as y
            ans="${ans//[^[:alpha:]]/}"
            case "${ans,,}" in
                "") ans=$def ;;
                y | yes) ans=y ;;
                d) rest=1 ans=$def ;;
                q) echo "Cancelled." >&2 && return 1 ;;
                *) ans=n ;;
            esac
        fi
        [ "$ans" = y ] && echo "${NAMES[$i]}"
    done
    return 0
}

# ---- parse arguments --------------------------------------------------------
DRY_RUN=0 ALL=0 ASK_ALL=0 PICKED=()
for a in "$@"; do
    case "$a" in
        -h | --help) usage && exit 0 ;;
        -l | --list) list_modules && exit 0 ;;
        -n | --dry-run) DRY_RUN=1 ;;
        -a | --all) ALL=1 ;;
        -A | --ask-all) ASK_ALL=1 ;;
        -*) die "unknown option $a (see --help)" ;;
        *) PICKED+=("$a") ;;
    esac
done

if [ "$ALL" = 1 ]; then
    for i in "${!NAMES[@]}"; do [ "${DEFAULTS[$i]}" = on ] && PICKED+=("${NAMES[$i]}"); done
elif [ ${#PICKED[@]} -eq 0 ]; then
    if [ -t 0 ]; then
        out="$(ask_each)" || exit 0
    else
        out="$(preselected)" # no terminal to ask on: use the defaults
    fi
    mapfile -t PICKED <<< "$out"
    FROM_MENU=1
fi

# Keep module order (dependencies run first) no matter how they were typed
ORDER=()
for p in "${PICKED[@]}"; do
    [ -z "$p" ] && continue
    index_of "$p" > /dev/null || die "no module named '$p' (see --list)"
done
for i in "${!NAMES[@]}"; do
    for p in "${PICKED[@]}"; do [ "$p" = "${NAMES[$i]}" ] && ORDER+=("$i") && break; done
done
[ ${#ORDER[@]} -eq 0 ] && { echo "Nothing selected."; exit 0; }

# Remember the answers so the next run on this machine starts from it
if [ "${FROM_MENU:-0}" = 1 ] && [ "$DRY_RUN" = 0 ]; then
    mkdir -p "$(dirname "$STATE_FILE")"
    for i in "${!NAMES[@]}"; do
        ans=n
        [ "$ASK_ALL" = 0 ] && [ "${INSTALLED[$i]}" = 1 ] && ans=y
        for j in "${ORDER[@]}"; do [ "$j" = "$i" ] && ans=y; done
        echo "${NAMES[$i]} $ans"
    done > "$STATE_FILE"
fi

info "Will set up: $(for i in "${ORDER[@]}"; do printf '%s ' "${NAMES[$i]}"; done)"
[ "$DRY_RUN" = 1 ] && exit 0
if [ "${FROM_MENU:-0}" = 1 ]; then
    read -rp "Start? [Y/n] " ans < /dev/tty
    ans="${ans//[^[:alpha:]]/}"
    [[ "${ans,,}" == n* ]] && { echo "Cancelled."; exit 0; }
fi

# ---- run --------------------------------------------------------------------
# Modules that need typing run first, together, so the rest can run while you're away
TYPED=() AUTO=()
for i in "${ORDER[@]}"; do
    if [ "${INPUT[$i]}" = yes ]; then TYPED+=("$i"); else AUTO+=("$i"); fi
done

banner() { printf '\n%s======== %s ========%s\n' "$1" "$2" "$c_off"; }

banner "$c_yellow" "PART 1: NEEDS YOU AT THE KEYBOARD"
echo "Your sudo password$([ ${#TYPED[@]} -gt 0 ] && printf ', then: %s' "$(for i in "${TYPED[@]}"; do printf '%s ' "${NAMES[$i]}"; done)")"
sudo -v || die "need sudo"
# keep sudo alive while modules run
(while kill -0 $$ 2> /dev/null; do sudo -n true; sleep 50; done) 2> /dev/null &

mkdir -p "$(dirname "$LOG_FILE")"
echo "=== $(date) ===" >> "$LOG_FILE"
DONE=() FAILED=()
run_module() {
    local i=$1 name="${NAMES[$1]}"
    info "[$name] ${DESCS[$i]}"
    # each module runs in its own shell: one failing doesn't stop the rest
    if bash -c 'set -euo pipefail; . "$DOTFILES/setup/lib.sh"; . "$1"' _ "${FILES[$i]}" \
        2>&1 | tee -a "$LOG_FILE"; then
        DONE+=("$name")
    else
        FAILED+=("$name")
        warn "[$name] failed, see $LOG_FILE"
    fi
}
for i in "${TYPED[@]}"; do run_module "$i"; done

if [ ${#AUTO[@]} -gt 0 ]; then
    banner "$c_green" "PART 2: AUTOMATIC, NO TYPING NEEDED (you can leave)"
    for i in "${AUTO[@]}"; do run_module "$i"; done
fi

echo
[ ${#DONE[@]} -gt 0 ] && ok "done: ${DONE[*]}"
if [ ${#FAILED[@]} -gt 0 ]; then
    warn "failed: ${FAILED[*]} (fix, then rerun: ./install.sh ${FAILED[*]})"
    exit 1
fi
echo "Open a new terminal (or log out and in) to pick everything up."
