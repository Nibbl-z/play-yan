local width, height = 240, 160
local camera = {X = 0, Y = 0}

local stairHeight, stairWidth = 17, 25
local stairXOffset, stairYOffset = 15, 0

require "yan"
require "biribiri"

local playyan = {X = 121, Y = 58, Sprite = "img/yan_stand.png", Moving = false, Direction = 1, Visible = true}
local backdoor = {X = 121 - 50, Y = 58 - 50, Index = 1, Visible = false, Whoosh = false}
local speechBubble = {X = 121, Y = 58, Sprite = "img/speech_note.png", Visible = true, Mode = false}
local car = {X = -20}
local fish = {X = 0}

local playbackState = "play"
local isDarkened = false
local flashProgress = false

local jumpSpeed = 0.15
local currentMedia = 1

local loading = false
local folderIndex = 1
local media = {

}

local isPlaying = false

local currentSong = nil

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
            table.insert(files, {
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

function love.load()
    love.filesystem.setIdentity("play-yan")
    love.filesystem.createDirectory("music")
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(love.graphics.newFont("W95FA.otf", 14, "mono"))
    love.window.setMode(720, 480)
    LoadMusicFolder("music")
    biribiri:LoadAudio("music", "stream")
    biribiri:LoadSprites("img")
    
    unjumpTimer = biribiri:CreateTimer(jumpSpeed, function ()
        playyan.Sprite = "img/yan_stand.png"  
        playyan.Moving = false
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
        if playyan.Moving then return end
        
        currentMedia = currentMedia - 1
        if GetMediaFolder()[currentMedia] ~= nil then 
            if isPlaying and GetMediaFolder()[currentMedia].type == "file" then
                if currentSong ~= nil then
                    currentSong:stop()
                end
                currentSong = assets[GetMediaFolder()[currentMedia].path]
                currentSong:play()
            end
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
    
    elseif key == "d" then
        if playyan.Moving then return end
        
        currentMedia = currentMedia + 1
        if GetMediaFolder()[currentMedia] ~= nil then 
            if isPlaying and GetMediaFolder()[currentMedia].type == "file" then
                if currentSong ~= nil then
                    currentSong:stop()
                end
                currentSong = assets[GetMediaFolder()[currentMedia].path]
                currentSong:play()
            end
        end
        playbackState = "ff"
        
        playyan.Moving = true
        yan:NewTween(camera, yan:TweenInfo(jumpSpeed / 2), {X = camera.X - stairWidth, Y = camera.Y + stairHeight}):Play()
        yan:NewTween(backdoor, yan:TweenInfo(jumpSpeed, EasingStyle.QuadInOut), {X = backdoor.X + stairWidth, Y = backdoor.Y - stairHeight}):Play()

        playyan.Sprite = "img/yan_jump.png"
        unjumpTimer:Start()
        
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.Linear), {X = playyan.X + stairWidth}):Play()
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.QuadOut), {Y = playyan.Y - 30}):Play()
        
        yanUpTimer:Start()

        playyan.Direction = 1
    elseif key == "space" then
        if playyan.Moving then return end
        if GetMediaFolder()[currentMedia] == nil then return end
        
        if GetMediaFolder()[currentMedia].type == "file" then
            isPlaying = not isPlaying
            if currentSong ~= nil then
                currentSong:stop()
                if not isPlaying then return end
            end
            currentSong = assets[GetMediaFolder()[currentMedia].path]
            currentSong:play()
            
        elseif GetMediaFolder()[currentMedia].type == "folder" then
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
        if backdoor.Visible == false then return end
        if playyan.Moving then return end

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
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(3, 3)
    love.graphics.translate(camera.X, camera.Y)
    love.graphics.setColor(0,1,1)
    
    if fading then
        love.graphics.pop()
        return
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
        
        love.graphics.print(file.name, 15 + ((i + 3) * stairWidth) + stairWidth + 5, height - ((i + 3) * stairHeight) - 33)
    end
    if backdoor.Visible then
        love.graphics.draw(assets["img/backdoor_"..tostring(backdoor.Index)..".png"], backdoor.X + 6, backdoor.Y + 8)

        if backdoor.Whoosh == true then
            love.graphics.draw(assets["img/backdoor_whoosh.png"], backdoor.X + 6, backdoor.Y + 8)
        end
    end
    if playyan.Visible then
        love.graphics.draw(assets[playyan.Sprite], playyan.X + 6, playyan.Y + 8, 0, playyan.Direction, 1, 6, 9)
    end
    
    if speechBubble.Visible and (not playyan.Moving and isPlaying) then
        love.graphics.draw(assets[speechBubble.Sprite], speechBubble.X, speechBubble.Y)
    end
    
    if isPlaying and currentSong ~= nil then
        print(playbackState..(isDarkened and "_darkened.png" or ".png"))
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
    end
    
    love.graphics.pop()
end
