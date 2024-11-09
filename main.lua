local width, height = 240, 160
local camera = {X = 0, Y = 0}

local stairHeight, stairWidth = 17, 25
local stairXOffset, stairYOffset = 15, 0

require "yan"
require "biribiri"

local playyan = {X = 121, Y = 58, Sprite = "img/yan_stand.png", Moving = false, Direction = 1, Visible = true, Warping = false}
local backdoor = {X = 121 - 50, Y = 58 - 50, Index = 1, Visible = false, Whoosh = false}
local speechBubble = {X = 121, Y = 58, Sprite = "img/speech_note.png", Visible = true, Mode = false}

local stars = require("stars")

local car = {X = -20}
local fish = {X = 0}

local playbackState = "play"
local playbackMode = 1
local playbackModes = {"loop", "loopsong", "shuffle", "song"}
local isDarkened = false
local flashProgress = false

local jumpSpeed = 0.15
local currentMedia = 1

local loading = false
local folderIndex = 1
local media = {

}

local volume = 27 -- 100% is 27 ticks, goes up to 36, which should be 133% volume
local adjustingVolume = false

local isPlaying = false

local currentSong = nil

function FastForward()
    if playyan.Moving then return end
    assets["sfx/blip.mp3"]:play()
    currentMedia = currentMedia + 1
    if GetMediaFolder()[currentMedia] ~= nil then 
        if isPlaying and GetMediaFolder()[currentMedia].type == "file" then
            if currentSong ~= nil then
                currentSong:stop()
            end
            currentSong = assets[GetMediaFolder()[currentMedia].path]
            currentSong:play()
            currentSong:setVolume(volume / 27)
        end
    end
    playbackState = "ff"

    if currentMedia == #GetMediaFolder() + 1 and #GetMediaFolder() > 0 then
        playyan.Warping = true
    end
    
    playyan.Moving = true
    yan:NewTween(camera, yan:TweenInfo(jumpSpeed / 2), {X = camera.X - stairWidth, Y = camera.Y + stairHeight}):Play()
    yan:NewTween(backdoor, yan:TweenInfo(jumpSpeed, EasingStyle.QuadInOut), {X = backdoor.X + stairWidth, Y = backdoor.Y - stairHeight}):Play()

    playyan.Sprite = "img/yan_jump.png"
    unjumpTimer:Start()
    
    yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.Linear), {X = playyan.X + stairWidth}):Play()
    yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.QuadOut), {Y = playyan.Y - 30}):Play()
    
    yanUpTimer:Start()

    playyan.Direction = 1
end

function Rewind()
    if playyan.Moving then return end

    assets["sfx/blip.mp3"]:play()
    currentMedia = currentMedia - 1
    if GetMediaFolder()[currentMedia] ~= nil then 
        if isPlaying and GetMediaFolder()[currentMedia].type == "file" then
            if currentSong ~= nil then
                currentSong:stop()
            end
            currentSong = assets[GetMediaFolder()[currentMedia].path]
            currentSong:play()
            currentSong:setVolume(volume / 27)
        end
    end

    if currentMedia == 0 and #GetMediaFolder() > 0 then
        playyan.WarpingUp = true
    end

    playbackState = "rewind"
    
    playyan.Moving = true
    yan:NewTween(camera, yan:TweenInfo(jumpSpeed / 2), {X = camera.X + stairWidth, Y = camera.Y - stairHeight}):Play()
    yan:NewTween(backdoor, yan:TweenInfo(jumpSpeed, EasingStyle.QuadInOut), {X = backdoor.X - stairWidth, Y = backdoor.Y + stairHeight}):Play()
    playyan.Sprite = "img/yan_jump.png"
    unjumpTimer:Start()
    
    yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.Linear), {X = playyan.X - stairWidth}):Play()
    yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.QuadOut), {Y = playyan.Y - 10}):Play()
    yanDownTimer:Start()

    playyan.Direction = -1
end

function LoadMusicFolder(folder, doReturn)
    local files = {}

    for _, file in ipairs(love.filesystem.getDirectoryItems(folder)) do
        local info = love.filesystem.getInfo(folder.."/"..file)
        
        if info.type == "file" then
            table.insert(files, {
                name = file,
                path = folder.."/"..file,
                type = "file",
                sprite = "img/music.png"
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

function Warp()
    yan:NewTween(camera, yan:TweenInfo(2, EasingStyle.QuadInOut), {X = 0, Y = 0}):Play()
    yan:NewTween(backdoor, yan:TweenInfo(2, EasingStyle.QuadInOut), {X = 121 - 50, Y = 58 - 50}):Play()
    biribiri:CreateAndStartTimer(2, function ()
        playyan.X = 121 - stairWidth
        playyan.Y = 58 + stairHeight
        playyan.Visible = true
        playyan.Moving = false
        currentMedia = 1
        
        playyan.Sprite = "img/yan_jump.png"
        unjumpTimer:Start()
        
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
                        currentSong:setVolume(volume / 27)
                    end
                end
            end)
        end
        
        playyan.Direction = 1
    end)
end

function WarpUp()
    yan:NewTween(camera, yan:TweenInfo(2, EasingStyle.QuadInOut), {X = -((#GetMediaFolder() - 1) * stairWidth), Y = ((#GetMediaFolder() - 1) * stairHeight)}):Play()
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
        unjumpTimer:Start()
        
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
                        currentSong:setVolume(volume / 27)
                    end
                end
            end)
        end
        
        playyan.Direction = -1
    end)
end

function love.load()
    love.window.setTitle("Play-Yan")
    love.window.setIcon(love.image.newImageData("/img/icon.png"))
    stars:Init()
    love.filesystem.setIdentity("play-yan")
    love.filesystem.createDirectory("music")
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(love.graphics.newFont("W95FA.otf", 14, "mono"))
    love.window.setMode(720, 480)
    LoadMusicFolder("music")
    biribiri:LoadAudio("music", "stream")
    biribiri:LoadAudio("sfx", "static")
    biribiri:LoadSprites("img")
    
    unjumpTimer = biribiri:CreateTimer(jumpSpeed, function ()
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
    end)
    
    yanUpTimer = biribiri:CreateTimer(jumpSpeed / 1.9, function ()
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2.2, EasingStyle.QuadOut), {Y = playyan.Y + 30 - stairHeight}):Play()
        playbackState = "play"
    end)
    
    yanDownTimer = biribiri:CreateTimer(jumpSpeed / 1.9, function ()
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2.2, EasingStyle.QuadOut), {Y = playyan.Y + 10 + stairHeight}):Play()
        playbackState = "play"
    end)
    
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
    
    backdoorSpinAnim = biribiri:CreateAndStartTimer(0.06, function ()
        backdoor.Index = backdoor.Index + 1
        if backdoor.Index == 7 then
            backdoor.Index = 1
        end
    end, true)
    
    speechBubbleSwap = biribiri:CreateAndStartTimer(0.5, function ()
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
end

function love.keypressed(key)
    if key == "a" then
        Rewind()
    elseif key == "d" then
        FastForward()
    elseif key == "space" then
        if GetMediaFolder()[currentMedia] == nil then return end
        
        if GetMediaFolder()[currentMedia].type == "file" then
            isPlaying = not isPlaying
            if currentSong ~= nil then
                currentSong:stop()
                if not isPlaying then return end
            end
            currentSong = assets[GetMediaFolder()[currentMedia].path]
            currentSong:play()
            currentSong:setVolume(volume / 27)

            playyan.Direction = -1
            
        elseif GetMediaFolder()[currentMedia].type == "folder" then
            assets["sfx/blip.mp3"]:play()
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

                fading = true
                backdoor.Visible = true
                biribiri:CreateAndStartTimer(0.5, function()
                    currentMedia = 1
                    fading = false
                    playyan.Visible = true

                    backdoor.X = 121 - 50
                    backdoor.Y = 58 - 50 
                    
                    playyan.X = backdoor.X + 20
                    playyan.Y = backdoor.Y + 22
                    
                    camera.X = 0
                    camera.Y = 0
                    
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
    elseif key == "w" then
        if isPlaying then
            adjustingVolume = true
            volume = volume + 1
            hideVolumeTimer.Started = false
            hideVolumeTimer:Start()
            
            if currentSong ~= nil then
                currentSong:setVolume(volume / 27)
            end
            

            return
        end
        if backdoor.Visible == false then return end
        if playyan.Moving then return end
        assets["sfx/blip.mp3"]:play()
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
            fading = true
            UnrootMedia(media)
            
            biribiri:CreateAndStartTimer(0.5, function ()
                playyan.Visible = true
                playyan.Moving = false
                backdoor.Visible = false
                backdoor.Whoosh = false
                fading = false
                
                media[folderIndex].sprite = "img/door_open.png"
                
                currentMedia = folderIndex
                
                playyan.X = 121 + (stairWidth * (folderIndex - 1))
                playyan.Y = 58 - (stairHeight * (folderIndex - 1))
                
                camera.X = 0 - (stairWidth * (folderIndex - 1))
                camera.Y = 0 + (stairHeight * (folderIndex - 1))
            end)
            
            biribiri:CreateAndStartTimer(0.7, function ()
                media[folderIndex].sprite = "img/door.png"
            end)
        end)
    elseif key == "s" then
        if isPlaying then
            adjustingVolume = true
            volume = volume - 1
            hideVolumeTimer.Started = false
            hideVolumeTimer:Start()

            if currentSong ~= nil then
                currentSong:setVolume(volume / 27)
            end
            return
        end
    elseif key == "z" then
        if isPlaying then
            playbackMode = playbackMode + 1
            if playbackMode == 5 then
                playbackMode = 1
            end
        end
    end
end

function love.update(dt)
    yan:Update(dt)
    biribiri:Update(dt)
    
    speechBubble.X = playyan.X - 12
    speechBubble.Y = playyan.Y - 9
    
    if speechBubble.Mode then
        speechBubble.Sprite = "img/speech_empty.png"
    else
        speechBubble.Sprite = "img/speech_note.png"
    end

    if currentSong ~= nil then
        currentSong:setLooping(playbackMode == 2)

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

function love.draw()
    love.graphics.push()
    love.graphics.scale(3, 3)
    love.graphics.translate(camera.X, camera.Y)
    if fading then
        love.graphics.pop()
        return
    end
    if isPlaying and currentSong ~= nil then
        stars:Draw(camera.X, camera.Y)
    end
    
    if #GetMediaFolder() > 0 then
        love.graphics.setColor(0,0,0.8)
        love.graphics.rectangle("fill", 
        10 + ((math.clamp(currentMedia, 1, #GetMediaFolder()) + 2) * stairWidth) + stairWidth + 5, 
        height - ((math.clamp(currentMedia, 1, #GetMediaFolder()) + 2) * stairHeight) - 34, 500, stairHeight)
        love.graphics.setColor(0,1,1)
    end
    
    
    
    for i = -10, 100 do
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
        love.graphics.draw(assets[file.sprite], 15 + ((i + 3) * stairWidth), height - ((i + 3) * stairHeight) - 39)
        
        love.graphics.print(file.name, 15 + ((i + 2) * stairWidth) + stairWidth + 5, height - ((i + 2) * stairHeight) - 33)
    end
    
   
    
    if backdoor.Visible then
        love.graphics.draw(assets["img/backdoor_"..tostring(backdoor.Index)..".png"], backdoor.X + 6, backdoor.Y + 8)

        if backdoor.Whoosh == true then
            love.graphics.draw(assets["img/backdoor_whoosh.png"], backdoor.X + 6, backdoor.Y + 8)
        end
        
        love.graphics.draw(assets["img/guy.png"], 7 + ((#m + 6) * stairWidth), height - ((#m + 6) * stairHeight) - 33)
    end
    
    

    
    if playyan.Visible then
        love.graphics.draw(assets[playyan.Sprite], playyan.X + 6, playyan.Y + 8, 0, playyan.Direction, 1, 6, 9)
    end
    if #GetMediaFolder() > 0 then
        love.graphics.draw(assets["img/warp.png"], 15 + ((#m + 4) * stairWidth), height - ((#m + 4) * stairHeight) - 47)
        love.graphics.draw(assets["img/warp_flip.png"], 15 + ((3) * stairWidth), height - ((3) * stairHeight) - 47)
    end
    
    if speechBubble.Visible and (not playyan.Moving and isPlaying) then
        love.graphics.draw(assets[speechBubble.Sprite], speechBubble.X, speechBubble.Y)
    end
    
    

    if adjustingVolume then
        local extraSize = 0
        
        for i = 1, volume do
            if i % 3 == 0 then
                extraSize = extraSize + 1
            end
        end
        
        print(extraSize, volume)
        love.graphics.draw(assets["img/volume.png"], 2 - camera.X, 30 - camera.Y)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", 5 - camera.X, 46 - camera.Y, 4, -volume - extraSize + 47)
        love.graphics.setColor(1,1,1)
    end
    
    if isPlaying and currentSong ~= nil then
        love.graphics.draw(assets["img/"..playbackState..(isDarkened and "_darkened.png" or ".png")], 30 - camera.X, 60 - camera.Y)
        
        love.graphics.draw(assets["img/bottom_gradient.png"], 0 - camera.X, height - 50 - camera.Y, 0, 2, 1)
        
        local seconds = math.floor(currentSong:tell("seconds") % 60)
        if seconds < 10 then
            seconds = "0"..tostring(seconds)
        end

        local minutes = math.floor(currentSong:tell("seconds") / 60)
        if minutes < 10 then
            minutes = "0"..tostring(minutes)
        end
        
        local hours = math.floor(currentSong:tell("seconds") / 3600 )-- dude whos listening to hour long audio on my playyan media player
        if hours < 10 then
            hours = "0"..tostring(hours)
        end
        
        love.graphics.printf(hours..":"..minutes..":"..seconds, width - 105 - camera.X, 98 - camera.Y, 100, "right")
        
        love.graphics.draw(assets[flashProgress and "img/progress_flash.png" or "img/progress.png"], (width * (currentSong:tell("seconds") / currentSong:getDuration("seconds"))) - camera.X, height - 51 - camera.Y )
        
        love.graphics.draw(assets["img/car.png"], car.X - camera.X, height - 8 - camera.Y)
        love.graphics.draw(assets["img/fish.png"], fish.X - camera.X, height - 40 - camera.Y)

        love.graphics.draw(assets["img/playback_"..playbackModes[playbackMode]..".png"], 2 - camera.X, 98 - camera.Y)
    end
    
    love.graphics.pop()
end

function love.filedropped(file)
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
end