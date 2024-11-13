local clouds = {}
clouds.Clouds = {}

require "yan"
require "biribiri"

function NewCloud(initial)
    local speed = love.math.random(10, 20)
    local x = love.math.random(-30, 240)
    if not initial then
        x = -30
    end
    local cloud = {
        X = x,
        Y = 100 - speed * 3 + 65 + love.math.random(-10, 10) / 10,
        Speed = speed,
        EndX = love.math.random(190, 240),
        Finished = false
    }
    
    table.insert(clouds.Clouds, cloud)
end
function clouds:Draw()
    table.sort(self.Clouds, function (a, b)
        return a.Y < b.Y
    end)
    
    for _, cloud in ipairs(self.Clouds) do
        love.graphics.draw(assets["img/menu_cloud.png"], cloud.X, cloud.Y)
    end
end

function clouds:Init()
    for i = 1, 30 do
        NewCloud(true)
    end
    
end

function clouds:Update(dt)
    for _, cloud in ipairs(self.Clouds) do
        cloud.X = cloud.X + cloud.Speed * dt
        if cloud.X >= cloud.EndX and cloud.Finished == false then
            NewCloud()
            cloud.Finished = true
        end
    end
end

return clouds