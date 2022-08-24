#! /bin/bash


#########################
#                       #
# Script Configurations #
#                       #
#########################

email="hi@fred.dev"

function notification {
    terminal-notifier -message "$1"
    read -pr 'Press enter to continue'
}

function pausethescript {
    echo "Press any key to continue the installation script"
    read -r
}

function openfilewithregex {
    file=$(find . -maxdepth 1 -execdir echo {} ';'  | grep "$1")
    open "${file}"
    pausethescript
    rm "${file}"
}

#
# DisplayLink Manager & DisplayLink Manager MacOS Extension
#
# Add the possibility to have more than one external monitor on MacBook M1 with a DisplayLink compatible hub
# Extension for DisplayLink Manager to work at the login screen
#
# https://www.displaylink.com
#
open "https://www.displaylink.com/downloads/file?id=1713"
openfilewithregex "DisplayLink Manager Graphics Connectivity.*\.pkg"
open "https://displaylink.com/downloads/macos_extension"
open "macOS App LoginExtension-EXE.dmg"



#######################
#                     #
# Pre-Installalations #
#                     #
#######################

#
# Rosetta2
#
# Run x86_64 app on arm64 chip
#
# https://developer.apple.com/documentation/apple_silicon/about_the_rosetta_translation_environment
#
/usr/sbin/softwareupdate --install-rosetta --agree-to-license

#
# iTerm2
# iTerm2 Shell Integration
#
# Terminal replacement
#
# https://github.com/gnachman/iTerm2
# https://iterm2.com/documentation-shell-integration.html
#
open https://iterm2.com/downloads/stable/latest
mv iTerm.app /Applications/
curl -L https://iterm2.com/shell_integration/install_shell_integration.sh | bash
open iTerm
exit

#
# Oh My Zsh
#
# https://github.com/ohmyzsh/ohmyzsh
#
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

#
# Create /usr/local/bin folder
#
sudo mkdir /usr/local/bin
sudo chown fharper:admin /usr/local/bin


#
# tmux
#
# Running multiple terminal sessions in the same window
#
# https://github.com/tmux/tmux
#
brew install tmux

#
# Configure SSH
#
ssh-keygen -t rsa -b 4096 -C $email
ssh-add -K ~/.ssh/id_rsa
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts
pbcopy < ~/.ssh/id_rsa.pub
open https://github.com/settings/keys
notification "Add your SSH key to Github (copied into the clipboard)"


############################
#                          #
# Utils to run this script #
#     (needed order)       #
#                          #
############################

#
# Xcode Command Line Tools
#
# Command line XCode tools & the macOS SDK frameworks and headers
#
# https://developer.apple.com/xcode
#
xcode-select --install

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
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off
brew tap homebrew/cask-versions
brew tap buo/cask-upgrade
brew tap homebrew/cask-fonts

#
# Dockutil
#
# Utility to manage macOS Dock items
#
# https://github.com/kcrawford/dockutil
#
brew install dockutil

#
# Duti
#
# Utility to set default applications for document types (file extensions)
#
# https://github.com/moretension/duti
#
brew install duti

#
# Git
#
# File versioning
#
# https://github.com/git/git
#
brew install git

#
# lastversion
#
# CLI to get latest GitHub Repo Release assets URL
#
# https://github.com/dvershinin/lastversion
#
pip install lastversion

#
# loginitems
#
# Utility to manage startup applications
#
# https://github.com/ojford/loginitems
#
brew tap OJFord/formulae
brew install loginitems

#
# mas-cli
#
# Unofficial macOS App Store CLI
#
# https://github.com/mas-cli/mas
#
brew install mas
mas signin $email

#
# mysides
#
# Finder sidebar tool
#
# https://github.com/mosen/mysides
#
brew install --cask mysides

#
# nvm + Node.js + npm cli
#
# https://github.com/nvm-sh/nvm
# https://github.com/nodejs/node
# https://github.com/npm/cli
#
brew install nvm
mkdir ~/.nvm
nvm install v18.0.0
nvm use v18.0.0
npm i -g npm@latest
npm adduser

#
# osXiconUtils
#
# Utilities for working with macOS icons
#
# https://github.com/sveinbjornt/osxiconutils
#
curl -L https://sveinbjorn.org/files/software/osxiconutils.zip --output osxiconutils.zip
unzip osxiconutils.zip
rm osxiconutils.zip
mv bin/geticon /usr/local/bin/
mv bin/seticon /usr/local/bin/
rm -rf bin/

#
# tccutil
#
# Command line tool to modify the accessibility database
#
# https://github.com/jacobsalmela/tccutil
#
brew install tccutil

#
# Script Editor
#
sudo -E tccutil -e com.apple.ScriptEditor2

#
# terminal-notifier
#
# Utility to send macOS notifications
#
# https://github.com/julienXX/terminal-notifier
#
brew install terminal-notifier


###########################
#                         #
# Top Helper Applications #
#                         #
###########################


notification "Deactivate the System Integrity Protection with 'csrutil disable' in Recovery Mode"

#
# Alfred & alfred-google-translate & alfred-language-configuration
#
# Spotlight replacement
# Google Translate Workflow
# Google Translate Language Configuration Workflow (needed by alfred-google-translate)
#
# https://www.alfredapp.com
# https://github.com/xfslove/alfred-google-translate
# https://github.com/xfslove/alfred-language-configuration
#
brew install --cask alfred
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>" # Deactivate Spotlight Global Shortcut to use it with Alfred instead (will work after logging off)
open -a "Alfred 4"
notification "Add Alfred's licenses & set sync folder"
sudo -E tccutil -e com.runningwithcrayons.Alfred
npm install -g alfred-google-translate
npm install -g alfred-language-configuration
notification "Configure alfred-google-translate with 'trc en&fr'"

#
# Bartender
#
# macOS menubar manager
#
# https://www.macbartender.com
#
brew install --cask bartender
sudo -E tccutil -e com.surteesstudios.Bartender

#
# CleanShot X
#
# Screenshot utility
#
# https://cleanshot.com
#
brew install --cask cleanshot
notification "install the audio component in Preferences >> Recording >> Audio Recording"

#
# CommandQ
#
# Utility to prevent accidentally quiting an application
#
# https://commandqapp.com
#
brew install --cask commandq

#
# Contexts
#
# Application windows switcher
#
# https://contexts.co
#
brew install --cask contexts
sudo -E tccutil -e com.contextsformac.Contexts
notification "Open the license file from 1Password"

#
# Control Plane
#
# Utility to automate things based on context & location
#
# https://github.com/dustinrue/ControlPlane
#
brew install --cask controlplane

#
# Dropbox
#
# File sharing & computer backup
#
# https://www.dropbox.com
#
brew install --cask dropbox

#
# Espanso
#
# Text expander / snipet
#
# https://github.com/federico-terzi/espanso
#
brew tap federico-terzi/espanso
brew install espanso
sudo tccutil -e "$(print -r =espanso\(:A\))"
espanso register
espanso start

#
# HSTR
#
# Shell command history management
#
# https://github.com/dvorka/hstr
#
brew install hh

#
# Karabiner-Elements
#
# Keyboard customization utility
#
# https://github.com/pqrs-org/Karabiner-Elements
#
brew install --cask karabiner-elements

#
# KeepingYouAwake
#
# Menubar app to manage caffeinate
#
# https://github.com/newmarcel/KeepingYouAwake
#
brew install --cask keepingyouawake

#
# Little Snitch
#
# Kinda dynamic firewall
#
# https://www.obdev.at/products/littlesnitch/index.html
#
brew install --cask little-snitch

#
# Logitech Mouse Manager
#
# Mouse Configuration
#
# https://www.logitech.com/en-ca/product/options
#
curl -L https://download01.logi.com/web/ftp/pub/techsupport/options/options_installer.zip --output logitech.zip
unzip logitech.zip
rm logitech.zip
openfilewithregex "LogiMgr Installer.*"
rm -rf "${file}"

#
# Moom
#
# Applications' windows management
#
# https://manytricks.com/moom
#
# install the App Store version since you bought it there
#
mas install 419330170

#
# Shush
#
# Easily mute or unmute your microphone
#
# https://mizage.com/shush/
#
mas install 496437906

#
# Sound Control
#
# Advanced audio controls
#
# https://staticz.com/soundcontrol/
#
brew install --cask sound-control

#
# The Clock
#
# macOS Clock replacement with more advance features like work clocks & time zones
#
# https://www.seense.com/the_clock/
#
# Notes
# - Install from the App Store for the license
# - You cannot remove the clock from the menubar anymore: minimizing used space as analog
#
mas install 488764545
defaults write com.apple.menuextra.clock IsAnalog -bool true

#
# TripMode
#
# Manage applications internet access
#
# https://tripmode.ch
#
brew install --cask TripMode

#
# Zoom
#
# Video conference
#
# https://zoom.us
#
brew install --cask zoomus

#
# Zsh-z
#
# fastest cd alternative
#
# https://github.com/agkozak/zsh-z
#
git clone git@github.com:agkozak/zsh-z.git "$ZSH_CUSTOM"/plugins/zsh-z


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
dockutil --remove 'Keynote' --allhomes

#
# Numbers
#
sudo rm -rf /Applications/Numbers.app
dockutil --remove 'Numbers' --allhomes

#
# Pages
#
sudo rm -rf /Applications/Pages.app
dockutil --remove 'Pages' --allhomes


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
# Messages
#
dockutil --remove 'Messages' --allhomes

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
# Photos
#
dockutil --remove 'Photos' --allhomes

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

#
# TV
#
dockutil --remove 'TV' --allhomes

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
defaults write com.apple.desktopservices DSDontWriteNetworkStores true

#
# New Finder windows show
#
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads"

#
# Show all filename extensions
#
defaults write -g AppleShowAllExtensions -bool true

#
# Show Library Folder
#
xattr -d com.apple.FinderInfo ~/Library
sudo chflags nohidden ~/Library

#
# Show Path Bar
#
defaults write com.apple.finder ShowPathbar -bool true

#
# Show Status Bar
#
defaults write com.apple.finder ShowStatusBar -boolean true

#
# Show these items on the desktop - CDs, DVDs, and iPods
#
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

#
# Show these items on the desktop - External disks
#
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false

#
# Sidebar Favorites
#
mysides remove Desktop
mysides remove Recents

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
# Point & Click - Look up & data detector
#
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool false


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
# Sound - Show volume in menu bar
#
# need to find a way to do this with the command line since Apple removed the Sound.menu from Menu Extras
#
open /System/Library/PreferencePanes/Sound.prefPane
notification 'Uncheck "Show volume in menu bar"'


# Trackpad - App Exposé & Mission Control (need to be done together)
defaults write com.apple.dock showAppExposeGestureEnabled -bool false
defaults write com.apple.dock showMissionControlGestureEnabled -bool false
defaults -currentHost write NSGlobalDomain com.apple.trackpad.fourFingerVertSwipeGesture -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -bool false

# Trackpad - Smart zoom
defaults write com.apple.dock showSmartZoomEnabled -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseTwoFingerDoubleTapGesture -bool false

# Trackpad - Swipe between full-screen apps
defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerVertSwipeGesture -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -bool false

#Disable Show Notification Center on Trackpad
defaults -currentHost write NSGlobalDomain com.apple.trackpad.twoFingerFromRightEdgeSwipeGesture -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -bool false

#Disable Launchpad and Show Desktop Gestures on Trackpad
defaults write com.apple.dock showDesktopGestureEnabled -bool true
defaults write com.apple.dock showLaunchpadGestureEnabled -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.fourFingerPinchSwipeGesture -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerPinchGesture -bool false
defaults -currentHost write NSGlobalDomain com.apple.trackpad.fiveFingerPinchSwipeGesture -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadFiveFingerPinchGesture -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFiveFingerPinchGesture -bool false

#Deactivate the Force click and haptic feedback from Trackpad manually
defaults write com.apple.systemsound "com.apple.sound.uiaudio.enabled" -bool false

#Activate Silent clicking
defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 0

#Finder display settings
defaults write com.apple.finder FXEnableExtensionChangeWarning -boolean false
defaults write com.apple.finder ShowPathbar -bool true

#Show all files extensions
defaults write -g AppleShowAllExtensions -bool true

# Prevent the dock from moving monitors
defaults write com.apple.Dock position-immutable -bool true

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

#Expand save panel
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

#Search the current folder by default in Finder
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

#Change the log in screen background
cp ~/Documents/misc/Mojave.heic /Library/Desktop\ Pictures

# Keyboard - Press Fn to
# Change to do nothing
defaults write com.apple.HIToolbox AppleFnUsageType -int 0



#
# Disable the accent characters menu
#
defaults write -g ApplePressAndHoldEnabled -bool true

#
# Kill Finder, Dock & SystemUIServer
#
# (for applying modified settings)
#
killall Finder
killall Dock
killall SystemUIServer


#####################
#                   #
# Main applications #
#                   #
#####################

#
# 1Password
#
# Password manager
#
# https://1password.com
#
brew install --cask 1password
dockutil --add /Applications/1Password\ 7.app/ --allhomes

#
# Antidote
#
# English & French corrector & dictionary
#
# https://www.antidote.info
#
open https://services.druide.com/
notification "Download & install Antidote"
pausethescript
filename=openfilewithregex "Antidote.*.dmg"
dockutil --add /Applications/Antidote/Antidote\ 10.app/
loginitems -a Antidote

#
# Brave Browser
#
# Chromium based browser
#
# https://github.com/brave
#
brew install --cask brave-browser
dockutil --add "/Applications/Brave Browser.app" --position 2 --allhomes
loginitems -a "Brave Browser"
defaults write com.brave.Browser ExternalProtocolDialogShowAlwaysOpenCheckbox -bool true
defaults write com.brave.Browser DisablePrintPreview -bool true

#
# Home Assistant
#
# Home automation
#
# https://github.com/home-assistant/iOS
#
brew install --cask home-assistant

#
# Mumu
#
# Emoji picker
#
# https://getmumu.com
#
brew install --cask mumu
loginitems -a Mumu
sudo -E tccutil -e com.wilbertliu.mumu

#
# Notion Enhanced
#
# Notion is a notes app & the Notion Enhanced give a lot of customizations possibilities
#
# https://www.notion.so
# https://github.com/notion-enhancer/desktop
#
brew install --cask notion-enhanced
dockutil --add "/Applications/Notion Enhanced.app" --allhomes

#
# OpenInEditor-Lite
#
# https://github.com/Ji4n1ng/OpenInTerminal
#
brew install --cask openineditor-lite
notification "drag openineditor-lite in Finder toolbar while pressing Command"
curl -L https://github.com/Ji4n1ng/OpenInTerminal/releases/download/v1.2.0/Icons.zip  --output icons.zip
unzip icons.zip
rm icons.zip
seticon icons/icon_vscode_dark.icns /Applications/OpenInEditor-Lite.app
rm -rf icons

#
# OpenInTerminal-Lite
#
# https://github.com/Ji4n1ng/OpenInTerminal
#
brew install --cask openinterminal-lite
notification "drag openinterminal-lite in Finder toolbar while pressing Command"
curl -L https://github.com/Ji4n1ng/OpenInTerminal/releases/download/v1.2.0/Icons.zip  --output icons.zip
unzip icons.zip
rm icons.zip
seticon icons/icon_terminal_dark.icnss /Applications/OpenInTerminal-Lite.app
rm -rf icons

#
# Rain
#
# https://github.com/fharper/rain
#
curl -L https://github.com/fharper/rain/releases/download/v1.0b2/rain.app.zip --output rain.zip
unzip rain.zip
rm rain.zip
mv rain.app /Applications
loginitems -a Rain

#
# Slack
#
# https://slack.com
#
brew install --cask slack
dockutil --add /Applications/Slack.app/ --allhomes

#
# Spaceship Prompt
#
# A Zsh prompt
#
# https://github.com/denysdovhan/spaceship-prompt
#
npm install -g spaceship-prompt

#
# Spotify
#
# https://www.spotify.com
#
brew install --cask spotify
dockutil --add /Applications/Spotify.app --allhomes

#
# Todoist
#
# https://todoist.com
#
mas install 585829637
dockutil --add /Applications/Todoist.app --allhomes
loginitems -a Todoist

#
# Trash CLI
#
# https://github.com/sindresorhus/trash-cli
#
npm i -g trash-cli

#
# Visual Studio Code
#
# https://github.com/microsoft/vscode
#
brew install --cask visual-studio-code
dockutil --add /Applications/Visual\ Studio\ Code.app/ --allhomes
npm config set editor code


###################
#                 #
# Developer stuff #
#                 #
###################

#
# Act
#
# https://github.com/nektos/act
#
# Run your GitHub Actions locally
#
brew install act

#
# actionlint
#
# Static checker for GitHub Actions workflow files
#
# https://github.com/rhysd/actionlint
#
go install github.com/rhysd/actionlint/cmd/actionlint@latest

#
# BFG Repo-Cleaner
#
# https://github.com/rtyley/bfg-repo-cleaner
#
# git-filter-branch replacement
#
brew install bfg

#
# Charles Proxy
#
# https://www.charlesproxy.com
#
brew install --cask charles
notification "Install Charles Proxy certificate in system & change to always trust"

#
# CocoaPods
#
# https://github.com/CocoaPods/CocoaPods
#
brew install cocoapods

#
# Cordova
#
# https://github.com/apache/cordova-cli
#
npm install -g cordova

#
# Deno
#
# https://github.com/denoland/deno
#
brew install deno

#
# Docker
#
# https://www.docker.com
#
brew install --cask docker

#
# Docker Toolbox
#
# https://github.com/docker/toolbox
#
brew install --cask docker-toolbox

#
# ESLint
# ESLint Formatter Pretty
# ESLint plugins: Markdown, React, Wordpress, Puppeteer, Jest Plugins, Node.js security, JSX a11y, i18n, JSDoc, JSON
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
# https://github.com/azeemba/eslint-plugin-json
#
brew install eslint
npm i -g eslint-formatter-pretty
npm i -g eslint-plugin-markdown
npm i -g eslint-plugin-react
npm i -g @wordpress/eslint-plugin
npm i -g eslint-plugin-ui-testing
npm i -g eslint-plugin-jest
npm i -g eslint-plugin-security-node
npm i -g eslint-plugin-jsx-a11y
npm i -g eslint-plugin-i18n
npm i -g eslint-plugin-jsdoc
npm i -g eslint-plugin-json

#
# Expo CLI
#
# Tools for creating, running, and deploying Universal Expo & React Native apps
#
# https://github.com/expo/expo-cli
#
npm install -g expo-cli

#
# Gist
#
# https://github.com/defunkt/gist
#
brew install gist
gist --login

#
# Git
#
# https://github.com/git/git
#
brew install git
git config --replace-all --global user.name "Frédéric Harper"
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


#
# Git Branch Status
#
# https://github.com/bill-auger/git-branch-status
#
npm i -g git-branch-status

#
# Git Large File Storage
#
# https://github.com/git-lfs/git-lfs
#
brew install git-lfs

#
# Git Open
#
# https://github.com/paulirish/git-open
#
npm i -g git-open

#
# Git Recent
#
# https://github.com/paulirish/git-recent
#
brew install git-recent

#
# Git Sizer
#
# https://github.com/github/git-sizer
#
brew install git-sizer

#
# GitHub CLI & gh-pr-draft
#
# GitHub CLI
# GitHub CLI Extension for converting PR to Draft
#
# https://github.com/cli/cli
# https://github.com/kyanny/gh-pr-draft
#
brew install gh
gh auth login
gh config set editor "code --wait"
gh config set git_protocol ssh --host github.com
gh extension install kyanny/gh-pr-draft

#
# GoEnv + Go
#
# https://github.com/syndbg/goenv
# https://golang.org
#
brew install goenv
goenv install 1.18.0
goenv global 1.18.0

#
# go-jira
#
# CLI for Jira
#
# https://github.com/go-jira/jira
#
go get github.com/go-jira/jira/cmd/jira
jira session

#
# GPG Suite
#
# https://gpgtools.org
#
brew install --cask gpg-suite
notification "get my private key from 1Password"
gpg --import private.key
git config --global user.signingkey 523390FAB896836F8769F6E1A3E03EE956F9208C
git config --global commit.gpgsign true

#
# Grip
#
# GitHub Readme Instant Preview
#
# https://github.com/joeyespo/grip
#
brew install grip

#
# Hadolint
#
# Docker file linter
#
# https://github.com/hadolint/hadolint
#
brew install hadolint

#
# iOS Deploy
#
# Install and debug iPhone apps from the command line, without using Xcode
#
# https://github.com/ios-control/ios-deploy
#
brew install ios-deploy

#
# Jest
#
# JavaScript Testing Framework
#
# https://github.com/facebook/jest
#
npm install -g jest

#
# JupyterLab
#
# Jupyter notebooks IDE
#
# https://jupyter.org/

brew install --cask jupyterlab

#
# Mocha
#
# Node.js testing framework
#
# https://github.com/mochajs/mocha
npm i -g mocha

#
# Multipass
#
# Ubuntu VM Manager
#
# https://github.com/canonical/multipass
#
brew install --cask multipass

#
# npm Check Updates (ncu)
#
# https://github.com/raineorshine/npm-check-updates
#
npm i -g npm-check-updates

#
# PHP_CodeSniffer
#
# PHP linter
#
# https://github.com/squizlabs/PHP_CodeSniffer
#
brew install php-code-sniffer
phpcs --config-set installed_paths ~/Documents/code/wordpress/coding-standards

#
# Postman
#
# https://postman.com
#
brew install --cask postman

#
#
# pre-commit
#
# Multi-language pre-commit hooks framework
#
# https://github.com/pre-commit/pre-commit
#
brew install pre-commit

#
# Prettier
#
# https://github.com/prettier/prettier
#
brew install prettier

#
# Puppeteer
#
# Headless Chrome Node.js API for automation
#
# https://github.com/puppeteer/puppeteer
#
npm install -g puppeteer

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
brew install --cask miniforge
conda activate base
conda install python=3.10.6
python -m pip install --upgrade pip
python -m pip install --upgrade build
pip install wheel
pip install pylint
pip install -U pytest
pip install twine

#
# RBenv + Ruby
#
# https://github.com/rbenv/rbenv
# https://github.com/ruby/ruby
#
brew install rbenv
rbenv init
omz reload
rbenv install 3.1.2
rbenv global 3.1.2

#
# React Native CLI
#
# CLI for React Native development
#
# https://github.com/facebook/react-native
#
brew install -cask react-native-cli

#
# S3cmd
#
# CLI for AWS S3
#
# https://github.com/s3tools/s3cmd
#
brew install s3cmd
s3cmd --configure

#
# Stylelint
#
# CSS, SCSS, Sass, Less & SugarSS linter
#
# https://github.com/stylelint/stylelint
#
npm i -g stylelint
npm i -g stylelint-config-recommended

#
# Xcode
#
# macOS/iOS Swift/Ojective-C IDE
#
# https://developer.apple.com/xcode
#
mas install 497799835
sudo xcodebuild -license accept

#
# Xcodes
#
# Xcode versions management
#
# https://github.com/RobotsAndPencils/XcodesApp
#
brew install --cask xcodes

#
# Yarn
#
# npm alternative
#
# https://github.com/yarnpkg/yarn
#
brew install yarn
yarn config set --home enableTelemetry 0

#
# PHP + Composer
#
# https://github.com/php/php-src
# https://github.com/composer/composer
#
brew install php
brew install composer

#
# Java (OpenJDK with AdoptOpenJDK) + jEnv
#
# https://github.com/jenv/jenv
# https://github.com/adoptium/temurin-build
# https://github.com/openjdk/jdk
#
brew install jenv
brew tap AdoptOpenJDK/openjdk
brew install --cask temurin
jenv add /Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
jenv global openjdk64-17.0.1

#
# Lynis
#
# https://github.com/CISOfy/lynis
#
# Security auditing tool
#
brew install lynis

# Rust + rustup
#
# https://github.com/rust-lang/rust
# https://github.com/rust-lang/rustups
#
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh


#
# ShellCheck
#
# https://github.com/koalaman/shellcheck
#
ibrew install shellcheck
https://github.com/koalaman/shellcheck/issues/2162

#
# Ripgrep
#
# https://github.com/BurntSushi/ripgrep
#
# Recursively searches directories for a regex pattern
#
brew install ripgrep

#
# Webnint
#
# https://github.com/webhintio/hint
#
npm i -g hint

#
# Webpack
#
# JavaScript bundler
#
# https://github.com/webpack/webpack
#
brew install webpack

#
# Wordpress CLI
#
# https://github.com/wp-cli/wp-cli
#
brew install wp-cli

#
# Yeoman
#
# https://github.com/yeoman/yeoman
#
npm i --global yo


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
brew install asciinema
asciinema auth

#
# Bandwhich
#
# https://github.com/imsnif/bandwhich
#
brew install bandwhich

#
# Bat
#
# https://github.com/sharkdp/bat
#
brew install bat

#
#
# Clipdown
#
# https://github.com/jhuckaby/clipdown
#
npm install -g clipdown

#
# Color LS
#
# https://github.com/athityakumar/colorls
#
gem install colorls

#
# ffmpeg + vmaf
#
# https://ffmpeg.org
# https://github.com/Netflix/vmaf
#
brew install libvmaf
brew tap homebrew-ffmpeg/ffmpeg
brew install homebrew-ffmpeg/ffmpeg/ffmpeg --with-libvmaf

#
# htop
#
# https://github.com/htop-dev/htop
#
brew install htop

#
# HTTPie
#
# https://github.com/httpie/httpie
#
brew install httpie

#
# ICS split
#
# https://github.com/beorn/icssplit
#
# icssplit  hi@fred.dev.ics fredcal --maxsize=300000
#
pip3 install icssplit

#
# ImageMagick
#
# https://github.com/ImageMagick/ImageMagick
#
brew install imagemagick

#
# jq
#
# https://github.com/stedolan/jq
#
brew install jq

#
# lsusb
#
# https://github.com/jlhonora/lsusb
#
brew install lsusb

#
# LZip
#
# https://www.nongnu.org/lzip
#
brew install lzip

#
# Noti
#
# https://github.com/variadico/noti
#
brew install noti

#
# Pandoc (for my resume)
#
# https://github.com/jgm/pandoc
#
brew install pandoc

#
# Public-ip-cli
#
# https://github.com/sindresorhus/public-ip-cli
#
npm i -g public-ip-cli

#
# Rename
#
# https://github.com/ap/rename
#
brew install rename

#
# Stress
#
# https://web.archive.org/web/20190702093856/https://people.seas.harvard.edu/~apw/stress/
#
brew install stress

#
# The Fuck
#
# https://github.com/nvbn/thefuck
#
brew install thefuck

#
# tl;dr Pages
#
# https://github.com/tldr-pages/tldr
#
brew install tldr

#
# Vundle
#
# Vim plugin manager
#
# https://github.com/VundleVim/Vundle.vim
#
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

#
# Wifi Password
#
# https://github.com/rauchg/wifi-password
#
brew install wifi-password

#
# wkhtmltopdf
#
# https://github.com/wkhtmltopdf/wkhtmltopdf
#
brew install --cask wkhtmltopdf

#
# Youtube Downloader
#
# https://github.com/ytdl-org/youtube-dl/
#
brew install youtube-dl


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
mas install 824171161

#
# AppCleaner
#
# https://freemacsoft.net/appcleaner
#
brew install --cask appcleaner

#
# AutoMute
#
# Mute your laptop when your headphones disconnect
#
# https://yoni.ninja/automute/
#
mas install 1118136179

#
# Bearded Spice
#
# Control web based media players & some apps with media keys on Keyboard
#
# https://github.com/beardedspice/beardedspice
#
brew install --cask beardedspice

#
# Calibre + DeDRM Tools
#
# https://github.com/kovidgoyal/calibre
# https://github.com/apprenticeharper/DeDRM_tools
#
brew install --cask calibre
open https://github.com/apprenticeharper/DeDRM_tools/releases
notification "Install the DeDRM plugin into Calibre"

#
# Captin
#
# https://captin.mystrikingly.com/
#
brew install --cask captin

#
# Chrome
#
# https://www.google.com/chrome
#
brew install cask google-chrome

#
# Cryptomator
#
# https://github.com/cryptomator/cryptomator
#
brew install --cask cryptomator

#
# CyberDuck
#
# FTP Client
#
# https://github.com/iterate-ch/cyberduck
#
brew install --cask cyberduck

#
# DaisyDisk
#
# https://daisydiskapp.com
#
brew install --cask daisydisk

#
# Deckset
#
# https://www.deckset.com
#
brew install --cask deckset

#
# Discord
#
# https://discord.com/
#
brew install --cask discord

#
# Disk Drill
#
# https://www.cleverfiles.com/
#
brew install --cask disk-drill

#
# Elgato Lights Control Center
#
# https://www.elgato.com/en/gaming/key-light
#
curl -L https://edge.elgato.com/egc/macos/eccm/1.1.3/Control_Center_1.1.3.10337.zip --output elgato-control-center.zip
unzip elgato-control-center.zip
rm elgato-control-center.zip
mv "Elgato Control Center.app" /Applications

#
# Elgato Stream Deck
# https://www.elgato.com/en/gaming/stream-deck
#
curl -L https://edge.elgato.com/egc/macos/sd/Stream_Deck_4.9.2.13193.pkg --output elgato-streamdeck.pkg
open elgato-streamdeck.pkg
rm elgato-streamdeck.pkg

#
# Firefox
#
# https://www.mozilla.org/en-CA/firefox
#
brew install --cask firefox

#
# Gifski
#
# https://github.com/ImageOptim/gifski
#
# (the one on homebrew is the CLI)
#
mas install 1351639930

#
# HA Menu
#
# Home Assistant menubar app
#
# https://github.com/codechimp-org/ha-menu/
#
brew install --cask ha-menu

#
# Hemingway
#
# http://www.hemingwayapp.com
#
open '/Users/fharper/Documents/mac/Hemingway Editor 3.0.0/Hemingway Editor-3.0.0.dmg'

#
# Jiffy
#
# https://sindresorhus.com/jiffy
#
mas install 1502527999

#
# Kap
#
# https://github.com/wulkano/Kap
#
brew install --cask kap

#
# Keybase
#
# https://github.com/keybase/client
#
brew install --cask keybase

#
# Keycastr
#
# https://github.com/keycastr/keycastr
#
brew install --cask keycastr

#
# Kindle
#
# https://www.amazon.ca/b?ie=UTF8&node=2972705011
#
mas install 405399194

#
# Krita
#
# Photoshop alternative
#
# https://github.com/KDE/krita
#
brew install --cask krita

#
# LibreOffice
#
# https://www.libreoffice.org
#
brew install --cask libreoffice

#
# Logitech Presentation
#
# https://www.logitech.com/en-ca/product/spotlight-presentation-remote
#
brew install --cask logitech-presentation
open '/usr/local/Caskroom/logitech-presentation/1.52.95/LogiPresentation Installer.app'

#
# Loopback
#
# https://rogueamoeba.com/loopback
#
brew install --cask loopback

#
# Messenger
#
# Facebook Messenger Client
#
# https://www.messenger.com/desktop
#
brew install --cask messenger

#
# Microsoft Edge
#
# https://www.microsoft.com/en-us/edge
#
brew install --cask microsoft-edge

#
# MindNode
#
# Mindmap app
#
# Installing the version I paid for before they moved to subscriptions
#
# https://mindnode.com
#
unzip ~/Documents/mac/MindNode/MindNode.zip
mv MindNode.app /Applications/

#
# Muzzle
#
# https://muzzleapp.com
#
brew install --cask muzzle

#
# NordVPN
#
# https://nordvpn.com
#
brew install --cask nordvpn

#
# OBS Studio
#
# https://github.com/obsproject/obs-studio
#
brew install --cask obs

#
# Paprika Recipe Manager
#
# https://www.paprikaapp.com
#
mas install 1303222628

#
# Parcel
#
# https://parcelapp.net
#
mas install 639968404
loginitems -a Parcel -s false

#
# Pika
#
# https://github.com/superhighfives/pika
#
brew install --cask pika

#
# Pocket
#
# https://getpocket.com
#
mas install 568494494
dockutil --add /Applications/Pocket.app/ --allhomes

#
# Raspberry Pi Imager
#
# https://www.raspberrypi.org/software/
#
brew install --cask raspberry-pi-imager

#
# Signal
#
# https://github.com/signalapp/Signal-Desktop
#
brew install --cask signal

#
# Silicon
#
# https://github.com/DigiDNA/Silicon
#
brew install --cask silicon

#
# Sloth
#
# https://sveinbjorn.org/sloth
#
# Displays all open files and sockets in use by all running processes on your system
#
brew install --cask sloth

#
# Speedtest
#
# https://www.speedtest.net
#
# More accurate than the CLI
#
mas install 1153157709

#
# Spotica Menu
#
# A Spotify menubar control
#
# https://spoti.ca
#
mas install 570549457

#
# TeamViewer
#
# https://www.teamviewer.com
#
brew install --cask teamviewer

#
# The Unarchiver
#
# https://theunarchiver.com
#
brew install --cask the-unarchiver

#
# TweetDeck
#
# Twitter client (I'm using it for managing my employer's account)
#
# https://tweetdeck.twitter.com
#
mas install 485812721

#
# Typora
#
# https://typora.io
#
brew install --cask typora

#
# VLC
#
# Vide Player
#
# https://www.videolan.org
#
brew install --cask vlc


#
# WebP Viewer: QuickLook & View
#
# https://langui.net/webp-viewer
#
mas install 1323414118

#
# WiFi Explorer Lite
#
# https://www.intuitibits.com/products/wifi-explorer
#
mas install 1408727408


##########################
# Restore configurations #
##########################

brew install mackup
mackup restore --force

#########
#       #
# Fonts #
#       #
#########

brew install --cask font-fira-sans
brew install --cask font-fira-code
brew install --cask font-arial
brew install --cask font-open-sans
brew install --cask font-dancing-script
brew install --cask font-dejavu
brew install --cask font-roboto
brew install --cask font-roboto-condensed
brew install --cask font-hack
brew install --cask font-pacifico
brew install --cask font-leckerli-one
brew install --cask font-gidole
brew install --cask font-fira-mono
brew install --cask font-blackout
brew install --cask font-alex-brush
brew install --cask font-fira-code-nerd-font #use with Starfish
brew install --cask font-hack-nerd-font #use with lscolor
brew install --cask font-caveat-brush
brew install --cask font-archivo-narrow


##################################################
#                                                #
# File Type Default App                          #
#                                                #
# Find the app bundle identifier                 #
# mdls /Applications/Photos.app | grep kMDItemCF #
#                                                #
# Find the Uniform Type Identifiers              #
# mdls -name kMDItemContentTypeTree ~/init.lua   #
#                                                #
##################################################

duti -s org.videolan.vlc public.mpeg-4 all #mp4
duti -s org.videolan.vlc com.apple.quicktime-movie all #mov
duti -s com.microsoft.VSCode public.plain-text all #txt
duti -s com.microsoft.VSCode dyn.ah62d4rv4ge8027pb all #lua
duti -s org.videolan.vlc public.avi all #avi
duti -s org.videolan.vlc public.3gpp all #3gp
duti -s com.apple.Preview com.nikon.raw-image all #NEF
duti -s com.microsoft.VSCode net.daringfireball.markdown all #Markdown
duti -s com.brave.Browser public.svg-image all #svg
duti -s net.kovidgoyal.calibre org.idpf.epub-container all # ePub
duti -s com.microsoft.VSCode public.shell-script all #Shell script
duti -s com.microsoft.VSCode com.apple.log all #log
duti -s com.microsoft.VSCode public.comma-separated-values-text all #CSV
duti -s com.microsoft.VSCode public.xml all #xml
duti -s com.microsoft.VSCode public.json all #json
duti -s com.microsoft.VSCode public.php-script all #php
duti -s com.microsoft.VSCode dyn.ah62d4rv4ge81k3u all #terraform tf
duti -s com.microsoft.VSCode dyn.ah62d4rv4ge81k3xxsvu1k3k all #terraform tfstate
duti -s com.microsoft.VSCode dyn.ah62d4rv4ge81k3x0qf3hg all #terraform tfvars
duti -s org.videolan.vlc com.microsoft.waveform-audio all #wav
duti -s com.apple.Preview com.adobe.pdf all #pdf
duti -s org.videolan.vlc public.mp3 all #mp3
duti -s net.kovidgoyal.calibre dyn.ah62d4rv4ge80c8x1gq all #Kindle ebooks
duti -s org.videolan.vlc com.apple.m4a-audio all #M4A
duti -s net.langui.WebPViewer public.webp all #WebP
duti -s com.microsoft.VSCode dyn.ah62d4rv4ge81g6pq all #SQL
duti -s com.apple.Preview org.openxmlformats.presentationml.presentation all #PPTX
duti -s com.microsoft.VSCode public.css all #CSS
duti -s com.microsoft.VSCode com.netscape.javascript-source all #JavaScript
duti -s com.microsoft.VSCode public.ruby-script all #Ruby
duti -s com.apple.Preview public.standard-tesselated-geometry-format all #3d CAD
duti -s com.brave.Browser com.compuserve.gif all #gif
duti -s com.microsoft.VSCode public.yaml all #YAML
duti -s com.microsoft.VSCode public.rtf all #RTF


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
mas install 1351168404

#
# Epic Games
#
# https://www.epicgames.com
#
brew install --cask epic-games

#
# OpenEmu
#
# https://github.com/OpenEmu/OpenEmu
#
brew install --cask openemu


###################
#                 #
# Dock apps order #
#                 #
###################

dockutil --move 'Brave Browser' --position end --allhomes
dockutil --move 'Evernote' --position end --allhomes
dockutil --move 'Todoist' --position end --allhomes
dockutil --move 'Slack' --position end --allhomes
dockutil --move 'Spotify' --position end --allhomes
dockutil --move 'iTerm' --position end --allhomes
dockutil --move 'Visual Studio Code' --position end --allhomes
dockutil --move 'Pocket' --position end --allhomes
dockutil --move '1Password 7' --position end --allhomes
dockutil --move 'Antidote 10' --position end --allhomes


###############
#             #
# Final steps #
#             #
###############

#
# Monolingual
#
# https://github.com/IngmarStein/Monolingual
#
brew install --cask monolingual
notification "Use Monolingual to remove unused languages files"
