local width, height = 240, 160
local camera = {X = 0, Y = 0}

local stairHeight, stairWidth = 16, 24

require "yan"
require "biribiri"

local playyan = {X = 116, Y = 63, Sprite = "img/yan_stand.png", Moving = false, Direction = 1}
local jumpSpeed = 0.15


function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setMode(720, 480)
    
    biribiri:LoadSprites("img")

    unjumpTimer = biribiri:CreateTimer(jumpSpeed, function ()
        playyan.Sprite = "img/yan_stand.png"  
        playyan.Moving = false
    end)
    
    yanUpTimer = biribiri:CreateTimer(jumpSpeed / 2, function ()
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.QuadOut), {Y = playyan.Y + 30 - stairHeight}):Play()
    end)

    yanDownTimer = biribiri:CreateTimer(jumpSpeed / 2, function ()
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.QuadOut), {Y = playyan.Y + 10 + stairHeight}):Play()
    end)
end

function love.keypressed(key)
    if key == "a" then
        if playyan.Moving then return end
        playyan.Moving = true
        yan:NewTween(camera, yan:TweenInfo(jumpSpeed / 2), {X = camera.X + stairWidth, Y = camera.Y - stairHeight}):Play()
        playyan.Sprite = "img/yan_jump.png"
        unjumpTimer:Start()
        
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.Linear), {X = playyan.X - 24}):Play()
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.QuadOut), {Y = playyan.Y - 10}):Play()
        yanDownTimer:Start()

        playyan.Direction = -1

    elseif key == "d" then
        if playyan.Moving then return end
        playyan.Moving = true
        yan:NewTween(camera, yan:TweenInfo(jumpSpeed / 2), {X = camera.X - stairWidth, Y = camera.Y + stairHeight}):Play()
        playyan.Sprite = "img/yan_jump.png"
        unjumpTimer:Start()
        
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.Linear), {X = playyan.X + 24}):Play()
        yan:NewTween(playyan, yan:TweenInfo(jumpSpeed / 2, EasingStyle.QuadOut), {Y = playyan.Y - 30}):Play()
        yanUpTimer:Start()

        playyan.Direction = 1
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
    
    for i = 1, 100 do
        love.graphics.line(
            15 + ((i - 1) * stairWidth), 
            height - ((i - 1) * stairHeight), 
            15 + ((i - 1) * stairWidth), 
            height - stairHeight - ((i - 1) * stairHeight)
        )
        love.graphics.line(
            15 + ((i - 1) * stairWidth), 
            height - stairHeight - ((i - 1) * stairHeight), 
            15 + stairWidth + ((i - 1) * stairWidth), 
            height - stairHeight - ((i - 1) * stairHeight)
        )
    end
    love.graphics.setColor(1,1,1)
    love.graphics.draw(assets[playyan.Sprite], playyan.X + 6, playyan.Y + 8, 0, playyan.Direction, 1, 6, 9)
    
    love.graphics.pop()
end
