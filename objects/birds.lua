local birds = {}
birds.Birds = {}

local animation = {1, 1, 1, 2, 3, 4, 5, 4, 3, 2}
require "biribiri"
function NewBird(initial)
    local speed = love.math.random(30, 50)
    local x = love.math.random(0, 240)
    
    if not initial then
        x = 240
    end
    
    local bird = {
        X = x,
        Y = love.math.random(40, 130),
        Speed = speed,
        EndX = love.math.random(0, 40),
        Finished = false,
        Frame = love.math.random(1, #animation)
    }
    
    table.insert(birds.Birds, bird)
end

function birds:Draw()
    for _, bird in ipairs(self.Birds) do
        love.graphics.draw(assets["img/menubgbird_"..tostring(animation[bird.Frame])..".png"], bird.X, bird.Y)
    end
end

function birds:Init()
    for i = 1, 15 do
        NewBird(true)
    end

    biribiri:CreateAndStartTimer(0.04, function ()
        for _, bird in ipairs(self.Birds) do
            bird.Frame = bird.Frame + 1
            if bird.Frame > #animation then
                bird.Frame = 1
            end
        end
    end, true)
end
function birds:Update(dt)
    for _, bird in ipairs(self.Birds) do
        bird.X = bird.X - bird.Speed * dt
        if bird.X <= bird.EndX and bird.Finished == false then
            NewBird()
            bird.Finished = true
        end
    end
end

return birds