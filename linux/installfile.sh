#!/usr/bin/env zsh
# installfile: install a downloaded app file (run via the installfile alias in .zshrc)
#   installfile blender-5.3.0-linux-x64.tar.xz
#   .deb                  -> sudo apt install ./file (pulls in dependencies)
#   .tar.* / .tgz / .zip  -> extracted, then by what is inside:
#       install.sh / setup.sh           -> runs it with sudo (asks first)
#       configure / CMakeLists / Makefile -> builds + sudo make install (asks first)
#       prebuilt app                    -> /opt/<name>, linked in /usr/local/bin,
#                                          app menu entry (Super+D)
#   .AppImage             -> /opt/<name>, linked in /usr/local/bin, app menu entry
_installfile_ask() { local r; read -q "r?$1 [y/N] "; print; [[ $r == y ]] }

# $1 = app name, $2 = command to run, $3 = icon (optional)
# Uses the app's own .desktop file if $4 is given, else writes one.
_installfile_desktop() {
    local app=$1 exe=$2 icon=$3 src=$4 tmp=$(mktemp)
    if [[ -n $src ]]; then
        cp $src $tmp
        [[ -n $icon ]] && sed -i "s|^Icon=.*|Icon=$icon|" $tmp
    else
        print -l "[Desktop Entry]" "Type=Application" "Name=${(C)app}" \
            "Exec=$exe %U" "Icon=${icon:-application-x-executable}" "Terminal=false" > $tmp
    fi
    sudo install -m 644 $tmp /usr/share/applications/$app.desktop
    rm -f $tmp
    sudo update-desktop-database -q /usr/share/applications 2>/dev/null
    print "app menu: /usr/share/applications/$app.desktop"
}

# Move a prebuilt app folder ($1) to /opt/$2, link its binary, add a menu entry
_installfile_opt() {
    local src=$1 app=$2 dest=/opt/$2 bin c
    if [[ -e $dest ]]; then
        _installfile_ask "$dest already exists. Replace it?" || return 1
        sudo rm -rf $dest
    fi
    sudo mv $src $dest || return 1

    for c in $dest/$app $dest/bin/$app $dest/$app.sh $dest/bin/$app.sh; do
        [[ -f $c && -x $c ]] && { bin=$c; break }
    done
    if [[ -z $bin ]]; then
        local -a cands=( ${(f)"$(find $dest -maxdepth 2 -type f -perm -u+x ! -name '*.so*' | sort)"} )
        if (( $#cands == 1 )); then
            bin=$cands[1]
        elif (( $#cands > 1 )); then
            print "Which file starts the app?"
            select bin in $cands; do [[ -n $bin ]] && break; done
        fi
    fi
    if [[ -z $bin ]]; then
        print -u2 "Moved to $dest, but found no executable to link."
        return 1
    fi
    local link=/usr/local/bin/${${bin:t}%.sh}
    sudo ln -sfn $bin $link
    print "command:  ${link:t}  ->  $bin"

    # App menu entry: the app's own .desktop file if it ships one
    local -a desk=( $dest/*.desktop $dest/*/*.desktop )
    local icon_name=$app
    [[ -n $desk[1] ]] && icon_name=$(sed -n 's/^Icon=//p' $desk[1] | head -1)
    local -a icons=( $dest/**/${icon_name:t:r}.(svg|png) $dest/**/(${app}|icon)*.(svg|png) )
    [[ $icon_name == /* ]] && icons=( $icon_name )
    _installfile_desktop $app $link "$icons[1]" "$desk[1]"
}

installfile() {
    emulate -L zsh
    setopt nullglob extendedglob
    if [[ -z $1 || ! -f $1 ]]; then
        print -u2 "usage: installfile <file .deb | .tar.gz/.xz/.bz2/.zst | .tgz | .zip | .AppImage>"
        return 1
    fi
    local file=${1:A}
    local base=${file:t}
    # blender-5.3.0-linux-x64.tar.xz -> blender
    local name=${base%.(deb|AppImage|appimage|tar.gz|tgz|tar.xz|txz|tar.bz2|tbz2|tar.zst|zip)}
    local app=${name%%[-_](v|)[0-9]*}
    app=${${app%%[-_.](linux|Linux|x86_64|x64|amd64)*}:l}

    case $base in
    *.deb)
        sudo apt install -y $file
        return
        ;;
    *.(AppImage|appimage))
        chmod +x $file
        local dest=/opt/$app
        sudo mkdir -p $dest || return 1
        sudo mv $file $dest/$app.AppImage || return 1
        sudo ln -sfn $dest/$app.AppImage /usr/local/bin/$app
        print "command:  $app  ->  $dest/$app.AppImage"
        _installfile_desktop $app /usr/local/bin/$app
        dpkg -s libfuse2t64 &>/dev/null || dpkg -s libfuse2 &>/dev/null ||
            print "note: AppImages need FUSE 2: sudo apt install libfuse2t64"
        return
        ;;
    *.(tar.gz|tgz|tar.xz|txz|tar.bz2|tbz2|tar.zst|zip)) ;;
    *)
        print -u2 "installfile: don't know how to install $base"
        return 1
        ;;
    esac

    # Extract next to the archive, then look at what is inside
    local tmp=$(mktemp -d "${file:h}/.installfile.XXXXXX") || return 1
    print "extracting $base ..."
    if [[ $base == *.zip ]]; then
        unzip -q $file -d $tmp
    else
        tar -xf $file -C $tmp
    fi || { rm -rf $tmp; return 1 }

    # Most archives hold one top folder; use it as the app root
    local root=$tmp
    local -a top=( $tmp/*(D) )
    (( $#top == 1 )) && [[ -d $top[1] ]] && root=$top[1]
    local rc=0

    if [[ -f $root/install.sh || -f $root/setup.sh ]]; then
        local script=$root/install.sh
        [[ -f $script ]] || script=$root/setup.sh
        print "Found ${script:t}. Read it first if you don't trust the source: $script"
        if _installfile_ask "Run sudo ./${script:t}?"; then
            ( cd $root && chmod +x ${script:t} && sudo ./${script:t} ) || rc=$?
        else
            print "Left the extracted files in $root"
            return 1
        fi
    elif [[ -f $root/configure || -f $root/CMakeLists.txt || -f $root/Makefile ]]; then
        print "This is source code; it will be built and installed with sudo make install."
        _installfile_ask "Build and install?" || { print "Left the extracted files in $root"; return 1 }
        (
            cd $root || exit 1
            if [[ -f configure ]]; then
                ./configure && make -j$(nproc) && sudo make install
            elif [[ -f CMakeLists.txt && ! -f Makefile ]]; then
                cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j$(nproc) &&
                    sudo cmake --install build
            else
                make -j$(nproc) && sudo make install
            fi
        ) || rc=$?
    else
        _installfile_opt $root $app || rc=$?
    fi
    (( rc == 0 )) && print "installed $app" || print -u2 "installfile: failed (exit $rc)"
    rm -rf $tmp
    return $rc
}

installfile "$@"
