-- Credits --
-- Script by Aboba10102
-- YouTube: https://youtube.com/@RoboaToba/
-- GameBanana: https://gamebanana.com/@Aboba19/

-- NPS logic by beihu

------------------------------------------------------------------------

-- Variables
-- You might not want to touch these unless you know what you're doing
local optionsTable = {}
local curSelected = 1
local Options = {"Return to Game","Restart Song","Change Difficulty","Options","Exit to Menu"}
local callbacks = {
    [1] = function() closeCustomSubstate(); end,
    [2] = function() restartSong(); end,
    [3] = function() debugPrint("Not yet lil blud.") end,
    [4] = function() addHaxeLibrary("flixel.FlxG")
        runHaxeCode('FlxG.switchState(new states.options.OptionsState());')
    end,
    [5] = function() exitSong(); end,
}

local difficulties = {'Easy','Normal','Hard','Erect','Nightmare'}

local keybinds = {'note_left','note_down','note_up','note_right'}
local allowInput = true
local isPixel = false
local nps = 0
local maxNPS = 0
local reduce = true
local kps = 0
local maxScore = 0
local totalNotes = 0


-- Customization --
-- Triggers: 'true' - Enable / 'false' - Disable

local div = '^' -- Change scoreTxt dividers! Example: 'Score: 0 ^ Misses: 0 ^ Rating: ?'
local laneUnderlayAlpha = 0.8 -- Set this to 0 to disable it (Default : 0.8)
local customBotplayTxt = "" -- Leave this empty if you want to keep the default botplay text.
local randomBotplayTexts = {'CPUPLAY','AUTOPLAY',''} -- Keep expanding the list as much as you want!
local randomBotplayTxt = false -- Set this to 'true' if you want randomized botplay texts!
local judgmentBar = true -- Displays detailed info on the left side on your screen! (Default : true)
local hudTransparency = 1 -- Controls the whole HUD camera transparency! (Default : 0.9)
local customTimeBG = true -- Set this to 'true' if you want custom timeBar BG! (Default : true)
local displayMsTxt = true -- Displays how early/late you press note in milliseconds! Simmiliar to Kade Engine (Default : true)
local verticalHPbar = false -- Displays HP bar in vertical! (Default : false)
local verticalHPalignment = 'Right' -- Controls whether if you want to move vertical HP to either left or right side. (Default : 'Right')
local resultsScreen = true -- Shows detailed stats of how you performed at the end of song/week! (Default : true)
local scoreTxtStyle = 'Kade' -- This controls scoreTxt style! Available styles: Default, Kade, Forever, Leather, Vanilla (Default: 'Default')
local iconBopStyle = '' -- This controls icon bop style! Available: Kade, Vanilla, Static (Default : Empty!)
local watermark = true -- Displays watermark like the one from Kade Engine! (Default : true)
local comboCounter = true -- Displays your combo! (Default : true)
local customDiscordRPC = true -- Set this to 'true' if you want to have custom Discord RPC! (Default : true)
local customWindowTitle = true -- Set this to 'true' if you want to have custom window title! (Default : true)
local windowTitleText = '' -- This allows you to change game window title! Leave it empty if you don't want to use it or want to keep the custom window title! (Default : '')
local keybindsHint = true -- Displays your note keybinds! (Default : true)
local opponentNoteGlow = true -- Set this to 'false' if you want to achieve that opponent note effect from OG FNF! (Default : true)
local oldHPBarColors = false -- Set this to 'true' to bring back red and green health bar colors! (Default : false)


-----------------------------------------------------------------------------------------------

function initializePostOptions()
    if hudTransparency < 1 then
        setProperty('camHUD.alpha', hudTransparency)
    end
    if customBotplayTxt ~= '' then
        setTextString('botplayTxt', customBotplayTxt)
        debugPrint('customBotplayTxt is running!')
    end
    if (randomBotplayTxt == true) then
        setTextString('botplayTxt', randomBotplayTexts[math.random(1, #randomBotplayTexts)])
    end
    if oldHPBarColors then
        setHealthBarColors('FF0000', '66FF33')
    end
    if verticalHPbar then
        setProperty('healthBar.angle', 90)
        setProperty('healthBar.x', screenWidth / 2 + 260)
        setProperty('healthBar.y', screenHeight / 2)
    end

    --debugPrint(getKeybind('note_left'))

    for i = 0, 3 do
        if laneUnderlayAlpha > 0 then
            -- Creating Notes Underlay For Player!
            makeLuaSprite("noteUnderlay_"..i, nil, getPropertyFromGroup('playerStrums', i, 'x'), screenHeight / getPropertyFromGroup('playerStrums', i, 'y'))
            makeGraphic("noteUnderlay_"..i, getPropertyFromGroup('playerStrums', i, 'width'), screenHeight, '000000')
            setObjectCamera("noteUnderlay_"..i, "camHUD")
            setProperty("noteUnderlay_"..i..".alpha", 0)
            addLuaSprite("noteUnderlay_"..i)
            --debugPrint('Created Note Underlay '.. i .. ' For Player!')
            
            -- Creating Notes Underlay For Player!
            makeLuaSprite("opponentNoteUnderlay_"..i, nil, getPropertyFromGroup('opponentStrums', i, 'x'), screenHeight / getPropertyFromGroup('opponentStrums', i, 'y'))
            makeGraphic("opponentNoteUnderlay_"..i, getPropertyFromGroup('opponentStrums', i, 'width'), screenHeight, '000000')
            setObjectCamera("opponentNoteUnderlay_"..i, "camHUD")
            setProperty("opponentNoteUnderlay_"..i..".alpha", 0)
            addLuaSprite("opponentNoteUnderlay_"..i)
            --debugPrint('Created Note Underlay '.. i .. ' For Opponent!')

            doTweenAlpha('bfUnderlayAlpha_' .. i, 'noteUnderlay_' .. i, laneUnderlayAlpha, 0.6, 'linear')
            doTweenAlpha('dadUnderlayAlpha_' .. i, 'opponentNoteUnderlay_' .. i, laneUnderlayAlpha, 0.6, 'linear')
        end

        if keybindsHint then 
            -- Creating Notes Keybind Hint!
            makeLuaText("keybindHint_"..i, keybinds[i], getPropertyFromGroup('playerStrums', i, 'x'), 0, getPropertyFromGroup('playerStrums', i, 'y'))
            setObjectCamera("keybindHint_"..i, "camHUD")
            setTextSize("keybindHint_"..i, 25)
            setProperty("keybindHint_" .. i .. '.alpha', 0)
            addLuaText("keybindHint_"..i, true)

            doTweenAlpha('keybindAlpha_' .. i, 'keybindHint_' .. i, 1, 0.8, 'linear')
        end
    end
end

function onCreate()

    makeLuaText("fakeTimeTxt", "- " ..songName.. " / (" ..string.upper(difficultyName).. ") -", screenWidth / 2, 0, screenHeight / 2 - 340)
    setTextSize("fakeTimeTxt", 23)
    setObjectCamera("fakeTimeTxt", "hud")
    setTextBorder("fakeTimeTxt", 1, "black", "outline")
    setTextAlignment("fakeTimeTxt", "center")
    screenCenter("fakeTimeTxt", "x")
    addLuaText("fakeTimeTxt", true)

    makeLuaText("songTime", "00:00", screenWidth, 0, getProperty("fakeTimeTxt.y") + 30)
    setTextSize("songTime", 23)
    setObjectCamera("songTime", "hud")
    setTextBorder("songTime", 1, "black", "outline")
    setTextAlignment("songTime", "center")
    screenCenter("songTime", "x")
    addLuaText("songTime", true)

    setProperty("fakeTimeTxt.alpha", 0)  
    setProperty("songTime.alpha", 0)

    if watermark then
        makeLuaText('watermarkLOL', songName .. ' - ' .. difficultyName .. ' | v' .. version, screenWidth, 0, screenHeight / 2 + 340)
        setObjectCamera('watermarkLOL', 'hud')
        setTextAlignment('watermarkLOL', 'left')
        addLuaText('watermarkLOL', true)
        if isStoryMode then
        setTextString('watermarkLOL', '(STORY MODE) ' .. getTextString('watermarkLOL'))
        end
    end

    if judgmentBar then
        makeLuaText("judgmentText", '', screenWidth, 0, screenHeight / 2 - 100)
        setObjectCamera("judgmentText", "hud")
        setTextAlignment("judgmentText", 'left')
        addLuaText("judgmentText", true)
    end

    if customTimeBG then
        makeLuaSprite('newTimeBar', nil, screenWidth / 2, screenHeight / 2 - 320)
        makeGraphic('newTimeBar', 400, 25, '000000')
        setObjectCamera('newTimeBar', 'hud')
        screenCenter("newTimeBar", "x")

        makeLuaSprite('newTimeBarBG', nil, getProperty('newTimeBar.x'), getProperty('newTimeBar.y'))
        makeGraphic('newTimeBarBG', 398, 23, '66ff33')
        setObjectCamera('newTimeBarBG', 'hud')
        
        addLuaSprite('newTimeBar')
        addLuaSprite('newTimeBarBG')
    end

    if downscroll then
        setProperty('fakeTimeTxt.y', screenHeight / 2 + 275)
        setProperty('songTime.y', getProperty("fakeTimeTxt.y") + 30)
    end
end

function onCreatePost()
    setProperty("timeTxt.visible", false)
    setProperty("timeBar.visible", false)
    initializePostOptions();

    for i = 0, getProperty('unspawnNotes.length') - 1 do
        if getPropertyFromGroup('unspawnNotes', i, 'mustPress') and not getPropertyFromGroup('unspawnNotes', i, 'isSustainNote') then
            totalNotes = totalNotes + 1
        end
    end
    if getPropertyFromClass('PlayState', 'isPixelStage') then 
		isPixel = true
	end
end

function goodNoteHit(a,b,c,isSustainNote)
    if not isSustainNote then
        nps = nps +1
    end
end

function onEvent(n)
    if n == 'Change Character' and oldHPBarColors then
        setHealthBarColors('FF0000', '66FF33')
    end
end

function onUpdate(elapsed)
    local combo = getProperty('combo')
    local health = round(getProperty("health") * 50, 2)
    local acc = round(rating*100,2)
    local notesPercent = (hits / totalNotes) * 100

    local newTimeCounter = milliToHuman(songLength - (getPropertyFromClass('backend.Conductor', 'songPosition') - noteOffset))
    local newScoreTxt
    local newJudgmentTxt = string.format(
        '> NPS: %d (Max: %d)\n> Note Hits: %d / %d (%.2f%%)\n> Combo: %d\n> Sicks: %d\n> Goods: %d\n> Bads: %d\n> Shits: %d', 
        nps,
        maxNPS,
        math.floor(tonumber(hits) or 0),
        totalNotes,
        notesPercent,
        combo,
        math.floor(tonumber(getProperty('sicks')) or 0),
        math.floor(tonumber(goods) or 0),
        math.floor(tonumber(bads) or 0),
        math.floor(tonumber(shits) or 0)
    )

    if scoreTxtStyle == "Default" then
        newScoreTxt = "Score: " ..score..
        " " ..div.. " Misses: " ..misses..
        " " ..div.. " HP: " .. health .. "%" ..
        " " ..div.. " ACC: " .. acc .. "% (" .. ratingFC.. ")"
    elseif scoreTxtStyle == "Kade" then
        --newScoreTxt = "Score: " .. score .. " | Combo Breaks: " .. misses .. " Accuracy: " .. acc .. "% - " .. ratingFC
        newScoreTxt = string.format('Score: %d | Combo Breaks: %d | Accuracy: %.2f%% - %s', score, misses, acc, ratingFC)
    end

    setTextString("songTime", newTimeCounter)
    setTextString("scoreTxt", newScoreTxt)
    setTextString("judgmentText", newJudgmentTxt)

    if nps > 0 and reduce == true then
        reduce = false
        runTimer('reduce nps', 1/nps , 1)
    end
    if nps ==0 then
        reduce = true
    end
    if nps > maxNPS then
        maxNPS = nps
    end
end

function onPause()
    openCustomSubstate("Pause", true)
    return Function_Stop
end

function onSongStart()
    setProperty('fakeTimeTxt.alpha', 1)
    setProperty('songTime.alpha', 1)
end

function onEndSong()
    openCustomSubstate("Results", true)
    return Function_Stop;
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

function round(x, n) --https://stackoverflow.com/questions/18313171/lua-rounding-numbers-and-then-truncate
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

function onCustomSubstateCreate(name)
    if name == "Pause" then
        curSelected = 1
        optionsTable = {}
        setPropertyFromClass('flixel.FlxG', 'mouse.visible', true)
        playSound('freeplayRandom', 1)
        runTimer('pauseSong', 20)

        makeLuaText('arrow', '>', screenWidth / 2 - 650, 0)
        setTextSize('arrow', 60)
        setObjectCamera('arrow', 'hud')

        makeLuaSprite("bg", nil, 0, 0)
        makeGraphic("bg", screenWidth, screenHeight, "000000")
        setObjectCamera("bg", "other")

        makeLuaText('title', 'Paused!', screenWidth / 2 + 1600, 0, screenHeight / 2 - 200)
        setTextSize('title', 60)
        setObjectCamera('title', 'other')

        makeLuaText('songInfo', songName .. ' - ' .. difficultyName:upper(), screenWidth / 2 + 625, 0, screenHeight / 2 - 340)
        setTextSize('songInfo', 25)
        setTextAlignment('songInfo', 'right')
        setObjectCamera('songInfo', 'other')

        makeLuaText('attempts', 'Deaths: 0', screenWidth / 2 + 625, 0, getProperty('songInfo.y') + 20)
        setTextSize('attempts', 25)
        setTextAlignment('attempts', 'right')
        setObjectCamera('attempts', 'other')

        if botplay then
            makeLuaText('botplay', 'BOTPLAY', screenWidth / 2 + 625, 0, getProperty('attempts.y') + 20)
            setTextSize('botplay', 25)
            setTextAlignment('botplay', 'right')
            setObjectCamera('botplay', 'other')
            addLuaText('botplay', true)
            doTweenAlpha('botplayTween', 'botplay', 1, 0.6, 'linear')
        end

        setProperty("bg.alpha", 0)
        setProperty('title.alpha', 0)
        setProperty('songInfo.alpha', 0)
        setProperty('attempts.alpha', 0)
        setProperty('arrow.alpha', 0)

        doTweenAlpha("bgTween", "bg", 0.7, 0.4," linear")
        doTweenAlpha('titleTween', 'title', 1, 0.6, 'linear')
        doTweenAlpha('songInfoTween', 'songInfo', 1, 0.6, 'linear')
        doTweenAlpha('attemptsTween', 'attempts', 1, 0.6, 'linear')
        doTweenAlpha('arrowTween', 'arrow', 1, 1, 'linear')

        addLuaText('arrow', true)
        addLuaSprite("bg", false)
        addLuaText('title', true)
        addLuaText('songInfo', true)
        addLuaText('attempts', true)

        for i = 1, #Options do 
            local optionName = "optionButton" .. i
            makeLuaText(optionName, Options[i], 0, screenWidth / 2 - 680, 0 + (i * 75))
            setTextSize(optionName, 50)
            setObjectCamera(optionName, "other")
            setProperty(optionName .. ".alpha", 0)
            addLuaText(optionName, true)
            table.insert(optionsTable, optionName)
        end
        tweenPause(1)
        highlightOptions()
    end

    if name == 'Results' then
        setPropertyFromClass('flixel.FlxG', 'mouse.visible', true)

        makeLuaSprite("bg", nil, 0, 0)
        makeGraphic("bg", screenWidth, screenHeight, "000000")
        setObjectCamera("bg", "other")

        makeLuaText('title', '- Results! -', screenWidth, 0, screenHeight / 2 - 455)
        setTextSize('title', 60)
        setObjectCamera('title', 'other')
        screenCenter('title', 'x')

        makeLuaText('judgmentTitle', string.upper(songName) .. ' [' .. string.upper(difficultyName) .. ']', screenWidth / 2 - 100, 0, screenHeight / 2 - 235)
        setTextSize('judgmentTitle', 40)
        setObjectCamera('judgmentTitle', 'other')

        makeLuaText('actualthing', '', screenWidth / 2 - 100, 0, getProperty('judgmentTitle.y') + 40)
        setTextSize('actualthing', 25)
        setObjectCamera('actualthing', 'other')

        makeLuaText('controlsHint', '! Press ACCEPT to continue !', getProperty('judgmentTitle.x'), 0, screenHeight / 2 + 300)
        setTextSize('controlsHint', 35)
        setObjectCamera('controlsHint', 'other')
        screenCenter('controlsHint', 'x')

        addLuaSprite("bg", false)
        addLuaText('title', true)
        addLuaText('judgmentTitle', true)
        addLuaText('actualthing', true)
        addLuaText('controlsHint', true)

        setProperty("bg.alpha", 0)
        setProperty('judgmentTitle.alpha', 0)
        setProperty('actualthing.alpha', 0)
        setProperty('controlsHint.alpha', 0)

        doTweenAlpha('bgTween', 'bg', 0.8, 1, 'linear')
        doTweenAlpha('judgTween', 'judgmentTitle', 1, 0.4, 'linear')
        doTweenAlpha('statsTween', 'actualthing', 1, 0.4, 'linear')
        doTweenAlpha('controlsTween', 'controlsHint', 1, 0.4, 'linear')
        doTweenY('titleTweenY', 'title', screenHeight / 2 - 325, 0.6, 'elasticOut')

        setTextString('actualthing', string.format('Total Score: %d\nMax Notes Per Second: %d\nNotes Hit: %d / %d (%.2f%%)', 
            score, maxNPS, hits, totalNotes, (hits / totalNotes) * 100)
        )
    end
end

function onCustomSubstateUpdate(name, elapsed)
    if name == "Pause" then
        if keyJustPressed("ui_up") then
            playSound("scrollMenu", 1)
            changeItem(-1)
            highlightOptions()
        end
        if keyJustPressed("ui_down") then
            playSound("scrollMenu", 1)
            changeItem(1)
            highlightOptions()
        end
        if keyJustPressed("accept") then
            --playSound("confirmMenu")
            callbacks[curSelected]();
            highlightOptions()
        end
        if keyJustPressed("back") then
            closeCustomSubstate()
            highlightOptions()
        end

        for i = 1, #optionsTable do
            local hovered = optionsTable[i]
            if leMouse(hovered) then
                if curSelected ~= i then 
                    curSelected = i 
                    playSound('scrollMenu', 1)
                    highlightOptions()
                end
                if mouseClicked('left') then
                    callbacks[curSelected]()
                end
            end
        end
    end
    if name == 'Results' then
        if keyJustPressed("accept") then
            endSong()
        end
    end
end

function onCustomSubstateDestroy(name)
    if name == "Pause" then
        setPropertyFromClass('flixel.FlxG', 'mouse.visible', false)
        cancelTimer('pause music')

        removeLuaSprite("bg")
        removeLuaText('title')
        removeLuaText('songInfo')
        removeLuaText('attempts')
        removeLuaText('arrow')
        for i = 1, #optionsTable do
            removeLuaText(optionsTable[i], true)
        end
        optionsTable = {}
    end
    if name == 'Results' then
        setPropertyFromClass('flixel.FlxG', 'mouse.visible', false)

        removeLuaSprite('bg')
        removeLuaText('title')
        removeLuaText('judgmentTitle')
        removeLuaText('actualthing')
        removeLuaText('controlsHint')
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
        if i == curSelected then
            setTextColor(optionsTable[i], "fff000")
            setTextSize(optionsTable[i], 51)
            setProperty(optionsTable[i]..".alpha", 1)
        
            setProperty("arrow.x", getProperty(optionsTable[i] .. '.x') - 50)
            doTweenY("arrowX", "arrow", getProperty(optionsTable[i] .. '.y'), 0.5, 'elasticOut')
        else
            setTextColor(optionsTable[i], "ffffff")
            setTextSize(optionsTable[i], 50)
            setProperty(optionsTable[i]..".alpha", 0.7)
        end
    end
end

function tweenPause(cool)
    if cool == 1 then
        for i = 1, #optionsTable do
            doTweenAlpha("optionTweenAlpha"..i, optionsTable[i], 1, 0.5, "linear")
            doTweenX("optionTweenX"..i, optionsTable[i], screenWidth / 2 - 650  + (i * 65), 1, "elasticOut")
        end
    elseif cool == 2 then
        for i = 1, #optionsTable do
            doTweenAlpha("optionTweenAlpha"..i, optionsTable[i], 0, 0.5, "linear")
            doTweenX("optionTweenX"..i, optionsTable[i], -600, 0.5, "quadOut")
        end
    end
end

function leMouse(uhh)
    return (getMouseX('other') > getProperty(uhh..'.x') and getMouseX('other') < getProperty(uhh..'.x') + getProperty(uhh..'.width'))
    and (getMouseY('other') > getProperty(uhh..'.y') and getMouseY('other') < getProperty(uhh..'.y') + getProperty(uhh..'.height'))
end

function onTimerCompleted(tag, loops, loopsLeft)
    for i = 0, 3 do
        if tag == 'keybindTimer_' .. i then
            doTweenAlpha('keybindFade' .. i, 'keybindHint_' .. i, 0, 1, 'linear')
        end
    end
    if tag == 'reduce nps' and nps > 0 then
        runTimer('reduce nps', 1/nps, 1)
        nps = nps - 1
    end
end

function onTweenCompleted(tag)
    for i = 0, 3 do
        if tag == 'keybindAlpha_' .. i then
            runTimer('keybindTimer_' .. i, 2)
        end
        if tag == 'keybindFade' .. i then
            removeLuaText('keybindsHint_' .. i)
            --debugPrint('DELETEEEEEEEEEEEE')
        end
    end
end