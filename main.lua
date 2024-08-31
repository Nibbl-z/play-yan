local width, height = 240, 160
local camera = {X = 0, Y = 0}

local stairHeight, stairWidth = 17, 25
local stairXOffset, stairYOffset = 15, 0

require "yan"
require "biribiri"

local playyan = {X = 121, Y = 58, Sprite = "img/yan_stand.png", Moving = false, Direction = 1, Visible = true}
local backdoor = {X = 121 - 50, Y = 58 - 50, Index = 1, Visible = false}
local jumpSpeed = 0.15
local currentMedia = 1

local loading = false

local media = {
    {
        name = "thisfolder",
        files = {
            "song2.mp3",
            "song3.mp3"
        },
        type = "folder",
        sprite = "img/door.png"
    },
    {
        name = "song.mp3",
        type = "file",
        sprite = "img/music.png"
    }
}


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
        media[currentMedia].sprite = "img/door_whoosh.png"
        playyan.Visible = false
    end)
    
    doorUnwhooshTimer = biribiri:CreateTimer(0.35, function ()
        media[currentMedia].sprite = "img/door_open.png"
    end)
    
    doorCloseTimer = biribiri:CreateTimer(0.45, function ()
        media[currentMedia].sprite = "img/door.png"
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
        
        if media[currentMedia].type == "folder" then
            playyan.Direction = 1
            playyan.Moving = true
            media[currentMedia].sprite = "img/door_open.png"
            doorEnterTimer:Start()
            doorUnwhooshTimer:Start()
            doorCloseTimer:Start()

            biribiri:CreateAndStartTimer(1, function ()
                fading = true
                backdoor.Visible = true
                biribiri:CreateAndStartTimer(0.5, function()
                    fading = false
                    playyan.Visible = true
                    playyan.X = backdoor.X + 20
                    playyan.Y = backdoor.Y + 22
                    
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
    for i, file in ipairs(media) do
        love.graphics.draw(assets[file.sprite], 15 + ((i + 3) * stairWidth), height - ((i + 3) * stairHeight) - 39)
        
        love.graphics.print(file.name, 15 + ((i + 3) * stairWidth) + stairWidth + 5, height - ((i + 3) * stairHeight) - 33)
    end
    if backdoor.Visible then
        love.graphics.draw(assets["img/backdoor_"..tostring(backdoor.Index)..".png"], backdoor.X + 6, backdoor.Y + 8)
    end
    if playyan.Visible then
        love.graphics.draw(assets[playyan.Sprite], playyan.X + 6, playyan.Y + 8, 0, playyan.Direction, 1, 6, 9)
    end
    
    
    
    
    love.graphics.pop()
end
