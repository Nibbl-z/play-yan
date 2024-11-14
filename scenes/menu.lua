local menu = {}
local common = require("common")
require "yan"
require "biribiri"

local birdAnim = {1, 2, 1, 2, 3, 4, 1, 2, 1, 2, 5, 6}
local selection = 1

local birds = require("objects.birds")
local clouds = require("objects.clouds")
local video = require("scenes.video")

local bird = {
    X = -20, 
    Y = 10, 
    AnimationFrame = 1, 
    GetYOffset = function(frame)
        if frame <= 4 then return 0 end 
        if frame >= 7 and frame <= 10 then return -2 end
        return -1
    end
}

function MenuEnter()
    bird.X = -20
    bird.Y = 10

    if selection == 1 then
        yan:NewTween(bird, yan:TweenInfo(0.7, EasingStyle.CircularOut), {X = 85, Y = 48}):Play()
    else
        yan:NewTween(bird, yan:TweenInfo(0.7, EasingStyle.CircularOut), {X = 85, Y = 68}):Play()
    end
end

function menu:Initialize()
    -- Loop through bird flapping animation
    biribiri:CreateAndStartTimer(0.06, function ()
        bird.AnimationFrame = bird.AnimationFrame + 1
        if bird.AnimationFrame == #birdAnim + 1 then bird.AnimationFrame = 1 end
    end, true)
    
    clouds:Init()
    birds:Init()
end

function menu:Draw()
    clouds:Draw()
    birds:Draw()
    
    love.graphics.draw(assets["img/menubird_"..tostring(birdAnim[bird.AnimationFrame])..".png"], bird.X, bird.Y + bird.GetYOffset(bird.AnimationFrame))
    love.graphics.draw(assets["img/menu_overlay.png"], 0, 0)
    
    if selection == 1 then
        -- If video selected, text pops out more
        love.graphics.setColor(136/255, 187/255, 240/255)
        love.graphics.print("Video", 126, 55)
        love.graphics.setColor(1,1,1)
        love.graphics.print("Video", 125, 55)           
    else
        love.graphics.setColor(136/255, 187/255, 240/255)
        love.graphics.print("Video", 125, 55)
    end
    
    
    if selection == 2 then
        -- If music selected, text pops out more
        love.graphics.setColor(136/255, 187/255, 240/255)
        love.graphics.print("Music", 126, 75)
        love.graphics.setColor(1,1,1)
        love.graphics.print("Music", 125, 75)
    else
        love.graphics.setColor(136/255, 187/255, 240/255)
        love.graphics.print("Music", 125, 75)
    end
    
    love.graphics.setColor(1,1,1)
end

function menu:KeyPressed(key)
    if key == "w" then
        if selection == 2 then
            selection = 1

            Blip()
            yan:NewTween(bird, yan:TweenInfo(0.5, EasingStyle.CircularOut), {Y = 48}):Play()
        end
    elseif key == "s" then
        if selection == 1 then
            selection = 2

            Blip()
            yan:NewTween(bird, yan:TweenInfo(0.5, EasingStyle.CircularOut), {Y = 68}):Play()
        end
    elseif key == "space" then
        yan:NewTween(common.Fade, yan:TweenInfo(0.3), {Alpha = 1}):Play()
        
        Blip()
        biribiri:CreateAndStartTimer(1, function ()
            if selection == 1 then
                common.Scene = "video"
                video:OpenVideos()
            elseif selection == 2 then
                common.Scene = "music"
            end

            common.Fade.Alpha = 0
        end)
    end
end

function menu:Update(dt)
    birds:Update(dt)
    clouds:Update(dt)
end

return menu