#!/bin/zsh
source ~/.zshrc

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
    read -r
}

#
# Open file without knowing their exact file name.
# Useful when opening a DMG or PKG file I downloaded which contains a version number I'm not aware about yet. 
#
# @param part of the file name
#
function openfilewithregex {
    local file=$(find . -maxdepth 1 -execdir echo {} ';'  | grep "$1")
    open "${file}"
    pausethescript "Wait for the $file installtion to end before continuing."
    rm "${file}"
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
	    echo true
    else
        echo false
    fi
}

#
# Install a Homebrew Keg, if not already installed
#
# @param the application name
#
function installkeg {
    echo $fg[blue]"Starting the installation of $1"$reset_color

    local alreadyInstalled=$(brew list "$1" 2>&1 | grep "No such keg")
    if [[ -n "$alreadyInstalled" ]]; then
        brew install "$1"
    else
	    echo $fg[red]"Nothing to do, $1 is already installed"$reset_color
    fi
}

#
# Install the Node.js package globally, if not already installed
#
# @param Node.js package name
#
function installNodePackages {
    echo $fg[blue]"Starting the installation of $1"$reset_color

    local alreadyInstalled=$(npm list -g "$1" | grep "$1")
    if [[ -z "$alreadyInstalled" ]]; then
        npm install -g "$1"
    else
	    echo $fg[red]"Nothing to do, $1 is already installed"$reset_color
    fi
}

#
# Install a Homebrew Cask, if not already installed
#
# @param the application name
#
function installcask {
    echo $fg[blue]"Starting the installation of $1"$reset_color

    if [[ "$(isAppInstalled $1)" = "false" ]]; then
        brew install --cask $1
    else
	    echo $fg[red]"Nothing to do, $1 is already installed"$reset_color
    fi
}

#
# Install a App Store application, if not already installed
#
# @param the application ID
#
function installFromAppStore {
    echo $fg[blue]"Starting the installation of $1"$reset_color

    if [[ "$(isAppInstalled $1)" = "false" ]]; then
        mas install "$2"
    else
	    echo $fg[red]"Nothing to do, $1 is already installed"$reset_color
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
        echo true
    else
        echo false
    fi
}

#
# Install a Python package, if not already installed
#
# @param the package name
#
function installPythonPackage {
    echo $fg[blue]"Installing the Python package $1"$reset_color

    local package=$(pip list | grep "$1")
    if [[ -n "$package" ]]; then
	echo $fg[red]"Nothing to do, $1 is already installed"$reset_color
    else
        pip install "$1"
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
        echo $fg[blue]"The script need to use root (sudo) to run the $command command"$reset_color
    else
        echo $fg[blue]"Using previously root (sudo) access to run the $command command"$reset_color
    fi
    /usr/bin/sudo $@
}

#
# Use Mackup to restore a specific application settings
#
# @param the application name from Mackup
#
function restoreAppSettings {
    echo "[applications_to_sync]\n$1" > /Users/fharper/.mackup.cfg
    mackup restore
    echo "" > /Users/fharper/.mackup.cfg
}

#
# Install the application from a DMG image when you just need to move the
# application into the macOS Applications folder
#
# @param DMG filename
#
function installDMG {
    hdiutil attach "$1"
    local volume="/Volumes/$(hdiutil info | grep /Volumes/ | sed 's@.*\/Volumes/@@')"
    local app=$(/bin/ls "$volume" | grep .app)
    mv "$volume/$app" /Applications
    hdiutil detach "/Volumes/$volume"
    rm "$1"
}

#
# Reload .zshrc in the current shell
#
function reload {
    source ~/.zshrc
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


############################
#                          #
# Utils to run this script #
#                          #
# (the order is important) #
#                          #
############################

#
# Disable System Integrity Protection (SIP)
#
if [[ ! $(csrutil status | grep "disabled") ]]; then
    echo $fg[red]"Before being able to run this script, deactivate the System Integrity Protection (SIP) with the command 'csrutil disable' in Recovery Mode (press & hold the power button until the option appear)"$reset_color
    exit
fi

#
# Rosetta2
#
# Run x86_64 app on arm64 chip
#
# https://developer.apple.com/documentation/apple_silicon/about_the_rosetta_translation_environment
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
# https://github.com/Homebrew/homebrew-cask-fonts
#
if [[ "$(isCLAppInstalled brew)" = "false" ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Needed once here since we didn't restore & source ~/.zshrc yet, but we need Homebrew
    eval "$(/opt/homebrew/bin/brew shellenv)"
    
    brew analytics off
    brew tap homebrew/cask
    brew tap homebrew/cask-versions
    brew tap buo/cask-upgrade
    brew tap homebrew/cask-fonts
    brew tap OJFord/formulae
    brew tap homebrew/cask-drivers
fi

#
# Mackup
#
# Sync applications settings with Dropbox
#
# https://github.com/lra/mackup
#
# Notes: needed right after Homebrew so configurations files can be restored
#
installkeg mackup

#
# Dropbox
#
# File sharing & computer backup
#
# https://www.dropbox.com
#
# Notes: needed right after mackup so configurations files can be restored
#
if [[ "$(isAppInstalled Dropbox)" = "false" ]]; then
    installcask dropbox
    giveAccessibilityPermission Dropbox
    open -a Dropbox
    pausethescript "Wait for Dropbox to finish Mackup folder synchronization (it's needed for restoring applications configurations) before continuing"
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
    #giveFullDiskAccessPermission iTerm

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
installkeg git
git config --replace-all --global user.name "Frédéric Harper"
git config --replace-all --global credential.username $email
git config --replace-all --global user.email $email
git config --replace-all --global init.defaultBranch main
git config --replace-all --global push.default current
git config --replace-all --global pull.rebase true
git config --replace-all --global difftool.prompt false
git config --replace-all --global diff.tool vscode
git config --replace-all --global difftool.vscode.cmd "code --diff --wait $LOCAL $REMOTE"
git config --replace-all --global core.hooksPath ~/.git/hooks
git config --replace-all --global advice.addIgnoredFile false
git config --replace-all --global rebase.autoStash true
git config --replace-all --global core.ignorecase false
git config --replace-all --global clean.requireForce false
git config --replace-all --global fetch.prune true
git config --replace-all --global advice.addEmptyPathspec false
git config --replace-all --global push.followTags true
git config --replace-all --global push.autoSetupRemote true
git config --replace-all --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --replace-all --global interactive.diffFilter "diff-so-fancy --patch"
git config --replace-all --global add.interactive.useBuiltin false


#
# Oh My Zsh
#
# https://github.com/ohmyzsh/ohmyzsh
#

if [[ "$(isCLAppInstalled omz)" = "false" ]]; then 
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    # Restoring here since OMZ backup ~/.zshrc to ~/.zshrc.pre-oh-my-zsh
    restoreAppSettings zsh
    rm ~/.zshrc.pre-oh-my-zsh
fi

#
# Restore different files with Mackup (not app specifics)
#
if [[ ! -L "/Users/fharper/.zshrc" ]]; then
    restoreAppSettings files
fi

#
# Miniforge + Python + Wheel + Pylint + pytest + Twine
#
# Python virtual environment manager
# Python SDK
# Python wheel packaging tool
# Python linter
# Python tests framework
# Utilities for interacting with PyPI
#
# https://github.com/conda-forge/miniforge
# https://www.python.org
# https://github.com/pypa/wheel
# https://github.com/PyCQA/pylint/
# https://github.com/pytest-dev/pytest
# https://github.com/pypa/twine/
#
if [[ "$(isCLAppInstalled conda)" = "false" ]]; then
    installcask miniforge
    conda activate base
    conda install python=3.10.8
    installPythonPackage wheel
    installPythonPackage pylint
    installPythonPackage pytest
    installPythonPackage twine
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
installkeg defbro

#
# Dockutil
#
# Utility to manage macOS Dock items
#
# https://github.com/kcrawford/dockutil
#
# Notes
#   - Homebrew version not updated
#
if [[ "$(isCLAppInstalled dockutil)" = "false" ]]; then
    curl -L "$(lastversion kcrawford/dockutil --assets)" --output dockutil.pkg
    sudo installer -pkg dockutil.pkg -target /
    pausethescript "Wait for Dockutil installation to finish before continuing"
    rm dockutil.pkg
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
# https://github.com/stedolan/jq
#
# Needed for my "git clone" function
#
installkeg jq

#
# lastversion
#
# CLI to get latest GitHub Repo Release assets URL
#
# https://github.com/dvershinin/lastversion
#
installPythonPackage lastversion

#
# loginitems
#
# Utility to manage startup applications
#
# https://github.com/ojford/loginitems
#
installkeg loginitems

#
# mysides
#
# Finder sidebar tool
#
# https://github.com/mosen/mysides
#
installkeg mysides

#
# nvm + Node.js + npm cli
#
# https://github.com/nvm-sh/nvm
# https://github.com/nodejs/node
# https://github.com/npm/cli
#
# Notes:
#  - Use "nvm ls-remote" to list all Node.js installable versions
#
if [[ -n $(brew list "$1" 2>&1 | grep "No such keg") ]]; then
    installkeg nvm
    reload
    nvm install v19.6.0
    nvm use v19.6.0
    ln -s $(nvm which node) /usr/local/bin #Needed by some Alfred workflows (no need to be latest version when I'll update Node & I cannot ln to node directly, too many symbolic links)
    npm i -g npm@latest
    npm adduser
fi

#
# OpenSSL
#
# TLS/SSL and crypto library
#
# https://github.com/openssl/openssl
#
installkeg openssl

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
    curl -L https://sveinbjorn.org/files/software/osxiconutils.zip --output osxiconutils.zip
    unzip osxiconutils.zip
    rm osxiconutils.zip
    sudo chown fharper:admin /usr/local/bin
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


###########################
#                         #
# Top Helper Applications #
#                         #
###########################

#
# Alfred & alfred-google-translate & alfred-language-configuration
#
# Spotlight replacement
#
# https://www.alfredapp.com
#
if [[ "$(isAppInstalled "Alfred 5")" = "false" ]]; then
    installcask alfred
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>" # Deactivate Spotlight Global Shortcut to use it with Alfred instead (will work after logging off)
    open -a Alfred
    getLicense Alfred
    giveAccessibilityPermission "Alfred 5"
    installNodePackages alfred-google-translate
    installNodePackages alfred-language-configuration
    pausethescript "Configure alfred-google-translate with 'trc en&fr' before continuing"
fi

#
# Bartender
#
# macOS menubar manager
#
# https://www.macbartender.com
#
if [[ "$(isAppInstalled "Bartender 4")" = "false" ]]; then
    installcask bartender
    giveAccessibilityPermission "Bartender 4"
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
    getLicense "CleanShot X"
    open -a "CleanShot X"
    pausethescript "Install the audio component for video audio recording before continuing. Go in Settings >> Recording >> Video >> Computer Audio, and click on the 'Configure' button. In the new window, check the 'Record Computer Audio' checkbox, and click 'Install' in the popup."
fi

#
# CommandQ
#
# Utility to prevent accidentally quiting an application
#
# https://commandqapp.com
#
installcask commandq

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
    op document get Contexts --output=contexts.contexts-license
    open contexts.contexts-license
    pausethescript "Wait for Contexts installation to finish before continuing"
    rm contexts.contexts-license
fi

#
# Espanso
#
# Text expander / snipet
#
# https://github.com/federico-terzi/espanso
#
if [[ "$(isAppInstalled Espanso)" = "false" ]]; then
    brew tap federico-terzi/espanso
    installcask espanso
    giveAccessibilityPermission Espanso
    restoreAppSettings espanso
    espanso service register
fi

#
# Hammerspoon
#
# macOS desktop automation tool
#
# https://github.com/Hammerspoon/hammerspoon
#
installcask hammerspoon

#
# HSTR
#
# Shell command history management
#
# https://github.com/dvorka/hstr
#
installkeg hh

#
# Karabiner-Elements
#
# Keyboard customization utility
#
# https://github.com/pqrs-org/Karabiner-Elements
#
installcask karabiner-elements

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
if [[ "$(isAppInstalled "Little Snitch")" = "false" ]]; then
    installcask little-snitch
    restoreAppSettings littlesnitch
    pausethescript "The rules aren't backup with Mackup, so on the previous computer, open Little Snitch Rules, go to File > Create Backup. On this laptop, open Little Snitch Rules, go to File > Restore from Backup before continuing"
fi

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
    curl -L https://download01.logi.com/web/ftp/pub/techsupport/optionsplus/logioptionsplus_installer.zip --output logitech.zip
    unzip logitech.zip
    rm logitech.zip
    open logioptionsplus_installer.app
    pausethescript "Wait for Logi Options+ installation to finish before continuing"
    rm -rf logioptionsplus_installer.app
fi

#
# Moom
#
# Applications' windows management
#
# https://manytricks.com/moom
#
# install the App Store version since you bought it there
#
installFromAppStore Moom 419330170

#
# Shush
#
# Easily mute or unmute your microphone
#
# https://mizage.com/shush/
#
installFromAppStore Shush 496437906

#
# Sound Control
#
# Advanced audio controls
#
# https://staticz.com/soundcontrol/
#
installcask sound-control

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
fi

#
# tmux
#
# Running multiple terminal sessions in the same window
#
# https://github.com/tmux/tmux
#
installkeg tmux

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
installcask zoom


########################
#                      #
# Applications Cleanup #
#                      #
########################

#
# Garage Band
#
sudo rm -rf /Applications/GarageBand.app

#
# iMovie
#
sudo rm -rf /Applications/iMovie.app

#
# Keynote
#
sudo rm -rf /Applications/Keynote.app

#
# Numbers
#
sudo rm -rf /Applications/Numbers.app

#
# Pages
#
sudo rm -rf /Applications/Pages.app

################
#              #
# Dock Cleanup #
#              #
################

#
# App Store
#
dockutil --remove 'App Store' --allhomes

#
# Calendar
#
dockutil --remove 'Calendar' --allhomes

#
# Contacts
#
dockutil --remove 'Contacts' --allhomes

#
# Facetime
#
dockutil --remove 'FaceTime' --allhomes

#
# Launchpad
#
dockutil --remove 'Launchpad' --allhomes

#
# Mail
#
dockutil --remove 'Mail' --allhomes

#
# Maps
#
dockutil --remove 'Maps' --allhomes

#
# Music
#
dockutil --remove 'Music' --allhomes

#
# News
#
dockutil --remove 'News' --allhomes

#
# Notes
#
dockutil --remove 'Notes' --allhomes

#
# Podcasts
#
dockutil --remove 'Podcasts' --allhomes

#
# Reminders
#
dockutil --remove 'Reminders' --allhomes

#
# Safari
#
dockutil --remove 'Safari' --allhomes

#
# System Preferences
#
dockutil --remove 'System Preferences' --allhomes


###############################
#                             #
# Dock & Menu Bar Preferences #
#                             #
###############################

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


######################
#                    #
# Finder Preferences #
#                    #
######################

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
xattr -d com.apple.FinderInfo ~/Library
sudo chflags nohidden ~/Library

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
# Settings - Sidebad - Show these items in the sidebar
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
mysides add Downloads file:///Users/fharper/Downloads
mysides add Documents file:///Users/fharper/Documents
mysides add Dropbox file:///Users/fharper/Dropbox
mysides add Applications file:///Applications/


############
#          #
# Keyboard #
#          #
############

#
# Accent characters menu on press & hold a letter with possible accents
#
defaults write -g ApplePressAndHoldEnabled -bool true

# Press Fn to
defaults write com.apple.HIToolbox AppleFnUsageType -bool false


###################
#                 #
# Mission Control #
#                 #
###################

#
# Hot Corners - Bottom Right (disable Note app)
#
defaults write com.apple.dock wvous-br-corner -int 0


##################################
#                                #
# Security & Privacy Preferences #
#                                #
##################################

#
# FileVault - Turn On Filevault...
#
sudo fdesetup enable

#
# General - Allow apps downloaded from Anywhere
#
sudo spctl --master-disable

##########################
#                        #
# Sharing Configurations #
#                        #
##########################

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
defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -int 0


###########################
#                         #
# Trackpad Configurations #
#                         #
###########################

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

#
# Guest User
#
sudo defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool false
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool false


########################
#                      #
# Other Configurations #
#                      #
########################

#
# iTerm2 configurations
#
dockutil --add /Applications/iTerm.app/ --allhomes

#
# Locate database generation
#
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

#
# Log-in Screen Background
#
cp ~/Documents/misc/Mojave.heic /Library/Desktop\ Pictures

########################
#                      #
# Apply Configurations #
#                      #
########################

killall Finder
killall Dock
killall SystemUIServer


#####################
#                   #
# Main applications #
#                   #
#####################

#
# 1Password + 1Password CLI + git-credential-1password + Safari Extension
#
# Password manager
# CLI for 1Password
# A git credential helper for 1Password
# Safari integration
#
# https://1password.com
# https://1password.com/downloads/command-line/
# https://github.com/develerik/git-credential-1password
# https://apps.apple.com/us/app/1password-for-safari/id1569813296
#
if [[ "$(isAppInstalled 1Password)" = "false" ]]; then
    installcask 1password
    dockutil --add /Applications/1Password.app --allhomes
    installkeg 1password-cli
    open -a 1Password
    pausethescript "Open 1Password settings, and check 'Connect with 1Password CLI' & click the 'Set up SSH Agent' button in the 'Developer' tab before continuing"
    restoreAppSettings ssh
    eval $(op signin)
    pausethescript "Sign in to 1Password before continuing"
    brew tap develerik/tools
    installkeg git-credential-1password
    git config --replace-all --global credential.helper '!git-credential-1password'
    installFromAppStore "1Password Safari Extension" 1569813296
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
    filename=openfilewithregex "Antidote.*.dmg"
    dockutil --add /Applications/Antidote/Antidote\ 11.app/
    loginitems -a Antidote
fi

#
# Brave Browser + Antidote Extension
#
# Chromium based browser
#
# https://github.com/brave
#
if [[ "$(isAppInstalled "Brave Browser")" = "false" ]]; then
    installcask brave-browser
    dockutil --add "/Applications/Brave Browser.app" --position 2 --allhomes
    loginitems -a "Brave Browser"
    defaults write com.brave.Browser ExternalProtocolDialogShowAlwaysOpenCheckbox -bool true
    defaults write com.brave.Browser DisablePrintPreview -bool true
    open https://chrome.google.com/webstore/detail/1password-%E2%80%93-password-mana/aeblfdkhhhdcdjpifhhbdiojplfjncoa
    open https://chrome.google.com/webstore/detail/antidote/lmbopdiikkamfphhgcckcjhojnokgfeo
    /Applications/Brave\ Browser.app/Contents/MacOS/Brave\ Browser "chrome-extension://jinjaccalgkegednnccohejagnlnfdag/options/index.html#settings"
    pausethescript "Authorize Dropbox for Violentmonkey sync before continuing"
fi

#
# Home Assistant
#
# Home automation
#
# https://github.com/home-assistant/iOS
#
installcask home-assistant

#
# Mumu X
#
# Emoji picker
#
# https://getmumu.com
#
# Note: don't install the Homebrew version, it's Mumu, not Mumu X
#
if [[ "$(isAppInstalled "Mumu X")" = "false" ]]; then
    curl -L $(op item get "Mumu X" --fields label="download link") --output mumux.dmg
    installDMG mumux.dmg
    loginitems -a "Mumu X"
    giveAccessibilityPermission "Mumu X"
fi

#
# Notion Enhanced
#
# Notion is a notes app & the Notion Enhanced give a lot of customizations possibilities
#
# https://www.notion.so
# https://github.com/notion-enhancer/desktop
#
if [[ "$(isAppInstalled "Notion Enhanced")" = "false" ]]; then
    installcask notion-enhanced
    dockutil --add "/Applications/Notion Enhanced.app" --allhomes
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
    curl -L https://github.com/fharper/rain/releases/download/v1.0b2/rain.app.zip --output rain.zip
    unzip rain.zip
    rm rain.zip
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
fi

#
# Spaceship Prompt
#
# A Zsh prompt
#
# https://github.com/denysdovhan/spaceship-prompt
#
installNodePackages spaceship-prompt

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
    installFromAppStore Todoist 585829637
    dockutil --add /Applications/Todoist.app --allhomes
    loginitems -a Todoist
fi

#
# Trash CLI
#
# rm replacement that moves files to the Trash folder
#
# https://github.com/sindresorhus/trash-cli
#
installNodePackages trash-cli

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
fi


###################
#                 #
# Developer stuff #
#                 #
###################

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
if [[ "$(isCLAppInstalled actionlint)" = "false" ]]; then
    go install github.com/rhysd/actionlint/cmd/actionlint@latest
fi

#
# aws-cli
#
# Amazon Web Services CLI
#
# https://github.com/aws/aws-cli
#
if [[ "$(isCLAppInstalled aws)" = "false" ]]; then
    installkeg awscli
    aws configure
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
# Caddy
#
# HTTP server
#
# https://github.com/caddyserver/caddy
#
installkeg caddy

#
# Charles Proxy
#
# HTTP proxy, monitor & reverse proxy
#
# https://www.charlesproxy.com
#
if [[ "$(isAppInstalled Charles)" = "false" ]]; then
    installcask charles
    pausethescript "Install Charles Proxy certificate in system & change to always trust before continuing"
fi

#
# CocoaPods
#
# XCode dependency manager
#
# https://github.com/CocoaPods/CocoaPods
#
installkeg cocoapods

#
# Cordova CLI
#
# CLI for Cordova
#
# https://github.com/apache/cordova-cli
#
installNodePackages cordova

#
# Deno
#
# deno programming language (runtime)
#
# https://github.com/denoland/deno
#
installkeg deno

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
# Docker
#
# Virtualization tool
#
# https://www.docker.com
#
installcask docker

#
# ESLint
# ESLint Formatter Pretty
# ESLint plugins:
# - eslint-plugin-markdown
# - eslint-plugin-react
# - WordPress Gutenberg ESLint Plugin
# - eslint-plugin-ui-testing (using for Puppeteer)
# - eslint-plugin-jest
# - eslint-plugin-security-node
# - eslint-plugin-jsx-a11y
# - eslint-plugin-i18n
# - eslint-plugin-jsdoc
# - eslint-plugin-json
#
# JavaScript linter
# Pretty ESLint formatter
# Lint JavaScript code blocks in Markdown documents
# React-specific linting rules for ESLint
# WordPress development configurations and custom rules for ESLint
# ESLint plugin that helps following best practices when writing UI tests like with Puppeteer
# ESLint plugin for Jest
# ESLint security plugin for Node.js
# a11y rules on JSX elements
# ESLint rules to find out the texts and messages not internationalized in the project
# JSDoc specific linting rules for ESLint
# JSON files rules
#
# https://github.com/eslint/eslint
# https://github.com/sindresorhus/eslint-formatter-pretty
# https://github.com/eslint/eslint-plugin-markdown
# https://github.com/yannickcr/eslint-plugin-react
# https://github.com/WordPress/gutenberg/blob/7b0736c5a97f770cc931616bd0d5c0e446584590/packages/eslint-plugin/README.md
# https://github.com/kwoding/eslint-plugin-ui-testing
# https://github.com/jest-community/eslint-plugin-jest
# https://github.com/gkouziik/eslint-plugin-security-node
# https://github.com/jsx-eslint/eslint-plugin-jsx-a11y
# https://github.com/chejen/eslint-plugin-i18n
# https://github.com/gajus/eslint-plugin-jsdoc
# https://github.com/azeemba/eslint-plugin-json
#
installkeg eslint
installNodePackages eslint-formatter-pretty
installNodePackages eslint-plugin-markdown
installNodePackages eslint-plugin-react
installNodePackages @wordpress/eslint-plugin
installNodePackages eslint-plugin-ui-testing
installNodePackages eslint-plugin-jest
installNodePackages eslint-plugin-security-node
installNodePackages eslint-plugin-jsx-a11y
installNodePackages eslint-plugin-i18n
installNodePackages eslint-plugin-jsdoc
installNodePackages eslint-plugin-json

#
# Expo CLI
#
# Tools for creating, running, and deploying Universal Expo & React Native apps
#
# https://github.com/expo/expo-cli
#
installNodePackages expo-cli

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
# Go + GoEnv
#
# Go programming language
# Go version manager
#
# https://golang.org
# https://github.com/syndbg/goenv
#
# Notes:
#  - List installable Go versions with "goenv install --list"
#
if [[ "$(isCLAppInstalled goenv)" = "false" ]]; then
    installkeg goenv
    reload
    goenv install 1.19.5
    goenv global 1.19.5
fi

#
# go-jira
#
# CLI for Jira
#
# https://github.com/go-jira/jira
#
if [[ "$(isCLAppInstalled jira)" = "false" ]]; then
    go get github.com/go-jira/jira/cmd/jira
    jira session
fi

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
# Hadolint
#
# Docker file linter
#
# https://github.com/hadolint/hadolint
#
installkeg hadolint

#
# iOS Deploy
#
# Install and debug iPhone apps from the command line, without using Xcode
#
# https://github.com/ios-control/ios-deploy
#
installkeg ios-deploy

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
# Kubefirst
#
# Delivery & infrastructure Kubernetes management gitops platforms
#
# https://github.com/kubefirst/kubefirst#installing-the-cli
#
installkeg kubefirst/tools/kubefirst

#
# local
#
# Local WordPress developement tool
#
# https://localwp.com
#
installcask local

#
# Mocha
#
# Node.js testing framework
#
# https://github.com/mochajs/mocha
installNodePackages mocha

#
# Multipass
#
# Ubuntu VM Manager
#
# https://github.com/canonical/multipass
#
installcask multipass

#
# npm Check Updates (ncu)
#
# Find newer versions of Node package dependencies
#
# https://github.com/raineorshine/npm-check-updates
#
installNodePackages npm-check-updates

#
# PHP_CodeSniffer
#
# PHP linter
#
# https://github.com/squizlabs/PHP_CodeSniffer
#
if [[ "$(isCLAppInstalled phpcs)" = "false" ]]; then
    installkeg php-code-sniffer
    phpcs --config-set installed_paths ~/Documents/code/wordpress/coding-standards
fi

#
# Postman
#
# GUI for managing, calling, and testing APIs
#
# https://postman.com
#
installcask postman

#
# pre-commit
#
# Multi-language pre-commit hooks framework
#
# https://github.com/pre-commit/pre-commit
#
installkeg pre-commit

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
# Ruby + RBenv
#
# Ruby programming language
# Ruby version manager
#
# https://github.com/ruby/ruby
# https://github.com/rbenv/rbenv
#
# Notes:
# - Use "rbenv install --list-all" to list installable Ruby versions
#
if [[ "$(isCLAppInstalled rbenv)" = "false" ]]; then
    installkeg rbenv
    rbenv init
    reload
    rbenv install 3.1.2
    rbenv global 3.1.2
fi

#
# React Native CLI
#
# CLI for React Native development
#
# https://github.com/facebook/react-native
#
installkeg -cask react-native-cli

#
# S3cmd
#
# CLI for AWS S3
#
# https://github.com/s3tools/s3cmd
#
if [[ "$(isCLAppInstalled s3cmd)" = "false" ]]; then
    installkeg s3cmd
    s3cmd --configure
fi

#
# Stylelint
#
# CSS, SCSS, Sass, Less & SugarSS linter
#
# https://github.com/stylelint/stylelint
#
installNodePackages stylelint
installNodePackages stylelint-config-recommended

#
# Task
#
# Task runner (Kubefirst use this for E2E testing)
#
# https://github.com/go-task/task
#
installkeg go-task

#
# Xcodes
#
# Xcode versions management
#
# https://github.com/RobotsAndPencils/XcodesApp
#
installcask xcodes

#
# Yarn
#
# npm alternative
#
# https://github.com/yarnpkg/yarn
#
if [[ "$(isCLAppInstalled yarn)" = "false" ]]; then
    installkeg yarn
    yarn config set --home enableTelemetry 0
fi

#
# PHP + PHPBrew + Composer
#
# PHP programming language
# PHP version manager
# PHP dependencies manager
#
# https://github.com/php/php-src
# https://github.com/phpbrew/phpbrew
# https://github.com/composer/composer
#
# Command:
# phpbrew known --more
#
# Notes:
# - Need to install olrder version of PHP as PHPBrew isn't comptabile with newer ones
# - https://github.com/phpbrew/phpbrew/issues/1245
#
if [[ "$(isCLAppInstalled phpbrew)" = "false" ]]; then
    installkeg php@7.4
    installkeg phpbrew
    brew link --overwrite php@7.4
    phpbrew init
    reload
    phpbrew install 8.1.9 -- --without-pcre-jit
    phpbrew use php-8.1.9
    installkeg composer
fi

#
# Java (OpenJDK with AdoptOpenJDK) + jEnv
#
# Java programming language
# Java version manager
#
# https://github.com/jenv/jenv
# https://github.com/adoptium/temurin-build
#
if [[ "$(isCLAppInstalled jenv)" = "false" ]]; then
    installkeg jenv
    reload
    brew tap AdoptOpenJDK/openjdk
    installcask temurin
    jenv add /Library/Java/JavaVirtualMachines/temurin-18.jdk/Contents/Home
    jenv global temurin64-18.0.2.1
fi

#
# Lynis
#
# Security auditing tool
#
# https://github.com/CISOfy/lynis
#
installkeg lynis

#
# Rust + rustup
#
# Rust programming language
# Rust toolchain installer
#
# https://github.com/rust-lang/rust
# https://github.com/rust-lang/rustup
#
if [[ "$(isCLAppInstalled rustup-init)" = "false" ]]; then
    installkeg rustup-init
    rustup-init
    reload
fi

#
# ShellCheck
#
# Shell scripts tatic analysis tool
#
# https://github.com/koalaman/shellcheck
#
installkeg shellcheck

#
# Ripgrep
#
# Recursively searches directories for a regex pattern
#
# https://github.com/BurntSushi/ripgrep
#
installkeg ripgrep

#
# OpenAPI Validator
#
# OpenAPI linter & validator
#
# https://github.com/IBM/openapi-validator
#
installNodePackages ibm-openapi-validator

#
# Vercel CLI
#
# CLI for Vercel
#
# https://github.com/vercel/vercel
#
installkeg vercel-cli

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
# WordPress CLI
#
# CLI for WordPress
#
# https://github.com/wp-cli/wp-cli
#
installkeg wp-cli

#
# Yeoman
#
# Scaffolding tool
#
# https://github.com/yeoman/yeoman
#
installNodePackages yo


######################
#                    #
# Command line tools #
#                    #
######################

#
# Asciinema
#
# https://github.com/asciinema/asciinema
#
if [[ "$(isCLAppInstalled asciinema)" = "false" ]]; then
    installkeg asciinema
    asciinema auth
fi

#
# Bandwhich
#
# https://github.com/imsnif/bandwhich
#
installkeg bandwhich

#
# Bat
#
# https://github.com/sharkdp/bat
#
installkeg bat

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
installPythonPackage coursera-dl

#
# empty-trash-cli
#
# CLI to empty the trash
#
# https://github.com/sindresorhus/empty-trash-cli
#
installNodePackages empty-trash-cli

#
# FFmpeg
#
# Libraries and tools to process multimedia content like video, audio & more
#
# https://github.com/FFmpeg/FFmpeg
#
#
installkeg ffmpeg

#
# FFmpeg Quality Metrics
#
# CLI video quality metrics tool using FFmpeg
#
# https://github.com/slhck/ffmpeg-quality-metrics
#
installPythonPackage ffmpeg-quality-metrics

#
# Ghostscript
#
# PostScript & PDF intepreter
#
# https://www.ghostscript.com
#
installkeg ghostscript

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
# https://github.com/htop-dev/htop
#
installkeg htop

#
# HTTPie
#
# https://github.com/httpie/httpie
#
installkeg httpie

#
# ImageMagick
#
# https://github.com/ImageMagick/ImageMagick
#
installkeg imagemagick

#
# LinkChecker
#
# cli tool to check all links from a website or specific page
#
# https://github.com/wummel/linkchecker
#
installPythonPackage linkchecker

#
# lsusb
#
# https://github.com/jlhonora/lsusb
#
installkeg lsusb

#
# LZip
#
# https://www.nongnu.org/lzip
#
installkeg lzip

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
# Pandoc (for my resume)
#
# https://github.com/jgm/pandoc
#
installkeg pandoc

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
# Scout
#
# Reading, writing & converting JSON, Plist, YAML and XML files
#
# https://github.com/ABridoux/scout
#
installkeg ABridoux/formulae/scout

#
# Stress
#
# https://web.archive.org/web/20190702093856/https://people.seas.harvard.edu/~apw/stress/
#
installkeg stress

#
# The Fuck
#
# https://github.com/nvbn/thefuck
#
installkeg thefuck

#
# tl;dr Pages
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
# Vundle
#
# Vim plugin manager
#
# https://github.com/VundleVim/Vundle.vim
#
if [ ! -d "~/.vim/bundle/Vundle.vim" ]; then
    git clone git@github.com:VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    vim +PluginInstall
fi

#
# Wifi Password
#
# https://github.com/rauchg/wifi-password
#
installkeg wifi-password

#
# wkhtmltopdf
#
# https://github.com/wkhtmltopdf/wkhtmltopdf
#
installcask wkhtmltopdf

#
# yt-dlp
#
# Video downloader
#
# https://github.com/yt-dlp/yt-dlp
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
# - run a benchmark, use: ~/zsh-bench/zsh-bench
#
if [ ! -d ~/zsh-bench ]; then
    git clone https://github.com/romkatv/zsh-bench ~/zsh-bench
fi


################
#              #
# Applications #
#              #
################

#
# Affinity Designer
#
# https://affinity.serif.com/en-us/designer
#
installFromAppStore "Affinity Designer" 824171161

#
# Akai Pro MPC Beats
#
# Software for my AKAI Professional MPD218
#
# https://www.akaipro.com/mpc-beats
#
if [[ "$(isAppInstalled "MPC Beats")" = "false" ]]; then
    curl -L https://cdn.inmusicbrands.com/akai/M2P11C6VI/Install-MPC-Beats-v2.11-2.11.6.8-release-Mac.zip --output mpc-beats.zip
    unzip -j mpc-beats.zip -d .
    rm mpc-beats.zip
    openfilewithregex Install-MPC-Beats*.pkg
fi

#
# AppCleaner
#
# https://freemacsoft.net/appcleaner
#
installcask appcleaner

#
# AutoMute
#
# Mute your laptop when your headphones disconnect
#
# https://yoni.ninja/automute/
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
# Calibre + DeDRM Tools
#
# https://github.com/kovidgoyal/calibre
# https://github.com/noDRM/DeDRM_tools
#
if [[ "$(isAppInstalled calibre)" = "false" ]]; then
    installcask calibre
    curl -L "$(lastversion noDRM/DeDRM_tools --assets)" --output Calibre-DeDRM.zip
    unzip Calibre-DeDRM.zip "DeDRM_plugin.zip"
    rm Calibre-DeDRM.zip
    pausethescript "Install the DeDRM plugin into Calibre before continuing"
    rm DeDRM_plugin.zip
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
# Chrome
#
# Browser
#
# https://www.google.com/chrome
#
if [[ "$(isAppInstalled "Google Chrome")" = "false" ]]; then
    installcask google-chrome
    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome https://chrome.google.com/webstore/detail/1password-%E2%80%93-password-mana/aeblfdkhhhdcdjpifhhbdiojplfjncoa
    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome https://chrome.google.com/webstore/detail/antidote/lmbopdiikkamfphhgcckcjhojnokgfeo
fi

#
# Chromium Ungoogled
#
# Chromium without Google stuff
#
# https://github.com/Eloston/ungoogled-chromium#downloads
#
installcask eloston-chromium

#
# Cryptomator & macFUSE
#
# https://github.com/cryptomator/cryptomator
# https://osxfuse.github.io
#
# Data encryption tool
# Third-party file systems.
#
if [[ "$(isAppInstalled Cryptomator)" = "false" ]]; then
    installcask cryptomator
    getLicense Cryptomator
    installcask macfuse
fi

#
# CyberDuck
#
# FTP Client
#
# https://github.com/iterate-ch/cyberduck
#
installcask cyberduck

#
# DaisyDisk
#
# Disk data & space analyzer
#
# https://daisydiskapp.com
#
installcask daisydisk

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
installcask disk-drill

#
# Elgato Lights Control Center
#
# Elgato Lights Control App
#
# https://www.elgato.com/en/gaming/key-light
#
installcask elgato-control-center

#
# Elgato Stream Deck
#
# Elagto Stream Deck Configuration App
#
# https://www.elgato.com/en/gaming/stream-deck
#
installcask elgato-stream-deck

#
# Firefox
#
# Browser
#
# https://www.mozilla.org/en-CA/firefox
#
installcask firefox

#
# Gimp
#
# Image Editor
#
# https://www.gimp.org/
#
installcask gimp

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
installcask ha-menu

#
# Hemingway
#
# Writing Readability Tool
#
# http://www.hemingwayapp.com
#
if [[ "$(isAppInstalled "Hemingway Editor")" = "false" ]]; then
    open '/Users/fharper/Documents/mac/Hemingway Editor 3.0.0/Hemingway Editor-3.0.0.dmg'
fi

#
# IGdm Messenger
#
# Instagram Messenger
#
# https://github.com/igdmapps/igdm
#
installcask igdm

#
# Jiffy
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
installcask keybase

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
installcask kindle

#
# Logitech Presentation
#
# Application to be able to use the Logitech Spotlight Remote Clicker
#
# https://www.logitech.com/en-ca/product/spotlight-presentation-remote
#
if [ ! -d "/Library/Application Support/Logitech.localized/Logitech Presentation.localized/Logitech Presentation.app" ]; then
    installkeg logitech-presentation
    openfilewithregex "/opt/homebrew/Caskroom/logitech-presentation/1.62.2/LogiPresentation Installer.app"
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
installcask microsoft-edge

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
    unzip ~/Documents/mac/MindNode/MindNode.zip
    mv MindNode.app /Applications/
fi

#
# Muzzle
#
# Set Do Not Disturb mode when screen sharing
#
# https://muzzleapp.com
#
installcask muzzle

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
installcask obs

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
if [[ "$(isAppInstalled Parcel)" = "false" ]]; then
    installFromAppStore "Parcel" 639968404
    loginitems -a Parcel -s false
fi

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
# Raspberry Pi Imager
#
# Raspberry Pi imaging utility
#
# https://github.com/raspberrypi/rpi-imager
#
installcask raspberry-pi-imager

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
# Sloth
#
# Displays all open files and sockets in use by all running processes on your system
#
# https://sveinbjorn.org/sloth
#
installcask sloth

#
# Speedtest
#
# More accurate than the CLI
#
# https://www.speedtest.net
#
installFromAppStore Speedtest 1153157709

#
# stats
#
# menubar system monitor stats
#
# https://github.com/exelban/stats
#
installcask stats

#
# TeamViewer
#
# Remote viewer & control
#
# https://www.teamviewer.com
#
installcask teamviewer

#
# TextSniper
#
# Extract text from your screen
#
# https://textsniper.app
#
installcask textsniper

#
# The Unarchiver
#
# Compress & extract GUI app supporting RAR, ZIP & more
#
# https://theunarchiver.com
#
installcask the-unarchiver

#
# TV
#
# Apple TV app
#
# https://www.apple.com/ca/apple-tv-app/
#
if [ ! -d ~/Movies/TV/Media.localized/TV\ Shows/The\ Office ]; then
    dockutil --remove 'TV' --allhomes
    open -a TV
    pausethescript "Sign into the TV app & download all The Office US episodes before continuing"
fi

#
# Typora
#
# Markdown distraction-free writing tool
#
# https://typora.io
#
installcask typora

#
# VLC
#
# Video Player
#
# https://www.videolan.org
#
installcask vlc


#
# WebP Viewer: QuickLook & View
#
# WebP image viewer
#
# https://langui.net/webp-viewer
#
installFromAppStore "WebPViewer" 1323414118

#
# WhatsApp
#
# Messaging app
#
# https://www.whatsapp.com
#
installcask whatsapp

#
# WiFi Explorer Lite
#
# Wifi discovery and analysis tool
#
# https://www.intuitibits.com/products/wifiexplorer/
#
installFromAppStore "WiFi Explorer Lite" 1408727408


#########
#       #
# Fonts #
#       #
#########

installcask font-alex-brush
installcask font-archivo-narrow
installcask font-arial
installcask font-blackout
installcask font-caveat-brush
installcask font-dancing-script
installcask font-dejavu
installcask font-fira-code
installcask font-fira-mono
installcask font-fira-sans
installcask font-gidole
installcask font-hack
installcask font-leckerli-one
installcask font-montserrat
installcask font-nunito
installcask font-nunito-sans
installcask font-open-sans
installcask font-pacifico
installcask font-roboto
installcask font-roboto-condensed


####################################################################
#                                                                  #
# File Type Default App                                            #
#                                                                  #
# Find the app bundle identifier                                   #
# mdls -name kMDItemCFBundleIdentifier -r /Applications/Photos.app #
#                                                                  #
# Find the file UTI (Uniform Type Identifiers)                     #
# mdls -name kMDItemContentTypeTree ~/init.lua                     #
#                                                                  #
####################################################################

# Brave Browser
duti -s com.brave.Browser com.compuserve.gif all #gif

# Calibre
duti -s net.kovidgoyal.calibre org.idpf.epub-container all # ePub
duti -s net.kovidgoyal.calibre dyn.ah62d4rv4ge80c8x1gq all #Kindle ebooks

# Figma
duti -s com.figma.Desktop com.figma.document all #Figma

# iTerm2
duti -s com.googlecode.iTerm2 com.apple.terminal.shell-script all #SH
duti -s com.googlecode.iTerm2 public.zsh-script all #ZSH

# Preview
duti -s com.apple.Preview com.nikon.raw-image all #NEF
duti -s com.apple.Preview com.adobe.pdf all #PDF
duti -s com.apple.Preview org.openxmlformats.presentationml.presentation all #PPTX
duti -s com.apple.Preview public.standard-tesselated-geometry-format all #3d CAD
duti -s com.apple.Preview com.adobe.photoshop-image all # Photoshop
duti -s com.apple.Preview public.heic all #HEIC

# Visual Studio Code
duti -s com.microsoft.VSCode public.plain-text all #txt
duti -s com.microsoft.VSCode dyn.ah62d4rv4ge8027pb all #lua
duti -s com.microsoft.VSCode net.daringfireball.markdown all #Markdown
duti -s com.microsoft.VSCode public.shell-script all #Shell script
duti -s com.microsoft.VSCode com.apple.log all #log
duti -s com.microsoft.VSCode public.comma-separated-values-text all #CSV
duti -s com.microsoft.VSCode public.xml all #xml
duti -s com.microsoft.VSCode public.json all #json
duti -s com.microsoft.VSCode public.php-script all #php
duti -s com.microsoft.VSCode dyn.ah62d4rv4ge81k3u all #terraform tf
duti -s com.microsoft.VSCode dyn.ah62d4rv4ge81k3xxsvu1k3k all #terraform tfstate
duti -s com.microsoft.VSCode dyn.ah62d4rv4ge81k3x0qf3hg all #terraform tfvars
duti -s com.microsoft.VSCode dyn.ah62d4rv4ge81g6pq all #SQL
duti -s com.microsoft.VSCode public.css all #CSS
duti -s com.microsoft.VSCode com.netscape.javascript-source all #JavaScript
duti -s com.microsoft.VSCode public.ruby-script all #Ruby
duti -s com.microsoft.VSCode public.yaml all #YAML
duti -s com.microsoft.VSCode public.rtf all #RTF
duti -s com.microsoft.VSCode public.python-script all # Python
duti -s com.microsoft.VSCode com.apple.property-list all # Plist

# VLC
duti -s org.videolan.vlc public.mpeg-4 all #mp4
duti -s org.videolan.vlc com.apple.quicktime-movie all #mov
duti -s org.videolan.vlc public.avi all #avi
duti -s org.videolan.vlc public.3gpp all #3gp
duti -s org.videolan.vlc com.microsoft.waveform-audio all #wav
duti -s org.videolan.vlc public.mp3 all #mp3
duti -s org.videolan.vlc com.apple.m4a-audio all #M4A
duti -s org.videolan.vlc com.apple.m4v-video all #m4v

# qView
duti -s com.interversehq.qView public.png all # PNG by using my own build
duti -s com.interversehq.qView public.svg-image all #svg
duti -s com.qview.qView public.png all # PNG

# WebPViewer
duti -s net.langui.WebPViewer org.webmproject.webp all #WebP


#########
#       #
# Games #
#       #
#########

#
# Among Us
#
# http://www.innersloth.com/gameAmongUs.php
#
installFromAppStore "Among Us" 1351168404

#
# Epic Games
#
# https://www.epicgames.com
#
installcask epic-games

#
# OpenEmu
#
# https://github.com/OpenEmu/OpenEmu
#
installcask openemu


###################
#                 #
# Dock apps order #
#                 #
###################

echo $fg[blue]"The Dock will restart a couple of time, giving a flashing impression: it's normal"$reset_color
dockutil --move 'Brave Browser' --position end --allhomes
dockutil --move 'Notion Enhanced' --position end --allhomes
dockutil --move 'Todoist' --position end --allhomes
dockutil --move 'Slack' --position end --allhomes
dockutil --move 'Visual Studio Code' --position end --allhomes
dockutil --move 'iTerm' --position end --allhomes
dockutil --move 'Spotify' --position end --allhomes
dockutil --move '1Password' --position end --allhomes
dockutil --move 'Photos' --position end --allhomes
dockutil --move 'Pocket' --position end --allhomes
dockutil --move 'Messages' --position end --allhomes
dockutil --move 'Antidote 11' --position end --allhomes


###############
#             #
# Final steps #
#             #
###############

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
