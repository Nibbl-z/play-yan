local playbackTime = {}

require "biribiri"

function playbackTime:Render(time, x, y)
    local seconds = math.floor(time % 60)
    if seconds < 10 then
        seconds = "0"..tostring(seconds)
    end
    
    local minutes = math.floor(time / 60)
    if minutes < 10 then
        minutes = "0"..tostring(minutes)
    end
    
    local hours = math.floor(time / 3600) -- who is to hour long media on my playyan media player???
    if hours < 10 then
        hours = "0"..tostring(hours)
    end

    love.graphics.draw(assets["img/progress/"..string.sub(tostring(hours), 1, 1)..".png"], x, y)
    love.graphics.draw(assets["img/progress/"..string.sub(tostring(hours), 2, 2)..".png"], x + 4, y)
    love.graphics.draw(assets["img/progress/colon.png"], x + 8, y + 1)
    love.graphics.draw(assets["img/progress/"..string.sub(tostring(minutes), 1, 1)..".png"], x + 10, y)
    love.graphics.draw(assets["img/progress/"..string.sub(tostring(minutes), 2, 2)..".png"], x + 14, y)
    love.graphics.draw(assets["img/progress/colon.png"], x + 18, y + 1)
    love.graphics.draw(assets["img/progress/"..string.sub(tostring(seconds), 1, 1)..".png"], x + 20, y)
    love.graphics.draw(assets["img/progress/"..string.sub(tostring(seconds), 2, 2)..".png"], x + 24, y)
end

return playbackTime