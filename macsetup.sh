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
brew cask install alfred
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>" # Deactivate Spotlight Global Shortcut to use it with Alfred instead (will work after logging off)
open -a "Alfred 4"
notification "add shortcut to Alfred"

#
# aText
#
# https://www.trankynam.com/atext
#
brew cask install atext

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
brew cask install bartender

#
# CleanShot X
#
brew cask install cleanshot

#
# Contexts
#
brew cask install contexts

#
# Control Plane
#
# https://github.com/dustinrue/ControlPlane
#
brew cask install controlplane

#
# Dropbox
#
# https://www.dropbox.com
#
brew cask install dropbox

#
# FruitJuice
#
mas install 671736912

#
# HSTR
#
brew install hh

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
brew cask install maccy

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
brew cask install slowquitapps

#
# Sound Control
#
brew cask install sound-control

#
# The Clock
#
brew install the-clock
defaults write com.apple.menuextra.clock IsAnalog -bool true #macOS Clock in analog format

#
# Zoom
#
# https://zoom.us
#
brew cask install zoomus


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

#Deactivate Play user interface sound effects

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
brew cask install 1password
dockutil --add /Applications/1Password\ 7.app/ --allhomes

#
# Antidote
#
# https://www.antidote.info
open https://services.druide.com/
notification "Download & install Antidote"
dockutil --add /Applications/Antidote/Antidote\ 10.app/
loginitems -a Antidote

#
# Brave Browser
#
# https://github.com/brave
#
brew cask install brave-browser
dockutil --add "/Applications/Brave Browser.app" --position 2 --allhomes
loginitems -a "Brave Browser"
defaults write com.brave.Browser ExternalProtocolDialogShowAlwaysOpenCheckbox -bool true
defaults write com.brave.Browser DisablePrintPreview -bool true

#
# Evernote
#
mas install 406056744
defaults write com.evernote.Evernote NSRequiresAquaSystemAppearance -bool true
dockutil --add /Applications/Evernote.app --allhomes
loginitems -a Evernote

#
# Home Assistant
#
brew cask install home-assistant

#
# Notion
#
brew cask install notion
dockutil --add /Applications/Notion.app --allhomes
loginitems -a Notion


#
# Oh My Zsh
#
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

#
# OpenInEditor-Lite
#
# https://github.com/Ji4n1ng/OpenInTerminal
#
brew cask install openineditor-lite
notification "drag openineditor-lite in Finder toolbar"

#
# OpenInTerminal-Lite
#
# https://github.com/Ji4n1ng/OpenInTerminal
#
brew cask install openinterminal-lite
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
brew cask install slack
dockutil --add /Applications/Slack.app/ --allhomes

#
# Spaceship Prompt
#
npm install -g spaceship-prompt

#
# Spotify
#
brew cask install spotify
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
brew cask install visual-studio-code
dockutil --add /Applications/Visual\ Studio\ Code.app/ --allhomes


###################
#                 #
# Developer stuff #
#                 #
###################

#
# BFG Repo-Cleaner
#
# https://github.com/rtyley/bfg-repo-cleaner
#
# git-filter-branch replacement
#
brew install bfg

#
# Docker
#
brew cask install docker

#
# Docker Toolbox
#
brew cask install docker-toolbox

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
# GitHub Desktop
#
brew cask install github

#
# GoEnv + Go
#
# https://github.com/syndbg/goenv
# https://golang.org
#
brew install goenv
goenv install 1.11.4

#
# GPG
#
brew cask install gpg-suite
notification "get my private key from 1Password"
gpg --import private.key
git config --global user.signingkey 523390FAB896836F8769F6E1A3E03EE956F9208C
git config --global commit.gpgsign true

#
#
#
brew install gulp-cli

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




#
# PYenv + Python + Pip
#
brew install pyenv

curl https://bootstrap.pypa.io/get-pip.py > get-pip.py
sudo python get-pip.py
rm get-pip.py

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

#Node stuff
npm i -g express-generator
npm i -g nodemon
npm i -g npm-remote-ls
npm i -g npm-check-updates

#
# Java (OpenJDK with AdoptOpenJDK) + jEnv
#
# https://github.com/jenv/jenv
# https://github.com/AdoptOpenJDK/homebrew-openjdk
# https://openjdk.java.net
#
brew install jenv
brew tap AdoptOpenJDK/openjdk
brew cask install adoptopenjdk
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




#Git scripts
npm i -g git-branch-status

pyenv install 3.7.0
pyenv global 3.7.0


#Mysql Shell
brew cask install mysql-shell

#ShellCheck
brew install shellcheck

#SQLite DB Browser
brew cask install db-browser-for-sqlite

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
#
brew install jq

#
# Noti
#
# https://github.com/variadico/noti
#
brew install noti

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
# https://freemacsoft.net/appcleaner/
brew cask install appcleaner

#
# Kap
#
# https://github.com/wulkano/Kap
#
brew cask install kap

#
# Raspberry Pi Imager
#
# https://www.raspberrypi.org/software/
#
brew cask install raspberry-pi-imager

#
# Silicon
#
# https://github.com/DigiDNA/Silicon
#
brew tap zgosalvez/repo
brew cask install zgosalvez-silicon






#Diablo II
open -a '/Users/fharper/Documents/mac/Diablo 2/Installer.app'
rm '/Users/fharper/Desktop/Diablo II'
ln -sf /Users/fharper/Documents/misc/Diablo/ /Applications/Diablo\ II/save

#Discord
brew cask install discord

#Calibre
brew cask install calibre
open https://github.com/apprenticeharper/DeDRM_tools/releases
notification "Install the DeDRM plugin into Calibre"

#
#Captin
# https://captin.mystrikingly.com/
#
brew cask install captin

#Charles Proxy
brew cask install Charles

#
# Chrome
#
# https://www.google.com/chrome
#
brew install cask google-chrome

#Control Center
open "/Users/fharper/Documents/mac/Elgato Control Center 1.1.3.10337/Control_Center_1.1.3.10337.zip"

#Cryptomator
brew cask install cryptomator

#
# DaisyDisk
#
# https://daisydiskapp.com/
#
brew cask install daisydisk

#Deckset
brew cask install deckset

#Disk Drill
brew cask install disk-drill

#Edge
brew cask install microsoft-edge

#
# ffmpeg + vmaf
#
# https://ffmpeg.org
# https://github.com/Netflix/vmaf
#
brew install libvmaf
brew tap homebrew-ffmpeg/ffmpeg
brew install homebrew-ffmpeg/ffmpeg/ffmpeg --with-libvmaf

#Firefox
brew cask install firefox

#Gifski
mas install 1351639930

#
# Gimp
#
# https://gitlab.gnome.org/GNOME/gimp/
#
brew cask install gimp

#Hemingway
open '/Users/fharper/Documents/mac/Hemingway Editor 3.0.0/Hemingway Editor-3.0.0.dmg'

#
# htop
#
# https://github.com/htop-dev/htop
#
brew install htop

#
# ICS split
#
# https://github.com/beorn/icssplit
#
# icssplit /.ics outfilename --maxsize=300000
#
pip3 install icssplit

#
# Iina
#
# https://github.com/iina/iina
#
brew cask install iina

#ImageMagick
brew install imagemagick

#Jiffy
mas install 1502527999

#Keybase
brew cask install keybase

#Keycastr
brew cask install keycastr

#Kindle
mas install 405399194

#Krita
brew cask install krita

#Logitech Presentation
brew cask install logitech-presentation
open '/usr/local/Caskroom/logitech-presentation/1.52.95/LogiPresentation Installer.app'

#LZip
brew install lzip

#Messenger
brew cask install Messenger

#Micro Snitch
brew cask install micro-snitch

#MindNode
mas install 992076693

#Mountain Duck
brew cask install mountain-duck

#
# Mumu
#
# https://getmumu.com
#
brew cask install mumu
loginitems -a Mumu

#Muzzle
brew cask install muzzle

#NordVPN
brew cask install nordvpn

#Pandoc (for my resume)
brew install pandoc

#
# Parcel
#
# https://parcelapp.net
#
mas install 639968404
loginitems -a Parcel

#PDFSam Basic
brew cask install pdfsam-basic

#Pikka - Color Picker
mas install 1195076754
loginitems -a Pikka

#Pocket
mas install 568494494
dockutil --add /Applications/Pocket.app/ --allhomes

#Postman
brew cask install postman

#Prey
#open https://panel.preyproject.com/login
#echo "Enter your Prey API key (found in the left corner of the Prey web dashboard settings page)"
#read preyapi
#HOMEBREW_NO_ENV_FILTERING=1 API_KEY="$preyapi" brew cask install prey
#open /usr/local/lib/prey/current/lib/agent/utils/Prey.app --args -picture

#Public-ip-cli
npm i -g public-ip-cli

#Rename
brew install rename

#
# Signal
#
# https://github.com/signalapp/Signal-Desktop
#
brew cask install signal

#Sloth (displays all open files and sockets in use by all running processes on your system)
brew cask install sloth

#Speedtest
mas install 1153157709

#StreamDeck
open ~/Documents/mac/Stream\ Deck\ 4.3.2.11299/Stream_Deck_4.3.2.11299.pkg

#TeamViewer
brew cask install teamviewer

#
# The Fuck
#
# https://github.com/nvbn/thefuck
#
brew install thefuck

#The Unarchiver
mas install 425424353

#Typora
brew cask install typora

#Unrar
brew install unrar

#WebP Viewer: QuickLook & View
mas install 1323414118

#WiFi Explorer Lite
mas install 1408727408

#wkhtmltopdf (for my resume)
brew cask install wkhtmltopdf

#
# Youtube Downloader
#
# https://github.com/ytdl-org/youtube-dl/
#
brew install youtube-dl

#
# Zoom
#
# https://zoom.us
#
brew cask install zoomus

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
brew cask install font-fira-sans
brew cask install font-fira-code
brew cask install font-arial
brew cask install font-open-sans
brew cask install font-dancing-script
brew cask install font-dejavu
brew cask install font-roboto
brew cask install font-roboto-condensed
brew cask install font-hack
brew cask install font-pacifico
brew cask install font-leckerli-one
brew cask install font-gidole
brew cask install font-fira-mono
brew cask install font-blackout
brew cask install font-alex-brush
brew cask install font-fira-code-nerd-font #use with Starfish


##########################################
# Change file type default association ###
##########################################
#How to find the app bundle identifier:
# mdls /Applications/Photos.app | grep kMDItemCF
#How to find the Uniform Type Identifiers
# mdls -name kMDItemContentTypeTree /Users/fharper/Downloads/init.lua
brew install duti
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

######################
# Order apps in Dock #
######################

#list them in inversed order
dockutil --move 'Antidote 10' --position beginning --allhomes
dockutil --move '1Password 7' --position beginning --allhomes
dockutil --move 'Pocket' --position beginning --allhomes
dockutil --move 'Visual Studio Code' --position beginning --allhomes
dockutil --move 'iTerm' --position beginning --allhomes
dockutil --move 'Spotify' --position beginning --allhomes
dockutil --move 'Slack' --position beginning --allhomes
dockutil --move 'Todoist' --position beginning --allhomes
dockutil --move 'Evernote' --position beginning --allhomes
dockutil --move 'Brave Browser' --position beginning --allhomes


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
# OpenEmu
#
# https://github.com/OpenEmu/OpenEmu
#
brew cask install openemu


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
brew cask install monolingual
notification "Use Monolingual to remove unused languages files"

#########
# END ###
#########


mackup backup --force

mackup restore --force