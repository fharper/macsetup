#!/usr/bin/env zsh

source $HOME/.zshrc

#
# - run this script with "zsh macsetup.sh"
# - to erase correctly previous laptop disk, use the command: "diskutil secureErase 4 /dev/disk0"
#

#########################
#                       #
# Script Configurations #
#                       #
#########################

email="hi@fred.dev"
workemail="fred@kubeshop.io"
username="fharper"

#
# Load the colors function from ZSH
#
autoload colors; colors

#
# Pause the script until the user hit ENTER & display information to the user
#
# @param message for the user
#
function pausethescript {
    echo $fg[yellow]"$1"$reset_color
    echo "Press ENTER to continue the installation script"
    read -r < /dev/tty
}

#
# Open file without knowing their exact file name.
#
# @param part of the file name
#
function openfilewithregex {
    local file=$(findfilewithregex "$1")
    open "${file}"
    pausethescript "Wait for the $file installtion to end before continuing."
    rm "${file}"
}

#
# Find a filename without knowing the exact file name
#
# @param part of the file name
#
function findfilewithregex {
    echo $(find . -maxdepth 1 -execdir echo {} ';'  | grep "$1")
}

#
# Detect if a GUI application has been installed
#
# @param the application name
#
# @return true if installed, false if not
#
function isAppInstalled {
    if [[ $(osascript -e "id of application \"$1\"" 2>/dev/null) ]]; then
        print $fg[green]"Skipped $fg[blue]$1$fg[green] already installed"$reset_color  >&2
	    echo true
    else
        print $fg[blue]"Starting the installation of $1"$reset_color  >&2
        echo false
    fi
}

#
# Install a Homebrew Keg, if not already installed
#
# @param the application name
#
function installkeg {
    local alreadyInstalled=$(brew list "$1" 2>&1 | grep "No such keg")

    if [[ -n "$alreadyInstalled" ]]; then
        echo $fg[blue]"Starting the installation of $1"$reset_color
        brew install "$1"
    else
	    echo $fg[green]"Skipped $fg[blue]$1$fg[green] already installed"$reset_color
        return 1
    fi
}

function installfont {
    local alreadyInstalled=$(brew list "$1" 2>&1 | grep "No such keg")

    if [[ -n "$alreadyInstalled" ]]; then
        echo $fg[blue]"Starting the installation of $1"$reset_color
        brew install --cask "$1"
    else
	    echo $fg[green]"Skipped $fg[blue]$1$fg[green] already installed"$reset_color
        return 1
    fi
}

#
# Detect if a Node.js package has been installed globally
#
# @param the package name
#
# @return true if installed, false if not
#
function isNodePackageInstalled {
    if npm list -g $1 --depth=0 > /dev/null; then
        echo true
    else
        echo false
    fi
}

#
# Install the Node.js package globally, if not already installed
#
# @param Node.js package name
#
function installNodePackages {
    if [[ "$(isNodePackageInstalled $1)" = "false" ]]; then
        echo $fg[blue]"Starting the installation of $1"$reset_color
        npm install -g "$1"
        rehash
    else
        echo $fg[green]"Skipped $fg[blue]$1$fg[green] already installed"$reset_color
        return 1
    fi
}

#
# Install a Homebrew Cask, if not already installed
#
# @param the application name
#
function installcask {
    if [[ "$(isAppInstalled $1)" = "false" ]]; then
        brew install --cask $1
    else
       return 1
    fi
}

#
# Install a App Store application, if not already installed
#
# @param the application ID
#
function installFromAppStore {
    if [[ "$(isAppInstalled $1)" = "false" ]]; then
        mas install "$2"
    else
        return 1
    fi
}

#
# Obtain the full path of a GUI application
#
# @param the application name
#
# @return the full path of the application, empty if it does not exist
#
function getAppFullPath {
    mdfind -name 'kMDItemFSName=="'"$1"'.app"' -onlyin /Applications -onlyin /System/Applications
}

#
# Detect if a CLI application has been installed
#
# @param the application name
#
# @return true if installed, false if not
#
function isCLAppInstalled {
    if which "$1" > /dev/null; then
        print $fg[green]"Skipped $fg[blue]$1$fg[green] already installed"$reset_color  >&2
        echo true
    else
        print $fg[blue]"Starting the installation of $1"$reset_color  >&2
        echo false
    fi
}

#
# Install a Python package, if not already installed
#
# @param the package name
#
function installPythonPackage {
    local package=$(pip list | grep "$1")

    if [[ -n "$package" ]]; then
        echo $fg[green]"Skipped $fg[blue]$1$fg[green] already installed"$reset_color
    else
        echo $fg[blue]"Installing the Python package $1"$reset_color
        pip install "$1"
    fi
}

#
# Install a Python application, if not already installed
#
# @param the application name
#
function installPythonApp {
    local package=$(pipx list | grep "$1")

    if [[ -n "$package" ]]; then
        echo $fg[green]"Skipped $fg[blue]$1$fg[green] already installed"$reset_color
        return 1
    else
        echo $fg[blue]"Installing the Python application $1"$reset_color
        pipx install "$1"
    fi
}

#
# Overwrite of the sudo command to give more context on why it's needed within the script
#
# @param the command to be executed with sudo
#
function sudo {
    local needpass=$(/usr/bin/sudo -nv 2>&1 | grep "Input required")
    #For whatever reason, chalk doesn't play well with $@,
    # but is fine if the value is stored in another variable
    local command=$@

    if [[ "$needpass" ]]; then
        echo $fg[blue]"The script need to use root (sudo) to run the $fg[green]$command$fg[blue] command"$reset_color
    else
        echo $fg[blue]"Using previously root (sudo) access to run the $fg[green]$command$fg[blue] command"$reset_color
    fi
    /usr/bin/sudo $@
}

#
# Use Mackup to restore a specific application settings
#
# @param the application name from Mackup
#
function restoreAppSettings {
    echo "[storage]\nengine = icloud\n\n[applications_to_sync]\n$1" > $HOME/.mackup.cfg
    mackup restore
    echo "[storage]\nengine = icloud\n" > $HOME/.mackup.cfg
}

#
# Install the application from PKG inside of a DMG
#
# @param DMG filename
#
function installPKGfromDMG {
    hdiutil attach "$1"
    local volume="/Volumes/$(hdiutil info | grep /Volumes/ | sed 's@.*\/Volumes/@@' | tail -1)"
    local pkg=$(/bin/ls "$volume" | grep .pkg)

    installPKG "$volume/$pkg"

    hdiutil detach "$volume"
    rm "$1"
}

# Install the application from a PKG
#
# @param DMG filename
#
function installPKG {
    sudo installer -pkg "$1" -target /

    # Cannot delete the pkg from inside a volume (happen when run from installPKGfromDMG)
    if [[ "$1" != "/Volumes/"* ]]; then
        rm "$1"
    fi
}

#
# Install the application from a DMG image when you just need to move the
# application into the macOS Applications folder
#
# @param DMG filename
# @param delete the DMG or not
#
function installDMG {
    hdiutil attach "$1"
    local volume="/Volumes/$(hdiutil info | grep /Volumes/ | sed 's@.*\/Volumes/@@')"
    local app=$(/bin/ls "$volume" | grep .app)
    mv "$volume/$app" /Applications
    hdiutil detach "$volume"

    if [[ "$2" = "true" ]]; then
        rm "$1"
    fi
}

#
# Reload .zshrc in the current shell
#
function reload {
    source $HOME/.zshrc
}

#
# Create a csreq blob for a specific application
#
# @param app name
#
# @return csreq blob in hexadecimal
#
# Notes:
# - Process taken from https://stackoverflow.com/a/57259004/895232
#
function getCsreqBlob {
    local app=$(getAppFullPath "$1")
    # Get the requirement string from codesign
    local req_str=$(codesign -d -r- "$app" 2>&1 | awk -F ' => ' '/designated/{print $2}')
    echo "$req_str" | csreq -r- -b /tmp/csreq.bin
    local hex_blob=$(xxd -p /tmp/csreq.bin  | tr -d '\n')
    rm /tmp/csreq.bin
    echo "$hex_blob"
}

#
# Get the application bundle identifier
#
# @param app name
#
# @return the application bundle identifier
#
function getAppBundleIdentifier {
    local app=$(getAppFullPath "$1")
    mdls -name kMDItemCFBundleIdentifier -r "$app"
}

#
# Give Full Disk Access Permission for a specific application
#
# @param app name
#
function giveFullDiskAccessPermission {
    updateTCC "kTCCServiceSystemPolicyAllFiles" "$1"
}

#
# Give Screen Recording Permission for a specific application
#
# @param app name
#
function giveScreenRecordingPermission {
    updateTCC "kTCCServiceScreenCapture" "$1"
}

#
# Give Accessibility Permission for a specific application
#
# @param app name
#
function giveAccessibilityPermission {
    updateTCC "kTCCServiceAccessibility" "$1"
}

#
# Update the access table in the TCC database with the new permission
#
# @param service for permission
# @param application identifier
# @param application csreq blob
#
# Notes:
# - More information on TCC at https://www.rainforestqa.com/blog/macos-tcc-db-deep-dive
#
function updateTCC {
    local app_identifier=$(getAppBundleIdentifier "$2")
    local app_csreq_blob=$(getCsreqBlob "$2")

    # Columns:
    # - service: the service for the permission (ex.: kTCCServiceSystemPolicyAllFiles for Full Disk Access permission)
    # - client: app bundle identifier
    # - client_type: 0 since it's the bundle identifier
    # - auth_value: 2 for allowed
    # - auth_reason: 3 user set
    # - auth_version: always 1 for now
    # - csreq: binary code signing requirement blob that the client must satisfy in order for access to be granted
    # - policy_id: null, related to MDM
    # - indirect_object_identifier_type: 0 since it's the bundle identifier
    # - indirect_object_identifier: UNUSED since it's not needed for this permission
    # - indirect_object_code_identity: same as csreq policy_id, so NULL
    # - flags: not sure, always 0
    # - last_modifified: last time entry was modified

    local exist=$(sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "select count(service) from access where service = '$1' and client = '$app_identifier';")
    if [[ exist ]]; then
        sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "update access SET auth_value=2 where service = '$1' and client = '$app_identifier';"
    else
        sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "insert into access values('$1', '$app_identifier', 0, 2, 3, 1, '$app_csreq_blob', NULL, 0, 'UNUSED', NULL, 0, CAST(strftime('%s','now') AS INTEGER));"
    fi

}

#
# Get the license key from 1Password & copy it to the clipboard
#
# @param the application we want the license key
#
function getLicense {
    op item get "$1" --fields label="license key" | pbcopy
    pausethescript "Add the license key from the clipboard to $1 before continuing"
}

#
# Get the license file from 1Password & open it
#
# @param the application we want the license key
# @param the filename of the license (will automate that when 1Password let you get the document file name)
#
function getLicenseFile {
    op document get "$1" --output="$2"
    open "$2"
    pausethescript "Wait for $1 license to be added properly"
    rm "$2"
}

#
# Remove an application from the Dock, if it's there
#
# @param the application we want to remove
#
function removeAppFromDock {
    if [[ $(dockutil --list | grep "$1") ]]; then
        echo $fg[blue]"Removing $1 from the Dock. The Dock will flash, it's normal."$reset_color
        dockutil --remove "$1" --allhomes
    fi
}

#
# Confirm running or not the command
#
# @param the text for the confirmation
# @param the command to run if accepted
#
function confirm {
    vared -p "$1 [y/N]: " -c ANSWER
    if [[ "$ANSWER" = "Y" ]] || [[ "$ANSWER" = "y" ]] || [[ "$ANSWER" = "yes" ]] || [[ "$ANSWER" = "YES" ]]; then
        eval $2
    fi
}

#
# Remove a pre-installed application
#
# @param application name
#
function removeApp {

    local app=$(getAppFullPath "$1")

    if [[ "$app" ]]; then
        echo $fg[blue]"Removing $1 from your computer."$reset_color
        sudo rm -rf "$app"
    fi
}

#
# Display the section information for the script section being run
#
# @param section name
#
function displaySection {
    local length=${#1}+4

    print "\n"

    for (( i=1; i<=$length; i++ )); do
        print -n "$fg[magenta]#";
    done

    print -n "\n#"

    for (( i=1; i<=$length-2; i++ )); do
        print -n " ";
    done

    print "#"

    print "# $1 #"

    print -n "#"

    for (( i=1; i<=$length-2; i++ )); do
        print -n " ";
    done

    print "#"

    for (( i=1; i<=$length; i++ )); do
        print -n "#";
    done

    print "\n$reset_color"
}

#
# Install a Rust application, if not already installed
#
# @param the application name
#
function installRustApp {
    local package=$(cargo install --list | grep "$1")

    if [[ -n "$package" ]]; then
        echo $fg[green]"Skipped $fg[blue]$1$fg[green] already installed"$reset_color
        return 1
    else
        echo $fg[blue]"Installing the Python application $1"$reset_color
        cargo install "$1"
        reload
    fi
}

#
# Install asdf plugin, and a specific version of the plugin while setting it as the global version
#
# @param plugin name
# @param version of the plugin to instal
#
function installAsdfPlugin {
    if [[ $(asdf current $1) ]]; then
        echo $fg[green]"Skipped asdf plugin $fg[blue]$1$fg[green] already installed"$reset_color
        return 1
    else
        echo $fg[blue]"Installing the asdf plugin $1 & its version $2"$reset_color
        asdf plugin-add $1
        asdf install $1 $2
        asdf global $1 $2
        reload
    fi
}

#
# Install Go applications
#
# @param application name
# @param version of the application (default to latest)
#
function installGoApp {
    if [[ "$(isCLAppInstalled $1)" = "true" ]]; then
        echo $fg[green]"Skipped $fg[blue]$1$fg[green] already installed"$reset_color
        return 1
    else
        version=$2
        if [[ "$version" = "" ]]; then
            version="latest"
        fi

        echo $fg[blue]"Installing the version $version of the Go application $1"$reset_color
        go install "$1"@"$version"
        asdf reshim golang
    fi
}

#
# Get macOS codename (Monterey, Ventura, Sonoma...)
#
# @return macOS codename
#
function getmacOSCodename {
    sed -nE '/SOFTWARE LICENSE AGREEMENT FOR/s/.*([A-Za-z]+ ){5}|\\$//gp' /System/Library/CoreServices/Setup\ Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf
}





############################
#                          #
# Utils to run this script #
#                          #
# (the order is important) #
#                          #
############################

displaySection "Utils to run this script"

#
# Rosetta2
#
# Run x86_64 app on arm64 chip
#
# https://developer.apple.com/documentation/apple_silicon/about_the_rosetta_translation_environment
#
# Notes
#  - You may get a "Package Authoring Error" even if the installation worked (https://discussions.apple.com/thread/253780410)
#  - Cannot be added to apps.yml for now as it doesn't manage custom installation check
#
if [[ -z $(pgrep oahd) ]]; then
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
fi

#
# Xcode Command Line Tools
#
# Command line XCode tools & the macOS SDK frameworks and headers
#
# https://developer.apple.com/xcode
#
# Notes
#  - Cannot be added to apps.yml for now as it doesn't manage custom installation check
#
if [[ $(xcode-select -p 1> /dev/null; echo $?) -eq 2 ]]; then
    xcode-select --install
    pausethescript "Wait for the XCode Tools installation to finish before continuing."
fi

#
# Homebrew + homebrew-cask-versions + brew-cask-upgrade + Casks for Fonts
#
# macOS package manager
# Alternate versions of Homebrew Casks
# CLI for upgrading outdated Homebrew Casks
# Casks for Fonts
#
# https://github.com/Homebrew/brew
# https://github.com/Homebrew/homebrew-cask-versions
# https://github.com/buo/homebrew-cask-upgrade
#
# Notes
#  - Cannot be added to apps.yml for now as it doesn't manage custom installation
#
if [[ "$(isCLAppInstalled brew)" = "false" ]]; then
    echo $fg[blue]"Starting the installation of Homebrew"$reset_color
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Needed once here since we didn't restore & source $HOME/.zshrc yet, but we need Homebrew
    eval "$(/opt/homebrew/bin/brew shellenv)"

    brew analytics off
    brew tap homebrew/cask-versions
    brew tap buo/cask-upgrade
fi

#
# Mackup
#
# Sync applications settings with any file sync services
#
# https://github.com/lra/mackup
#
# Notes: needed right after Homebrew so configurations files can be restored
#
installkeg mackup

#
# asdf
#
# Version manager with support for everything
#
# https://github.com/asdf-vm/asdf
#
# Notes
#  - Needed before Python
#
# Help
#  - To list all available versions for a language, use: asdf list all nodejs
#  - To install a language version, use: asdf install nodejs 22.4.1
#
if [[ "$(isCLAppInstalled asdf)" = "false" ]]; then
    installkeg asdf
    reload
fi

#
# Python + PipX + Wheel + Pylint + pytest + Twine
#
# Python SDK
# Isolated Environments Pip alternative for app (not packages)
# Python wheel packaging tool
# Python linter
# Python tests framework
# Utilities for interacting with PyPI
#
# https://www.python.org
# https://github.com/pypa/pipx
# https://github.com/pypa/wheel
# https://github.com/PyCQA/pylint/
# https://github.com/pytest-dev/pytest
# https://github.com/pypa/twine/
#
# Notes
#   - Needed before lastversion
#
if [[ ! $(asdf current python) ]]; then
    installAsdfPlugin python 3.13.3

    installkeg pipx
    pipx ensurepath
    installPythonPackage wheel
    installPythonApp pylint
    installPythonApp pytest
    installPythonApp twine
fi

#
# lastversion
#
# CLI to get latest GitHub Repo Release assets URL
#
# https://github.com/dvershinin/lastversion
#
# Notes
#   - Needed before Dockutil
#
installPythonApp lastversion

#
# macports-base
#
# MacPorts CLI
#
# https://github.com/macports/macports-base/
#
# Notes:
#  - Needed after lastversion install
#  - Cannot be added to apps.yml for now as it doesn't manage custom installation check
#
if [[ "$(isCLAppInstalled port)" = "false" ]]; then
    curl -L "$(lastversion macports/macports-base --assets --filter $(getmacOSCodename)\.pkg$)" --output macports.pkg

    installPKG macports.pkg
fi

#
# Dockutil
#
# Utility to manage macOS Dock items
#
# https://github.com/kcrawford/dockutil
#
# Notes
#  - Homebrew version not updated
#  - Needed before iTerm2
#  - Cannot be added to apps.yml for now as it doesn't manage custom installation check
#
if [[ "$(isCLAppInstalled dockutil)" = "false" ]]; then
    echo $fg[blue]"Starting the installation of Dockutil"$reset_color
    curl -L "$(lastversion kcrawford/dockutil --assets)" --output dockutil.pkg
    sudo installer -pkg dockutil.pkg -target /
    rm dockutil.pkg
fi

#
# iTerm2
# iTerm2 Shell Integration
#
# Terminal replacement
#
# https://github.com/gnachman/iTerm2
# https://iterm2.com/documentation-shell-integration.html
#
if [[ "$(isAppInstalled iTerm)" = "false" ]]; then
    installcask iterm2
    giveFullDiskAccessPermission iTerm
    dockutil --add /Applications/iTerm.app/ --allhomes

    curl -L https://iterm2.com/shell_integration/install_shell_integration.sh | bash
    open -a iTerm
    echo $fg[yellow]"You can now close the Terminal app, and continue on iTerm"$reset_color
    exit
fi

#
# Git
#
# File versioning
#
# https://github.com/git/git
#
# Notes: needed before Oh My Zsh as .zhrc have some git usage in it
#
if [[brew list git 2>&1 | grep "No such keg"]]; then
    installkeg git
    git config --replace-all --global advice.addIgnoredFile false
    git config --replace-all --global advice.addEmptyPathspec false
    git config --replace-all --global advice.skippedCherryPicks false
    git config --replace-all --global clean.requireForce false
    git config --replace-all --global core.hooksPath $HOME/.git/hooks
    git config --replace-all --global core.ignorecase false
    git config --replace-all --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
    git config --replace-all --global credential.username $email
    git config --replace-all --global diff.tool vscode
    git config --replace-all --global difftool.prompt false
    git config --replace-all --global difftool.vscode.cmd "code --diff --wait $LOCAL $REMOTE"
    git config --replace-all --global fetch.prune true
    git config --replace-all --global help.autocorrect 10
    git config --replace-all --global http.postBuffer 2097152000
    git config --replace-all --global init.defaultBranch main
    git config --replace-all --global interactive.diffFilter "diff-so-fancy --patch"
    git config --replace-all --global pull.rebase true
    git config --replace-all --global push.autoSetupRemote true
    git config --replace-all --global push.default current
    git config --replace-all --global push.followTags true
    git config --replace-all --global rebase.autoStash true
    git config --replace-all --global user.email $email
    git config --replace-all --global user.name "Frédéric Harper"
fi


#
# GitPython
#
# Python library for Git
#
# https://github.com/gitpython-developers/GitPython
#
# Notes: needed for the file size pre-commit hook
#
installPythonPackage gitpython

#
# Oh My Zsh
#
# Zsh configurations framework & management
#
# https://github.com/ohmyzsh/ohmyzsh
#

if [[ "$(isCLAppInstalled omz)" = "false" ]]; then
    echo $fg[blue]"Starting the installation of Oh My Zsh"$reset_color
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    # Restoring here since OMZ backup $HOME/.zshrc to $HOME/.zshrc.pre-oh-my-zsh
    restoreAppSettings zsh
    rm $HOME/.zshrc.pre-oh-my-zsh
    reload
fi

#
# starship
#
# The minimal, blazing-fast, and infinitely customizable prompt for any shell
#
# https://github.com/starship/starship
#
# Notes: need to be after Oh My Zsh
#
if [[ ! -d "/opt/homebrew/opt/spaceship/" ]]; then
    instalkeg starship
    reload
fi

#
# Restore different files with Mackup (not app specifics)
#
if [[ ! -L "$HOME/.zshrc" ]]; then
    restoreAppSettings files
    restoreAppSettings vim
    reload
fi

#
# mas-cli
#
# Unofficial macOS App Store CLI
#
# https://github.com/mas-cli/mas
#
# Notes: Need to install before Xcode
#
if [[ "$(isCLAppInstalled mas)" = "false" ]]; then
    installkeg mas
    open -a "App Store"
    pausethescript "Sign in into the App Store before continuing"
fi

#
# Xcode
#
# macOS/iOS Swift/Ojective-C IDE
#
# https://developer.apple.com/xcode
#
# Notes: need to install before defbro
#
if [[ "$(isAppInstalled Xcode)" = "false" ]]; then
    installFromAppStore XCode 497799835
    sudo xcodebuild -license accept
    xcodebuild -runFirstLaunch
    restoreAppSettings Xcode
fi

#
# defbro
#
# CLI to change the default browser
#
# https://github.com/jwbargsten/defbro
#
if [[ "$(isCLAppInstalled defbro)" = "false" ]]; then
    brew tap jwbargsten/misc
    installkeg defbro
fi

#
# Duti
#
# Utility to set default applications for document types (file extensions)
#
# https://github.com/moretension/duti
#
installkeg duti

#
# jq
#
# Command-line JSON processor
#
# https://github.com/stedolan/jq
#
# JSON processor
#
installkeg jq

#
# icalBuddy
#
# Command-line utility for printing events and tasks from the OS X calendar database
#
# https://github.com/ali-rantakari/icalBuddy
#
installkeg ical-buddy

#
# loginitems
#
# Utility to manage startup applications
#
# https://github.com/ojford/loginitems
#
if [[ "$(isCLAppInstalled loginitems)" = "false" ]]; then
    brew tap OJFord/formulae
    installkeg loginitems
fi

#
# mysides
#
# Finder sidebar tool
#
# https://github.com/mosen/mysides
#
installkeg mysides

#
# Node.js + npm CLI
#
# Node.js programming language SDK
# Node Package Manager CLI
#
# https://github.com/nodejs/node
# https://github.com/npm/cli
#
if [[ ! $(asdf current nodejs) ]]; then
    installAsdfPlugin nodejs 23.9.0

    npm i -g npm@latest
    npm adduser
fi

#
# BZip2
#
# Data compressor
#
# https://sourceware.org/bzip2/
#
installkeg BZip2

#
# osXiconUtils
#
# Utilities for working with macOS icons
#
# https://github.com/sveinbjornt/osxiconutils
#
if [[ "$(isCLAppInstalled geticon)" = "false" ]]; then
    echo $fg[blue]"Starting the installation of osXiconUtils"$reset_color
    curl -L https://sveinbjorn.org/files/software/osxiconutils.zip --output osxiconutils.zip
    unzip osxiconutils.zip
    rm osxiconutils.zip
    rm -rf __MACOSX #created by the unzip call
    sudo chown $username:admin /usr/local/bin
    mv bin/geticon /usr/local/bin/
    mv bin/seticon /usr/local/bin/
    rm -rf bin/
fi

#
# Script Editor
#
giveAccessibilityPermission "Script Editor"

#
# terminal-notifier
#
# Utility to send macOS notifications
#
# https://github.com/julienXX/terminal-notifier
#
installkeg terminal-notifier

#
# wallpaper
#
# Manage the wallpaper(s) from command line
#
# https://github.com/sindresorhus/macos-wallpaper
#
installkeg wallpaper


########################
#                      #
# Applications Cleanup #
#                      #
########################

displaySection "Applications Cleanup"

removeApp GarageBand
removeApp iMovie
removeApp Keynote
removeApp Numbers
removeApp Pages

################
#              #
# Dock Cleanup #
#              #
################

displaySection "Dock Cleanup"

removeAppFromDock "App Store"
removeAppFromDock "Calendar"
removeAppFromDock "Contacts"
removeAppFromDock "FaceTime"
removeAppFromDock "Freeform"
removeAppFromDock "Launchpad"
removeAppFromDock "Mail"
removeAppFromDock "Maps"
removeAppFromDock "Music"
removeAppFromDock "News"
removeAppFromDock "Notes"
removeAppFromDock "Podcasts"
removeAppFromDock "Reminders"
removeAppFromDock "Safari"
removeAppFromDock "System Settings"
removeAppFromDock "TV"

###########################
#                         #
# Top Helper Applications #
#                         #
###########################

displaySection "Top Helper Applications"

#
# Alfred & alfred-google-translate & alfred-language-configuration
#
# Spotlight replacement
#
# https://www.alfredapp.com
#
if [[ "$(isAppInstalled "Alfred 5")" = "false" ]]; then
    installcask alfred
    open /System/Library/PreferencePanes/Keyboard.prefPane
    pausethescript "In System Preferences, Keyboard, click on the 'Keyboard Shortcuts...' button. Select the 'Spotlight' pane & uncheck the 'Show Spotlight Search' checkbox."
    open -a Alfred
    getLicense Alfred
    giveAccessibilityPermission "Alfred 5"
    giveFullDiskAccessPermission "Alfred 5"
    #TODO: add Contacts Permission
    #TODO: add Automation Permission
    installNodePackages alfred-google-translate
    installNodePackages alfred-language-configuration
    pbcopy "trc en&fr"
    pausethescript "Configure alfred-google-translate with 'trc en&fr' (in your clipboard) before continuing"
fi

#
# Apple Juice
#
# Advanced battery gauge
#
# https://github.com/raphaelhanneken/apple-juice
#
installcask apple-juice

#
# Bartender
#
# macOS menubar manager
#
# https://www.macbartender.com
#
# Notes
#   - Cannot use mackup with Bartender (https://github.com/lra/mackup/issues/1126)
#
if [[ "$(isAppInstalled "Bartender 5")" = "false" ]]; then
    installcask bartender
    giveAccessibilityPermission "Bartender 5"
    giveScreenRecordingPermission "Bartender 5"
    open -a "Bartender 5"
    getLicense "Bartender"
fi

#
# CleanShot X
#
# Screenshot utility
#
# https://cleanshot.com
#
if [[ "$(isAppInstalled "CleanShot X")" = "false" ]]; then
    installcask cleanshot
    giveAccessibilityPermission "CleanShot X"
    getLicense "CleanShot X"
    open -a "CleanShot X"
    pausethescript "Install the audio component for video audio recording before continuing. Go in Settings >> Recording >> Video >> Computer Audio, and click on the 'Configure' button. In the new window, check the 'Record Computer Audio' checkbox, and click 'Install' in the popup."
    pausethescript "You now need to configure the right keyboard shortcuts before continuing. Go in Settings >> Shortcuts. In the 'Screenshoots' section, add 'CMD + Shift + 4' for 'Capture Area'. In the 'Screen Recording' section, add 'CMD + Shift + 6' for 'Record Screen / Stop Recording'. In the 'Scrolling Capture' section, add 'CMD + Shift + 5' for 'Scrolling Capture'. Finally, in the 'OCR' section, add 'CMD + Shift + 2' for 'Capture Text'. You can now close the window."
fi

#
# CommandQ
#
# Utility to prevent accidentally quiting an application
#
# https://commandqapp.com
#
if [[ "$(isAppInstalled CommandQ)" = "false" ]]; then
    installcask commandq
    getLicense CommandQ
    open -a CommandQ
fi

#
# Contexts
#
# Application windows switcher
#
# https://contexts.co
#
if [[ "$(isAppInstalled Contexts)" = "false" ]]; then
    installcask contexts
    giveAccessibilityPermission Contexts
    getLicenseFile "Contexts" "contexts.contexts-license"
    open -a Contexts
fi

#
# Espanso
#
# Text expander / snipet
#
# https://github.com/federico-terzi/espanso
#
if [[ "$(isAppInstalled Espanso)" = "false" ]]; then
    brew tap espanso/espanso
    installcask espanso
    giveAccessibilityPermission Espanso
    restoreAppSettings espanso
    loginitems -a Espanso
fi

#
# HSTR
#
# Shell command history management
#
# https://github.com/dvorka/hstr
#
installkeg hstr

#
# Karabiner-Elements
#
# Keyboard customization utility
#
# https://github.com/pqrs-org/Karabiner-Elements
#
if [[ "$(isAppInstalled "Karabiner-Elements")" = "false" ]]; then
    installcask karabiner-elements
    restoreAppSettings karabiner-elements
    #TODO: add karabiner_observer Receive Keystrokes Permission
    #TODO: add karabiner_observer & karabiner_graber Input Monitor Permission
    #TODO: add karabiner_graber Full Disk Access Permission (needed because of Mackup)
fi

#
# KeepingYouAwake
#
# Menubar app to manage caffeinate
#
# https://github.com/newmarcel/KeepingYouAwake
#
installcask keepingyouawake

#
# Little Snitch
#
# Kinda dynamic firewall
#
# https://www.obdev.at/products/littlesnitch/index.html
#
# Notes
#   - To backup the rules, run 'sudo littlesnitch export-model > little-snitch.json' on previous laptop
#
if [[ "$(isAppInstalled "Little Snitch")" = "false" ]]; then
    installcask little-snitch
    restoreAppSettings littlesnitch
    pausethescript "Activate the CLI by opening Little Snitch Preferences, go to Security, and click the lock icon. Check the 'Allow access via Terminal' option, and run 'sudo littlesnitch restore-model little-snitch.json' (copied in your clipboard) in your Terminal where the backup file is."
    reload
    pbcopy "sudo littlesnitch restore-model little-snitch.json"
fi

#
# lolcat
#
# Display any terminal output in rainbows colors
#
# https://github.com/busyloop/lolcat
#
installkeg lolcat

#
# MeetingBar
#
# Calendar menubar app
#
# https://github.com/leits/MeetingBar
#
installcask meetingbar

#
# Mic Drop
#
# Easily mute or unmute your microphone
#
# https://getmicdrop.com
#
if [[ "$(isAppInstalled Moom)" = "false" ]]; then
    installcask mic-drop
    getLicense "Mic Drop"
fi

#
# Moom
#
# Applications' windows management
#
# https://manytricks.com/moom
#
# Notes:
#  - Need to install the App Store version, since you bought it there
#
if [[ "$(isAppInstalled Moom)" = "false" ]]; then
    installFromAppStore Moom 419330170
    giveAccessibilityPermission Moom
fi

#
# The Clock
#
# macOS Clock replacement with more advance features like work clocks & time zones
#
# https://www.seense.com/the_clock/
#
# Notes
# - You cannot remove the clock from the menubar anymore: minimizing used space as analog
#
if [[ "$(isAppInstalled "The Clock")" = "false" ]]; then
    defaults write com.apple.menuextra.clock IsAnalog -bool true
    installcask the-clock
    open -a "The Clock"
    getLicense "The Clock"
    pausethescript "Before continuing, restore the settings of The Clock by going in 'Preferences' and select the tab 'Backup/Restore'. Click on the 'iCloud' checkbox, and click the 'Restore' button."
fi

#
# TripMode
#
# Manage applications internet access
#
# https://tripmode.ch
#
installcask TripMode

#
# Zoom
#
# Video conference
#
# https://zoom.us
#
if [[ "$(isAppInstalled "zoom.us")" = "false" ]]; then
    installcask zoom
    giveScreenRecordingPermission "zoom.us"
    #TODO: add Notifications Permission
fi


##################################
#                                #
# Dock & Menu Bar Configurations #
#                                #
##################################

displaySection "Dock & Menu Bar Configurations"

#
# Minimize window into application icon
#
defaults write com.apple.dock minimize-to-application -bool true

#
# Position on screen
#
defaults write com.apple.dock "orientation" -string "right"

#
# Show recent applications in Dock
#
defaults write com.apple.dock show-recents -bool false

#
# Tile Size
#
defaults write com.apple.dock tilesize -int 35


#########################
#                       #
# Finder Configurations #
#                       #
#########################

displaySection "Finder Configurations"

#
# .DS_Store files creation on Network Disk
#
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

#
# Extension Change Warning
#
defaults write com.apple.finder FXEnableExtensionChangeWarning -boolean false

#
# Show Library Folder
#
sudo chflags nohidden $HOME/Library

#
# Settings - General - New Finder windows show
#
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads"

#
# Settings - Advanced - Show all filename extensions
#
defaults write -g AppleShowAllExtensions -bool true

#
# View - Show Path Bar
#
defaults write com.apple.finder ShowPathbar -bool true

#
# View - Show Status Bar
#
defaults write com.apple.finder ShowStatusBar -bool true

#
# Settings - General - Show these items on the desktop - CDs, DVDs, and iPods
#
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

#
# Settings - General - Show these items on the desktop - External disks
#
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false

#
# Settings - Sidebar - Show these items in the sidebar
#
defaults write com.apple.Finder ShowRecentTags -bool false

#
# Default Search Scope: search the current folder by default
#
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

#
# Expand Save Panel by default
#
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

#
# Sidebar Favorites Reordering
#
mysides remove all
mysides add Downloads file://$HOME/Downloads
mysides add Documents file://$HOME/Documents
mysides add Applications file:///Applications/


###########################
#                         #
# Keyboard Configurations #
#                         #
###########################

displaySection "Keyboard Configurations"

#
# Accent characters menu on press & hold a letter with possible accents
#
defaults write -g ApplePressAndHoldEnabled -bool true

# Press Fn to (do nothing)
defaults write com.apple.HIToolbox AppleFnUsageType -bool false


##################################
#                                #
# Mission Control Configurations #
#                                #
##################################

displaySection "Mission Control Configurations"

#
# Hot Corners - Bottom Right (disable Note app)
#
defaults write com.apple.dock wvous-br-corner -int 0


#####################################
#                                   #
# Security & Privacy Configurations #
#                                   #
#####################################

displaySection "Security & Privacy Configurations"

#
# General - Allow apps downloaded from Anywhere
#
sudo spctl --master-disable

###########################
#                         #
# Sharing  Configurations #
#                         #
###########################

displaySection "Sharing  Configurations"

#
# Computer name
#
sudo scutil --set ComputerName "lapta"
sudo scutil --set HostName "lapta"
sudo scutil --set LocalHostName "lapta"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "lapta"


########################
#                      #
# Sound Configurations #
#                      #
########################

displaySection "Sound Configurations"

#
# Show volume in menu bar
#
open /System/Library/PreferencePanes/Sound.prefPane
pausethescript "Uncheck 'Show Sound in menu bar' before continuing"

#
# Sound Effects - Play sound on startup
#
sudo nvram StartupMute=%01

#
# Sound Effects - Play user interface sound effects
#
defaults write com.apple.sound.uiaudio.enabled -bool false


###########################
#                         #
# Trackpad Configurations #
#                         #
###########################

displaySection "Trackpad Configurations"

#
# More Gestures - App Exposé
#
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -bool false

#
# More Gestures - Launchpad
#
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture -bool false

#
# More Gestures - Mission Control
#
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -bool false

#
# More Gestures - Notification Center
#
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -bool false

#
# More Gestures - Show Desktop
#
defaults write com.apple.AppleMultitouchTrackpad TrackpadFiveFingerPinchGesture -bool false

#
# Point & Click - Look up & data detector
#
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool false

# Point & Click - Silent clicking (not in the settings page anymore)
defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 0


################################
#                              #
# User & Groups Configurations #
#                              #
################################

displaySection "User & Groups Configurations"

#
# Guest User
#
sudo defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool false
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool false


#######################
#                     #
# Misc Configurations #
#                     #
#######################

displaySection "Misc Configurations"

#
# Input source switch popup
#
# Notes: This is the keyboard layout blue icons that is sometimes shown by macOS on application text input.
#
defaults write kCFPreferencesAnyApplication TSMLanguageIndicatorEnabled 0

#
# Internet Accounts
#
# Notes:
#  - I assume that if my work calendar is available, it means this step was done during a previous run of this script
#
if [[ ! "$(icalbuddy calendars | grep "$workemail")" ]]; then
    open /System/Library/PreferencePanes/InternetAccounts.prefPane
    pausethescript "Add your Email accounts to the macOS Internet Accounts"
fi

#
# Locate database generation
#
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

#
# Printer
#
local alreadyInstalled=$(system_profiler SPPrintersDataType | grep "The printers list is empty")
if [[ -n "$alreadyInstalled" ]]; then
    open /System/Library/PreferencePanes/PrintAndScan.prefPane
    pausethescript "Add your HP OfficeJet 7740"
fi

#
# Time Machine
#
sudo tmutil setdestination -p "smb://fharper@synology.local/Time Machine Backup/"

#
# Wallpaper
#
wallpaper set /Users/fharper/Documents/misc/background.png


########################
#                      #
# Apply Configurations #
#                      #
########################

echo $fg[blue]"The Dock, Finder & SystemUIServer will restart, giving a flashing impression: it's normal\n"$reset_color
killall Finder
killall Dock
killall SystemUIServer


#####################
#                   #
# Main applications #
#                   #
#####################

displaySection "Main applications"

#
# 1Password + 1Password CLI + git-credential-1password + Safari Extension
#
# Password manager
# CLI for 1Password
# Safari integration
#
# https://1password.com
# https://1password.com/downloads/command-line/
# https://apps.apple.com/us/app/1password-for-safari/id1569813296
#
if [[ "$(isAppInstalled 1Password)" = "false" ]]; then
    installcask 1password
    giveScreenRecordingPermission 1Password
    dockutil --add /Applications/1Password.app --allhomes
    installkeg 1password-cli
    open -a 1Password
    pausethescript "Open 1Password settings, and check 'Connect with 1Password CLI' & click the 'Set up SSH Agent' button in the 'Developer' tab before continuing"
    restoreAppSettings ssh
    eval $(op signin)
    pausethescript "Sign in to 1Password before continuing"
    brew tap develerik/tools
    installFromAppStore "1Password Safari Extension" 1569813296
    open -a Safari
    pausethescript "Open Safari Settings, and in the Extensions tab, check the box for '1Password for Safari' before continuing"
fi

#
# Antidote
#
# English & French corrector & dictionary
#
# https://www.antidote.info
#
if [[ "$(isAppInstalled "Antidote 11")" = "false" ]]; then
    open https://services.druide.com/
    pausethescript "Download Antidote in the macsetup folder before continuing"
    cd $HOME/Downloads/
    local filename=$(findfilewithregex "Antidote")
    installPKGfromDMG "$filename"
    cd -
    dockutil --add /Applications/Antidote/Antidote\ 11.app/
    loginitems -a Antidote
fi

#
# Google Chrome
#
# Browser
#
# https://www.google.com/chrome
#
if [[ "$(isAppInstalled "Google Chrome")" = "false" ]]; then
    installcask google-chrome
    dockutil --add "/Applications/Google Chrome.app" --position 2 --allhomes

    defaults write com.google.Chrome ExternalProtocolDialogShowAlwaysOpenCheckbox -bool true
    defaults write com.google.Chrome DisablePrintPreview -bool true
    defbro com.google.Chrome

    /Applications/Google\ Chrome/Contents/MacOS/Google\ Chrome "chrome-extension://jinjaccalgkegednnccohejagnlnfdag/options/index.html#settings"
    pausethescript "Authorize Dropbox for Violentmonkey sync before continuing"

    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome "chrome-extension://clngdbkpkpeebahjckkjfobafhncgmne/manage.html#stylus-options"
    pausethescript "Authorize Dropbox for Stylus sync before continuing"

    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome "chrome-extension://pncfbmialoiaghdehhbnbhkkgmjanfhe/pages/options.html"
    pausethescript "Authorize Dropbox for uBlacklist sync before continuing"

    duti -s com.google.Chrome com.compuserve.gif all #GIF (Image)

    #TODO: add Location Services permission
fi

#
# Home Assistant
#
# Home automation
#
# https://github.com/home-assistant/iOS
#
if [[ "$(isAppInstalled "Home Assistant")" = "false" ]]; then
    installcask home-assistant
fi

#
# macos-trash
#
# rm replacement that moves files to the Trash folder
#
# https://github.com/sindresorhus/macos-trash
#
brew install macos-trash

#
# Mumu X
#
# Emoji picker
#
# https://getmumu.com
#
# Notes
#  - Need to install manually as Mumu X is not in Hombrew (just Mumu)
#
if [[ "$(isAppInstalled "Mumu X")" = "false" ]]; then
    echo $fg[blue]"Starting the installation of Mumu X"$reset_color
    curl -L $(op item get "Mumu X" --fields label="download link") --output mumux.dmg
    installDMG mumux.dmg true
    loginitems -a "Mumu X"
    giveAccessibilityPermission "Mumu X"
fi

#
# Notion
#
# Notes application
#
# https://www.notion.so
#
if [[ "$(isAppInstalled "Notion")" = "false" ]]; then
    installcask notion
    dockutil --add "/Applications/Notion.app" --allhomes
fi

#
# OpenInEditor-Lite
#
# Finder Toolbar app to open the current directory in your preferred Editor
#
# https://github.com/Ji4n1ng/OpenInTerminal
#
if [[ "$(isAppInstalled OpenInEditor-Lite)" = "false" ]]; then
    installcask openineditor-lite
    defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor "Visual Studio Code"
    open /Applications
    pausethescript "drag openineditor-lite in Finder toolbar while pressing Command before continuing"
    curl -L https://github.com/Ji4n1ng/OpenInTerminal/releases/download/v1.2.0/Icons.zip  --output icons.zip
    unzip icons.zip
    rm icons.zip
    rm -rf __MACOSX #created by the unzip call
    seticon icons/icon_vscode_dark.icns /Applications/OpenInEditor-Lite.app
    rm -rf icons
fi

#
# OpenInTerminal-Lite
#
# Finder Toolbar app to open the current directory in your preferred Terminal
#
# https://github.com/Ji4n1ng/OpenInTerminal
#
if [[ "$(isAppInstalled OpenInTerminal-Lite)" = "false" ]]; then
    installcask openinterminal-lite
    defaults write wang.jianing.app.OpenInTerminal-Lite LiteDefaultTerminal iTerm
    open /Applications
    pausethescript "drag openinterminal-lite in Finder toolbar while pressing Command before continuing"
    curl -L https://github.com/Ji4n1ng/OpenInTerminal/releases/download/v1.2.0/Icons.zip  --output icons.zip
    unzip icons.zip
    rm icons.zip
    rm -rf __MACOSX #created by the unzip call
    seticon icons/icon_terminal_dark.icns /Applications/OpenInTerminal-Lite.app
    rm -rf icons
fi

#
# Rain
#
# Simple macOS menubar app that play rainforest sound
#
# https://github.com/fharper/rain
#
if [[ "$(isAppInstalled rain)" = "false" ]]; then
    echo $fg[blue]"Starting the installation of Rain"$reset_color
    curl -L https://github.com/fharper/rain/releases/download/v1.0b2/rain.app.zip --output rain.zip
    unzip rain.zip
    rm rain.zip
    rm -rf __MACOSX #created by the unzip call
    mv rain.app /Applications
    loginitems -a Rain
fi

#
# Slack
#
# Text-based communication app
#
# https://slack.com
#
if [[ "$(isAppInstalled Slack)" = "false" ]]; then
    installcask slack
    dockutil --add /Applications/Slack.app/ --allhomes
    open -a Slack
    local slack_workspaces=($(op item list --categories Login --format json | jq '.[] | select(.title|test("Slack")) | .urls[0].href' | tr -d '"'))
    for slack in "${slack_workspaces[@]}"; do
      open "$slack"
      pausethescript "Sign in this Slack community: $slack"
    done
fi

#
# Spotify
#
# Music service player
#
# https://www.spotify.com
#
if [[ "$(isAppInstalled Spotify)" = "false" ]]; then
    installcask spotify
    dockutil --add /Applications/Spotify.app --allhomes
fi

#
# Todoist
#
# Todo app
#
# https://todoist.com
#
if [[ "$(isAppInstalled Todoist)" = "false" ]]; then
    installcask todoist
    dockutil --add /Applications/Todoist.app --allhomes
    loginitems -a Todoist
fi

#
# Visual Studio Code
#
# Code editor
#
# https://github.com/microsoft/vscode
#
if [[ "$(isAppInstalled "Visual Studio Code")" = "false" ]]; then
    installcask visual-studio-code
    dockutil --add /Applications/Visual\ Studio\ Code.app/ --allhomes

    npm config set editor code

    duti -s com.microsoft.VSCode public.css all #CSS
    duti -s com.microsoft.VSCode public.comma-separated-values-text all #CSV
    duti -s com.microsoft.VSCode com.netscape.javascript-source all #JavaScript
    duti -s com.microsoft.VSCode public.json all #JSON
    duti -s com.microsoft.VSCode dyn.ah62d4rv4ge8027pb all #lua
    duti -s com.microsoft.VSCode com.apple.log all #logs
    duti -s com.microsoft.VSCode net.daringfireball.markdown all #Markdown
    duti -s com.microsoft.VSCode public.php-script all #PHP
    duti -s com.microsoft.VSCode com.apple.property-list all # Plist
    duti -s com.microsoft.VSCode public.python-script all # Python
    duti -s com.microsoft.VSCode public.rtf all #RTF
    duti -s com.microsoft.VSCode public.ruby-script all #Ruby
    duti -s com.microsoft.VSCode com.apple.terminal.shell-script all #SH
    duti -s com.microsoft.VSCode public.shell-script all #Shell script
    duti -s com.microsoft.VSCode public.svg-image all #SVG
    duti -s com.microsoft.VSCode dyn.ah62d4rv4ge81g6pq all #SQL
    duti -s com.microsoft.VSCode dyn.ah62d4rv4ge81k3u all #Terraform tf
    duti -s com.microsoft.VSCode dyn.ah62d4rv4ge81k3xxsvu1k3k all #Terraform tfstate
    duti -s com.microsoft.VSCode dyn.ah62d4rv4ge81k3x0qf3hg all #Terraform tfvars
    duti -s com.microsoft.VSCode public.plain-text all #TXT
    duti -s public.mpeg-2-transport-stream all #TypeScript (there's no official UTI, so using the recognized one as I never have MPEG .ts files)
    duti -s com.microsoft.VSCode public.xml all #XML
    duti -s com.microsoft.VSCode public.yaml all #YAML
    duti -s com.microsoft.VSCode public.zsh-script all #ZSH
    duti -s com.microsoft.VSCode text/x-shellscript all #ZSH
fi


###################
#                 #
# Developer stuff #
#                 #
###################

displaySection "Developer stuff"

#
# .Net Core
#
# .Net Core Programming Language
#
# https://github.com/dotnet/core
#
installAsdfPlugin dotnet-core 7.0.305

#
# Act
#
# Run your GitHub Actions locally
#
# https://github.com/nektos/act
#
installkeg act

#
# actionlint
#
# Static checker for GitHub Actions workflow files
#
# https://github.com/rhysd/actionlint
#
installkeg actionlint

#
# Air
#
# Live reload for Go applications
#
# https://github.com/cosmtrek/air
#
installGoApp air latest

#
# ajv-cli
#
# Ajv JSON Schema Validator CLI
#
# https://github.com/ajv-validator/ajv-cli
#
installNodePackages ajv-cli

#
# Akamai Linode
#
# Linode CLI
#
# https://github.com/linode/linode-cli
#
if [[ "$(isCLAppInstalled linode)" = "false" ]]; then
    installkeg linode-cli
    confirm "Do you want to configure the Akamai Linode CLI now?" "linode configure"
fi

#
# argo
#
# Argo Workflows CLI
#
# https://github.com/argoproj/argo-workflows/
#
installkeg argo

#
# argocd
#
# Argo CD CLI
#
# https://github.com/argoproj/argo-cd
#
installkeg argocd

#
# aws-cli
#
# Amazon Web Services CLI
#
# https://github.com/aws/aws-cli
#
if [[ "$(isCLAppInstalled aws)" = "false" ]]; then
    installkeg awscli

    confirm "Do you want to configure the AWS CLI now?" "aws configure"
fi

#
# BFG Repo-Cleaner
#
# git-filter-branch replacement
#
# https://github.com/rtyley/bfg-repo-cleaner
#
installkeg bfg

#
# Black
#
# Python code formatter
#
# https://github.com/psf/black
#
installkeg black

#
# cabal-install
#
# Build & installation tool for Haskell application
#
# https://github.com/haskell/cabal
#
installkeg cabal-install

#
# Caddy
#
# HTTP server
#
# https://github.com/caddyserver/caddy
#
installkeg caddy

#
# caniuse-cmd
#
# Search caniuse.com from the command line
#
# https://github.com/sgentle/caniuse-cmd
#
npm install -g caniuse-cmd

#
# Charles Proxy
#
# HTTP proxy, monitor & reverse proxy
#
# https://www.charlesproxy.com
#
installcask charles

#
# Chrome Webstore CLI
#
# CLI for interacting with Google Chrome Webstore
#
# https://github.com/vladimyr/chrome-webstore-cli
#
installNodePackages chrome-webstore-cli

#
# Civo
#
# Civo CLI
#
# https://github.com/civo/cli
#
if [[ "$(isCLAppInstalled civo)" = "false" ]]; then
    brew tap civo/tools
    installkeg civo
fi

#
# cockroach-sql
#
# CockroachDB CLI
#
# https://www.cockroachlabs.com
#
installkeg cockroachdb/tap/cockroach-sql

#
# CocoaPods
#
# XCode dependency manager
#
# https://github.com/CocoaPods/CocoaPods
#
installkeg cocoapods

#
# commitlint
#
# Lint commit messages
#
# https://github.com/conventional-changelog/commitlint
#
installkeg commitlint

#
# Cordova CLI
#
# CLI for Cordova
#
# https://github.com/apache/cordova-cli
#
installNodePackages cordova

#
# Curl
#
# Transfer data from URL CLI
#
# https://github.com/curl/curl
#
installkeg curl

#
# Cypress
#
# E2E testing
#
# https://github.com/cypress-io/cypress
#
installNodePackages cypress

#
# delete-gh-workflow-runs + fzf
#
# Easily mass-delete GitHub Workflow runs
# A command-line fuzzy finder
#
# https://github.com/jv-k/delete-gh-workflow-runs
# https://github.com/junegunn/fzf
#
# Notes:
# - fzf is a dependency for delete-gh-workflow-runs
#
if [[ "$(isCLAppInstalled delete-workflow-runs)" = "false" ]]; then
    installNodePackages delete-workflow-runs
    installkeg fzf
fi

#
# Delve
#
# Go Debugger
#
# https://github.com/go-delve/delve
#
installkeg delve

#
# Deno
#
# deno programming language (runtime)
#
# https://github.com/denoland/deno
#
installAsdfPlugin deno 1.30.3

#
# diff-so-fancy
#
# better looking git diff
#
# https://github.com/so-fancy/diff-so-fancy
#
installkeg diff-so-fancy

#
# direnv
#
# Load and unload environment variables depending on the current directory
#
# https://github.com/direnv/direnv
#
installkeg direnv

#
# dive
#
# A tool for exploring each layer of Docker images
#
# https://github.com/wagoodman/dive
#
installkeg dive

#
# Docker Desktop
#
# Virtualization tool
#
# https://www.docker.com
#
if [[ "$(isAppInstalled Docker)" = "false" ]]; then
    installcask docker
    docker extension install docker/resource-usage-extension
    docker login -u $username
fi

#
# ESLint
# ESLint Formatter Pretty
# ESLint plugins:
# - eslint-plugin-markdown
# - eslint-plugin-react
# - eslint-plugin-ui-testing (using for Puppeteer)
# - eslint-plugin-jest
# - eslint-plugin-security-node
# - eslint-plugin-jsx-a11y
# - eslint-plugin-i18n
# - eslint-plugin-jsdoc
# - eslint-plugin-json
# - eslint-mdx
#
# JavaScript linter
# Pretty ESLint formatter
# Lint JavaScript code blocks in Markdown documents
# React-specific linting rules for ESLint
# ESLint plugin that helps following best practices when writing UI tests like with Puppeteer
# ESLint plugin for Jest
# ESLint security plugin for Node.js
# a11y rules on JSX elements
# ESLint rules to find out the texts and messages not internationalized in the project
# JSDoc specific linting rules for ESLint
# JSON files rules
# ESLint Parser/Plugin for MDX
#
# https://github.com/eslint/eslint
# https://github.com/sindresorhus/eslint-formatter-pretty
# https://github.com/eslint/eslint-plugin-markdown
# https://github.com/yannickcr/eslint-plugin-react
# https://github.com/kwoding/eslint-plugin-ui-testing
# https://github.com/jest-community/eslint-plugin-jest
# https://github.com/gkouziik/eslint-plugin-security-node
# https://github.com/jsx-eslint/eslint-plugin-jsx-a11y
# https://github.com/chejen/eslint-plugin-i18n
# https://github.com/gajus/eslint-plugin-jsdoc
# https://github.com/azeemba/eslint-plugin-json
# https://github.com/mdx-js/eslint-mdx
#
installkeg eslint
installNodePackages eslint-formatter-pretty
installNodePackages eslint-plugin-markdown
installNodePackages eslint-plugin-react
installNodePackages eslint-plugin-ui-testing
installNodePackages eslint-plugin-jest
installNodePackages eslint-plugin-security-node
installNodePackages eslint-plugin-jsx-a11y
installNodePackages eslint-plugin-i18n
installNodePackages eslint-plugin-jsdoc
installNodePackages eslint-plugin-json
installNodePackages eslint-plugin-mdx

#
# doctl
#
# DigitalOcean CLI
#
# https://github.com/digitalocean/doctl
#
if [[ "$(isCLAppInstalled doctl)" = "false" ]]; then
    installkeg doctl
    doctl auth init
fi

#
# Expo CLI
#
# Tools for creating, running, and deploying Universal Expo & React Native apps
#
# https://github.com/expo/expo-cli
#
installNodePackages expo-cli

#
# flow-bin
#
# Binary wrapper for Flow - A static type checker for JavaScript
#
# https://github.com/flow/flow-bin
#
# Notes:
#  - Needed by the vscode-flow-ide Visual Studio Code extension
#
installNodePackages flow-bin

#
# Gist
#
# CLI to manage gist
#
# https://github.com/defunkt/gist
#
if [[ "$(isCLAppInstalled gist)" = "false" ]]; then
    installkeg gist
    gist --login
fi

#
# Git Branch Status
#
# Prints git branch sync status reports
#
# https://github.com/bill-auger/git-branch-status
#
installNodePackages git-branch-status

#
# Git Large File Storage
#
# Git extension for versioning large files
#
# https://github.com/git-lfs/git-lfs
#
installkeg git-lfs

#
# Git Open
#
# Open the GitHub page for a repository
#
# https://github.com/paulirish/git-open
#
# Notes:
#  - git-open in Homebrew isn't the same
#
installNodePackages git-open

#
# Git Recent
#
# See your latest local git branches, formatted real fancy
#
# https://github.com/paulirish/git-recent
#
installkeg git-recent

#
# Git Sizer
#
# Compute various size metrics for a Git repository
#
# https://github.com/github/git-sizer
#
installkeg git-sizer

#
# GitHub CLI & gh-pr-draft
#
# GitHub CLI
# GitHub CLI Extension for converting PR to Draft
#
# https://github.com/cli/cli
# https://github.com/kyanny/gh-pr-draft
#
if [[ "$(isCLAppInstalled gh)" = "false" ]]; then
    installkeg gh
    gh auth login
    gh config set editor "code --wait"
    gh extension install kyanny/gh-pr-draft
fi

#
# GitLab CLI
#
# GitLab CLI
#
# https://gitlab.com/gitlab-org/cli
#
if [[ "$(isCLAppInstalled glab)" = "false" ]]; then
    installkeg glab

    if [[ -z "${GITLAB_TOKEN}" ]]; then
        glab auth login
    fi
fi

#
# Gitleaks
#
# Detect hardcoded secrets
#
# https://github.com/gitleaks/gitleaks
#
installkeg gitleaks

#
# GNU sed
#
# GNU implementation of the famous sed
#
# https://www.gnu.org/software/sed/
#
installkeg gnu-sed

#
# Go
#
# Go programming language
#
# https://golang.org
#
installAsdfPlugin golang 1.23.2

#
# go-jira
#
# CLI for Jira
#
# https://github.com/go-jira/jira
#
if [[ "$(isCLAppInstalled jira)" = "false" ]]; then
    installkeg go-jira

    confirm "Do you want to connect the JIRA CLI right now?" "jira session"
fi

#
# golangci-lint
#
# Go linter
#
# https://github.com/golangci/golangci-lint
#
installkeg golangci-lint

#
# Google Cloud SDK
#
# Google Cloud CLI
#
# https://cloud.google.com/sdk
#
if [[ "$(isCLAppInstalled gcloud)" = "false" ]]; then
    installcask google-cloud-sdk
    gcloud config set disable_usage_reporting true
    gcloud components install gke-gcloud-auth-plugin

    # Configure gcloud
    local confirmation=$(gum confirm "Do you want to log into Google Cloud right now?" && echo "true" || echo "false")
    if [[ $confirmation == "true" ]] ; then
        gcloud auth login
        gcloud config set compute/region us-east1
        gcloud config set compute/zone us-east1-b
    fi
fi

#
# gopls
#
# Go language server
#
# https://github.com/golang/tools/tree/master/gopls
#
# Notes:
#  - Needed by the Go extension for Visual Studio Code
#
installkeg gopls

#
# GPG Suite
#
# GPG keychain management & tools
#
# https://gpgtools.org
#
if [[ "$(isAppInstalled "GPG Keychain")" = "false" ]]; then
    installcask gpg-suite
    op document get "PGP/GPG Key" --output=private.key
    gpg --import private.key
    pausethescript "Enter your passphrase to finish the import of your private PGP key before continuing"
    rm private.key
    git config --replace-all --global user.signingkey 523390FAB896836F8769F6E1A3E03EE956F9208C
    git config --replace-all --global commit.gpgsign true
fi

#
# Grip
#
# GitHub Readme Instant Preview
#
# https://github.com/joeyespo/grip
#
installkeg grip

#
# gulp-cli
#
# Gulp CLI
#
# https://github.com/gulpjs/gulp-cli
#
installkeg gulp-cli

#
# Gum
#
# Utils for Shell Scripts
#
# https://github.com/charmbracelet/gum
#
installkeg gum

#
# Hadolint
#
# Docker file linter
#
# https://github.com/hadolint/hadolint
#
installkeg hadolint

#
# Helm
#
# Kubernetes Package Manager
#
# https://github.com/helm/helm
#
if [[ "$(isCLAppInstalled helm)" = "false" ]]; then
    installkeg helm

    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo add chaoskube https://linki.github.io/chaoskube/
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo add kubeinvaders https://lucky-sideburn.github.io/helm-charts/
    helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
    helm repo add kubescape https://kubescape.github.io/helm-charts/
    helm repo add opencost https://opencost.github.io/opencost-helm-chart/
    helm repo add portainer https://portainer.github.io/k8s
    helm repo add robusta https://robusta-charts.storage.googleapis.com
    helm repo add yourls https://charts.yourls.org
    helm repo add yugabytedb https://charts.yugabyte.com

    helm repo update
fi

#
# Hukum
#
# Displays Github Action live progress in the terminal
#
# https://github.com/abskmj/hukum
#
installNodePackages hukum

#
# ImageMagick
#
# Images tooling suite
#
# https://github.com/ImageMagick/ImageMagick
#
# Notes:
#  - Needed before PHP install with asdf
#
installkeg imagemagick

#
# iOS Deploy
#
# Install and debug iPhone apps from the command line, without using Xcode
#
# https://github.com/ios-control/ios-deploy
#
installkeg ios-deploy

#
# iTermocil
#
# Pre-defined iTerm2 window/pane layouts
#
# https://github.com/TomAnthony/itermocil
#
if [[ "$(isCLAppInstalled itermocil)" = "false" ]]; then
    brew install TomAnthony/brews/itermocil
    restoreAppSettings itermocil
fi

#
# Java (OpenJDK)
#
# Java programming language
#
# https://openjdk.org
#
installAsdfPlugin java openjdk-19.0.2

#
# Jest
#
# JavaScript Testing Framework
#
# https://github.com/facebook/jest
#
installNodePackages jest

#
# json2csv
#
# JSON to CSV converting tool
#
# https://github.com/zemirco/json2csv
#
installNodePackages json2csv

#
# Jsonnet
#
# JSON extension for data templating
#
# https://github.com/google/jsonnet
#
installkeg jsonnet

#
# JupyterLab
#
# Jupyter notebooks IDE
#
# https://jupyter.org/

installcask jupyterlab

#
# k3d
#
# k3s multi-nodes tools for Docker
#
# https://github.com/k3d-io/k3d
#
installkeg k3d

#
# K9s
#
# Kubernetes cluster management from the CLI
#
# https://github.com/derailed/k9s
#
installkeg k9s

#
# Korb
#
# Move Kubernetes PVCs between Storage Classes and Namespaces (or export their content)
#
# https://github.com/BeryJu/korb
#
installkeg krob

#
# Krew
#
# kubectl plugins manager
#
# https://github.com/kubernetes-sigs/krew
#
installkeg krew

#
# KubeColor
#
# Colorize your kubectl output
#
# https://github.com/kubecolor/kubecolor
#
installkeg kubecolor

#
# kubectl
#
# Kubernetes CLI
#
# https://github.com/kubernetes/kubectl
#
if [[ "$(isCLAppInstalled kubectl)" = "false" ]]; then
    installkeg kubectl
    kubectl krew update
fi

#
# kubectx & kubens
#
# Kubernetes clusters & namespaces switcher
#
# https://github.com/ahmetb/kubectx
#
installkeg kubectx

#
# Kubescape
#
# Kubernetes security audit tool
#
# https://github.com/kubescape/kubescape
#
installkeg kubescape

#
# kustomize
#
# Customize Kubernetes YAML configurations files
#
# https://github.com/kubernetes-sigs/kustomize
#
installkeg kustomize

#
# Lighthouse
#
# Analyzes web pages for performance & best practices
#
# https://github.com/GoogleChrome/lighthouse
#
installNodePackages lighthouse

#
# localtunnel
#
# Expose localhost to the web
#
# https://github.com/localtunnel/localtunnel
#
installkeg localtunnel

#
# lsof
#
# List open files
#
# https://github.com/lsof-org/lsof
#
# Notes: newer version than the macOS default one
#
installkeg lsof

#
# Lynis
#
# Security auditing tool for Linux, macOS, and UNIX-based systems
#
# https://github.com/CISOfy/lynis
#
installkeg lynis

#
# MAC Address Vendor Lookup
#
# Command line tool for macaddress.io API
#
# https://github.com/CodeLineFi/maclookup-cli
#
installPythonApp maclookup-cli

#
# markdown-link-check
#
# Check links inside Markdown files
#
# https://github.com/tcort/markdown-link-check
#
installNodePackages markdown-link-check

#
# markdownlint-cli2
#
# Markdown linting CLI
#
# https://github.com/DavidAnson/markdownlint-cli2
#
installkeg markdownlint-cli2

#
# Microsoft Azure
#
# Azure CLI
#
# https://github.com/Azure/azure-cli
#
installkeg azure-cli

#
# Mocha
#
# Node.js testing framework
#
# https://github.com/mochajs/mocha
installNodePackages mocha

#
# minikube
#
# Run Kubernetes locally
#
# https://github.com/kubernetes/minikube
#
installkeg minikube

#
# mkcert
#
# Tool to make local trusted development certificates
#
# https://github.com/FiloSottile/mkcert
#
if [[ "$(isCLAppInstalled mkcert)" = "false" ]]; then
    installkeg mkcert
    mkcert -install
fi

# mongosh
#
# MongoDB Shell
#
# https://github.com/mongodb-js/mongosh
#
installkeg mongosh

#
# MongoDB Atlas CLI
#
# MongoDB Atlas CLI
#
# https://github.com/mongodb/mongodb-atlas-cli
#
if [[ "$(isCLAppInstalled atlas)" = "false" ]]; then
    installkeg mongodb-atlas-cli
    confirm "Do you want to configure the MongoDB CLI now?" "atlas auth login"
fi

#
# MongoDB Compass
#
# MongoDB GUI client
#
# https://www.mongodb.com/products/compass
#
installcask mongodb-compass

#
# MQTT Explorer
#
# MQTT client
#
# https://github.com/thomasnordquist/MQTT-Explorer
#
installcask mqtt-explorer

#
# MySQL Workbench
#
# MySQL Client GUI
#
# https://github.com/mysql/mysql-workbench
#
installcask mysqlworkbench

#
# Newman
#
# Postman command-line collection runner
#
# https://github.com/postmanlabs/newman
#
installkeg newman

#
# npm Check Updates (ncu)
#
# Find newer versions of Node package dependencies
#
# https://github.com/raineorshine/npm-check-updates
#
installNodePackages npm-check-updates

#
# OpenAPI Validator
#
# OpenAPI linter & validator
#
# https://github.com/IBM/openapi-validator
#
installNodePackages ibm-openapi-validator

#
# Perl
#
# Perl programming language
#
# https://github.com/Perl/perl5
#
installAsdfPlugin perl 5.36.1

#
# pgAdmin 4
#
# PostgreSQL client
#
# https://github.com/pgadmin-org/pgadmin4
#
installcask pgadmin4

#
# PHP
#
# PHP programming language
#
# https://github.com/php/php-src
#
#
# PHP Dependencies:
#
# Bison
# Parser generator
# https://www.gnu.org/software/bison/
#
# GMP
# GNU multiple precision arithmetic library
# https://gmplib.org
#
# ICU
# C/C++ and Java libraries for Unicode and globalization
# https://icu.unicode.org
#
# LibGD
# Graphics library to dynamically manipulate images
# https://libgd.github.io
#
# libiconv
# Conversion library
# https://www.gnu.org/software/libiconv/
#
# libzip
# C library for reading, creating, and modifying zip archives
# https://libzip.org
#
# pkg-config
# Manage compile and link flags for libraries
# https://freedesktop.org/wiki/Software/pkg-config/
#
# re2c
# Generate C-based recognizers from regular expressions
# https://re2c.org
#
# Sodium
# NaCl networking and cryptography library
# https://libsodium.org
#
if [[ ! $(asdf current php) ]]; then
    installkeg bison
    installkeg gmp
    installkeg icu4c
    installkeg libgd
    installkeg libiconv
    installkeg libzip
    installkeg pkg-config
    installkeg re2c
    installkeg libsodium

    installAsdfPlugin php 8.3.0
fi

#
# PHP_CodeSniffer
#
# PHP linter
#
# https://github.com/squizlabs/PHP_CodeSniffer
#
installkeg php-code-sniffer

#
# Postman
#
# GUI for managing, calling, and testing APIs
#
# https://postman.com
#
installcask postman

#
# PowerShell
#
# Cross-platform command-line shell task automation solution, a scripting language, and a configuration management framework
#
# https://github.com/PowerShell/PowerShell
#
installcask powershell

#
# Prettier
#
# Code formatter
#
# https://github.com/prettier/prettier
#
installkeg prettier

#
# Puppeteer
#
# Headless Chrome Node.js API for automation
#
# https://github.com/puppeteer/puppeteer
#
installNodePackages puppeteer

#
# Ruby
#
# Ruby programming language
#
# https://github.com/ruby/ruby
#
installAsdfPlugin ruby 3.2.2

#
# React Native CLI
#
# CLI for React Native development
#
# https://github.com/facebook/react-native
#
installkeg react-native-cli

#
# Rust
#
# Rust programming language
#
# https://github.com/rust-lang/rust
#
installAsdfPlugin rust 1.75.0

#
# S3cmd
#
# CLI for AWS S3
#
# https://github.com/s3tools/s3cmd
#
if [[ "$(isCLAppInstalled s3cmd)" = "false" ]]; then
    installkeg s3cmd

    confirm "Do you want to configure s3cmd right now?" "s3cmd --configure"
fi

#
# secretlint
#
# Pluggable linting tool to prevent committing credential.
#
# https://github.com/secretlint/secretlint
#
if [[ "$(isCLAppInstalled secretlint)" = "false" ]]; then
    installNodePackages secretlint
    installNodePackages @secretlint/secretlint-rule-preset-recommend
fi

#
# ShellCheck
#
# Shell scripts linter
#
# https://github.com/koalaman/shellcheck
#
installkeg shellcheck

#
# Steampipe
#
# Use SQL to query cloud infrastructure & more
#
# https://github.com/turbot/steampipe
#
installkeg steampipe

#
# Stern
#
# Multi pod and container log tailing for Kubernetes
#
# https://github.com/stern/stern
#
installkeg stern

#
# Stylelint
#
# CSS, SCSS, Sass, Less & SugarSS linter
#
# https://github.com/stylelint/stylelint
#
installkeg stylelint
installNodePackages stylelint-config-recommended

#
# Telnet
#
# Terminal emulation for logging into a remote hosts
#
# https://github.com/apple-oss-distributions/remote_cmds/tree/main/telnet
#
installkeg telnet

#
# Terraform
#
# Infrastructure as Code (IaC)
#
# https://github.com/hashicorp/terraform
#
installkeg hashicorp/tap/terraform

#
# TFLint
#
# Terraform Linter
#
# https://github.com/terraform-linters/tflint
#
if [[ "$(isCLAppInstalled tflint)" = "false" ]]; then
    installkeg tflint
    tflint --init
fi

#
# tfsec
#
# Terraform security scanner
#
# https://github.com/aquasecurity/tfsec
#
installkeg tfsec

#
# TypeScript
#
# JavaScript superset
#
# https://github.com/microsoft/TypeScript/
#
installkeg typescript

#
# UTM
#
# Virtual machine host
#
# https://github.com/utmapp/UTM
#
installcask utm

#
# vale
#
# Text validator
#
# https://github.com/errata-ai/vale
#
installkeg vale

#
# Vault
#
# HashiCorp Vault CLI
#
# https://github.com/hashicorp/vault
#
if [[ "$(isCLAppInstalled defbro)" = "false" ]]; then
    brew tap hashicorp/tap
    brew install hashicorp/tap/vault
    confirm "Do you want to connect the Vault CLI now?" "vault login"
fi

#
# Vercel CLI
#
# CLI for Vercel
#
# https://github.com/vercel/vercel
#
if [[ "$(isCLAppInstalled vercel)" = "false" ]]; then
    installkeg vercel-cli
    vercel login $email
fi

#
# vultr-cli
#
# Vultr CLI
#
# https://github.com/vultr/vultr-cli
#
installkeg vultr/vultr-cli/vultr-cli

#
# Webhint
#
# Accessibility, speed, cross-browser compatibility analysis tool
#
# https://github.com/webhintio/hint
#
installNodePackages hint

#
# Webpack
#
# JavaScript bundler
#
# https://github.com/webpack/webpack
#
installkeg webpack

#
# woff2
#
# woff2 fonts tools
#
# https://github.com/google/woff2
#
# Notes: the binary for decompressing woff2 to otf is called woff2_decompress
#
installkeg woff2

#
# xcodes
#
# Xcode versions management
#
# https://github.com/XcodesOrg/xcodes
#
# Notes: to list runtimes `xcodes runtimes`
#
if [[ "$(isCLAppInstalled xcodes)" = "false" ]]; then
    installkeg xcodesorg/made/xcodes
    xcodes runtimes install "iOS 17.4"
fi

#
# yamale
#
# YAML Schema validator
#
# https://github.com/23andMe/Yamale
#
installkeg yamale

#
# yamllint
#
# YAML files linter
#
# https://github.com/adrienverge/yamllint
#
installkeg yamllint

#
# Yarn
#
# npm alternative
#
# https://github.com/yarnpkg/yarn
#
# Notes:
#  - Installing with npm instead of Homebrew so it's easier when updating Node.js version with asdf
#
if [[ "$(isCLAppInstalled yarn)" = "false" ]]; then
    installNodePackages yarn
    yarn config set --home enableTelemetry 0
fi

#
# Yeoman
#
# Scaffolding tool
#
# https://github.com/yeoman/yeoman
#
installNodePackages yo

#
# yq
#
# YAML processor
#
# https://github.com/mikefarah/yq
#
installkeg yq


######################
#                    #
# Command line tools #
#                    #
######################

displaySection "Command line tools"

#
# alex
#
# Text analyzer to catch insensitive, and inconsiderate writing
#
# https://github.com/get-alex/alex
#
installkeg alexjs

#
# Asciinema + svg-term-cli + agg
#
# Terminal session recorder
# Convert tool for asciicast to animated SVG
# asciinema gif generator
#
# https://github.com/asciinema/asciinema
# https://github.com/marionebl/svg-term-cli
# https://github.com/asciinema/agg
#
if [[ "$(isCLAppInstalled asciinema)" = "false" ]]; then
    installkeg asciinema
    asciinema auth
    pausethescript "Authenticate with asciinema before continuing the installation script."
    installNodePackages svg-term-cli
    installkeg agg
fi

#
# asimov
#
# Excludes developers dependencies automatically from Time Machine backups
#
# https://github.com/stevegrunwell/asimov
#
if [[ "$(isCLAppInstalled asimov)" = "false" ]]; then
    installkeg asimov
    asimov
    sudo brew services start asimov
fi

#
# backgroundremover
#
# Image & video background remover
#
# https://github.com/nadermx/backgroundremover
#
installPythonApp backgroundremover

#
# Bandwhich
#
# Network utilization visualization terminal tool
#
# https://github.com/imsnif/bandwhich
#
installkeg bandwhich

#
# Bat
#
# A better cat
#
# https://github.com/sharkdp/bat
#
installkeg bat

#
# ccase
#
# Command line interface to convert strings into any case
#
# https://github.com/rutrum/ccase
#
cargo install ccase

#
# Color LS + Nerd Fonts
#
# Beautifies the terminal's ls command
# Fonts collections aggregator
#
# https://github.com/athityakumar/colorls
# https://github.com/ryanoasis/nerd-fonts
#
if [[ "$(isCLAppInstalled colorls)" = "false" ]]; then
    gem install colorls
    installcask font-hack-nerd-font
fi

#
# Coreutils
#
# Basic file, shell and text manipulation utilities
#
# https://www.gnu.org/software/coreutils/
#
# Notes
# - Needed for shuf, which is used in the espanso trigger "":randomtime"
#
installkeg coreutils

#
# Coursera Downloader
#
# CLI to download Coursera courses
#
# https://github.com/coursera-dl/coursera-dl
#
installPythonApp coursera-dl

#
# diff-pdf
#
# Tool for visually comparing two PDF files
#
# https://github.com/vslavik/diff-pdf
#
installkeg diff-pdf

#
# empty-trash-cli
#
# CLI to empty the trash
#
# https://github.com/sindresorhus/empty-trash-cli
#
installNodePackages empty-trash-cli

#
# fd
#
# A simple, fast and user-friendly alternative to 'find'
#
# https://github.com/sharkdp/fd
#
installkeg fd

#
# FFmpeg
# ffmpeg-progressbar-cli
#
# Libraries and tools to process multimedia content like video, audio & more
# A colored progress bar for FFmpeg
#
# https://github.com/FFmpeg/FFmpeg
# https://github.com/sidneys/ffmpeg-progressbar-cli
#
installkeg ffmpeg
installNodePackages ffmpeg-progressbar-cli

#
# FFmpeg Quality Metrics
#
# CLI video quality metrics tool using FFmpeg
#
# https://github.com/slhck/ffmpeg-quality-metrics
#
installPythonApp ffmpeg-quality-metrics

#
# file-icon-cli
#
# Get the file or app icon as a PNG
#
# https://github.com/sindresorhus/file-icon-cli
#
installNodePackages file-icon-cli

#
# Ghostscript
#
# PostScript & PDF intepreter
#
# https://www.ghostscript.com
#
installkeg ghostscript

#
# GHunt
#
# Google OSINT tool
#
# https://github.com/mxrch/GHunt
#
if [[ "$(isCLAppInstalled ghunt)" = "false" ]]; then
    installPythonApp ghunt
    ghunt login
fi

#
# gifsicle
#
# Create, manipulate, and optimize GIF images and animations
#
# https://github.com/kohler/gifsicle
#
installkeg gifsicle

#
# gsed
#
# GNU sed which support extended regular expressions
#
# https://www.gnu.org/software/sed/
#
installkeg gsed

#
# Homebrew Command Not Found
#
# Suggest a package to install when the command is not found
#
# https://github.com/Homebrew/homebrew-command-not-found
#
brew tap homebrew/command-not-found

#
# htop
#
# Terminal interactive process viewer
#
# https://github.com/htop-dev/htop
#
installkeg htop

#
# HTTPie
#
# Terminal HTTP client
#
# https://github.com/httpie/httpie
#
installkeg httpie

#
# libsixel
#
# SIXEL image format encoder/decoder
#
# https://github.com/saitoha/libsixel
#
# Notes: img2sixel is the binary
#
installkeg libsixel

#
# LinkChecker
#
# cli tool to check all links from a website or specific page
#
# https://github.com/wummel/linkchecker
#
installPythonApp linkchecker

#
# lsusb
#
# Tool to list USB devices
#
# https://github.com/jlhonora/lsusb
#
installkeg lsusb

#
# LZip
#
# Lossless data compressor
#
# https://www.nongnu.org/lzip
#
installkeg lzip

#
# macos-focus-mode
#
# Control macOS Do Not Disturb from the command line
#
# https://github.com/arodik/macos-focus-mode
#
# Notes: used by MeetingBar AppleScript automation
#
if [[ "$(isCLAppInstalled macos-focus-mode)" = "false" ]]; then
    installNodePackages macos-focus-mode
    macos-focus-mode install
fi

#
# markmap
#
# Markdown as mindmaps visualization tool
#
# https://github.com/markmap/markmap
#
installNodePackages markmap-cli

#
# mermaid-cli
#
# Mermaid CLI
#
# https://github.com/mermaid-js/mermaid-cli
#
installNodePackages mermaid-cli

#
# Miller
#
# CSV processor
#
# https://github.com/johnkerl/miller
#
installkeg miller

#
# ncdu-zig
#
# Command line disk usage analyzer
#
# https://code.blicky.net/yorhel/ncdu
#
installkeg ncdu

#
# nmap
#
# Network discovery and security auditing tool
#
# https://github.com/nmap/nmap
#
installkeg nmap

#
# Noti
#
# Monitor a process and trigger a notification when the process is done
#
# https://github.com/variadico/noti
#
installkeg noti

#
# Pandoc
#
# Markup converter
#
# https://github.com/jgm/pandoc
#
# Notes:
#  - Using it for my resume https://github.com/fharper/resume
#
installkeg pandoc

#
# pdf2svg
#
# PDF to SVG converter
#
# https://github.com/dawbarton/pdf2svg/
#
installkeg pdf2svg

#
# pdfcrack
#
# PDF Protection Brute Force Cracker
#
# https://sourceforge.net/projects/pdfcrack/
#
installkeg pdfcrack

#
# peco
#
# Simplistic interactive filtering tool
#
# https://github.com/peco/peco
#
installkeg peco

#
# Poppler
#
# PDF rendering library
#
# https://poppler.freedesktop.org/
#
# Notes:
# - I use Poppler for the executables:
#     - pdfimages to extract images from PDFs
#     - pdffonts to list embedded fonts from PDFs
# .   - pdfinfo to get information from PDFs
#
installkeg poppler

#
# Public-ip-cli
#
# Get public IP
#
# https://github.com/sindresorhus/public-ip-cli
#
installNodePackages public-ip-cli

#
# QPDF
#
# Tools for and transforming and inspecting PDF files
#
# https://github.com/qpdf/qpdf
#
installkeg qpdf

#
# Rename
#
# CLI for renaming multiple files based on regex
#
# https://github.com/ap/rename
#
installkeg rename

#
# Ripgrep
#
# Recursively searches directories for a regex pattern
#
# https://github.com/BurntSushi/ripgrep
#
installkeg ripgrep

#
# Scout
#
# Reading, writing & converting JSON, Plist, YAML and XML files
#
# https://github.com/ABridoux/scout
#
if [[ "$(isCLAppInstalled scout)" = "false" ]]; then
    brew tap ABridoux/formulae
    installkeg scout
fi

#
# speedtest-cli
#
# Internet bandwidth speed test
#
# https://github.com/sivel/speedtest-cli
#
# Notes: used by utils.zsh
#
installkeg speedtest-cli

#
# Stress
#
# Stress test your hardware
#
# https://github.com/resurrecting-open-source-projects/stress
#
installkeg stress

#
# SVGO
#
# SVG Optimizer
#
# https://github.com/svg/svgo
#
installkeg svgo

#
# termdown
#
# Countdown timer & stopwatch
#
# https://github.com/trehn/termdown
#
installPythonApp termdown

#
# The Fuck
#
# Corrects your previous console command
#
# https://github.com/nvbn/thefuck
#
installkeg thefuck

#
# tldr-pages
#
# Consice commmunity-driven man pages
#
# https://github.com/tldr-pages/tldr
#
installkeg tldr

#
# topgrade
#
# upgrade everything with one tool
#
# https://github.com/topgrade-rs/topgrade
#
installkeg topgrade

#
# video-compare
#
# Visual split screen video comparaison tool
#
# https://github.com/pixop/video-compare
#
installkeg video-compare

#
# Vundle
#
# Vim plugin manager
#
# https://github.com/VundleVim/Vundle.vim
#
if [[ ! -d "$HOME/.vim/bundle/Vundle.vim" ]]; then
    git clone git@github.com:VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
    vim +PluginInstall
fi

#
# wget
#
# CLI download tool
#
# https://github.com/mirror/wget
#
installkeg wget

#
# Wifi Password
#
# Obtain connected wifi password
#
# https://github.com/rauchg/wifi-password
#
installkeg wifi-password

#
# wkhtmltopdf
#
# Convert HTML to PDF
#
# https://github.com/wkhtmltopdf/wkhtmltopdf
#
# Notes:
#  - listed as a Cask, but it's a Keg
#
installkeg wkhtmltopdf

#
# yt-dlp 
#
# Video downloader (YouTube & all)
#
# https://github.com/yt-dlp/yt-dlp
# https://github.com/ariya/phantomjs
#
installkeg yt-dlp

#
# zsh-bench
#
# Benchmark for interactive Zsh
#
# https://github.com/romkatv/zsh-bench
#
# Note:
# - run a benchmark, use: $HOME/zsh-bench/zsh-bench
#
if [ ! -d $HOME/zsh-bench ]; then
    git clone https://github.com/romkatv/zsh-bench $HOME/zsh-bench
fi


################
#              #
# Applications #
#              #
################

displaySection "Applications"

#
# Actions
#
# Additional actions for the Shortcuts app
#
# https://github.com/sindresorhus/Actions
#
installFromAppStore "Actions" 1586435171

#
# Affinity Designer
#
# Vector Graphics Design Tool
#
# https://affinity.serif.com/en-us/designer
#
# Notes:
#  - Homebrew version is Affinity Designer 2, which needs a subscription
#
installFromAppStore "Affinity Designer" 824171161

#
# AirBuddy
#
# Bluetooth devices battery monitoring & alerts
#
# https://airbuddy.app
#
if [[ "$(isAppInstalled "AirBuddy")" = "false" ]]; then
    curl -L https://su.airbuddy.app/kCRSAmcjBc/AirBuddy_v2.7-624.dmg --output AirBuddy.dmg
    installDMG AirBuddy.dmg true
    getLicense AirBuddy
fi

#
# Akai Pro MPC Beats
#
# Software for my AKAI Professional MPD218
#
# https://www.akaipro.com/mpc-beats
#
if [[ "$(isAppInstalled "MPC Beats")" = "false" ]]; then
    echo $fg[blue]"Starting the installation of Akai Pro MPC Beats"$reset_color
    curl -L https://cdn.inmusicbrands.com/akai/M2P11C6VI/Install-MPC-Beats-v2.11-2.11.6.8-release-Mac.zip --output mpc-beats.zip
    unzip -j -o mpc-beats.zip -d .
    rm mpc-beats.zip
    rm -rf __MACOSX #created by the unzip call
    local filename=$(findfilewithregex "Install-MPC-Beats")
    installPKG "$filename"
fi

#
# App Tamer
#
# CPU Throttling Tool
#
# https://www.stclairsoft.com/AppTamer/
#
if [[ "$(isAppInstalled "App Tamer")" = "false" ]]; then
    installcask app-tamer
    open -a "App Tamer"
    getLicense "App Tamer"
fi

#
# AppCleaner
#
# Applications uninstaller
#
# https://freemacsoft.net/appcleaner
#
if [[ "$(isAppInstalled AppCleaner)" = "false" ]]; then
    installcask appcleaner
    restoreAppSettings appcleaner
    giveFullDiskAccessPermission "AppCleaner"
fi

#
# Around
#
# Video call app
#
# https://www.around.co
#
installcask around

#
# Audacity
#
# Audio editor
#
# https://github.com/audacity/audacity
#
installcask audacity

#
# AutoMute
#
# Mute your laptop when your headphones disconnect
#
# https://github.com/yonilevy/automute
#
# Notes:
#  - AutoMute in Homebrew isn't the same application
#
installFromAppStore "AutoMute" 1118136179

#
# Bearded Spice
#
# Control web based media players & some apps with media keys on Keyboard
#
# https://github.com/beardedspice/beardedspice
#
installcask beardedspice

#
# BlockBlock
#
# Monitor persistence locations
#
# https://github.com/objective-see/BlockBlock
#
if [[ "$(isAppInstalled "BlockBlock Helper")" = "false" ]]; then
    installcask blockblock
    loginitems -a "BlockBlock Helper"
fi

#
# Brave Browser
#
# Chromium based browser
#
# https://github.com/brave
#
if [[ "$(isAppInstalled "Brave Browser")" = "false" ]]; then
    installcask brave-browser

    # Install the 1Password extension
    open -a "Brave Browser"
    /Applications/Brave\ Browser.app/Contents/MacOS/Brave\ Browser https://chrome.google.com/webstore/detail/1password-%E2%80%93-password-mana/aeblfdkhhhdcdjpifhhbdiojplfjncoa
fi

#
# Calibre + DeDRM Tools
#
# Ebook Manager
# Ebook DRM Remover Calibre Plugin
#
# https://github.com/kovidgoyal/calibre
# https://github.com/noDRM/DeDRM_tools
#
if [[ "$(isAppInstalled calibre)" = "false" ]]; then
    installcask calibre

    curl -L "$(lastversion noDRM/DeDRM_tools --assets)" --output Calibre-DeDRM.zip
    unzip Calibre-DeDRM.zip "DeDRM_plugin.zip"
    rm Calibre-DeDRM.zip
    rm -rf __MACOSX #created by the unzip call

    open -a Calibre
    open .
    pausethescript "Install the DeDRM plugin into Calibre before continuing. In Calibre, go to 'Preferences', and under the 'Advanced' section, click on 'Plugins'. On the Plugins window, press the 'Load plugin from file' and drop the 'DeDRM_plugin.zip' file into the File window. Click 'Open', 'Yes', 'OK', 'Apply' & 'Close'. You can now quit Calibre."
    rm DeDRM_plugin.zip

    duti -s net.kovidgoyal.calibre org.idpf.epub-container all # ePub
    duti -s net.kovidgoyal.calibre dyn.ah62d4rv4ge80c8x1gq all #Kindle ebooks
fi

#
# Captin
#
# App that show the caps lock status
#
# https://captin.mystrikingly.com/
#
installcask captin

#
# Chromium Ungoogled
#
# Chromium without Google stuff
#
# https://github.com/Eloston/ungoogled-chromium#downloads
#
# Notes:
#  - need to detect if installed already manually since the application name is different from the Homebrew Cask one
#
if [[ "$(isAppInstalled Chromium)" = "false" ]]; then
    installcask eloston-chromium
fi

#
# Command X
#
# Finder's cut & paste
#
# https://sindresorhus.com/command-x
#
mas install 6448461551

#
# Cryptomator & macFUSE
#
# Data encryption tool
#
# https://github.com/cryptomator/cryptomator
#
if [[ "$(isAppInstalled Cryptomator)" = "false" ]]; then
    installcask cryptomator
    open -a Cryptomator
    getLicense Cryptomator
    pausethescript "Add your vault to Cryptomator"
fi

#
# CyberDuck
#
# FTP Client
#
# https://github.com/iterate-ch/cyberduck
#
if [[ "$(isAppInstalled Cyberduck)" = "false" ]]; then
    installcask cyberduck
    restoreAppSettings cyberduck
    getLicenseFile "Cyberduck" "license.cyberducklicense"
fi

#
# DaisyDisk
#
# Disk data & space analyzer
#
# https://daisydiskapp.com
#
if [[ "$(isAppInstalled DaisyDisk)" = "false" ]]; then
    installcask daisydisk
    getLicense "DaisyDisk"
fi

#
# Deckset
#
# Presentation slides designing tool using Markdown
#
# https://www.deckset.com
#
installcask deckset

#
# Descript
#
# Video transcription & edition
#
# https://www.descript.com
#
installcask descript

#
# Discord
#
# Chat application
#
# https://discord.com/
#
installcask discord

#
# Disk Drill
#
# Data Recovery Tool
#
# https://www.cleverfiles.com/
#
# Notes:
#  - need to detect if installed already manually since the application name is different from the Homebrew Cask one
#
if [[ "$(isAppInstalled "Disk Drill")" = "false" ]]; then
    installcask disk-drill
fi

#
# DHS
#
# dylib hijack scanner
#
# https://objective-see.org/products/dhs.html
#
installcask dhs

#
# DuckDuckGo
#
# Browser
#
# https://duckduckgo.com
#
installcask duckduckgo

#
# Elgato Lights Control Center
#
# Elgato Lights Control App
#
# https://www.elgato.com/en/gaming/key-light
#
# Notes:
#  - need to detect if installed already manually since the application name is different from the Homebrew Cask one
#
if [[ "$(isAppInstalled "Elgato Control Center")" = "false" ]]; then
    installcask elgato-control-center
fi

#
# Elgato Stream Deck
#
# Elagto Stream Deck Configuration App
#
# https://www.elgato.com/en/gaming/stream-deck
#
# Notes:
#  - need to detect if installed already manually since the application name is different from the Homebrew Cask one
#
if [[ "$(isAppInstalled "Elgato Stream Deck")" = "false" ]]; then
    installcask elgato-stream-deck
    restoreAppSettings streamdeck
fi

#
# ExcalidrawZ
#
# Excalidraw app
#
# https://github.com/chocoford/ExcalidrawZ
#
if [[ "$(isCLAppInstalled ExcalidrawZ)" = "false" ]]; then
    curl -L "$(lastversion chocoford/ExcalidrawZ --assets)" --output excalidrawz.dmg

    installDMG excalidrawz.dmg true
fi

#
# Figma
#
# Vector Design Tool
#
# https://www.figma.com
#
if [[ "$(isAppInstalled Figma)" = "false" ]]; then
    installcask figma
    duti -s com.figma.Desktop com.figma.document all #Figma
fi

#
# Firefox
#
# Browser
#
# https://www.mozilla.org/en-CA/firefox
#
if [[ "$(isAppInstalled Firefox)" = "false" ]]; then
    installcask firefox

    # Install the 1Password extension
    open -a Firefox
    /Applications/Firefox.app/Contents/MacOS/Firefox https://addons.mozilla.org/en-CA/firefox/addon/1password-x-password-manager/
fi

#
# Gimp
#
# Image Editor
#
# https://www.gimp.org/
#
if [[ "$(isAppInstalled Gimp)" = "false" ]]; then
    installcask gimp
    restoreAppSettings gimp
fi

#
# Gray
#
# Manage dark or light apparence individually by applications
#
# https://github.com/zenangst/Gray
#
installcask gray

#
# HA Menu
#
# Home Assistant menubar app
#
# https://github.com/codechimp-org/ha-menu/
#
# Notes:
#  - need to detect if installed already manually since the application name is different from the Homebrew Cask one
#
if [[ "$(isAppInstalled "HA Menu")" = "false" ]]; then
    installcask ha-menu
fi

#
# Hemingway
#
# Writing Readability Tool
#
# http://www.hemingwayapp.com
#
if [[ "$(isAppInstalled "Hemingway Editor")" = "false" ]]; then
    installDMG "$HOME/Documents/mac/Hemingway Editor 3.0.3/Hemingway Editor-3.0.3.dmg" false
fi

#
# HistoryHound
#
# Search browsers history with content (not just URLs or pages titles)
#
# https://www.stclairsoft.com/HistoryHound/
#
if [[ "$(isAppInstalled "HistoryHound")" = "false" ]]; then
    installcask historyhound
    open -a HistoryHound
    getLicense HistoryHound
fi

#
# Hyperduck
#
# Receive links from iOS even when offline
#
# https://sindresorhus.com/hyperduck
#
installFromAppStore "Hyperduck" 6444667067

#
# Insta360 Link Controller
#
# Insta360 Link webcam settings & controller
#
# https://www.insta360.com/download/insta360-link
#
if [[ "$(isAppInstalled "Insta360 Link Controller")" = "false" ]]; then
    curl -L https://file.insta360.com/static/ff3fc5347835495dd970735b96db1097/Insta360LinkController_20230303_144839_signed_1677827088327.pkg --output Insta360LinkController.pkg
    installPKGfromDMG Insta360LinkController.pkg
    installPKG Insta360LinkController.pkg
fi
#
# Jiffy
#
# Gif in your menubar
#
# https://sindresorhus.com/jiffy
#
installFromAppStore Jiffy 1502527999

#
# Keybase
#
# Secure messaging and file-sharing app
#
# https://github.com/keybase/client
#
# Notes: Homebrew version wasn't updated in a while
#
if [[ "$(isAppInstalled "Keybase")" = "false" ]]; then
    curl -L  https://prerelease.keybase.io/Keybase-arm64.dmg --output keybase.dmg
    installDMG keybase.dmg true

    # Disable Keybase adding itself as a favorite in Finder
    touch "/Users/fharper/Library/Application Support/Keybase/finder_disabled.config2"
fi

#
# Keycastr
#
# Keystroke visualizer
#
# https://github.com/keycastr/keycastr
#
installcask keycastr

#
# Kindle
#
# Kindle app
#
# https://www.amazon.ca/b?ie=UTF8&node=2972705011
#
installFromAppStore "Kindle" 302584613

#
# KnockKnock
#
# Enumerate persistently installed softwares
#
# https://github.com/objective-see/knockknock
#
installcask knockknock

#
# Logi Options+
#
# Logitech Mouse Configurations App
#
# https://www.logitech.com/en-ca/software/logi-options-plus.html
#
# Notes
#   - Not using Homebrew as you need to run the installer, and do not know the full path because of the version number
#   - File name for the app is logioptionsplus, not "Logi Options+" in the "Applications" folder
#
if [[ "$(isAppInstalled logioptionsplus)" = "false" ]]; then
    echo $fg[blue]"Starting the installation of Logi Options+"$reset_color
    curl -L https://download01.logi.com/web/ftp/pub/techsupport/optionsplus/logioptionsplus_installer.zip --output logitech.zip

    unzip logitech.zip
    rm logitech.zip
    rm -rf __MACOSX #created by the unzip call

    open logioptionsplus_installer.app
    pausethescript "Wait for Logi Options+ installation to finish before continuing"
    rm -rf logioptionsplus_installer.app
fi

#
# Logitech Presentation
#
# Application to be able to use the Logitech Spotlight Remote Clicker
#
# https://www.logitech.com/en-ca/product/spotlight-presentation-remote
#
if [ ! -d "/Library/Application Support/Logitech.localized/Logitech Presentation.localized/Logitech Presentation.app" ]; then
    installcask logitech-presentation
    cd /opt/homebrew/Caskroom/logitech-presentation/*/

    open "LogiPresentation Installer.app"
    pausethescript "Wait for the Logitech Presentation application to finish before continuing."

    rm "LogiPresentation Installer.app"
    cd -

    #TODO: add Input Monitoring Permissions
    #TODO: add Accessibility Permissions
fi

#
# LyricsX
#
# Lyrics & Karaoke Application
#
# https://github.com/ddddxxx/LyricsX
#
installcask LyricsX

#
# MailReceipt
#
# Delivery notification & read receipt requests for Apple Mail
#
# https://github.com/scr34m/MailReceipt
#
if [ ! -d "/Library/Mail/Bundles/MailReceipt.mailbundle/" ]; then
    curl -L "$(lastversion scr34m/MailReceipt --assets)" --output MailReceipt.pkg
    installPKG MailReceipt.pkg
fi

#
# MailTrackerBlocker
#
# Email tracker, read receipt and spy pixel blocker plugin for Apple Mail
#
# https://github.com/apparition47/MailTrackerBlocker
#
installkeg mailtrackerblocker

#
# Messenger
#
# Facebook Messenger Client
#
# https://www.messenger.com/desktop
#
installcask messenger

#
# Microsoft Edge
#
# Browser
#
# https://www.microsoft.com/en-us/edge
#
# Notes:
#  - need to detect if installed already manually since the application name is different from the Homebrew Cask one
#
if [[ "$(isAppInstalled "Microsoft Edge")" = "false" ]]; then
    installcask microsoft-edge

    # Install the 1Password extension
    open -a "Microsoft Edge"
    /Applications/Microsoft\ Edge.app/Contents/MacOS/Microsoft\ Edge https://microsoftedge.microsoft.com/addons/detail/1password-%E2%80%93-password-mana/dppgmdbiimibapkepcbdbmkaabgiofem
fi

#
# Microsoft Teams
#
# Video call
#
# https://www.microsoft.com/en-us/microsoft-teams/group-chat-software
#
installcask microsoft-teams

#
# MindNode
#
# Mindmap app
#
# Installing the version I paid for before they moved to subscriptions
#
# https://mindnode.com
#
if [[ "$(isAppInstalled MindNode)" = "false" ]]; then
    unzip $HOME/Documents/mac/MindNode/MindNode.zip
    mv MindNode.app /Applications/
fi

#
# monday.com
#
# Project management
#
# https://monday.com
#
# Note: for Tiugo
#
installFromAppStore 1298450641

#
# Muzzle
#
# Set Do Not Disturb mode when screen sharing in video calls
#
# https://muzzleapp.com
#
if [[ "$(isAppInstalled Muzzle)" = "false" ]]; then
    installcask muzzle
    giveAccessibilityPermission Muzzle
fi

#
# NordVPN
#
# VPN
#
# https://nordvpn.com
#
installcask nordvpn

#
# OBS Studio
#
# Live streaming & vide/screen recording
#
# https://github.com/obsproject/obs-studio
#
if [[ "$(isAppInstalled "OBS")" = "false" ]]; then
    installcask obs
    giveScreenRecordingPermission OBS
    giveAccessibilityPermission OBS
    #TODO: give Camera Permission
    #TODO: give Microphone Permission
fi

#
# One Thing
#
# Add text to menubar
#
# https://sindresorhus.com/one-thing
#
mas install "One Thing" 1604176982

#
# Opera
#
# Browser
#
# https://www.opera.com
#
if [[ "$(isAppInstalled "Opera")" = "false" ]]; then
    installcask opera

    # Install the 1Password extension
    open -a Opera
    /Applications/Opera.app/Contents/MacOS/Opera https://chrome.google.com/webstore/detail/1password-%E2%80%93-password-mana/aeblfdkhhhdcdjpifhhbdiojplfjncoa
fi

#
# Opera GX
#
# Browser
#
# https://www.opera.com/gx
#
if [[ "$(isAppInstalled "Opera GX")" = "false" ]]; then
    installcask opera-gx

    # Install the 1Password extension
    open -a "Opera GX"
    /Applications/Opera\ GX.app/Contents/MacOS/Opera https://chrome.google.com/webstore/detail/1password-%E2%80%93-password-mana/aeblfdkhhhdcdjpifhhbdiojplfjncoa
fi

#
# OverSight
#
# Monitor the microphone & webcam
#
# https://github.com/objective-see/OverSight
#
installcask oversight

#
# Paprika Recipe Manager
#
# Recipes manager
#
# https://www.paprikaapp.com
#
installFromAppStore "Paprika Recipe Manager 3" 1303222628

#
# Parcel
#
# Deliveries tracking
#
# https://parcelapp.net
#
installFromAppStore "Parcel" 639968404

#
# Pika
#
# Color Picker
#
# https://github.com/superhighfives/pika
#
installcask pika

#
# Pocket
#
# Save & read articles later
#
# https://getpocket.com
#
if [[ "$(isAppInstalled Pocket)" = "false" ]]; then
    installFromAppStore Pocket 568494494
    dockutil --add /Applications/Pocket.app/ --allhomes
fi

#
# Pure Paste
#
# Paste as plain text by default
#
# https://sindresorhus.com/pure-paste
#
installFromAppStore "Pure Paste" 1611378436

#
# QR Capture
#
# Screen & webcam QR code reader
#
# https://iqr.hrubasko.com
#
installFromAppStore "QR Capture" 1369524274

#
# Quitter
#
# Automatically hides or quits apps after periods of inactivity
#
# https://marco.org/apps#quitter
#
installcask quitter

#
# RansomWhere?
#
# Monitoring the creation of encrypted files
#
# https://objective-see.org/products/ransomwhere.html
#
# Notes:
#  - Need to check the installation manually as it does not install in default folders
if [ ! -d "/Library/Objective-See/RansomWhere/" ]; then
    installcask ransomwhere
fi

#
# Raspberry Pi Imager
#
# Raspberry Pi imaging utility
#
# https://github.com/raspberrypi/rpi-imager
#
# Notes:
#  - need to detect if installed already manually since the application name is different from the Homebrew Cask one
#
if [[ "$(isAppInstalled "Raspberry Pi Imager")" = "false" ]]; then
    installcask raspberry-pi-imager
fi

#
# ReiKey
#
# Persistent keyboard keystrokes listeners/intercepters scanner
#
# https://github.com/objective-see/ReiKey
#
installcask reikey

#
# Remote Desktop
#
# Access Windows computers remotely
#
# https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/remote-desktop-mac
#
installcask microsoft-remote-desktop

#
# Shareful
#
# Add additional options to the macOS share menu
#
# https://sindresorhus.com/shareful
#
mas install 1522267256

#
# Signal
#
# Encrypted messaging app
#
# https://github.com/signalapp/Signal-Desktop
#
installcask signal

#
# Silicon
#
# Identify Applications Architecture
#
# https://github.com/DigiDNA/Silicon
#
installcask silicon

#
# Sim Daltonism
#
# Color blindness simulation
#
# https://github.com/michelf/sim-daltonism/
#
installcask sim-daltonism

#
# Sloth
#
# Displays all open files and sockets in use by all running processes on your system
#
# https://sveinbjorn.org/sloth
#
installcask sloth

#
# Sound Siphon
#
# Audio virtual inputs
#
# https://staticz.com/soundsiphon/
#
if [[ "$(isAppInstalled "Sound Siphon")" = "false" ]]; then
    installcask sound-siphon
    getLicense "Sound Siphon"
fi

#
# Speedtest
#
# Speed test application
#
# https://www.speedtest.net
#
# Notes:
#  - It's more accurate than the CLI
#
installFromAppStore Speedtest 1153157709

#
# stats
#
# menubar system monitor stats
#
# https://github.com/exelban/stats
#
if [[ "$(isAppInstalled stats)" = "false" ]]; then
    installcask stats
    restoreAppSettings stats
fi

#
# SwiftDefaultApps
#
# Change default application with URI Scheme and/or filetype in macOS
#
# https://github.com/Lord-Kamina/SwiftDefaultApps
#
# Notes:
# - Using it for default things like default application for emails. File type are handled with duti for automation
#
if [[ -d "$HOME/Library/PreferencePanes/SwiftDefaultApps.prefpane/" ]]; then
    installcask swiftdefaultappsprefpane
fi

#
# TeamViewer
#
# Remote viewer & control
#
# https://www.teamviewer.com
#
installcask teamviewer

#
# The Unarchiver
#
# Compress & extract GUI app supporting RAR, ZIP & more
#
# https://theunarchiver.com
#
# Notes:
#  - need to detect if installed already manually since the application name is different from the Homebrew Cask one
#
if [[ "$(isAppInstalled "The Unarchiver")" = "false" ]]; then
    installcask the-unarchiver
    duti -s com.macpaw.site.theunarchiver com.rarlab.rar-archive all # RAR
fi

#
# TigerVNC
#
# VNC client
#
# https://github.com/TigerVNC/tigervnc
#
installcask tigervnc-viewer

#
# TV
#
# The Office for offline viewing
#
# https://www.apple.com/ca/apple-tv-app/
#
if [ ! -d $HOME/Movies/TV/Media.localized/TV\ Shows/The\ Office ]; then

    # Download The Office only if HDD has at least 500GB available
    local hddleft=$(diskutil info /dev/disk3s1 | grep "Container Free Space" | grep -o '[0-9]*\.[0-9]*')

    if (( $(echo "$hddleft > 500" | bc -l) )); then
        open -a TV
        pausethescript "Sign into the TV app & start the download the whole series The Office US before continuing."
    fi
fi

#
# Typesense Dashboard
#
# A Typesense Dashboard to manage and browse collections
#
# https://github.com/bfritscher/typesense-dashboard
#
if [[ "$(isAppInstalled "Typesense-Dashboard")" = "false" ]]; then
    curl -L "$(lastversion bfritscher/typesense-dashboard --assets)" --output typesense-dashboard.zip
    unzip typesense-dashboard.zip
    mv dist/electron/Typesense-Dashboard-darwin-x64/Typesense-Dashboard.app /Applications
    rm dist
    rm typesense-dashboard.zip
fi

#
# Typora
#
# Markdown distraction-free writing tool
#
# https://typora.io
#
if [[ "$(isAppInstalled "Typora")" = "false" ]]; then
    installcask typora
    getLicense Typora
fi

#
# UPS Power Monitor
#
# Menubar UPS monitoring
#
# https://apps.dniklewicz.com/ups-mac/
#
installFromAppStore "UPS Power Monitor" 1500180529

#
# VLC
#
# Video Player
#
# https://github.com/videolan/vlc
#
if [[ "$(isAppInstalled VLC)" = "false" ]]; then
    installcask vlc
    restoreAppSettings vlc

    duti -s org.videolan.vlc public.3gpp all #3gp
    duti -s org.videolan.vlc audio/x-hx-aac-adts all #aac
    duti -s org.videolan.vlc public.avi all #avi
    duti -s org.videolan.vlc com.apple.m4a-audio all #M4A
    duti -s org.videolan.vlc com.apple.m4v-video all #m4v
    duti -s org.videolan.vlc com.apple.quicktime-movie all #mov
    duti -s org.videolan.vlc public.mp3 all #mp3
    duti -s org.videolan.vlc public.mpeg-4 all #mp4
    duti -s org.videolan.vlc com.microsoft.waveform-audio all #wav
    duti -s org.videolan.vlc org.webmproject.webm all #webm
fi

#
# Vivid
#
# Boost Apple screens & monitors brithness
#
# https://www.getvivid.app
#
if [[ "$(isAppInstalled Vivid)" = "false" ]]; then
    installcask vivid
    getLicense Vivid
fi

#
# WebP Viewer: QuickLook & View
#
# WebP image viewer
#
# https://langui.net/webp-viewer
#
if [[ "$(isAppInstalled WebPViewer)" = "false" ]]; then
    installFromAppStore "WebPViewer" 1323414118
    duti -s net.langui.WebPViewer org.webmproject.webp all #WebP
fi

#
# WhatsApp
#
# Messaging app
#
# https://www.whatsapp.com
#
installcask whatsapp

#
# WhatsYourSign
#
# Finder menu to show files cryptographic signing information
#
# https://github.com/objective-see/WhatsYourSign
#
if [[ "$(isAppInstalled WhatsYourSign)" = "false" ]]; then
    installcask whatsyoursign
    open -a "/opt/homebrew/Caskroom/whatsyoursign/2.0.1/WhatsYourSign Installer.app"
fi

#
# WiFi Explorer Lite
#
# Wifi discovery and analysis tool
#
# https://www.intuitibits.com/products/wifiexplorer/
#
installFromAppStore "WiFi Explorer Lite" 1408727408

#
# Zen Browser
#
# Browser
#
# https://github.com/zen-browser/desktop
#
installcask zen-browser


#########
#       #
# Fonts #
#       #
#########

displaySection "Fonts"

installfont font-alex-brush
installfont font-archivo-narrow
installfont font-arial
installfont font-blackout
installfont font-caveat-brush
installfont font-dancing-script
installfont font-dejavu
installfont font-fira-code
installfont font-fira-mono
installfont font-fira-sans
installfont font-fontawesome
installfont font-gidole
installfont font-hack
installfont font-leckerli-one
installfont font-montserrat
installfont font-nunito
installfont font-nunito-sans
installfont font-open-sans
installfont font-pacifico
installfont font-rancho
installfont font-roboto


####################################################################
#                                                                  #
# macOS Applications File Types Default                            #
#                                                                  #
# Find the app bundle identifier                                   #
# mdls -name kMDItemCFBundleIdentifier -r /Applications/Photos.app #
#                                                                  #
# Find the file UTI (Uniform Type Identifiers)                     #
# mdls -name kMDItemContentTypeTree $HOME/init.lua                 #
#                                                                  #
# Notes:                                                           #
#  - Non MacOS application have their file type associated with    #
#    them where they are installed                                 #
#                                                                  #
####################################################################

displaySection "macOS Applications File Types Default"

# Preview
duti -s com.apple.Preview public.standard-tesselated-geometry-format all #3D CAD
duti -s com.apple.Preview public.heic all #HEIC
duti -s com.apple.Preview com.nikon.raw-image all #NEF
duti -s com.apple.Preview com.adobe.pdf all #PDF
duti -s com.apple.Preview  public.png all # PNG
duti -s com.apple.Preview org.openxmlformats.presentationml.presentation all #PPTX
duti -s com.apple.Preview com.adobe.photoshop-image all # PSD (Photoshop)


#########
#       #
# Games #
#       #
#########

displaySection "Games"

#
# Among Us
#
# http://www.innersloth.com/gameAmongUs.php
#
installFromAppStore "Among Us" 1351168404

#
# Chess
#
# https://chess.com
#
installFromAppStore "Chess" 329218549

#
# Epic Games
#
# Epic Games library management
#
# https://www.epicgames.com
#
# Notes:
#  - need to detect if installed already manually since the application name is different from the Homebrew Cask one
#
if [[ "$(isAppInstalled "Epic Games Launcher")" = "false" ]]; then
    installcask epic-games
    # TODO: add keystroke permission
fi

#
# OpenEmu
#
# Retro video games emulation
#
# https://github.com/OpenEmu/OpenEmu
#
installcask openemu


###########################
#                         #
# Dock Applications Order #
#                         #
###########################

displaySection "Dock Applications Order"

echo $fg[blue]"The Dock will restart a couple of time, giving a flashing impression: it's normal\n"$reset_color
dockutil --move 'Google Chrome' --position end --allhomes
dockutil --move 'Notion' --position end --allhomes
dockutil --move 'Todoist' --position end --allhomes
dockutil --move 'Slack' --position end --allhomes
dockutil --move 'Visual Studio Code' --position end --allhomes
dockutil --move 'iTerm' --position end --allhomes
dockutil --move 'Spotify' --position end --allhomes
dockutil --move '1Password' --position end --allhomes
dockutil --move 'Photos' --position end --allhomes
dockutil --move 'Pocket' --position end --allhomes
dockutil --move 'Messenger' --position end --allhomes
dockutil --move 'Antidote 11' --position end --allhomes


###############
#             #
# Final Steps #
#             #
###############

displaySection "Final Steps"

#
# Monolingual
#
# Remove unnecessary language resources from macOS
#
# https://github.com/IngmarStein/Monolingual
#
if [[ "$(isAppInstalled Monolingual)" = "false" ]]; then
    installcask monolingual
    open -a Monolingual
    pausethescript "Use Monolingual to remove unused languages files before continuing"
fi

echo $fg[blue]"Everything has been installed & configured on you new laptop, congratulations!"$reset_color
