local stars = {}
stars.Stars = {}

require "yan"
require "biribiri"

function NewStar()
    local star = {
        X = love.math.random(150, 280),
        Y = love.math.random(-20,100),
        FlashOpacity = 1,
        StarOpacity = 1,
        Size = love.math.random(5,14) / 10,
        Rotation = 0,
        Draw = function (star, cx, cy)
            
            love.graphics.setColor(1,1,1,star.StarOpacity)
            love.graphics.draw(assets["img/star.png"], star.X - cx, star.Y - cy, star.Rotation, star.Size, star.Size, 20, 25)
            love.graphics.setColor(1,1,1,star.FlashOpacity)
            love.graphics.draw(assets["img/star_flash.png"], star.X - cx, star.Y - cy, star.Rotation, star.Size, star.Size, 20, 25)
            love.graphics.setColor(1,1,1,1)
        end
    }
    
    yan:NewTween(star, yan:TweenInfo(love.math.random(10, 20) / 10), {X = love.math.random(-20,100), Y = love.math.random(50,190), StarOpacity = 0, Rotation = 10, Size = 0}):Play()
    yan:NewTween(star, yan:TweenInfo(0.5), {FlashOpacity = 0}):Play()
    table.insert(stars.Stars, star)
    biribiri:CreateAndStartTimer(love.math.random(5,20) / 100, NewStar, false)
end

function stars:Init()
    NewStar()
end

function stars:Draw(cx, cy)
    for _, star in ipairs(self.Stars) do
        star.Draw(star, cx, cy)
    end
end

return stars