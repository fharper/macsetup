#! /bin/bash


#########################
#                       #
# Script Configurations #
#                       #
#########################

email="hi@fred.dev"

function notification {
    /usr/local/Cellar/terminal-notifier/2.0.0/terminal-notifier.app/Contents/MacOS/terminal-notifier -message "$1"
    read -pr 'Press enter to continue'
}


#######################
#                     #
# Pre-Installalations #
#                     #
#######################

#
# Rosetta2
#
# https://developer.apple.com/documentation/apple_silicon/about_the_rosetta_translation_environment
#
/usr/sbin/softwareupdate --install-rosetta --agree-to-license

#
# iTerm2
#
# https://iterm2.com
#
open https://iterm2.com/downloads/stable/latest
mv iTerm.app /Applications/
open iTerm
exit

#
# tmux
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
# https://developer.apple.com/xcode
#
xcode-select --install

#
# Brew
#
# https://brew.sh
#
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.0/install.sh | bash
brew analytics off

#
# Dockutil
#
brew install dockutil

#
# Duti
#
# https://github.com/moretension/duti
#
brew install duti

#
# loginitems
#
brew tap OJFord/formulae
brew install loginitems

#
# Mac App Store cli
#
# https://github.com/mas-cli/mas
#
brew install mas
mas signin $email

#
# nvm + node.js + npm cli
#
# https://github.com/nvm-sh/nvm
# https://github.com/nodejs/node
# https://github.com/npm/cli
#
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash #don't use brew
nvm install v14.15.1
npm i -g npm@latest
npm config set editor code
npm adduser

#
# wget
#
# https://www.gnu.org/software/wget
#
brew install wget

#
# osXiconUtils
#
# https://github.com/sveinbjornt/osxiconutils
#
wget -O osxiconutils.zip https://sveinbjorn.org/files/software/osxiconutils.zip
unzip osxiconutils.zip
rm osxiconutils.zip
mv bin/geticon /usr/local/sbin/
mv bin/seticon /usr/local/sbin/
rm -rf bin/

#
# Terminal Notifier
#
# https://github.com/julienXX/terminal-notifier
#
brew install terminal-notifier


###########################
#                         #
# Top Helper Applications #
#                         #
###########################

#
# Alfred
#
# https://www.alfredapp.com
#
brew install --cask alfred
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>" # Deactivate Spotlight Global Shortcut to use it with Alfred instead (will work after logging off)
open -a "Alfred 4"
notification "add shortcut to Alfred"

#
# aText
#
# https://www.trankynam.com/atext
#
brew install --cask atext

#
# Amphetamine
#
# https://apps.apple.com/app/amphetamine/id937984704
#
mas install 937984704

#
# Bartender
#
# https://www.macbartender.com
#
brew install --cask bartender

#
# CleanShot X
#
brew install --cask cleanshot
notification "install the audio component in Preferences >> Recording >> Audio Recording"

#
# Contexts
#
brew install --cask contexts

#
# Control Plane
#
# https://github.com/dustinrue/ControlPlane
#
brew install --cask controlplane

#
# Dropbox
#
# https://www.dropbox.com
#
brew install --cask dropbox

#
# FruitJuice
#
mas install 671736912

#
# HSTR
#
brew install hh

#
# Karabiner-Elements
#
# https://github.com/pqrs-org/Karabiner-Elements
#
brew install --cask karabiner-elements

#
# Logitech Mouse Manager
#
wget https://download01.logi.com/web/ftp/pub/techsupport/options/Options_8.34.91.zip
unzip Options_8.34.91.zip
rm Options_8.34.91.zip
open -a "LogiMgr Installer 8.34.91.app"
rm -rf "LogiMgr Installer 8.34.91.app"

#
# Maccy
#
# https://github.com/p0deje/Maccy
#
brew install --cask maccy

#
# Moom
#
# https://manytricks.com/moom
#
mas install 419330170 #install the App Store version since you bought it

#
# Slow Quit Apps
#
# https://github.com/dteoh/SlowQuitApps
#
brew tap dteoh/sqa
brew install --cask slowquitapps

#
# Sound Control
#
brew install --cask sound-control

#
# The Clock
#
# https://www.seense.com/the_clock/
#
# install from the App Store for the license
#
mas install 488764545
defaults write com.apple.menuextra.clock IsAnalog -bool true #macOS Clock in analog format

#
# Zoom
#
# https://zoom.us
#
brew install --cask zoomus


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


#####################
#                   #
# OS Configurations #
#                   #
#####################

#
# Desktop & Screen Saver - Start after
#
defaults -currentHost write com.apple.screensaver idleTime 0

#
# Dock - Minimize window into application icon
#
defaults write com.apple.dock minimize-to-application -bool true

#
# Dock - Show recent applications in Dock
#
defaults write com.apple.dock show-recents -bool false

#
# Finder - .DS_Store files creation
#
defaults write com.apple.desktopservices DSDontWriteNetworkStores true

#
# Finder - New Finder windows show
#
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads"

#
# Finder - Show all filename extensions
#
defaults write -g AppleShowAllExtensions -bool true

#
# Finder - Show Library Folder
#
sudo chflags nohidden ~/Library

#
# Finder - Show Path Bar
#
defaults write com.apple.finder ShowPathbar -bool true

#
# Finder - Show Status Bar
#
defaults write com.apple.finder ShowStatusBar -boolean true

#
# Finder - Show these items on the desktop - CDs, DVDs, and iPods
#
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

#
# Finder - Show these items on the desktop - Connected servers
#
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false

#
# Finder - Show these items on the desktop - External disks
#
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false

#
# Finder - Show these items on the desktop - Hard disks
#
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

#
# Finder - Sort By - Name
defaults write -g com.apple.finder FXArrangeGroupViewBy -string "Name"

#
# HP OfficeJet 7740 series installation
#
# shellcheck disable=SC2027,SC2046
#
lpadmin -E -p "HP_OfficeJet_Pro_7740_series" -E -D "HP OfficeJet 7740" -v ""$(ippfind)"" -o printer-is-shared=false -o Name="HP OfficeJet 7740" -P "/Users/fharper/Documents/mac/HP OfficeJet Pro 7740/HP_OfficeJet_Pro_7740_series.ppd"

#
# iTerm2 configurations
#
dockutil --add /Applications/iTerm.app/ --allhomes

#
# Locate database generation
#
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

#
# Security & Privacy - Allow apps downloaded from Anywhere
#
sudo spctl --master-disable

#
# Sound - Play sound on startup
#
sudo nvram StartupMute=%01

#
# Sound - Play user interface sound effects
#
defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -int 0

#
# Sound - Show volume in menu bar
#
# need to find a way to do this with the command line since Apple removed the Sound.menu from Menu Extras
#
open /System/Library/PreferencePanes/Sound.prefPane
notification 'Uncheck "Show volume in menu bar"'

#
# Trackpad - Look up & data detector
#
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool false

#
# User & Groups - Guest User
#
sudo defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool false
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool false

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

# Set computer name
sudo scutil --set ComputerName "lapta"
sudo scutil --set HostName "lapta"
sudo scutil --set LocalHostName "lapta"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "lapta"

#Expand save panel
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

#Search the current folder by default in Finder
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

#Change the log in screen background
cp ~/Documents/misc/Mojave.heic /Library/Desktop\ Pictures

#
# Disable the accent characters menu
#
defaults write -g ApplePressAndHoldEnabled -bool true



#Kill apps
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
# https://1password.com
#
brew install --cask 1password
dockutil --add /Applications/1Password\ 7.app/ --allhomes

#
# Antidote
#
# https://www.antidote.info
#
open https://services.druide.com/
notification "Download & install Antidote"
dockutil --add /Applications/Antidote/Antidote\ 10.app/
loginitems -a Antidote

#
# Brave Browser
#
# https://github.com/brave
#
brew install --cask brave-browser
dockutil --add "/Applications/Brave Browser.app" --position 2 --allhomes
loginitems -a "Brave Browser"
defaults write com.brave.Browser ExternalProtocolDialogShowAlwaysOpenCheckbox -bool true
defaults write com.brave.Browser DisablePrintPreview -bool true

#
# Evernote
#
# https://evernote.com
#
mas install 406056744
defaults write com.evernote.Evernote NSRequiresAquaSystemAppearance -bool true
dockutil --add /Applications/Evernote.app --allhomes
loginitems -a Evernote

#
# Home Assistant
#
# https://github.com/home-assistant/iOS
#
brew install --cask home-assistant

#
# jrnl
#
# https://github.com/jrnl-org/jrnl
#
brew install jrnl

#
# Mumu
#
# https://getmumu.com
#
brew install --cask mumu
loginitems -a Mumu

#
# Notion
#
# https://www.notion.so
#
brew install --cask notion
dockutil --add /Applications/Notion.app --allhomes
loginitems -a Notion


#
# Oh My Zsh
#
# https://github.com/ohmyzsh/ohmyzsh
#
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

#
# OpenInEditor-Lite
#
# https://github.com/Ji4n1ng/OpenInTerminal
#
brew install --cask openineditor-lite
notification "drag openineditor-lite in Finder toolbar"

#
# OpenInTerminal-Lite
#
# https://github.com/Ji4n1ng/OpenInTerminal
#
brew install --cask openinterminal-lite
notification "drag openinterminal-lite in Finder toolbar"

#
# Rain
#
# https://github.com/fharper/rain
#
wget https://github.com/fharper/rain/releases/download/v1.0b2/rain.app.zip
unzip rain.app.zip
rm rain.app.zip
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
npm install -g spaceship-prompt

#
# Spotify
#
brew install --cask spotify
dockutil --add /Applications/Spotify.app --allhomes

#
# Todoist
#
mas install 585829637
dockutil --add /Applications/Todoist.app --allhomes
loginitems -a Todoist

#
# Trash CLI
#
npm i -g trash-cli

#
# Visual Studio Code
#
brew install --cask visual-studio-code
dockutil --add /Applications/Visual\ Studio\ Code.app/ --allhomes


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
brew install act

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
brew install --cask docker

#
# Docker Toolbox
#
brew install --cask docker-toolbox

#
# ESLint
#
# https://eslint.org/
#
brew install eslint

#
# Gist
#
brew install gist
gist --login

#
# Git
#
brew install git
git config --global user.name "Frédéric Harper"
git config --global user.email $email
git config --global init.defaultBranch main
git config --global push.default current
git config --global pull.rebase true
git config --global difftool.prompt false
git config --global diff.tool vscode
git config --global difftool.vscode.cmd "code --diff --wait $LOCAL $REMOTE"
git config --global core.hooksPath ~/.git/hooks
git config --global advice.addIgnoredFile false

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
# GitHub CLI
#
brew install gh
gh auth login

#
# GoEnv + Go
#
# https://github.com/syndbg/goenv
# https://golang.org
#
brew install goenv
goenv install 1.11.4

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
# https://github.com/joeyespo/grip
#
brew install grip

#
# iOS Deploy
#
# https://github.com/ios-control/ios-deploy
#
brew install ios-deploy

#
# npm Check Updates
#
# https://github.com/raineorshine/npm-check-updates
#
npm i -g npm-check-updates

#
#
#
brew install gulp-cli

#
# Postman
#
# https://www.postman.com
#
brew install --cask postman

#
# Prettier
#
# https://github.com/prettier/prettier
#
brew install prettier

#
# RBenv + Ruby + Bundler
#
brew install rbenv
rbenv init
rbenv install 2.7.2
rbenv global 2.7.2
gem install bundler

#
# Xcode
#
mas install 497799835
sudo xcodebuild -license accept

#
# Yarn
#
# https://github.com/yarnpkg/yarn
#
brew install yarn

# PHPenv + PHP + Composer
curl -L https://raw.githubusercontent.com/phpenv/phpenv-installer/master/bin/phpenv-installer | bash
brew uninstall pkg-config
brew uninstall bzip2
phpenv install 7.4.9
brew install composer

brew install autoconf bison bzip2 curl icu4c libedit libjpeg libiconv libpng libxml2 libzip openssl re2c tidy-html5 zlib

PATH="$(brew --prefix icu4c)/bin:$(brew --prefix icu4c)/sbin:$(brew --prefix libiconv)/bin:$(brew --prefix curl)/bin:$(brew --prefix libxml2)/bin:$(brew --prefix bzip2)/bin:$(brew --prefix bison)/bin:$PATH"
PHP_BUILD_CONFIGURE_OPTS="--with-zlib-dir=$(brew --prefix zlib) --with-bz2=$(brew --prefix bzip2) --with-curl=$(brew --prefix curl) --with-iconv=$(brew --prefix libiconv) --with-libedit=$(brew --prefix libedit)"
phpenv install 7.3.9


#
# PYenv + Python + Pip
#
brew install pyenv
read -pr "Remove Homebrew folders in $PATH (pyenv bug)"
pyenv install 3.10-dev

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

#Node stuff
npm i -g express-generator
npm i -g nodemon
npm i -g npm-remote-ls

#
# Java (OpenJDK with AdoptOpenJDK) + jEnv
#
# https://github.com/jenv/jenv
# https://github.com/AdoptOpenJDK/homebrew-openjdk
# https://openjdk.java.net
#
brew install jenv
brew tap AdoptOpenJDK/openjdk
brew install --cask adoptopenjdk
jenv add /usr/local/opt/openjdk@15/
jenv global openjdk64-15.0.1

#Kubernetes
brew install kubernetes-cli
kubectl completion bash >/usr/local/etc/bash_completion.d/kubectl
brew install kubernetes-helm
brew install minikube
brew install kops

#MysSQL
brew install mysql

#PostgreSQL
brew install postgresql

#Redis
brew install redis

# Rust + rustup
#
# https://www.rust-lang.org
# https://rustup.rs
#
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

#Mysql Shell
brew install --cask mysql-shell

#ShellCheck
brew install shellcheck

#SQLite DB Browser
brew install --cask db-browser-for-sqlite

#Ripgrep (recursively searches directories for a regex pattern)
brew install ripgrep

#Terraform
brew install terraform

#WebHint
npm i -g hint

#Bundle Phobia
npm i -g bundle-phobia-cli

#Yeoman
npm i --global yo

#Lynis
brew install lynis


####################
#                  #
# MeiliSeach tools #
#                  #
####################

#
# MeiliSearch
#
# https://github.com/meilisearch/MeiliSearch
#
brew install meilisearch


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
# icssplit /.ics outfilename --maxsize=300000
#
pip3 install icssplit

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
# Bearded Spice
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
wget https://edge.elgato.com/egc/macos/eccm/1.1.3/Control_Center_1.1.3.10337.zip
unzip Control_Center_1.1.3.10337.zip
rm Control_Center_1.1.3.10337.zip
mv "Elgato Control Center.app" /Applications

#
# Elgato Stream Deck
# https://www.elgato.com/en/gaming/stream-deck
#
wget https://edge.elgato.com/egc/macos/sd/Stream_Deck_4.9.2.13193.pkg
open Stream_Deck_4.9.2.13193.pkg
rm Stream_Deck_4.9.2.13193.pkg

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
mas install 1351639930

#
# Gimp
#
# https://gitlab.gnome.org/GNOME/gimp/
#
brew install --cask gimp

#
# Hemingway
#
# http://www.hemingwayapp.com
#
open '/Users/fharper/Documents/mac/Hemingway Editor 3.0.0/Hemingway Editor-3.0.0.dmg'

#
# Iina
#
# https://github.com/iina/iina
#
brew install --cask iina

#ImageMagick
brew install imagemagick

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

#Krita
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

#Micro Snitch
brew install --cask micro-snitch

#
# Microsoft Edge
#
# https://www.microsoft.com/en-us/edge
#
brew install --cask microsoft-edge

#MindNode
mas install 992076693

#Mountain Duck
brew install --cask mountain-duck

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

#Pandoc (for my resume)
brew install pandoc

#
# Parcel
#
# https://parcelapp.net
#
mas install 639968404
loginitems -a -s false Parcel

#PDFSam Basic
brew install --cask pdfsam-basic

#
# Pika
#
# https://github.com/superhighfives/pika
#
brew install --cask pika

#Pocket
mas install 568494494
dockutil --add /Applications/Pocket.app/ --allhomes

#Prey
#open https://panel.preyproject.com/login
#echo "Enter your Prey API key (found in the left corner of the Prey web dashboard settings page)"
#read preyapi
#HOMEBREW_NO_ENV_FILTERING=1 API_KEY="$preyapi" brew install --cask prey
#open /usr/local/lib/prey/current/lib/agent/utils/Prey.app --args -picture

#Public-ip-cli
npm i -g public-ip-cli

#
# Raspberry Pi Imager
#
# https://www.raspberrypi.org/software/
#
brew install --cask raspberry-pi-imager

#Rename
brew install rename

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

#Sloth (displays all open files and sockets in use by all running processes on your system)
brew install --cask sloth

#Speedtest
mas install 1153157709

#TeamViewer
brew install --cask teamviewer

#
# The Unarchiver
#
# https://theunarchiver.com
#
brew install --cask the-unarchiver

#
# Typora
#
# https://typora.io
#
brew install --cask typora

#Unrar
brew install unrar

#WebP Viewer: QuickLook & View
mas install 1323414118

#WiFi Explorer Lite
mas install 1408727408

#Zoom It
mas install 476272252


##########################
# Restore configurations #
##########################

brew install mackup
mackup restore --force

#####################
# Install the Fonts #
#####################
brew tap homebrew/cask-fonts
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
brew install --cask font-hack-nerd-font


##########################################
# Change file type default association ###
##########################################
#How to find the app bundle identifier:
# mdls /Applications/Photos.app | grep kMDItemCF
#How to find the Uniform Type Identifiers
# mdls -name kMDItemContentTypeTree /Users/fharper/Downloads/init.lua
duti -s com.colliderli.iina public.mpeg-4 all #mp4
duti -s com.colliderli.iina com.apple.quicktime-movie all #mov
duti -s com.microsoft.VSCode public.plain-text all #txt
duti -s com.microsoft.VSCode dyn.ah62d4rv4ge8027pb all #lua
duti -s com.colliderli.iina public.avi all #avi
duti -s com.colliderli.iina public.3gpp all #3gp
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
duti -s com.colliderli.iina com.microsoft.waveform-audio all #wav
duti -s com.apple.Preview com.adobe.pdf all #pdf
duti -s com.colliderli.iina public.mp3 all #mp3
duti -s net.kovidgoyal.calibre dyn.ah62d4rv4ge80c8x1gq all #Kindle ebooks
duti -s com.colliderli.iina com.apple.m4a-audio all #M4A
duti -s net.langui.WebPViewer public.webp all #WebP
duti -s com.microsoft.VSCode dyn.ah62d4rv4ge81g6pq all #SQL
duti -s com.apple.Preview org.openxmlformats.presentationml.presentation all #PPTX
duti -s com.microsoft.VSCode public.css all #CSS
duti -s com.microsoft.VSCode com.netscape.javascript-source all #JavaScript
duti -s com.microsoft.VSCode public.ruby-script all #Ruby
duti -s com.apple.Preview public.standard-tesselated-geometry-format all #3d CAD
duti -s com.brave.Browser com.compuserve.gif all #gif

#########
# Games #
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

#######
#     #
# END #
#     #
#######


mackup backup --force

mackup restore --force