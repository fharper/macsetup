#! /bin/bash

#########
# Notes #
#########

# Search for App Store apps
# mas search "App Name"

# Reload bash
# source ~/.bash_profile


txtflash=$(tput setaf 3) #yellow
txtblack=$(tput setaf 7)
todo="\n########\n# TODO #\n########\n"


#####################
# OS Configurations #
#####################

#Dock: minimize window into application icon
defaults write com.apple.dock minimize-to-application -bool true

#Generate the locate database
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

#Show Users Library folder
chflags nohidden ~/Library/

#Create the symlinks between system folders and Dropbox before the sync start
ln -s ${HOME}/Pictures/ ${HOME}"/Dropbox"
ln -s ${HOME}/Music/ ${HOME}"/Dropbox"
ln -s ${HOME}/Movies/ ${HOME}"/Dropbox"
ln -s ${HOME}/Downloads/ ${HOME}"/Dropbox"
ln -s ${HOME}/Documents/ ${HOME}"/Dropbox"

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
defaults write com.apple.dock showDesktopGestureEnabled   -bool true
defaults write com.apple.dock showLaunchpadGestureEnabled -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.fourFingerPinchSwipeGesture -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerPinchGesture -bool false
defaults -currentHost write NSGlobalDomain com.apple.trackpad.fiveFingerPinchSwipeGesture -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadFiveFingerPinchGesture -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFiveFingerPinchGesture -bool false

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

#Show all hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true

#New Finder windows in my Downloads folder
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads"

#Prevent .DS_Store File Creation on Network Volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores true

#Show all files extensions
defaults write -g AppleShowAllExtensions -bool true

#Volume - Don't play feedback on volume change
defaults write NSGlobalDomain com.apple.sound.beep.feedback -int 0

#Git configurations
git config --global user.name "Frédéric Harper"
git config --global user.email fharper@oocz.net
git config --global push.default current
git config --global difftool.prompt false
git config --global diff.tool Kaleidoscope
git config --global difftool.Kaleidoscope.cmd 'ksdiff --partial-changeset --relative-path "$MERGED" -- "$LOCAL" "$REMOTE"'

#Deactivate the Chrome Printing Dialog
defaults write com.google.Chrome DisablePrintPreview -bool true

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

#Disable the Notification Center but doesn't remove the menubar icon anymore!
#echo -e "\n"
#read -p "${txtflash}Deactivate the System Integrity Protection first... " -n1 -s
#echo -e "\n"
#launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist

#Search the current folder by default in Finder
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

#Deactivate Play user interface sound effects (not working)
#defaults write com.apple.systemsound "com.apple.sound.uiaudio.enabled" -boolean false
#defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -boolean false
todo+="- Deactivate Play user interface sound effects"
todo+="\n"

#delete defaults apps
brew install dockutil
sudo rm -rf /Applications/Numbers.app
dockutil --remove 'Numbers' --allhomes
sudo rm -rf /Applications/Keynote.app
dockutil --remove 'Keynote' --allhomes
sudo rm -rf /Applications/Pages.app
dockutil --remove 'Pages' --allhomes
sudo rm -rf /Applications/GarageBand.app

#remove apps from dock
dockutil --remove 'Books' --allhomes
dockutil --remove 'Maps' --allhomes
dockutil --remove 'Reminders' --allhomes
dockutil --remove 'FaceTime' --allhomes
dockutil --remove 'Notes' --allhomes
dockutil --remove 'System Preferences' --allhomes
dockutil --remove 'Calendar' --allhomes
dockutil --remove 'Mail' --allhomes
dockutil --remove 'Contacts' --allhomes
dockutil --remove 'Siri' --allhomes
dockutil --remove 'Launchpad' --allhomes
dockutil --remove 'Safari' --allhomes
dockutil --remove 'App Store' --allhomes
dockutil --remove 'iTunes' --allhomes
#Kill apps
killall Finder
killall Dock
killall SystemUIServer


#######################################
# Install brew, brew cask, mas & more #
#######################################

#iTerm
brew cask install iterm2
open -a iTerm

#Brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew analytics off
brew install bash-completion

#Brew Cask
brew tap caskroom/cask

#Fix XCode
xcode-select --install

#Visual Studio Code
brew cask install visual-studio-code
open -a "Visual Studio Code"

#Mac App Store command line interface
brew install mas

#Install pip
curl https://bootstrap.pypa.io/get-pip.py > get-pip.py
sudo python get-pip.py
rm get-pip.py

#Ruby stuff
brew install rbenv
rbenv init
rbenv install 2.5.3
rbenv global 2.5.3

#Install Bundle (Gem/Ruby)
gem install bundler

#Xcode (before Antibody)
mas install 497799835
open -a Xcode

#Antibody
brew install getantibody/tap/antibody

#Git PR open
antibody bundle caarlos0/open-pr kind:path

#Hub (for Github)
brew install hub

#Prevent code to show in Alfred
brew install tag
tag -a alfred:ignore -R ~/Code
tag -a alfred:ignore -R ~/Dropbox
tag -a alfred:ignore -R ~/Music

#####################
# Install dev stuff #
#####################

#Generate a new public SSH key
ssh-keygen -t rsa -b 4096 -C "fharper@oocz.net"
ssh-add -K ~/.ssh/id_rsa
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts
pbcopy < ~/.ssh/id_rsa.pub
echo -e "\n"
read -p "${txtflash}Add SSH key to Github at https://github.com/settings/keys (copied in the clipboard)" -n1 -s
read -p "${txtflash}Add SSH key to Bitbucket at https://bitbucket.org/account/user/fharper/ssh-keys/ (copied in the clipboard)" -n1 -s
echo -e "\n"

#Node stuff
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash
nvm install v10.13.0
nvm alias default v10.13.0

#Node packages
npm install -g npm@latest
npm install -g express-generator
npm install -g nodemon
npm install -g npx

#Security
npm install -g snyk
snyk auth

#JavaScript
npm install -g uglify-js

#HTML
npm install -g html-minifier

#CSS
npm install -g cssnano-cli

#Images
npm install -g imagemin-cli
npm install -g imagemin-pngquant
npm install -g imagemin-jpegtran

#Accessibility
npm install -g pa11y

#Git open
npm install -g git-open

#Python stuff
brew install pyenv
pyenv install 3.7.0
pyenv global 3.7.0

#Mysql Shell
brew cask install mysql-shell

#MongoDB
brew install mongodb

#Android Studio, SDK and tools
#brew cask install android-studio
#open -a "Android Studio"
#/Users/fharper/Library/Android/sdk/tools/bin/sdkmanager "platforms;android-27"
#/Users/fharper/Library/Android/sdk/tools/bin/sdkmanager "build-tools;26.0.2"
#android update sdk -u -a -t 5 #Android SDK Tools, revision 25
#/Users/fharper/Library/Android/sdk/tools/bin/sdkmanager "ndk-bundle"


#########################
# Install the main apps #
#########################

#Dropbox
brew cask install dropbox
open -a Dropbox
echo -e "\n"
read -p "${txtflash}Setup Dropbox and press any key to continue after... " -n1 -s
echo -e "\n"

#Chrome
brew cask install google-chrome
open -a "Google Chrome"

#YARN
brew install yarn

#Caffeine
brew cask install caffeine
open -a Caffeine

#1Password
brew cask install 1password
open -a "1Password 7"

#Alfred
brew cask install alfred
open -a "Alfred 3"
todo+="- Remove the spotlight keyboard shortcut and set the Alfred one"
todo+="\n"

#Bartender
brew cask install bartender
open -a "Bartender 3"

#Hammerspoon
brew cask install hammerspoon
rm -rf ${HOME}/.hammerspoon
ln -s ${HOME}/Documents/Personal/Configurations/.hammerspoon ${HOME}/.hammerspoon
open -a Hammerspoon

#Evernote
mas install 406056744
open -a Evernote

#Todoist
mas install 585829637
open -a Todoist


############################
# Install the applications #
############################

#Antidote
todo+="- Download & install Antidote (see the link in 1Password) "
todo+="\n"
open -a "Antidote 9"

#Appcleaner
brew cask install appcleaner

#Asciinema
brew install asciinema

#Battery Indicator
mas install 1206020918
open -a "Battery Indicator"

#Battery Stats for AirPods
mas install 1405763798
#Battle.net (Diablo II, World of Warcraft)
brew cask install battle-net
open -a /usr/local/Caskroom/battle-net/latest/Battle.net-Setup.app

#Boxer
brew cask install boxer
open -a Boxer

#Brave browser
brew cask install brave-browser

#Brew Cask Upgrade
brew tap buo/cask-upgrade
#brew update
#brew cu -y

#Calibre
brew cask install calibre
open -a Calibre

#Camtasia
brew cask install camtasia
open -a "Camtasia 2018"
todo+="- Add your license to Camtasia"
todo+="\n"

#Cryptomator
brew cask install cryptomator

#DaisyDisk (better to install the non App Store version)
brew cask install daisydisk
open -a DaisyDisk
todo+="- Add your license to DaisyDisk"
todo+="\n"

#Discord
brew cask install discord
open -a Discord

#Duplicate Photo Fixer Pro
mas install 963642514

#FileZilla
brew cask install filezilla

#Firefox
brew cask install firefox

#Fliqlo screensaver
brew cask install fliqlo

#Gimp
brew cask install gimp

#ICS split
#icssplit file.ics outfilename --maxsize=900000
pip3 install icssplit
#iMovie
mas install 408981434

#Inkscape
brew install caskformula/caskformula/inkscape
/usr/local/Cellar/inkscape/0.92.2_1/bin/inkscape

#Kaleidoscope
mas install 587512244

#Kaleidoscope KSDiff
brew cask install ksdiff

#Larch
gem install larch

#Lightshot
mas install 526298438
open -a "Lightshot Screenshot"

#Luminar
mas install 1161679618

#LZip
brew install lzip

#MacDown
brew cask install macdown

#Mate Translator (previously Instant Translate)
mas install 1005088137
open -a "Mate Translator"

#Menubar Countdown
brew cask install menubar-countdown
open -a "Menubar Countdown"

#Messenger
brew cask install messenger

#Moom
mas install 419330170
open -a Moom

#MindNode
mas install 992076693

#Noizio
mas install 928871589
open -a Noizio

#OpenEmu
brew cask install openemu
open -a OpenEmu

#Opera
brew cask install opera

#Parcel
mas install 639968404
open -a Parcel

#PDFSam Basic
brew cask install pdfsam-basic

#Pocket
mas install 568494494
open -a Pocket

#Postman
brew cask install postman
open -a Postman

#Revisions for Dropbox
mas install 819348619
open -a Revisions

#ShellCheck
brew install shellcheck

#Signal
brew cask install signal

#Slack
brew cask install slack

#Smallpdf
brew cask install smallpdf

#Spotify
brew cask install spotify

#Teams
brew cask install microsoft-teams
#Steam
brew cask install steam

#TeamViewer
brew cask install teamviewer

#The Clock
mas install 488764545
open -a "The Clock"
todo+="- Remove the System Clock from the menubar"
todo+="\n"

#The Unarchiver
mas install 425424353

#TripMode
brew cask install tripmode
open -a TripMode

#TweetDeck
mas install 485812721

#VLC
brew cask install vlc

#WhatsApp
brew cask install whatsapp

#Witch
brew cask install witch

#Zoom
brew cask install zoomus

#Zoom It
mas install 476272252

##########################################
# Change file type default association ###
##########################################
#How to find the app bundle identifier: 
# mdls /Applications/Photos.app | grep kMDItemCF
#How to find the Uniform Type Identifiers
# mdls -name kMDItemContentTypeTree /Users/fharper/Documents/init.lua
brew install duti
duti -s org.videolan.vlc public.mpeg-4 all #mp4
duti -s org.videolan.vlc com.apple.quicktime-movie all #mov
duti -s com.microsoft.VSCode public.plain-text all #txt
duti -s com.microsoft.VSCode dyn.ah62d4rv4ge8027pb all #lua
duti -s org.videolan.vlc public.avi all #avi
duti -s com.seriflabs.affinitydesigner public.svg-image all #svg
duti -s org.videolan.vlc public.3gpp all #3gp
duti -s com.apple.Preview com.nikon.raw-image all #NEF
duti -s com.microsoft.Outlook com.apple.ical.ics all #iCal
duti -s com.uranusjr.macdown net.daringfireball.markdown all #Markdown
duti -s com.google.Chrome public.svg-image all #SVG
duti -s net.kovidgoyal.calibre org.idpf.epub-container all # ePub
duti -s com.microsoft.VSCode public.shell-script all #Shell script
duti -s com.microsoft.VSCode com.apple.log all #log
duti -s com.microsoft.Excel public.comma-separated-values-text all #CSV
duti -s com.microsoft.VSCode public.data all #yml


#####################
# Add login items ###
#####################
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Antidote", path:"/Applications/Antidote.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "CapSee", path:"/Applications/CapSee.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Evernote", path:"/Applications/Evernote.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Google Chrome", path:"/Applications/Google Chrome.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Mate Translator ", path:"/Applications/Mate Translator.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Menubar Countdown", path:"/Applications/Menubar Countdown.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Messages", path:"/Applications/Messages.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Messenger", path:"/Applications/Messenger.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "RightZoom", path:"/Applications/RightZoom.app", hidden:true}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Todoist", path:"/Applications/Todoist.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "TweetDeck", path:"/Applications/TweetDeck.app", hidden:false}'


#Add apps in the Dock
dockutil --add /Applications/Google\ Chrome.app/ --allhomes
dockutil --add /Applications/Visual\ Studio\ Code.app/ --allhomes
dockutil --add /Applications/iTerm.app/ --allhomes
dockutil --add /Applications/Evernote.app/ --allhomes
dockutil --add /Applications/Todoist.app/ --allhomes
dockutil --add /Applications/Messenger.app/ --allhomes
dockutil --add /Applications/1Password\ 7.app/ --allhomes
dockutil --add /Applications/Pocket.app/ --allhomes
dockutil --add /Applications/Spotify.app/ --allhomes
dockutil --add /Applications/Antidote\ 9.app/ --allhomes
dockutil --add /Applications/TweetDeck.app/ --allhomes
dockutil --add /Applications/Slack.app/ --allhomes

#Order apps in Dock (list them in inversed order)
dockutil --move 'Antidote' --position beginning --allhomes
dockutil --move '1Password' --position beginning --allhomes
dockutil --move 'Messages' --position beginning --allhomes
dockutil --move 'Messenger' --position beginning --allhomes
dockutil --move 'TweetDeck' --position beginning --allhomes
dockutil --move 'Photos' --position beginning --allhomes
dockutil --move 'Pocket' --position beginning --allhomes
dockutil --move 'Visual Studio Code' --position beginning --allhomes
dockutil --move 'iTerm' --position beginning --allhomes
dockutil --move 'Spotify' --position beginning --allhomes
dockutil --move 'Slack' --position beginning --allhomes
dockutil --move 'Todoist' --position beginning --allhomes
dockutil --move 'Evernote' --position beginning --allhomes
dockutil --move 'Google Chrome' --position beginning --allhomes


###################
# TODO at the end #
###################

#Mackup
brew install mackup
mackup restore
#mackup -f backup


#################
# Manual TODO ###
#################

#Other apps
todo+="- Install Apps from the local folder"
todo+="\n"

todo+="\n"
todo+="(copied to keyboard)"
echo -e ${txtflash}$todo${txtblack}
echo -e $todo | pbcopy