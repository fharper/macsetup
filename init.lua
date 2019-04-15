--
-- Hammerspoon
--

-- Some applications have alternate names which can also be checked if you enable Spotlight support 
hs.application.enableSpotlightForNameSearches(true)

-- List of text shortcut (ala TextExpander)
local keywords = {
    -- Personal
    ["fredadd"] = "tbd", --will find a way to access the info and not put it in the script directly

    -- Dev stuff
    ["gitc"] = "git commit -m \"\"",
    ["gitd"] = "git difftool",
    ["gitr"] = "git reset --hard HEAD",
    ["gitl"] = "git log",
    ["gitp"] = "git push origin",
    ["gita"] = "git add ",
    ["gits"] = "git status",
    ["gitu"] = "git update-index --assume-unchanged ",
    ["gitt"] = "git tag -a v -m \"\"",

    -- Social media
    ["thxpost"] = "thanks for sharing my post in your network ",
    ["thxfol"] = "thanks for following me",
    ["fredlinkedin"] = "https://www.linkedin.com/in/fredericharper",
    ["fredfacebook"] = "https://www.facebook.com/fharper",
    ["fredtwitter"] = "https://twitter.com/fharper",
    ["fredslideshare"] = "https://www.slideshare.net/fredericharper",
    ["fredgoodread"] = "https://www.goodreads.com/fharper",

    -- Emoticons
    [":flipp"] = "(╯°□°)╯︵ ┻━┻",
    [":shrug"] = "¯\\_(ツ)_/¯",
    [":disapprove"] = "ಠ_ಠ",

    -- Email templates
}

local left = {
    ["gitc"] = 1,
    ["indeven"] = 140,
    ["indevfr"] = 160,
    ["inbcfr"] = 183,
    ["inbcen"] = 123,
    ["gitt"] = 1,
}

local selectText = {
    ["indeven"] = 3,
    ["indevfr"] = 3,
}

local typedText = ""

-- List of application I don't want to maximize
local ignoredWindows = {
    ["Finder"] = "1",
    ["Hammerspoon"] = "1",
    ["System Preferences"] = "1",
    ["Bartender"] = "1",
    ["Harvest"] = "1",
    ["Archive Utility"] = "1",
    ["Microsoft Outlook"] = "1",
    ["Save"] = "1",
}

-- List of applications I want on my left external monitor
local leftScreenWindows = {
    ["Todoist"] = "1",
    ["Evernote"] = "1",
    ["Spotify"] = "1",
}

-- Maximize all the apps!
local function applicationWatcher(appName, eventType, appObject)
    -- Some app doesn't have window when launched is used
    if (eventType == hs.application.watcher.launched) then

        -- Let's maximize the application
        if (not ignoredWindows[appName]) then
            -- Need to wait as some applications (like Messages and Sublime Text) doesn't load their windows fast enough I guess
            hs.timer.doAfter(0.4, function ()
                hs.application.get(appName):focusedWindow():maximize(0)
                if (hs.screen.allScreens()[2] and leftScreenWindows[appName]) then
                    hs.application.get(appName):focusedWindow():moveOneScreenWest(0)
                end
            end)
        end
    end
end

local appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

-- Managing the displays changes
local function screenWatcher()
    windows = hs.window.allWindows()

    for i, window in ipairs(windows) do
        appName = window:application():name()

        -- Let's maximize all the apps (Macbook <=> external displays)
        if (ignoredWindows[appName] == nil) then
            window:maximize()
        end

        -- If I have more than one screen, let's move some apps to the left display
        if (hs.screen.allScreens()[2] and leftScreenWindows[appName]) then
            window:moveOneScreenWest(0)
        end
    end
end

local screenWatcher = hs.screen.watcher.new(screenWatcher)
screenWatcher:start()

-- Because hs.eventtap.keyStroke is slow as hell
keyStroke = function(modifiers, character)
  local event = require("hs.eventtap").event
  event.newKeyEvent(modifiers, string.lower(character), true):post()
  event.newKeyEvent(modifiers, string.lower(character), false):post()
end

-- Managing text shortcuts
local function keyWatcher(event)
    char = event:getCharacters()

    -- These character will fuck the find function
    if (char ~= "(" and char ~= ")" and char ~= "[" and char ~= "]" and char ~= "%") then
        typedText = typedText .. char

        foundStartWith = nil
        for word, replacement in pairs(keywords) do
            if(string.find(word, "^" .. typedText)) then
                if (word == typedText) then
                    keyWatcher:stop()

                    -- Let's erase the shortcut
                    for j = 1, string.len(word) do
                        keyStroke({}, 'delete')
                    end

                    -- Let's write the full replacement
                    hs.eventtap.keyStrokes(replacement)

                    -- Let's see if we need to move the cursor inside the replacement
                    if (left[word]) then
                        for j = 1, left[word] do
                            keyStroke({}, 'left')
                        end
                    end

                    -- Let's see if we need to select some text
                    if (selectText[word]) then
                        for j = 1, selectText[word] do
                            keyStroke({"shift"}, 'left')
                        end
                    end

                    typedText = ""
                    keyWatcher:start()
                else
                    foundStartWith = "1"
                end
            end
        end

        if (not foundStartWith) then
            typedText = ""
        end
    end
end

keyWatcher = hs.eventtap.new({hs.eventtap.event.types.keyUp}, keyWatcher)
keyWatcher:start()

-- Some windows management
local function moveScreen()
    local actualWindow = hs.window.focusedWindow()

    -- For whatever reason, previous and next doesn't work correctly for me
    if (actualWindow:screen() == hs.screen.allScreens()[1]) then
        actualWindow:moveToScreen(hs.screen.allScreens()[2])
    else
        actualWindow:moveToScreen(hs.screen.allScreens()[1])
    end
end

hs.hotkey.bind({"cmd"}, "up", function() hs.window.focusedWindow():maximize() end)
hs.hotkey.bind({"cmd"}, "down", function() hs.window.focusedWindow():minimize() hs.window.visibleWindows()[1]:focus() end)
hs.hotkey.bind({"cmd"}, "left", moveScreen)
hs.hotkey.bind({"cmd"}, "right", moveScreen)