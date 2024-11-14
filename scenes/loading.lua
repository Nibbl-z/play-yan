local loading = {}

local common = require("common")
local menu = require("scenes.menu")
require "yan"
require "biribiri"

local bird = {X = 240, Y = -20, Sprite = "img/loadingbird_stand.png", Flapping = true, AnimationFrame = 1}
local yanBlink = false

local birdFlapAnimation = {"wingup", "glide", "wingdown", "glide"}

function FinishLoading()
    yan:NewTween(common.Fade, yan:TweenInfo(0.5), {Alpha = 1}):Play()
    biribiri:CreateAndStartTimer(0.5, function ()
        common.Scene = "menu"
        MenuEnter()
        yan:NewTween(common.Fade, yan:TweenInfo(0.5), {Alpha = 0}):Play()
    end)
end

function loading:Initialize()
    local function Blink()
        yanBlink = true
        
        biribiri:CreateAndStartTimer(0.06, function ()
            yanBlink = false
        end)
    end
    
    -- Loop through animation frames
    biribiri:CreateAndStartTimer(0.04, function ()
        bird.AnimationFrame = bird.AnimationFrame + 1
        if bird.AnimationFrame == 5 then bird.AnimationFrame = 1 end
    end, true)

    -- Bird fly in
    yan:NewTween(bird, yan:TweenInfo(2, EasingStyle.CircularOut), {X = 189, Y = 45}):Play()
    
    -- Bird land
    biribiri:CreateAndStartTimer(2, function ()
        bird.Flapping = false
    end)

    -- Play-Yan blinks
    biribiri:CreateAndStartTimer(2.4, function ()
        yanBlink = true
        Blink()
        
        biribiri:CreateAndStartTimer(0.12, Blink)
        biribiri:CreateAndStartTimer(0.9, Blink)
    end)
    
    -- Bird fly off
    biribiri:CreateAndStartTimer(4, function ()
        bird.Flapping = true
        yan:NewTween(bird, yan:TweenInfo(0.8, EasingStyle.CircularIn), {X = 100, Y = -20}):Play()
    end)
    
    -- Transition to menu
    biribiri:CreateAndStartTimer(4.5, function ()
        if common.Scene ~= "loading" then return end -- Don't fade again if skipped
        FinishLoading()
    end)
end

function loading:Draw()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(assets["img/loading_screen.png"], 0, 0)

    if bird.Flapping then
        love.graphics.draw(assets["img/loadingbird_"..birdFlapAnimation[bird.AnimationFrame]..".png"], bird.X, bird.Y)
    else
        love.graphics.draw(assets[bird.Sprite], bird.X, bird.Y)
    end

    if yanBlink then
        love.graphics.draw(assets["img/loadingyan_blink.png"], 0, 0)
    end
    love.graphics.setColor(0,0,0)
    love.graphics.print("Press any key to skip loading", 44, 140)
end

function loading:KeyPressed()
    FinishLoading()
end

return loading