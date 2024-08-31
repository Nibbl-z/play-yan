local width, height = 240, 160
local camera = {X = 0, Y = 0}

require "yan"
require "biribiri"

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setMode(720, 480)
end

function love.keypressed(key)
    if key == "a" then
        yan:NewTween(camera, yan:TweenInfo(0.1), {X = camera.X + 30, Y = camera.Y - 20}):Play()
    elseif key == "d" then
        yan:NewTween(camera, yan:TweenInfo(0.1), {X = camera.X - 30, Y = camera.Y + 20}):Play()
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
            40 + ((i - 1) * 30), 
            height - ((i - 1) * 20), 
            40 + ((i - 1) * 30), 
            height - 20 - ((i - 1) * 20)
        )
        love.graphics.line(
            40 + ((i - 1) * 30), 
            height - 20 - ((i - 1) * 20), 
            70 + ((i - 1) * 30), 
            height - 20 - ((i - 1) * 20)
        )
    end
    
    love.graphics.pop()
end
