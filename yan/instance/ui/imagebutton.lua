local imagebutton = {}
local guibase = require("yan.instance.ui.guibase")
imagebutton.__index = guibase

function imagebutton:New(screen, image)
    local o = guibase:New(screen)
    setmetatable(o, self)
    
    o.Type = "ImageButton"
    o.Image = love.graphics.newImage(image)

    function o:Draw()
        local pX, pY, sX, sY = o:GetDrawingCoordinates()
        
        love.graphics.setColor(o.Color:GetColors())
        
        love.graphics.draw(o.Image, pX, pY, 0, sX / o.Image:getPixelWidth(), sY / o.Image:getPixelHeight())
        
        love.graphics.setColor(1,1,1,1)
    end

    return o
end

return imagebutton