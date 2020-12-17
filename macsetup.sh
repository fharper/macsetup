#! /bin/bash


#########################
#                       #
# Script Configurations #
#                       #
#########################

#Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
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

############################
#                          #
# Utils to run this script #
#     (needed order)       #
#                          #
############################

# Brew
#
# https://brew.sh
#
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.0/install.sh | bash
brew analytics off
brew install bash-completion

#Mac App Store CLI
#
# Mac App Store cli
#
# https://github.com/mas-cli/mas
#
brew install mas
mas signin $email

#osXiconUtils
curl https://sveinbjorn.org/files/software/osxiconutils.zip > osxiconutils.zip
unzip osxiconutils.zip
rm osxiconutils.zip
mv bin/geticon /usr/local/sbin/
mv bin/seticon /usr/local/sbin/
rm -rf bin/

#Dockutil
brew install dockutil
#
# Terminal Notifier
#
# https://github.com/julienXX/terminal-notifier
#
brew install terminal-notifier


#Mackup
brew cask install mackup

#wget
brew install wget
brew tap dteoh/sqa
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
open -a "Alfred 4"
notification "add shortcut to Alfred"

#############################
# Install main applications #
#############################
#
# aText
#
# https://www.trankynam.com/atext
#
brew cask install atext

#iTerm
brew cask install iterm2
dockutil --add /Applications/iTerm.app/ --allhomes
#
# Amphetamine
#
# https://apps.apple.com/app/amphetamine/id937984704
#
mas install 937984704

#Spaceship Prompt
npm install -g spaceship-prompt
#
# Bartender
#
# https://www.macbartender.com
#
brew cask install bartender

#Little Snitch
brew cask install little-snitch
#
# CleanShot X
#
brew cask install cleanshot

#iTerm CD
brew cask install cd-to-iterm
geticon /Applications/iTerm.app/ iterm.icns
seticon iterm.icns /Applications/cd\ to\ iterm.app/
rm iterm.icns
#
# Contexts
#
brew cask install contexts

#Visual Studio Code
brew cask install visual-studio-code
dockutil --add /Applications/Visual\ Studio\ Code.app/ --allhomes

#Visual Studio Code Open
brew cask install open-in-code
geticon /Applications/Visual\ Studio\ Code.app/ code.icns
seticon code.icns /Applications/Open\ in\ Code.app/
rm code.icns
#
# FruitJuice
#
mas install 671736912

#Brave
brew cask install brave-browser
defaults write com.brave.Browser DisablePrintPreview -bool true
dockutil --add /Applications/Brave.app/ --allhomes
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Brave", path:"/Applications/Brave.app", hidden:false}'
defaults write com.brave.Browser ExternalProtocolDialogShowAlwaysOpenCheckbox -bool true
#
# HSTR
#
brew install hh

#1Password
brew cask install 1password
dockutil --add /Applications/1Password\ 7.app/ --allhomes
#
# Logitech Mouse Manager
#
wget https://download01.logi.com/web/ftp/pub/techsupport/options/Options_8.34.91.zip
unzip Options_8.34.91.zip
rm Options_8.34.91.zip
open -a "LogiMgr Installer 8.34.91.app"
rm -rf "LogiMgr Installer 8.34.91.app"

#Jrnl
brew install jrnl

#Evernote
mas install 406056744
dockutil --add /Applications/Evernote.app/ --allhomes
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Evernote", path:"/Applications/Evernote.app", hidden:false}'
#
# Moom
#
# https://manytricks.com/moom
#
mas install 419330170 #install the App Store version since you bought it

#Todoist
mas install 585829637
dockutil --add /Applications/Todoist.app/ --allhomes
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Todoist", path:"/Applications/Todoist.app", hidden:false}'
#
# Slow Quit Apps
#
# https://github.com/dteoh/SlowQuitApps
#
brew tap dteoh/sqa
brew cask install slowquitapps

#Slack
brew cask install slack
dockutil --add /Applications/Slack.app/ --allhomes
#
# Sound Control
#
brew cask install sound-control

#Spotify
brew cask install spotify
dockutil --add /Applications/Spotify.app/ --allhomes
#
# The Clock
#
brew install the-clock

#Rain
wget https://github.com/fharper/rain/releases/download/v1.0/rain.app.zip && unar rain.app.zip && rm rain.app.zip && mv rain.app /Applications
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Rain", path:"/Applications/Rain.app", hidden:false}'


#
# Garage Band
#
sudo rm -rf /Applications/GarageBand.app


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

######################
# Git configurations #
######################
brew install git
git config --global user.name "Frédéric Harper"
git config --global user.email hi@fred.dev
git config --global push.default current
git config --global difftool.prompt false
git config --global diff.tool vscode
git config --global difftool.vscode.cmd 'code --diff --wait $LOCAL $REMOTE'
git config --global pull.rebase true

npx git-the-latest

curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash

brew install git-lfs
#
# Notes
#
dockutil --remove 'Notes' --allhomes

brew install bfg

brew install gh
#
# Podcasts
#
dockutil --remove 'Podcasts' --allhomes

brew install gist
#
# Reminders
#
dockutil --remove 'Reminders' --allhomes

#GPG
brew cask install gpg-suite
gpg --list-secret-keys --keyid-format LONG
echo "Copy & paste your public key UUID listed below (line sec - after the /)"
read gpgUUID
git config --global user.signingkey $gpgUUID
git config --global commit.gpgsign true
#
# Safari
#
dockutil --remove 'Safari' --allhomes

#
# System Preferences
#
dockutil --remove 'System Preferences' --allhomes

######################
# Command line tools #
######################
npm i -g trash-cli
brew install wifi-password
curl -sLo- http://get.bpkg.sh | bash


#####################
# OS Configurations #
#####################

#Dock: minimize window into application icon
defaults write com.apple.dock minimize-to-application -bool true

#Generate the locate database
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

#Show Users Library folder
chflags nohidden ~/Library/

#Allow Apps from anywhere to be installed without warnings
sudo spctl --master-disable

#Disable the accent characters menu
defaults write -g ApplePressAndHoldEnabled -bool false

#Disable the look up & data detector on Trackpad
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool false
defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerTapGesture -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -bool false

#Disable Mission Control and Exposé Gestures on Trackpad
defaults write com.apple.dock showAppExposeGestureEnabled -bool false
defaults write com.apple.dock showMissionControlGestureEnabled -bool false
defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerVertSwipeGesture -bool false
defaults -currentHost write NSGlobalDomain com.apple.trackpad.fourFingerVertSwipeGesture -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseTwoFingerDoubleTapGesture -bool false

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

#Stop the creation of the stupid .DS_Store files
defaults write com.apple.desktopservices DSDontWriteNetworkStores true

#Mute the boot chime
sudo nvram StartupMute=%01

echo -e "\n"
read -p "${txtflash}Deactivate the Force click and haptic feedback from Trackpad manually" -n1 -s
echo -e "\n"

echo -e "\n"
read -p "${txtflash}Deactivate Show recent applications in Dock from the Dock manually" -n1 -s
echo -e "\n"

#Activate Silent clicking
defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 0

#Disable Guest Account
sudo defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool false
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool false

#Finder display settings
defaults write com.apple.finder FXArrangeGroupViewBy -string "Name"
defaults write com.apple.finder ShowRemovableMediaOnDesktop -boolean false
defaults write com.apple.finder ShowRecentTags -boolean false
defaults write com.apple.finder ShowHardDrivesOnDesktop -boolean false
defaults write com.apple.finder ShowStatusBar -boolean true
defaults write com.apple.finder FXEnableExtensionChangeWarning -boolean false
defaults write com.apple.finder ShowPathbar -bool true

#New Finder windows in my Downloads folder
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads"

#Prevent .DS_Store File Creation on Network Volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores true

#Show all files extensions
defaults write -g AppleShowAllExtensions -bool true

#Volume - Don't play feedback on volume change
defaults write NSGlobalDomain com.apple.sound.beep.feedback -int 0

#Add extra system menuitems
defaults write com.apple.systemuiserver menuExtras -array \
"/System/Library/CoreServices/Menu Extras/Volume.menu" \
"/System/Library/CoreServices/Menu Extras/Bluetooth.menu"

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
todo+="- Deactivate Play user interface sound effects"
todo+="\n"

#Disable screensaver
defaults -currentHost write com.apple.screensaver idleTime 0

git config --global user.email $email
git config --global init.defaultBranch main

dockutil --remove 'Books' --allhomes
dockutil --remove 'Siri' --allhomes
dockutil --remove 'iTunes' --allhomes

#Kill apps
killall Finder
killall Dock
killall SystemUIServer
#
# Git Sizer
#
brew install git-sizer


#####################
# Install dev stuff #
#####################

#Install pip
curl https://bootstrap.pypa.io/get-pip.py > get-pip.py
sudo python get-pip.py
rm get-pip.py

#Composer
brew install composer

#Ruby stuff
brew install rbenv
rbenv init
rbenv install 2.6.3
rbenv global 2.6.3

#Install Bundle (Gem/Ruby)
gem install bundler

#Xcode (before Antibody)
mas install 497799835
open -a Xcode

#Antibody
brew install getantibody/tap/antibody

#Git PR open
antibody bundle caarlos0/open-pr kind:path

#Gulp
npm i -g gulp-cli

#Hub (for Github)
brew install hub
# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

#Docker
brew cask install docker
brew cask install docker-toolbox

#Generate a new public SSH key
ssh-keygen -t rsa -b 4096 -C "fharper@oocz.net"
ssh-add -K ~/.ssh/id_rsa
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts
pbcopy < ~/.ssh/id_rsa.pub
open https://github.com/settings/keys
echo -e "${txtflash}Add SSH key to Github (copied in the clipboard)"
open https://bitbucket.org/account/user/fharper/ssh-keys/
read -p "${txtflash}Add SSH key to Bitbucket (copied in the clipboard)" -n1 -s
echo -e "\n"

#Node stuff
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash
nvm install v12.18.3
nvm alias default v12.18.3
npm i -g npm@latest
npm config set prefix /usr/local
npm config set editor code
npm config set sign-git-tag true
npm adduser
npm i -g express-generator
npm i -g nodemon
npm i -g npx
npm i -g npm-remote-ls
npm i -g npm-check-updates
npm i -g yarn
npm i -g eslint
npm i -g prettier

#Go
brew install go

#Java stuff
brew install jenv
brew cask install java
jenv add /Library/Java/JavaVirtualMachines/openjdk-12.0.1.jdk/Contents/Home/
jenv global openjdk64-12.0.1

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

#Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

#JavaScript
npm i -g uglify-js

#HTML
npm i -g html-minifier

#CSS
npm i -g cssnano-cli

#Images
npm i -g imagemin-cli
npm i -g imagemin-pngquant
npm i -g imagemin-jpegtran

#Accessibility
npm i -g pa11y

#Git scripts
npm i -g git-open
npm i -g git-recent
npm i -g git-branch-status

#Python stuff
brew install pyenv
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

#Hub
brew install hub

#Xcode
mas install 497799835


############################
# Install the applications #
############################

#Affinity Designer
mas install 824171161

#Antidote
open https://services.druide.com/
read -p "${txtflash}Download & install Antidote before continuing..." -n1 -s
dockutil --add /Applications/Antidote/Antidote\ 10.app/
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Antidote", path:"/Applications/Antidote.app", hidden:false}'

#AppCleaner
brew cask install appcleaner
todo+="- Activate AppCleaner Smart Delete"
todo+="\n"

#Asciinema
brew install asciinema

#Bandwhich
brew install bandwhich

#Bat
brew install bat

#Diablo II
open -a '/Users/fharper/Documents/mac/Diablo 2/Installer.app'
rm '/Users/fharper/Desktop/Diablo II'
ln -sf /Users/fharper/Documents/misc/Diablo/ /Applications/Diablo\ II/save

#Calibre
brew cask install calibre
todo+="- Add DeDRM plugin to Calibre"
todo+="\n"

#Camtasia
brew cask install camtasia
todo+="- Add your license to Camtasia"
todo+="\n"

#
#Captin
# https://captin.mystrikingly.com/
#
brew cask install captin

#Charles Proxy
brew cask install Charles

#Cryptomator
brew cask install cryptomator

#DaisyDisk
brew cask install daisydisk
todo+="- Add your license to DaisyDisk"
todo+="\n"

#Deckset
brew cask install deckset

#Disk Drill
brew cask install disk-drill

#Dropbox
brew cask install dropbox

#Edge
brew cask install microsoft-edge

#ffmpeg
brew install libvma
brew tap homebrew-ffmpeg/ffmpeg
brew install homebrew-ffmpeg/ffmpeg/ffmpeg --with-libvmaf

#Firefox
brew cask install firefox

#Gifski
mas install 1351639930

#Gimp
brew cask install gimp

#Hemingway
open '/Users/fharper/Documents/mac/Hemingway Editor 3.0.0/Hemingway Editor-3.0.0.dmg'

#ICS split
#icssplit file.ics outfilename --maxsize=900000
#
# htop
#
# https://github.com/htop-dev/htop
#
brew install htop

pip3 install icssplit

#Iina
brew cask install iina

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

#Maccy
brew cask install maccy


#Messenger
brew cask install Messenger

#Micro Snitch
brew cask install micro-snitch

#MindNode
mas install 992076693

#Mountain Duck
brew cask install mountain-duck

#Mumu
brew cask install mumu
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Mumu", path:"/Applications/Mumu.app", hidden:false}'

#Muzzle
brew cask install muzzle

#NordVPN
brew cask install nordvpn

#Pandoc (for my resume)
brew install pandoc

#Parcel
mas install 639968404

#PDFSam Basic
brew cask install pdfsam-basic

#Pikka - Color Picker
mas install 1195076754
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Pikka", path:"/Applications/Pikka.app", hidden:false}'

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

#Signal
brew cask install signal

#Sloth (displays all open files and sockets in use by all running processes on your system)
brew cask install sloth

#Speedtest
mas install 1153157709

#StreamDeck
open ~/Documents/mac/Stream\ Deck\ 4.3.2.11299/Stream_Deck_4.3.2.11299.pkg

#TeamViewer
brew cask install teamviewer

#The Fuck
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

#Zoom
brew cask install zoomus

#Zoom It
mas install 476272252

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

todo+="\n"
todo+="(copied to keyboard)"
echo -e ${txtflash}$todo${txtblack}
echo -e $todo | pbcopy


mackup backup --force

mackup restore --force