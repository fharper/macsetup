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
ln -s ${HOME}/Pictures/ ${HOME}"/Dropbox (Personal)"
ln -s ${HOME}/Music/ ${HOME}"/Dropbox (Personal)"
ln -s ${HOME}/Movies/ ${HOME}"/Dropbox (Personal)"
ln -s ${HOME}/Downloads/ ${HOME}"/Dropbox (Personal)"
ln -s ${HOME}/Documents/ ${HOME}"/Dropbox (Personal)"

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

#Activate Silent clicking
defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 0

#Disable Guest Account
sudo defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool false
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool false

#Finder display settingsa
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
git config --global user.email fharper@fitbit.com
git config --global push.default current

#Deactivate the Chrome Printing Dialog
defaults write com.google.Chrome DisablePrintPreview -bool true

#Battery percentage
defaults write com.apple.menuextra.battery ShowPercent -bool true

#Setup clock format
defaults write com.apple.menuextra.clock "DateFormat" "EEE MMM d  h.mm a"

#Add extra system menuitems
defaults write com.apple.systemuiserver menuExtras -array \
"/System/Library/CoreServices/Menu Extras/Volume.menu" \
"/System/Library/CoreServices/Menu Extras/Bluetooth.menu"

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName "lapta"
sudo scutil --set HostName "lapta"
sudo scutil --set LocalHostName "lapta"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "lapta"

#Expand save panel
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

#Disable the Notification Center but doesn't remove the menubar icon anymore!
echo -e "\n"
read -p "${txtflash}Deactivate the System Integrity Protection first... " -n1 -s
echo -e "\n"
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist

#Search the current folder by default in Finder
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

#Deactivate Play user interface sound effects (not working)
#defaults write com.apple.systemsound "com.apple.sound.uiaudio.enabled" -boolean false
#defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -boolean false
todo+="- Deactivate Play user interface sound effects"
todo+="\n"

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

#Oh My ZSH!
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
chsh -s /bin/zsh

#Brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew analytics off
brew tap homebrew/completions
brew install bash-completion

#Brew Cask
brew tap caskroom/cask

#Mac App Store command line interface
brew install mas
mas signin fharper@oocz.net

#Install pip
curl https://bootstrap.pypa.io/get-pip.py > get-pip.py
sudo python get-pip.py
rm get-pip.py

#Xcode (before Antibody)
mas install 497799835

#Antibody
brew install getantibody/tap/antibody

#Git open
npm install --global git-open

#Git PR open
antibody bundle caarlos0/open-pr kind:path

#Hub (for Github)
brew install hub

#####################
# Install dev stuff #
#####################

#Generate a new public SSH key
ssh-keygen -t rsa -b 4096 -C "fharper@oocz.net"
ssh-add -K ~/.ssh/id_rsa
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
ssh-keyscan -t rsa source.fitbit.com >> ~/.ssh/known_hosts
ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts
pbcopy < ~/.ssh/id_rsa.pub
echo -e "\n"
read -p "${txtflash}Add SSH key to Github at https://github.com/settings/keys (copied in the clipboard)" -n1 -s
read -p "${txtflash}Add SSH key to Bitbucket at https://bitbucket.org/account/user/fharper/ssh-keys/ (copied in the clipboard)" -n1 -s
echo -e "\n"

#Node stuff
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash
nvm install 7
nvm use 7
npm install -g express-generator
npm install -g nodemon

#Python stuff
brew install pyenv
pyenv install 3.7.0
pyenv global 3.7.0

#Mysql Shell
brew cask install mysql-shell

#Android Studio, SDK and tools
#brew cask install android-studio
#open -a "Android Studio"
#/Users/fharper/Library/Android/sdk/tools/bin/sdkmanager "platforms;android-27"
#/Users/fharper/Library/Android/sdk/tools/bin/sdkmanager "build-tools;26.0.2"
#android update sdk -u -a -t 5 #Android SDK Tools, revision 25
#/Users/fharper/Library/Android/sdk/tools/bin/sdkmanager "ndk-bundle"

#UnCSS
npm install -g uncss


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

#NPM/YARN
brew install npm
brew install yarn

#Caffeine
brew cask install caffeine
open -a Caffeine

#1Password
brew cask install 1password
open ${HOME}/Dropbox/Documents/Programmes/OS\ X/1Password/1Password.onepassword-license

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

#HipChat
brew cask install hipchat
open -a HipChat


############################
# Install the applications #
############################

#Antidote
todo+="- Download & install Antidote (see the link in 1Password) "
todo+="\n"
open -a "Antidote 9"

#Appcleaner
brew cask install appcleaner
open -a AppCleaner

#Asciinema
brew install asciinema

#Battery Indicator
mas install 1206020918
open -a "Battery Indicator"

#Battle.net (Diablo II, World of Warcraft)
brew cask install battle-net
open -a /usr/local/Caskroom/battle-net/latest/Battle.net-Setup.app

#BetterTouchTool
brew cask install bettertouchtool
open -a BetterTouchTool

#Boxer
brew cask install boxer
open -a Boxer

#Brave browser
brew cask install brave
open -a Brave

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

#CopyClip
mas install 595191960
open -a CopyClip

#Cryptomator
brew cask install cryptomator
open -a Cryptomator

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
open -a "Duplicate Photo Fixer Pro"

#FileZilla
brew cask install filezilla
open -a FileZilla

#Firefox
brew cask install firefox
open -a Firefox

#Gimp
brew cask install gimp
open -a Gimp

#iMovie
mas install 408981434
open -a iMovie

#Inkscape
brew install caskformula/caskformula/inkscape
/usr/local/Cellar/inkscape/0.92.2_1/bin/inkscape

#Kaleidoscope
mas install 587512244
open -a Kaleidoscope

#Kaleidoscope KSDiff
brew cask install ksdiff

#Lightshot
mas install 526298438
open -a "Lightshot Screenshot"

#Luminar
mas install 1161679618
open -a Luminar

#LZip
brew install lzip

#MacDown
brew cask install macdown
open -a MacDown

#Mate Translator (previously Instant Translate)
mas install 1005088137
open -a "Mate Translator"

#Menubar Countdown
brew cask install menubar-countdown
open -a "Menubar Countdown"

#Messenger
brew cask install messenger
open -a Messenger

#Moom
mas install 419330170
open -a Moom

#MindNode
mas install 992076693
open -a MindNode

#Noizio
mas install 928871589
open -a Noizio

#OpenEmu
brew cask install openemu
open -a OpenEmu

#Opera
brew cask install opera
open -a Opera

#Parcel
mas install 639968404
open -a Parcel

#PDFSam Basic
brew cask install pdfsam-basic
open -a PDFSam

#Pocket
mas install 568494494
open -a Pocket

#Postman
brew cask install postman
open -a Postman

#Revisions for Dropbox
mas install 819348619
open -a Revisions

#Rightzoom (not the latest version, doesn't work on my OS)
#brew cask install rightzoom
#open -a RightZoom

#Slack
brew cask install slack
open -a Slack

#Spotify
brew cask install spotify
open -a Spotify

#Stars by Karelia
mas install 926319434
open -a Stars

#Steam
brew cask install steam
open -a Steam

#TeamViewer
brew cask install teamviewer

#The Clock
mas install 488764545
open -a "The Clock"
todo+="- Remove the System Clock from the menubar"
todo+="\n"

#Time Sink
mas install 404363161
open -a "Time Sink"

#TripMode
brew cask install tripmode
open -a TripMode

#TweetDeck
mas install 485812721
open -a TweetDeck

#Visual Studio Code
brew cask install visual-studio-code
open -a "Visual Studio Code"

#VLC
brew cask install vlc
open -a VLC

#WhatsApp
brew cask install whatsapp
open -a WhatsApp

#Zoom It
mas install 476272252
open -a "Zoom It"

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
osascript -e 'tell application "System Events" to make login item at end with properties {name: "BIG-IP Edge Client", path:"/Applications/BIG-IP Edge Client.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "CapSee", path:"/Applications/CapSee.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Discord", path:"/Applications/Discord.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Evernote", path:"/Applications/Evernote.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Google Chrome", path:"/Applications/Google Chrome.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "HipChat", path:"/Applications/HipChat.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Mate Translator ", path:"/Applications/Mate Translator.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Menubar Countdown", path:"/Applications/Menubar Countdown.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Messages", path:"/Applications/Messages.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Messenger", path:"/Applications/Messenger.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "RightZoom", path:"/Applications/RightZoom.app", hidden:true}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Slack", path:"/Applications/Slack.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Sublime Text", path:"/Applications/Sublime Text.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Todoist", path:"/Applications/Todoist.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {name: "TweetDeck", path:"/Applications/TweetDeck.app", hidden:false}'

###################
# TODO at the end #
###################

#Mackup
brew install mackup
mackup restore
#mackup backup -fbl


#################
# Manual TODO ###
#################
todo+="- Add picture to your account"
todo+="\n"

todo+="- Sign-in in iCloud"
todo+="\n"

#Other apps
todo+="- Install Apps from the local folder"
todo+="\n"

todo+="\n"
todo+="(copied to keyboard)"
echo -e ${txtflash}$todo${txtblack}
echo -e $todo | pbcopy
