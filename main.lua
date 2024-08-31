local width, height = 240, 160
local camera = {X = 0, Y = 0}

local stairHeight, stairWidth = 17, 25
local stairXOffset, stairYOffset = 15, 0

require "yan"
require "biribiri"

local playyan = {X = 121, Y = 58, Sprite = "img/yan_stand.png", Moving = false, Direction = 1, Visible = true}
local backdoor = {X = 121 - 50, Y = 58 - 50, Index = 1, Visible = false, Whoosh = false}
local jumpSpeed = 0.15
local currentMedia = 1

local loading = false
local folderIndex = 1
local media = {
    {
        name = "song.mp3",
        type = "file",
        sprite = "img/music.png"
    },
    {
        name = "thisfolder",
        files = {
            {
                name = "song3.mp3",
                type = "file",
                sprite = "img/music.png"
            },
            
            {
                name = "song2534.mp3",
                type = "file",
                sprite = "img/music.png"
            }
        },
        type = "folder",
        sprite = "img/door.png",
        isRoot = false
    } 
    
}

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
        print(v.name)
        if v.isRoot == true then
            m = v.files
        end
    end
    
    return m or media
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setMode(720, 480)
    
    biribiri:LoadSprites("img")
    
    unjumpTimer = biribiri:CreateTimer(jumpSpeed, function ()
        playyan.Sprite = "img/yan_stand.png"  
        playyan.Moving = false
    end)
    
    yanUpTimer = biribiri:CreateTimer(jumpSpeed / 1.9, function ()
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2.2, EasingStyle.QuadOut), {Y = playyan.Y + 30 - stairHeight}):Play()
    end)
    
    yanDownTimer = biribiri:CreateTimer(jumpSpeed / 1.9, function ()
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2.2, EasingStyle.QuadOut), {Y = playyan.Y + 10 + stairHeight}):Play()
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
end

function love.keypressed(key)

    if key == "a" then
        if playyan.Moving then return end

        currentMedia = currentMedia - 1

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
        if GetMediaFolder()[currentMedia].type == "folder" then
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
    
    
    
    love.graphics.pop()
end
