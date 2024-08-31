local frame = {}
local guibase = require("yan.instance.ui.guibase")
frame.__index = guibase

function frame:New(screen)
    local o = guibase:New(screen)
    setmetatable(o, self)

    o.Type = "Frame"
    o.CornerRoundness = 0
    
    function o:Draw()
        local pX, pY, sX, sY = o:GetDrawingCoordinates()
        
        love.graphics.setColor(o.Color:GetColors())
        love.graphics.rectangle("fill", pX, pY, sX, sY, o.CornerRoundness, o.CornerRoundness)
        love.graphics.setColor(1,1,1,1)
    end
    
    return o
end

return frame