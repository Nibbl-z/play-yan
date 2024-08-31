local instance = {}
instance.__index = instance
--[[instance.Position = {X = 0, Y = 0}
instance.Rotation = 0
instance.Size = {X = 1, Y = 1}
instance.Sprite = nil]]

local Vector2 = require("yan.datatypes.vector2")
local Color = require("yan.datatypes.color")

function instance:New(name)
    local o = {
        Name = name,
        Position = Vector2.new(0,0),
        Rotation = 0,
        Size = Vector2.new(1,1),
        Offset = Vector2.new(0,0),
        Sprite = nil,
        Shape = nil,
        Color = Color.new(1,1,1,1),
        Type = "Instance",
        Scene = nil,
        SceneEnabled = true,
        Visible = true
    }
    setmetatable(o, self)
    
    if name == nil then
        math.randomseed(love.timer.getTime())
        o.Name = tostring(love.timer.getTime() * 1000 * math.random(1,1000))
    end
    
    function o:SetSprite(spritePath)
        o.Sprite = love.graphics.newImage(spritePath)
    end

    function o:SetLoadedSprite(sprite)
        o.Sprite = sprite
    end

    function o:Draw()
        if not o.Visible then return end
        if o.SceneEnabled == false then return end
        love.graphics.setColor(o.Color:GetColors())
    
        if o.Sprite ~= nil then
            love.graphics.draw(
                o.Sprite,
                o.Position.X,
                o.Position.Y,
                o.Rotation,
                o.Size.X,
                o.Size.Y,
                o.Offset.X,
                o.Offset.Y
            )
        elseif o.Shape == "rectangle" then
            love.graphics.rectangle(
                "fill",
                o.Position.X,
                o.Position.Y,
                o.Size.X,
                o.Size.Y
            )
        end
    end
    
    return o
end

return instance