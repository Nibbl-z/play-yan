local label = {}
local guibase = require("yan.instance.ui.guibase")
label.__index = guibase

local Color = require("yan.datatypes.color")

function label:New(screen, text, textSize, align, verticalAlign, fontPath)
    local o = guibase:New(screen)
    setmetatable(o, self)
    
    o.Type = "Label"
    o.Text = text
    o.TextSize = textSize
    o.Align = align
    o.VerticalAlign = verticalAlign
    
    if fontPath ~= nil then
        o.Font = love.graphics.newFont(fontPath, o.TextSize)
    else
        o.Font = love.graphics.newFont(o.TextSize)
    end
    
    o.TextColor = Color.new(0,0,0,1)
    
    function o:Draw()
        local pX, pY, sX, sY = o:GetDrawingCoordinates()
        
        love.graphics.setFont(o.Font)
        love.graphics.setColor(o.TextColor:GetColors())
        
        local yOffset = 0
        
        if o.VerticalAlign == "center" then
            local _, lines = o.Font:getWrap(o.Text, sX)
            yOffset = sY * 0.5 - ((o.Font:getHeight() / 2) * #lines)
        elseif o.VerticalAlign == "bottom" then
            local _, lines = o.Font:getWrap(o.Text, sX)
            yOffset = sY * 1 - ((o.Font:getHeight()) * #lines)
        end

        love.graphics.printf(
            o.Text, 
            pX,
            pY + yOffset,
            sX, 
            o.Align
        )

        love.graphics.setColor(1,1,1,1)
    end
    
    return o
end

return label