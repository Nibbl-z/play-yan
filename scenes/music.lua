local music = {}

local common = require("common")
local playbackTime = require("objects.playbacktime")
require "yan"
require "biribiri"

local width, height = 240, 160
local stairHeight, stairWidth = 17, 25
local stairXOffset = 15

local jumpSpeed = 0.15
local playyan = {X = 121, Y = 58, Sprite = "img/yan_stand.png", Moving = false, Direction = 1, Visible = true, Warping = false, Grooviness = 0, GrooveDuration = 0.0}
local yanPlant = {X = 121, Y = 58, Type = "plant", Frame = 1, Visible = false}
local backdoor = {X = 121 - 50, Y = 58 - 50, Index = 1, Whoosh = false, Type = "exit"}
local speechBubble = {X = 121, Y = 58, Sprite = "img/speech_note.png", Visible = true, Mode = false}

local playbackState = "play"
local playbackMode = 1
local playbackModes = {"loop", "loopsong", "shuffle", "song"}
local isDarkened = false
local flashProgress = false

local currentMedia = 1

local musicBopAnim = {
    {Sprite = "img/musicgroove_3.png", Y = 2},
    {Sprite = "img/music.png", Y = -1},
    {Sprite = "img/musicgroove_2.png", Y = -1},
    {Sprite = "img/musicgroove_2.png", Y = 0},
    {Sprite = "img/music.png", Y = 1},
    {Sprite = "img/music.png", Y = 0},
}

local musicJumpAnim = {
    {Sprite = "img/musicgroove_3.png", Y = -2},
    {Sprite = "img/musicgroove_3.png", Y = -4},
    {Sprite = "img/musicgroove_2.png", Y = -4},
    {Sprite = "img/music.png", Y = -4},
    {Sprite = "img/music.png", Y = -3},
    {Sprite = "img/music.png", Y = 0},
}

local stars = require("objects.stars")

local car = {X = -20}
local fish = {X = 0}

local isPlaying = false

local currentSong = nil

local adjustingVolume = false

local media = {}

function LoadMusicFolder(folder, doReturn)
    local files = {}
    
    for _, file in ipairs(love.filesystem.getDirectoryItems(folder)) do
        local info = love.filesystem.getInfo(folder.."/"..file)
        
        if info.type == "file" then
            table.insert(files, {
                name = file,
                path = folder.."/"..file,
                type = "file",
                sprite = "img/music.png",
                yOffset = 0,
                jumping = false
            })
        elseif info.type == "directory" and not doReturn then
            table.insert(files, 1, {
                name = file,
                type = "folder",
                sprite = "img/door.png",
                files = LoadMusicFolder(folder.."/"..file, true),
                isRoot = false
            })
        end
    end

    if doReturn then return files end
    
    for _, v in ipairs(files) do
        table.insert(media, v)
    end
end

function UnrootMedia(folder)
    for _, v in ipairs(folder) do
        if v.isRoot == true then
            v.isRoot = false
        end
        
        if v.files ~= nil then
            UnrootMedia(v.files)
        end
    end
end

function GetMediaFolder()
    local m
    
    for _, v in ipairs(media) do
        if v.isRoot == true then
            m = v.files
        end
    end
    
    return m or media
end

function FastForward()
    if playyan.Moving then return end
    playyan.Grooviness = 0
    yanPlant.Visible = false
    Blip()
    currentMedia = currentMedia + 1
    if GetMediaFolder()[currentMedia] ~= nil then 
        if isPlaying and GetMediaFolder()[currentMedia].type == "file" then
            if currentSong ~= nil then
                currentSong:stop()
            end
            currentSong = assets[GetMediaFolder()[currentMedia].path]
            currentSong:play()
            currentSong:setVolume(common.Volume / 36)
        end
    end
    playbackState = "ff"
    
    if currentMedia == #GetMediaFolder() + 1 and #GetMediaFolder() > 0 then
        playyan.Warping = true
    end
    
    playyan.Moving = true
    yan:NewTween(common.Camera, yan:TweenInfo(jumpSpeed / 2), {X = common.Camera.X - stairWidth, Y = common.Camera.Y + stairHeight}):Play()
    yan:NewTween(backdoor, yan:TweenInfo(jumpSpeed, EasingStyle.QuadInOut), {X = backdoor.X + stairWidth, Y = backdoor.Y - stairHeight}):Play()

    playyan.Sprite = "img/yan_jump.png"
    landTimer:Start()
    
    yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.Linear), {X = playyan.X + stairWidth}):Play()
    yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.QuadOut), {Y = playyan.Y - 30}):Play()
    
    yanUpTimer:Start()
    
    playyan.Direction = 1
end

function Rewind()
    if playyan.Moving then return end
    playyan.Grooviness = 0
    yanPlant.Visible = false
    Blip()
    currentMedia = currentMedia - 1
    if GetMediaFolder()[currentMedia] ~= nil then 
        if isPlaying and GetMediaFolder()[currentMedia].type == "file" then
            if currentSong ~= nil then
                currentSong:stop()
            end
            currentSong = assets[GetMediaFolder()[currentMedia].path]
            currentSong:play()
            currentSong:setVolume(common.Volume / 36)
        end
    end
    
    if currentMedia == 0 and #GetMediaFolder() > 0 then
        playyan.WarpingUp = true
    end
    
    playbackState = "rewind"
    
    playyan.Moving = true
    yan:NewTween(common.Camera, yan:TweenInfo(jumpSpeed / 2), {X = common.Camera.X + stairWidth, Y = common.Camera.Y - stairHeight}):Play()
    yan:NewTween(backdoor, yan:TweenInfo(jumpSpeed, EasingStyle.QuadInOut), {X = backdoor.X - stairWidth, Y = backdoor.Y + stairHeight}):Play()
    playyan.Sprite = "img/yan_jump.png"
    landTimer:Start()
    
    yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.Linear), {X = playyan.X - stairWidth}):Play()
    yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.QuadOut), {Y = playyan.Y - 10}):Play()
    yanDownTimer:Start()
    
    playyan.Direction = -1
end

function Warp()
    yan:NewTween(common.Camera, yan:TweenInfo(2, EasingStyle.QuadInOut), {X = 0, Y = 0}):Play()
    yan:NewTween(backdoor, yan:TweenInfo(2, EasingStyle.QuadInOut), {X = 121 - 50, Y = 58 - 50}):Play()
    biribiri:CreateAndStartTimer(2, function ()
        playyan.X = 121 - stairWidth
        playyan.Y = 58 + stairHeight
        playyan.Visible = true
        playyan.Moving = false
        currentMedia = 1
        
        playyan.Sprite = "img/yan_jump.png"
        landTimer:Start()
        
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.Linear), {X = playyan.X + stairWidth}):Play()
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.QuadOut), {Y = playyan.Y - 30}):Play()
        
        yanUpTimer:Start()

        if isPlaying then
            biribiri:CreateAndStartTimer(jumpSpeed / 1.9, function ()
                if GetMediaFolder()[currentMedia] ~= nil then 
                    if isPlaying and GetMediaFolder()[currentMedia].type == "file" then
                        if currentSong ~= nil then
                            currentSong:stop()
                        end
                        currentSong = assets[GetMediaFolder()[currentMedia].path]
                        currentSong:play()
                        currentSong:setVolume(common.Volume / 36)
                    end
                end
            end)
        end
        
        playyan.Direction = 1
    end)
end

function WarpUp()
    yan:NewTween(common.Camera, yan:TweenInfo(2, EasingStyle.QuadInOut), {X = -((#GetMediaFolder() - 1) * stairWidth), Y = ((#GetMediaFolder() - 1) * stairHeight)}):Play()
    yan:NewTween(backdoor, yan:TweenInfo(2, EasingStyle.QuadInOut), 
    {X = 121 + ((#GetMediaFolder() - 1) * stairWidth - 50), 
    Y = 58 - ((#GetMediaFolder() - 1) * stairHeight) - 50}):Play()
    biribiri:CreateAndStartTimer(2, function ()
        playyan.X = 121 + (#GetMediaFolder() * stairWidth)
        playyan.Y = 58 - (#GetMediaFolder() * stairHeight)
        
        playyan.Visible = true
        playyan.Moving = false
        currentMedia = #GetMediaFolder()
        
        playyan.Sprite = "img/yan_jump.png"
        landTimer:Start()
        
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.Linear), {X = playyan.X - stairWidth}):Play()
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.QuadOut), {Y = playyan.Y - 10}):Play()
        
        yanDownTimer:Start()

        if isPlaying then
            biribiri:CreateAndStartTimer(jumpSpeed / 1.9, function ()
                if GetMediaFolder()[currentMedia] ~= nil then 
                    if isPlaying and GetMediaFolder()[currentMedia].type == "file" then
                        if currentSong ~= nil then
                            currentSong:stop()
                        end
                        currentSong = assets[GetMediaFolder()[currentMedia].path]
                        currentSong:play()
                        currentSong:setVolume(common.Volume / 36)
                    end
                end
            end)
        end
        
        playyan.Direction = -1
    end)
end

function NoteJump(note)
    if note == nil then return end
    if note.type == "folder" then return end
    
    for i = 1, #musicJumpAnim do
        biribiri:CreateAndStartTimer(i * 0.03, function ()
            if note.jumping then
                note.sprite = musicJumpAnim[i].Sprite
                note.yOffset = musicJumpAnim[i].Y
            end
        end)
    end
end

function NoteBop(note)
    if note == nil then return end
    if note.type == "folder" then return end
    
    for i = 1, #musicBopAnim do
        biribiri:CreateAndStartTimer(i * 0.03, function ()
            if not note.jumping then
                note.sprite = musicBopAnim[i].Sprite
                note.yOffset = musicBopAnim[i].Y
            end
        end)
    end
end

function music:Initialize()
    LoadMusicFolder("music")
    
    stars:Init() -- bbbring out the stars

    -- When Play-Yan lands
    landTimer = biribiri:CreateTimer(jumpSpeed, function ()
        playyan.Sprite = "img/yan_stand.png"  
        playyan.Moving = false
        
        if isPlaying then
            playyan.Direction = -1
        end
        
        if playyan.Warping then
            playyan.Warping = false
            playyan.Moving = true
            playyan.Visible = false
            biribiri:CreateAndStartTimer(0.5, Warp)
        end

        if playyan.WarpingUp then
            playyan.WarpingUp = false
            playyan.Moving = true
            playyan.Visible = false
            biribiri:CreateAndStartTimer(0.5, WarpUp)
        end

        biribiri:CreateAndStartTimer(0.02, function ()
            playyan.Y = 58 - (currentMedia - 1) * stairHeight
        end)
    end)
    
    -- Animations for Play-Yan falling down when going up or down on stairs
    yanUpTimer = biribiri:CreateTimer(jumpSpeed / 1.7, function ()
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 3, EasingStyle.QuadOut), {Y = playyan.Y + 30 - stairHeight}):Play()
        playbackState = "play"
    end)
    
    yanDownTimer = biribiri:CreateTimer(jumpSpeed / 1.7, function ()
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 3, EasingStyle.QuadOut), {Y = playyan.Y + 10 + stairHeight}):Play()
        playbackState = "play"
    end)
    
    -- Animations for entering door
    doorEnterTimer = biribiri:CreateTimer(0.2, function ()
        GetMediaFolder()[currentMedia].sprite = "img/door_whoosh.png"
        playyan.Visible = false
    end)
    
    doorUnwhooshTimer = biribiri:CreateTimer(0.35, function ()
        GetMediaFolder()[currentMedia].sprite = "img/door_open.png"
    end)
    
    doorCloseTimer = biribiri:CreateTimer(0.45, function ()
        GetMediaFolder()[currentMedia].sprite = "img/door.png"
    end)
    
    -- Back door propeller spin animation
    biribiri:CreateAndStartTimer(0.06, function ()
        backdoor.Index = backdoor.Index + 1
        if backdoor.Index == 7 then
            backdoor.Index = 1
        end
    end, true)
    
    -- A loop for all the things that constantly pulse
    biribiri:CreateAndStartTimer(0.5, function ()
        speechBubble.Mode = not speechBubble.Mode
        isDarkened = not isDarkened
        
        flashProgress = true
        biribiri:CreateAndStartTimer(0.1, function ()  
            flashProgress = false
        end)
    end, true)
    
    hideVolumeTimer = biribiri:CreateTimer(2, function ()
        adjustingVolume = false
    end)
    
    -- Car and fish at bottom of screen when playing
    yan:NewTween(car, yan:TweenInfo(4), {X = width + 40}):Play()
    yan:NewTween(fish, yan:TweenInfo(8), {X = width + 40}):Play()

    biribiri:CreateAndStartTimer(8, function ()
        car.X = -20
        yan:NewTween(car, yan:TweenInfo(4), {X = width + 40}):Play()
    end, true)
    
    biribiri:CreateAndStartTimer(12, function ()
        fish.X = -20
        yan:NewTween(fish, yan:TweenInfo(8), {X = width + 40}):Play()
    end, true)
    
    -- Makes Play-Yan get less groovy if he stops groovying
    biribiri:CreateAndStartTimer(0.5, function ()
        if playyan.Grooviness > 0 then
            playyan.Grooviness = playyan.Grooviness - 1
        end
    end, true)
    
    -- Constantly make the notes get groovy if Play-Yan is also groovy
    biribiri:CreateAndStartTimer(0.2, function ()
        if playyan.Grooviness >= 5 then
            local startJump, endJump = 0, 0
            
            if playyan.Grooviness >= 17 then
                startJump = -3
                endJump = 3
            elseif playyan.Grooviness >= 13 then
                startJump = -2
                endJump = 2
            elseif playyan.Grooviness >= 8 then
                startJump = -1
                endJump = 1
            end

            for i = startJump, endJump do
                NoteBop(GetMediaFolder()[currentMedia + i])
            end
        end
        
        for _, f in ipairs(GetMediaFolder()) do -- reset if play-yan stops being groovy mid-animation
            if f.type == "file" then
                f.sprite = "img/music.png"
                f.yOffset = 0
            end
        end
    
    end, true)
end

function music:KeyReleased(key)
    if key == "j" and isPlaying then
        local duration = love.timer.getTime() - playyan.GrooveDuration
            
        if playyan.Grooviness < 5 then -- Not very groovy + Short input
            if duration <= 0.2 then
                playyan.Sprite = "img/yan_stand.png"
            end
            
        elseif playyan.Grooviness >= 5 then -- Very groovy + Short input
            if duration <= 0.2 then
                playyan.Sprite = "img/yan_stretch.png"
                
                biribiri:CreateAndStartTimer(0.02, function ()
                    playyan.Sprite = "img/yan_stand.png"
                end)
            end
        end
        
        if duration > 0.2 then
            if playyan.Grooviness < 8 then -- Not very groovy + Long input
                yanPlant.Type = "plant"
            else -- Very groovy + Long input
                yanPlant.Type = "flower"
            end

            playyan.Sprite = "img/yan_flower.png"
            yanPlant.Visible = true
            yanPlant.Frame = 1
            playyan.Y = playyan.Y - 1

            yanPlant.X = playyan.X - 8
            yanPlant.Y = playyan.Y - 21
            
            -- More notes jump the groovier you ar
            local startJump, endJump = 0, 0
            
            if playyan.Grooviness >= 17 then
                startJump = -3
                endJump = 3
            elseif playyan.Grooviness >= 13 then
                startJump = -2
                endJump = 2
            elseif playyan.Grooviness >= 8 then
                startJump = -1
                endJump = 1
            end
            
            for i = startJump, endJump do
                biribiri:CreateAndStartTimer(math.abs(i) * 0.06, function ()
                    if GetMediaFolder()[currentMedia + i] ~= nil then
                        GetMediaFolder()[currentMedia + i].jumping = true
                        NoteJump(GetMediaFolder()[currentMedia + i])
                    end
                end)
            end
            
            biribiri:CreateAndStartTimer(0.06, function ()
                playyan.Y = playyan.Y + 1

                yanPlant.Frame = 2
                biribiri:CreateAndStartTimer(0.12, function ()
                    yanPlant.Frame = 3
                end)
            end)
            
            biribiri:CreateAndStartTimer(0.4, function ()
                if playyan.Sprite == "img/yan_flower.png" then
                    yanPlant.Visible = false
                    playyan.Sprite = "img/yan_stand.png"
                    for _, f in ipairs(GetMediaFolder()) do
                        if f.type == "file" then
                            f.jumping = false            
                        end
                    end
                end
            end)
        end
    end
end

function music:KeyPressed(key)
    if key == "j" and isPlaying then -- Get groovy
        for _, f in ipairs(GetMediaFolder()) do
            if f.type == "file" then
                f.jumping = false            
            end
        end

        yanPlant.Visible = false
        playyan.GrooveDuration = love.timer.getTime()
        playyan.Grooviness = math.clamp(playyan.Grooviness + 1, 0, 20)

        if playyan.Grooviness < 5 then -- Not very groovy
            playyan.Sprite = "img/yan_bop.png"
        elseif playyan.Grooviness >= 5 then -- Very groovy
            playyan.Sprite = "img/yan_squat1.png"

            biribiri:CreateAndStartTimer(0.02, function ()
                playyan.Sprite = "img/yan_squat2.png"
            end)
        end
    end

    if key == "a" then Rewind() end
    if key == "d" then FastForward() end
    
    if key == "space" then -- Play song/enter folder
        if GetMediaFolder()[currentMedia] == nil then return end
            
        if GetMediaFolder()[currentMedia].type == "file" then -- Play song
            isPlaying = true
            
            if currentSong ~= nil then
                if currentSong:isPlaying() then
                    playbackState = "pause"
                    Blip()
                    currentSong:pause()
                    return 
                end
            end
            playbackState = "play"
            currentSong = assets[GetMediaFolder()[currentMedia].path]
            currentSong:play()
            currentSong:setVolume(common.Volume / 36)

            playyan.Direction = -1
        elseif GetMediaFolder()[currentMedia].type == "folder" then -- Open folder
            Blip()
            folderIndex = currentMedia
            playyan.Direction = 1
            playyan.Moving = true
            GetMediaFolder()[currentMedia].sprite = "img/door_open.png"
            doorEnterTimer:Start()
            doorUnwhooshTimer:Start()
            doorCloseTimer:Start()

            biribiri:CreateAndStartTimer(1, function ()
                UnrootMedia(media)
                GetMediaFolder()[currentMedia].isRoot = true

                common.ToggleRendering = true
                backdoor.Type = "back"
                biribiri:CreateAndStartTimer(0.5, function()
                    currentMedia = 1
                    common.ToggleRendering = false
                    playyan.Visible = true

                    backdoor.X = 121 - 50
                    backdoor.Y = 58 - 50 
                    
                    playyan.X = backdoor.X + 20
                    playyan.Y = backdoor.Y + 22
                    
                    common.Camera.X = 0
                    common.Camera.Y = 0
                    
                    biribiri:CreateAndStartTimer(0.7, function ()
                        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 0.5, EasingStyle.Linear), {X = playyan.X + stairWidth + 6}):Play()
                        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed, EasingStyle.QuadOut), {Y = playyan.Y - 20}):Play()
                        playyan.Sprite = "img/yan_jump.png"
                        biribiri:CreateAndStartTimer(jumpSpeed, function ()
                            yan:NewTween(playyan, yan:TweenInfo(jumpSpeed, EasingStyle.QuadIn), {Y = playyan.Y + 48}):Play()
                        end)
                        
                        biribiri:CreateAndStartTimer(jumpSpeed / 0.5, function ()
                            playyan.Sprite = "img/yan_stand.png"
                            playyan.Moving = false
                        end)
                    end)
                end)
            end)
        end
    end
    
    if key == "w" then -- Raise volume
        if isPlaying then
            adjustingVolume = true
            common.Volume = math.clamp(common.Volume + 1, 0, 36)
            hideVolumeTimer.Started = false
            hideVolumeTimer:Start()
            
            if currentSong ~= nil then
                currentSong:setVolume(common.Volume / 36)
            end
        end
    end
    
    if key == "s" then -- Lower volume
        if isPlaying then
            adjustingVolume = true
            common.Volume = math.clamp(common.Volume - 1, 0, 36)
            hideVolumeTimer.Started = false
            hideVolumeTimer:Start()
            
            if currentSong ~= nil then
                currentSong:setVolume(common.Volume / 36)
            end
            return
        end
    end

    if key == "escape" then -- Exit folder or music scene
        if playyan.Moving then return end
        
        
        Blip()

        if currentSong ~= nil then
            currentSong:stop()
            
            if isPlaying then 
                isPlaying = false
                return 
            end
        end

        playyan.Moving = true
        playyan.Direction = -1
        
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 0.5, EasingStyle.Linear), {X = playyan.X - stairWidth - 7}):Play()
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed, EasingStyle.QuadOut), {Y = playyan.Y - 48}):Play()

        biribiri:CreateAndStartTimer(jumpSpeed, function ()
            yan:NewTween(playyan, yan:TweenInfo(jumpSpeed, EasingStyle.QuadIn), {Y = playyan.Y + 20}):Play()
        end)
        
        biribiri:CreateAndStartTimer(jumpSpeed / 0.5 + 0.3, function ()
            playyan.Visible = false
            backdoor.Whoosh = true
        end)
        biribiri:CreateAndStartTimer(jumpSpeed / 0.5 + 0.4, function ()
            backdoor.Whoosh = false
        end)
        biribiri:CreateAndStartTimer(jumpSpeed / 0.5 + 0.5, function ()
            common.ToggleRendering = true
            
            if backdoor.Type == "back" then
                UnrootMedia(media)
                
                biribiri:CreateAndStartTimer(0.5, function ()
                    playyan.Visible = true
                    playyan.Moving = false
                    backdoor.Whoosh = false
                    common.ToggleRendering = false
                    
                    media[folderIndex].sprite = "img/door_open.png"
                    
                    currentMedia = folderIndex
                    
                    playyan.X = 121 + (stairWidth * (folderIndex - 1))
                    playyan.Y = 58 - (stairHeight * (folderIndex - 1))
                    
                    common.Camera.X = 0 - (stairWidth * (folderIndex - 1))
                    common.Camera.Y = 0 + (stairHeight * (folderIndex - 1))
                    
                    backdoor.X = playyan.X - 50
                    backdoor.Y = playyan.Y - 50
                end)
                
                biribiri:CreateAndStartTimer(0.7, function ()
                    media[folderIndex].sprite = "img/door.png"
                end)
                backdoor.Type = "exit"
            elseif backdoor.Type == "exit" then
                yan:NewTween(common.Fade, yan:TweenInfo(0.3), {Alpha = 1}):Play()
                
                biribiri:CreateAndStartTimer(0.6, function ()
                    playyan.Visible = true
                    playyan.Moving = false
                    backdoor.Whoosh = false
                    common.ToggleRendering = false
                    
                    currentMedia = 1 
                    
                    playyan.X = 121 + (stairWidth * (currentMedia - 1))
                    playyan.Y = 58 - (stairHeight * (currentMedia - 1))
                    
                    common.Camera.X = 0 - (stairWidth * (currentMedia - 1))
                    common.Camera.Y = 0 + (stairHeight * (currentMedia - 1))

                    backdoor.X = 121 - 50
                    backdoor.Y = 58 - 50

                    yan:NewTween(common.Fade, yan:TweenInfo(0.5), {Alpha = 0}):Play()
                    common.Scene = "menu"
                    MenuEnter()
                end)
            end

            
        end)
    end
    
    if key == "z" then -- Switch playback mode
        if isPlaying then
            playbackMode = playbackMode + 1
            if playbackMode == 5 then
                playbackMode = 1
            end
        end
    end
end

function music:Update(dt)
    speechBubble.X = playyan.X - 12
    speechBubble.Y = playyan.Y - 9
    
    if speechBubble.Mode then
        speechBubble.Sprite = "img/speech_empty.png"
    else
        speechBubble.Sprite = "img/speech_note.png"
    end

    if currentSong ~= nil then
        currentSong:setLooping(playbackMode == 2)
        
        if love.keyboard.isDown("left") then
            if love.keyboard.isDown("lshift") then
                currentSong:seek(currentSong:tell() - dt * 18)
            else
                currentSong:seek(currentSong:tell() - dt * 6)
            end
            
        elseif love.keyboard.isDown("right") then
            if love.keyboard.isDown("lshift") then
                currentSong:seek(currentSong:tell() + dt * 18)
            else
                currentSong:seek(currentSong:tell() + dt * 6)
            end
        end

        if currentSong:tell() >= currentSong:getDuration() - 0.1 then
            if playbackMode == 1 then
                FastForward()
            end
            
            if playbackMode == 3 then
                currentSong:stop()
                local function PickNextSong()
                    local i = love.math.random(1, #GetMediaFolder())
                    local chosen = GetMediaFolder()[i]
                    if chosen.type == "folder" then return PickNextSong() end
                    if i == currentMedia then return PickNextSong() end
                    return i
                end
                
                local picked = PickNextSong()
                print(picked - currentMedia)
                
                if picked - currentMedia > 0 then
                    for i = 1, picked - currentMedia do
                        biribiri:CreateAndStartTimer((jumpSpeed / 1.9) * i, FastForward)
                    end
                else
                    for i = 1, -(picked - currentMedia) do
                        biribiri:CreateAndStartTimer((jumpSpeed / 1.9) * i, Rewind)
                    end
                end
            end
        end
    end
end

function music:Draw()
    love.graphics.translate(common.Camera.X, common.Camera.Y)
    
    if isPlaying and currentSong ~= nil then
        stars:Draw(common.Camera.X, common.Camera.Y)
    end
    
    if #GetMediaFolder() > 0 then
        love.graphics.setColor(0,0,0.8)
        love.graphics.rectangle("fill", 
        10 + ((math.clamp(currentMedia, 1, #GetMediaFolder()) + 2) * stairWidth) + stairWidth + 5, 
        height - ((math.clamp(currentMedia, 1, #GetMediaFolder()) + 2) * stairHeight) - 34, 500, stairHeight)
        love.graphics.setColor(0,1,1)
    end
    
    
    
    for i = -10, #GetMediaFolder() + 10 do
        love.graphics.line(
            stairXOffset + ((i - 1) * stairWidth), 
            height - ((i - 1) * stairHeight), 
            stairXOffset + ((i - 1) * stairWidth), 
            height - stairHeight - ((i - 1) * stairHeight)
        )
        love.graphics.line(
            stairXOffset + ((i - 1) * stairWidth), 
            height - stairHeight - ((i - 1) * stairHeight), 
            stairXOffset + stairWidth + ((i - 1) * stairWidth), 
            height - stairHeight - ((i - 1) * stairHeight)
        )
    end
    love.graphics.setColor(1,1,1)

    local m = GetMediaFolder()
    
    for i, file in ipairs(m) do
        local yOffset = file.yOffset or 0
        love.graphics.draw(assets[file.sprite], 15 + ((i + 3) * stairWidth), height - ((i + 3) * stairHeight) - 39 + yOffset)
        
        love.graphics.print(file.name, 15 + ((i + 2) * stairWidth) + stairWidth + 5, height - ((i + 2) * stairHeight) - 33)
    end
    
    
    
    love.graphics.draw(assets["img/"..backdoor.Type.."door_"..tostring(backdoor.Index)..".png"], backdoor.X + 6, backdoor.Y + 8)
    
    if backdoor.Whoosh == true then
        love.graphics.draw(assets["img/backdoor_whoosh.png"], backdoor.X + 6, backdoor.Y + 8)
    end
    
    love.graphics.draw(assets["img/guy.png"], 7 + ((#m + 6) * stairWidth), height - ((#m + 6) * stairHeight) - 33)

    
    

    
    if playyan.Visible then
        love.graphics.draw(assets[playyan.Sprite], playyan.X + 6, playyan.Y + 8, 0, playyan.Direction, 1, 6, 9)
    end
    
    if yanPlant.Visible then
        love.graphics.draw(assets["img/"..yanPlant.Type.."_"..tostring(yanPlant.Frame)..".png"], yanPlant.X, yanPlant.Y)
    end

    if #GetMediaFolder() > 0 then
        love.graphics.draw(assets["img/warp.png"], 15 + ((#m + 4) * stairWidth), height - ((#m + 4) * stairHeight) - 47)
        love.graphics.draw(assets["img/warp_flip.png"], 15 + ((3) * stairWidth), height - ((3) * stairHeight) - 47)
    end
    
    if speechBubble.Visible and (not playyan.Moving and isPlaying) and playyan.Grooviness == 0 then
        love.graphics.draw(assets[speechBubble.Sprite], speechBubble.X, speechBubble.Y)
    end
    
    
    
    if adjustingVolume then
        local extraSize = 0
        
        for i = 1, common.Volume do
            if i % 3 == 0 then
                extraSize = extraSize + 1
            end
        end

        love.graphics.draw(assets["img/volume.png"], 2 - common.Camera.X, 30 - common.Camera.Y)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", 7 - common.Camera.X, 48 - common.Camera.Y, 4, -common.Volume - extraSize + 47)
        love.graphics.setColor(1,1,1)
    end
    
    if isPlaying and currentSong ~= nil then
        love.graphics.draw(assets["img/"..playbackState..(isDarkened and "_darkened.png" or ".png")], 30 - common.Camera.X, 60 - common.Camera.Y)
        
        love.graphics.draw(assets["img/bottom_gradient.png"], 0 - common.Camera.X, height - 50 - common.Camera.Y, 0, 2, 1)
        
        playbackTime:Render(currentSong:tell("seconds"), width - 30 - common.Camera.X, 105 - common.Camera.Y)
        love.graphics.draw(assets[flashProgress and "img/progress_flash.png" or "img/progress.png"], (width * (currentSong:tell("seconds") / currentSong:getDuration("seconds"))) - common.Camera.X, height - 51 - common.Camera.Y )
        
        love.graphics.draw(assets["img/car.png"], car.X - common.Camera.X, height - 8 - common.Camera.Y)
        love.graphics.draw(assets["img/fish.png"], fish.X - common.Camera.X, height - 40 - common.Camera.Y)

        love.graphics.draw(assets["img/playback_"..playbackModes[playbackMode]..".png"], 2 - common.Camera.X, 98 - common.Camera.Y)
    end
end

--[[function love.filedropped(file)
    file:open("r")
	local data = file:read()
    
    local t={}
    for str in string.gmatch(file:getFilename(), "([^".."\\".."]+)") do
        table.insert(t, str)
    end
    
    fileName = t[#t]
    
    love.filesystem.write("music/"..fileName, data)
    
    table.clear(media)
    LoadMusicFolder("music")
    biribiri:LoadAudio("music", "stream")
end]] -- ughhh i dont like how this is implemented and i dont wanna make it better so it go byebye now

return music