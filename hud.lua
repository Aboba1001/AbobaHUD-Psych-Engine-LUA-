---------------------------------------------------------------------------------------------------------

-- Variables
-- You might not want to touch these unless you know what you're doing
local optionsTable = {}
local curSelected = 1
local Options = {
    "Return to Game", "Restart Song",
    "Change Difficulty", "Options",
    "Exit to Menu"
}
local callbacks = {
    [1] = function() closeCustomSubstate(); end,
    [2] = function() restartSong(); end,
    [3] = function() debugPrint("Not yet lil blud.") end,
    [4] = function() 
        addHaxeLibrary("flixel.FlxG")
        runHaxeCode('FlxG.switchState(new states.options.OptionsState());')
    end,
    [5] = function() exitSong(); end
}
local keybinds = {'note_left','note_down','note_up','note_right'}
local sicks, goods, bads, shits = getProperty('sicks'), getProperty('goods'), getProperty('bads'), getProperty('bads')
local combo = getProperty('combo')

-- Customization --
-- Triggers: 'true' - Enable / 'false' - Disable

local div = '^' -- Change scoreTxt dividers! Example: 'Score: 0 ^ Misses: 0 ^ Rating: ?'
local laneUnderlayAlpha = 0.4 -- Set this to 0 to disable it (Default : 0.4)
local customBotplayTxt = "" -- Leave this empty if you want to keep the default botplay text.
local randomBotplayTexts = {'CPUPLAY','AUTOPLAY',''} -- Keep expanding the list as much as you want!
local randomBotplayTxt = false -- Set this to 'true' if you want randomized botplay texts!
local judgmentBar = true -- Displays detailed info on the left side on your screen! (Default : true)
local hudTransparency = 0.9 -- Controls whole HUD transparency! (Default : 0.9)
local customTimeBG = true -- Set this to 'true' if you want custom timeBar BG! (Default : true)
local displayMsTxt = true -- Displays how early/late you press note in milliseconds! Simmiliar to Kade Engine (Default : true)
local verticalHPbar = false -- Displays HP bar in vertical! (Default : false)
local resultsScreen = true -- Shows detailed stats of how you performed at the end of song/week! (Default : true)
local scoreTxtStyle = 'Default' -- This controls scoreTxt style! Available styles: Default, Kade, Forever, Leather, Vanilla (Default: 'Default')
local iconBopStyle = '' -- This controls icon bop style! Available: Kade, Vanilla, Static (Default : Empty!)
local watermark = true -- Displays watermark like the one from Kade Engine! (Default : true)
local comboCounter = true -- (Default : true)
local customDiscordRPC = true -- (Default : true)
local customWindowTitle = true -- (Default : true)


-----------------------------------------------------------------------------------------------

function onCreate()
    makeLuaText("fakeTimeTxt", "- " ..songName.. " / (" ..string.upper(difficultyName).. ") -", screenWidth, 0, 25)
    setTextSize("fakeTimeTxt", 23)
    setObjectCamera("fakeTimeTxt", "hud")
    setTextBorder("fakeTimeTxt", 1, "black", "outline")
    setTextAlignment("fakeTimeTxt", "center")
    screenCenter("fakeTimeTxt", "x")
    addLuaText("fakeTimeTxt", true)

    makeLuaText("songTime", "00:00", screenWidth, 0, 0)
    setProperty("songTime.y", getProperty("fakeTimeTxt.y") + 25)
    setTextSize("songTime", 23)
    setObjectCamera("songTime", "hud")
    setTextBorder("songTime", 1, "black", "outline")
    setTextAlignment("songTime", "center")
    screenCenter("songTime", "x")
    addLuaText("songTime", true)

    if watermark then
        if not isStoryMode then
            makeLuaText('watermarkLOL', songName .. ' - ' .. difficultyName .. ' | v' .. version, screenWidth, 0, screenHeight / 2 + 340)
            setObjectCamera('watermarkLOL', 'hud')
            setTextAlignment('watermarkLOL', 'left')
        else
            makeLuaText('watermarkLOL', '(STORY MODE) ' .. songName .. ' - ' .. difficultyName .. ' | v' .. version, screenWidth, 0, screenHeight / 2 + 340)
            setObjectCamera('watermarkLOL', 'hud')
            setTextAlignment('watermarkLOL', 'left')
        end
        addLuaText('watermarkLOL', true)
    end

    if judgmentBar then
        makeLuaText("judgmentText", '', screenWidth, 0, screenHeight / 2 - 100)
        setObjectCamera("judgmentText", "hud")
        setTextAlignment("judgmentText", 'left')
        addLuaText("judgmentText", true)

        makeLuaSprite('judgmentBG', nil, screenWidth, 0, screenHeight / 2 - 100)
        makeGraphic('judgmentBG', 20, 300, '000000')
        setObjectCamera('judgmentBG', 'hud')
        setProperty('judgmentBG.alpha', 0.5)
        addLuaSprite('judgmentBG')
    end

    if customTimeBG then
        makeLuaSprite('newTimeBG', nil, screenWidth, 0, 0)
        makeGraphic('newTimeBG', 500, 300, '000000')
        setObjectCamera('newTimeBG', 'hud')
        setProperty('newTimeBG.alpha', 0.5)
        addLuaSprite('newTimeBG')
    end
end

function onCreatePost()
    setProperty("timeTxt.visible", false)
    setProperty("timeBar.visible", false)

    if (hudTransparency >= 0) then
        setProperty('camHUD.alpha', hudTransparency)
    end

    if (customBotplayTxt ~= string.find(customBotplayTxt, '')) then
        setTextString('botplayTxt', customBotplayTxt)
    end

    if (randomBotplayTxt) then
        setTextString('botplayTxt', randomBotplayTexts[math.random(1, #randomBotplayTexts)])
    end

    debugPrint(getKeybind('note_left'))

    for i = 0, 3 do
        -- Creating Notes Underlay For Player!
        makeLuaSprite("noteUnderlay_"..i, nil, getPropertyFromGroup('playerStrums', i, 'x'), getPropertyFromGroup('playerStrums', i, 'y'))
        makeGraphic("noteUnderlay_"..i, getPropertyFromGroup('playerStrums', i, 'width'), 1000, '000000')
        setObjectCamera("noteUnderlay_"..i, "camHUD")
        setProperty("noteUnderlay_"..i..".alpha", 0.7)
        addLuaSprite("noteUnderlay_"..i)
        debugPrint('created '.. i .. ' for player!')
        
        -- Creating Notes Underlay For Player!
        makeLuaSprite("opponentNoteUnderlay_"..i, nil, getPropertyFromGroup('opponentStrums', i, 'x'), getPropertyFromGroup('opponentStrums', i, 'y'))
        makeGraphic("opponentNoteUnderlay_"..i, getPropertyFromGroup('opponentStrums', i, 'width'), 1000, '000000')
        setObjectCamera("opponentNoteUnderlay_"..i, "camHUD")
        setProperty("opponentNoteUnderlay_"..i..".alpha", 0.7)
        addLuaSprite("opponentNoteUnderlay_"..i)
        debugPrint('created '.. i .. ' for opponent!')

        -- Creating Notes Keybind Hint!
        makeLuaText("keybindHint_"..i, keybinds[i], getPropertyFromGroup('playerStrums', i, 'x'), 0, getPropertyFromGroup('playerStrums', i, 'y'))
        setObjectCamera("keybindHint_"..i, "camHUD")
        setTextSize("keybindHint_"..i, 25)
        addLuaText("keybindHint_"..i, true)
    end
end

function onUpdate(elapsed)
    local newTimeCounter = milliToHuman(songLength - (getPropertyFromClass('backend.Conductor', 'songPosition') - noteOffset))
    local newScoreTxt = "Score: " ..score..
    " " ..div.. " Misses: " ..misses..
    " " ..div.. " HP: " ..getProperty("health")*50 .. "%" ..
    " " ..div.. " ACC: " ..math.floor(rating*100).. "% (" .. ratingFC.. ")" 
    local newJudgmentTxt = string.format(
        '> Hits: %d\n> Sicks: %d\n> Goods: %d\n> Bads: %d\n> Shits: %d', 
        math.floor(tonumber(hits) or 0),
        math.floor(tonumber(sicks) or 0),
        math.floor(tonumber(goods) or 0),
        math.floor(tonumber(bads) or 0),
        math.floor(tonumber(shits) or 0)
    )

    setTextString("songTime", newTimeCounter)
    setTextString("scoreTxt", newScoreTxt)
    setTextString("judgmentText", newJudgmentTxt)
end

function onPause()
    openCustomSubstate("Pause", true)
    return Function_Stop
end

function getKeybind(what)
    local bind = getPropertyFromClass('ClientPrefs', 'keyBinds')[what]
    if bind ~= nil then
        local key = bind[1] or bind
        local map = getPropertyFromClass('flixel.input.keyboard.FlxKey', 'toStringMap')
        if map ~= nil and key ~= nil then
            return tostring(map[key] or key)
        end
        return tostring(key)
    end
    return '?'
end

function milliToHuman(milliseconds) -- https://stackoverflow.com/questions/18313171/lua-rounding-numbers-and-then-truncate
    local totalseconds = math.floor(milliseconds / 1000)
    local seconds = totalseconds % 60
    local minutes = math.floor(totalseconds / 60)
    minutes = minutes % 60
    return string.format("%02d:%02d", minutes, seconds)
end

function onCustomSubstateCreate(name)
    if name == "Pause" then
        curSelected = 1
        optionsTable = {}

        makeLuaSprite("bg", nil, 0, 0)
        makeGraphic("bg", screenWidth, screenHeight, "000000")
        setObjectCamera("bg", "other")
        setProperty("bg.alpha", 0)
        addLuaSprite("bg", false)

        for i = 1, #Options do 
            local name = "optionButton"..i
            makeLuaText(name, Options[i], 0, -600, 0 + (i * 105))
            setTextSize(name, 50)
            setObjectCamera(name, "other")
            setProperty(name..".alpha", 0)
            addLuaText(name, true)
            table.insert(optionsTable, name)
        end
        tweenPause(1)
        highlightOptions()
    end
end

function onCustomSubstateUpdate(name, elapsed)
    if name == "Pause" then
        if keyJustPressed("ui_up") then
            playSound("scrollMenu", 1)
            changeItem(-1)
        end
        if keyJustPressed("ui_down") then
            playSound("scrollMenu", 1)
            changeItem(1)
        end

        if keyJustPressed("accept") then
            playSound("confirmMenu")
            callbacks[curSelected]();
        end else if keyJustPressed("back") or keyJustPressed('escape') then
            playSound("confirmMenu")
            closeCustomSubstate()
        end
        highlightOptions()
    end
end

function onCustomSubstateDestroy(name)
    if name == "Pause" then
        removeLuaSprite("bg")
        for i = 1, #optionsTable do
            removeLuaText(optionsTable[i], true)
        end
        optionsTable = {}
    end
end

function changeItem(huh)
    curSelected = curSelected + huh
    
    if (curSelected < 1) then 
        curSelected = #Options 
    end
    if (curSelected > #Options) then 
        curSelected = 1 
    end
end

function highlightOptions()
    for i = 1, #optionsTable do
        if i == curOption then
            setTextColor(optionsTable[i], "fff000")
            setTextSize(optionsTable[i], 51)
            setProperty(optionsTable[i]..".alpha", 1)
        else
            setTextColor(optionsTable[i], "ffffff")
            setTextSize(optionsTable[i],50)
            setProperty(optionsTable[i]..".alpha", 0.7)
        end
    end
end

function tweenPause(cool)
    if cool == 1 then
        for i = 1, #optionsTable do
            doTweenAlpha("optionTweenAlpha"..i, optionsTable[i], 1, 0.5, "linear")
            doTweenX("optionTweenX"..i, optionsTable[i], 400, 0.5, "quadIn")
        end
        doTweenAlpha("bgTweenAlpha", "bg", 0.7, 0.4," linear")
    elseif cool == 2 then
        for i = 1, #optionsTable do
            doTweenAlpha("optionTweenAlpha"..i, optionsTable[i], 0, 0.5, "linear")
            doTweenX("optionTweenX"..i, optionsTable[i], -600, 0.5, "quadOut")
        end
    end
end

function onTimerCompleted(tag, loops, loopsLeft)

end

function onTweenCompleted(tag)

end