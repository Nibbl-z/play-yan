local list = {}
local guibase = require("yan.instance.ui.guibase")
local utils = require("yan.utils")
list.__index = guibase

function list:New(screen, padding, align, direction)
    local o = guibase:New(screen)
    setmetatable(o, self)
    
    o.Type = "List"
    o.ListPadding = padding or 0
    o.Align = align or "left"
    o.CornerRoundness = 16
    o.Direction = direction
    
    function o:GetOffsetForListItem(element)
        --if #o.Children == 0 then return 0 end
        
        if element.LayoutOrder == 1 then return 0 end
        
        local totalOffset = 0
        
        for i = 1, element.LayoutOrder - 1 do
            local currentItem = o.Children[i]
            
            if currentItem ~= nil then
                local _, _, itemX, itemY = currentItem:GetDrawingCoordinates(true)
                
                if o.Direction == "vertical" then
                    totalOffset = totalOffset + itemY + o.ListPadding 
                elseif o.Direction == "horizontal" then
                    totalOffset = totalOffset + itemX + o.ListPadding 
                end
            end
        end
        
        --[[if o.Parent ~= nil then
            if o.Parent.Type == "Scrollable" then
                totalOffset = totalOffset + o.Parent.ScrollOffset
            end
        end]]

        return totalOffset
    end

    function o:Draw()
        local pX, pY, sX, sY = o:GetDrawingCoordinates()
        
        love.graphics.setColor(o.Color:GetColors())
        love.graphics.rectangle("fill", pX, pY, sX, sY, o.CornerRoundness, o.CornerRoundness)
    end
    
    return o
end

return list