local grid = {}
local guibase = require("yan.instance.ui.guibase")
local utils = require("yan.utils")
grid.__index = guibase

function grid:New(screen, padding, verticalAlign, horizontalAlign, direction, gridSize)
    local o = guibase:New(screen)
    setmetatable(o, self)
    
    o.Type = "Grid"
    o.GridPadding = padding or 0
    o.VerticalAlignmenet = verticalAlign or "top"
    o.HorizontalAlignment = horizontalAlign or "left"
    o.CornerRoundness = 16
    o.Direction = direction or "vertical"
    o.GridSize = gridSize or 4
    
    function o:GetOffsetForGridItem(element)
        if #o.Children == 0 then return 0, 0 end
        
        if element.LayoutOrder == 1 then return 0, 0 end
        
        local xOffset = 0
        local yOffset = 0
        
        local gridIndex = 1
        for i = 1, element.LayoutOrder - 1 do
            local currentItem = o.Children[i]
            
            if currentItem ~= nil then
                local _, _, itemX, itemY = currentItem:GetDrawingCoordinates(true)
                
                if o.Direction == "vertical" then
                    yOffset = yOffset + itemY + o.GridPadding 
                    
                    if gridIndex >= o.GridSize then
                        gridIndex = 1
                        xOffset = xOffset + itemX + o.GridPadding
                        yOffset = 0
                    end
                elseif o.Direction == "horizontal" then
                    xOffset = xOffset + itemX + o.GridPadding 

                    if gridIndex >= o.GridSize then
                        gridIndex = 1
                        yOffset = yOffset + itemY + o.GridPadding
                        xOffset = 0
                    end
                end
            end
            gridIndex = gridIndex + 1
        end
        
        --[[if o.Parent ~= nil then
            if o.Parent.Type == "Scrollable" then
                totalOffset = totalOffset + o.Parent.ScrollOffset
            end
        end]]

        return xOffset, yOffset
    end

    function o:Draw()
        local pX, pY, sX, sY = o:GetDrawingCoordinates()
        
        love.graphics.setColor(o.Color:GetColors())
        love.graphics.rectangle("fill", pX, pY, sX, sY, o.CornerRoundness, o.CornerRoundness)
    end
    
    return o
end

return grid