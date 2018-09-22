# macsetup

A shell script I use to setup my mac.

Feel free to suggest other great tools!

## Table of contents
* [Getting started](#getting-started)
* [Features](#features)

## Getting started

Clone this repo to your mac.
```git clone git@github.com:fharper/macsetup.git```

Once cloned, you will need to give execute permission to the script. Replace the path with where you cloned the repository.
```chmod +x /path/to/script/macsetup.sh```

Now, you can run the script.
```/path/to/script/macsetup.sh```

If you are already in the repository directory, you can run simplify the command like this:
```./macsetup.sh```

## Features
This script will make configuration changes to:
* MacOS preferences
* Development tools (installation)
* Development environment (SSH, etc)
* Install apps
* Default file type association

### OS configuration changes
#### Enable features
* Minimize window into application icon
* Show the Library folder
* Allow apps from anywhere to be installed without warning
* Activate silent clicking
* Show all hidden files in Finder
* New Finder windows in my Downloads folder
* Show all file extensions
* Show battery percentage
* Add system menu items for volume and Bluetooth
* Expand save panel

#### Disable features
* Disable the accent characters menu
* Disable the look up & data detector on Trackpad
* Disable Mission Control and Exposé Gestures on Trackpad
* Disable Show Notification Center on Trackpad
* Disable Launchpad and Show Desktop Gestures on Trackpad
* Disable Guest Account
* Prevent .DS_Store file creation on network volumes
* Disable feedback on volume change
* Deactivate the Chrome printing dialog
* Disable the Notifications Center but don't remove the menubar icon
* (TODO) Deactivate Play user interface sound effects

#### Create/Change
* Generate the locate database
* Create symlinks between system folders and Dropbox
* Finder display settings
* Git configuration
* Change clock format
* Set computer name
* Search the current folder by default in Finder

### First-time dev environment setup
#### Install
* iTerm (terminal replacement)
* Homebrew
* Homebrew Cask
* Mac App Store CLI
* Pip (python package manager)
* Bundler (ruby gems manager)
* Xcode
* Antibody (shell plugin manager)
* git-open (CLI utility)
* open-pr (CLI utility)
* hub  (CLI utility)
* Node 7.X
* npm & yarn
* Caffeine
* Python 3.7.0
* MySQL-shell
* UnCSS
* (TODO) Android Studio SDK & tools

#### Create
* Public SSH key

### More installations
#### Browsers
* Chrome
* Brave browser
* Firefox
* Opera

#### Browser replacement utilities
* Parcel
* Pocket
* TweetDeck

#### Video games
* Battle.net
* Steam
* Boxer
* OpenEmu

#### Chat
* Slack
* Whatsapp
* Messenger
* Discord
* Signal

#### Music
* Spotify
* Stars by Karelia
* Noizio

#### Writing & notes
* Todoist
* Evernote
* MacDown
* MindNode

#### File management
* Dropbox
* Revisions for Dropbox
* Cryptomator
* FileZilla
* LZip
* PDFSam Basic
* Calibre
* The Unarchiver

#### Media creation & editing
* Camtasia
* Gimp
* iMovie
* Lightshot
* Luminar
* Kaleidoscope
* Inkscape
* Asciinema
* Duplicate Photo Fixer Pro

#### Dev tools
* Visual studio code
* Postman
* Teamviewer

#### Menubar utilities
* Bartender
* Menubar Countdown
* Battery Indicator
* Moom
* The Clock

#### Touchbar utilities
* BetterTouchTool

#### Other utilities
* 1Password
* Alfred 3
* TripMode
* Hammerspoon
* Appcleaner
* CopyClip
* DaisyDisk
* Mate Translator
* Time Sink
* Rightzoom
* Zoom it
* YubiKey Personalization Tool
* Larch