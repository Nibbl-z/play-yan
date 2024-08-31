local guiBase = {}
local instance = require("yan.instance.instance")
guiBase.__index = instance

local utils = require("yan.utils")
local UIVector2 = require("yan.datatypes.uivector2")
local Vector2 = require("yan.datatypes.vector2")

function guiBase:New(screen)
    local o = instance:New()
    setmetatable(o, self)
    
    o.Type = "GuiBase"

    o.Position = UIVector2.new(o.Position.X, 0, o.Position.Y, 0)
    
    o.Size = UIVector2.new(o.Size.X, 0, o.Size.Y, 0)
    
    o.Padding = UIVector2.new(0,0,0,0)

    o.AnchorPoint = Vector2.new(0, 0)
    o.ZIndex = 1
    o.LayoutOrder = 1
    
    o.Children = {}
    o.Parent = nil
    o.MaskChildren = false
    
    screen:AddElement(o)
    
    function o:GetDrawingCoordinates(ignoreYOffset)
        local sizeWidth = love.graphics.getWidth()
        local sizeHeight = love.graphics.getHeight()
        local pXOffset = 0
        local pYOffset = 0

        if o.Parent ~= nil then
            pXOffset, pYOffset, sizeWidth, sizeHeight = o.Parent:GetDrawingCoordinates()
            
            if o.Parent.Type == "Scrollable" then
                if o.Parent.ScrollDirection == "horizontal" then
                    sizeWidth = sizeWidth * o.Parent.ScrollSize.Scale + o.Parent.ScrollSize.Offset
                
                    pXOffset = pXOffset + o.Parent.ScrollOffset
                elseif o.Parent.ScrollDirection == "vertical" then
                    sizeHeight = sizeHeight * o.Parent.ScrollSize.Scale + o.Parent.ScrollSize.Offset
                
                    pYOffset = pYOffset + o.Parent.ScrollOffset
                end
                
            end

            if o.Parent.Type == "List" and ignoreYOffset ~= true then
                if o.Parent.Direction == "horizontal" then
                    pXOffset = pXOffset + o.Parent:GetOffsetForListItem(o)
                
                    if o.Parent.Align == "center" then
                        pYOffset = pYOffset + ((o.Size.YScale * sizeHeight + o.Size.YOffset) * 0.5) 
                    elseif o.Parent.Align == "bottom" then
                        pYOffset = pYOffset + ((o.Size.YScale * sizeHeight + o.Size.YOffset)) 
                    end
                elseif o.Parent.Direction == "vertical" then
                    pYOffset = pYOffset + o.Parent:GetOffsetForListItem(o)
                
                    if o.Parent.Align == "center" then
                        pXOffset = pXOffset + ((o.Size.XScale * sizeWidth + o.Size.XOffset) * 0.5) 
                    elseif o.Parent.Align == "right" then
                        pXOffset = pXOffset + ((o.Size.XScale * sizeWidth + o.Size.XOffset)) 
                    end
                end
            end
            
            if o.Parent.Type == "Grid" and ignoreYOffset ~= true then
                local gridXOffset, gridYOffset = o.Parent:GetOffsetForGridItem(o)
                
                pXOffset = pXOffset + gridXOffset
                pYOffset = pYOffset + gridYOffset
                -- TODO: align stuff
                if o.Parent.Direction == "horizontal" then
                    local rows = math.ceil(#o.Parent.Children / o.Parent.GridSize)
                    local excessOffsetY = sizeHeight - (o.Size.YScale * sizeHeight + o.Size.YOffset) * rows - (o.Parent.GridPadding) * (rows - 1)
                    local excessOffsetX = sizeWidth - (o.Size.XScale * sizeWidth + o.Size.XOffset) * o.Parent.GridSize - (o.Parent.GridPadding) * (o.Parent.GridSize - 1)

                    if o.Parent.VerticalAlignment == "center" then
                        pYOffset = pYOffset + excessOffsetY / 2
                    elseif o.Parent.VerticalAlignment == "bottom" then
                        pYOffset = pYOffset + excessOffsetY
                    end

                    if o.Parent.HorizontalAlignment == "center" then
                        pXOffset = pXOffset + excessOffsetX / 2
                    elseif o.Parent.HorizontalAlignment == "right" then
                        pXOffset = pXOffset + excessOffsetX
                    end
                elseif o.Parent.Direction == "vertical" then
                    local cols = math.ceil(#o.Parent.Children / o.Parent.GridSize)
                    local excessOffsetY = sizeHeight - (o.Size.YScale * sizeHeight + o.Size.YOffset) * o.Parent.GridSize - (o.Parent.GridPadding) * (o.Parent.GridSize - 1)
                    local excessOffsetX = sizeWidth - (o.Size.XScale * sizeWidth + o.Size.XOffset) * cols - (o.Parent.GridPadding) * (cols - 1)
                    if o.Parent.VerticalAlignment == "center" then
                        pYOffset = pYOffset + excessOffsetY / 2
                    elseif o.Parent.VerticalAlignment == "bottom" then
                        pYOffset = pYOffset + excessOffsetY
                    end

                    if o.Parent.HorizontalAlignment == "center" then
                        pXOffset = pXOffset + excessOffsetX / 2
                    elseif o.Parent.HorizontalAlignment == "right" then
                        pXOffset = pXOffset + excessOffsetX
                    end
                end

            end
            
            
            pXOffset = pXOffset + o.Parent.Padding.XOffset + (sizeWidth * o.Parent.Padding.XScale)
            pYOffset = pYOffset + o.Parent.Padding.YOffset + (sizeHeight * o.Parent.Padding.YScale)
            
            sizeWidth = sizeWidth - (o.Parent.Padding.XOffset + (sizeWidth * o.Parent.Padding.XScale)) * 2
            sizeHeight = sizeHeight - (o.Parent.Padding.YOffset + (sizeHeight * o.Parent.Padding.YScale)) * 2
        end

      
        
        local sX = o.Size.XScale * sizeWidth + o.Size.XOffset
        local sY = o.Size.YScale * sizeHeight + o.Size.YOffset
        
        local pX = (o.Position.XScale * sizeWidth - sX * o.AnchorPoint.X) + o.Position.XOffset + pXOffset
        local pY = (o.Position.YScale * sizeHeight - sY * o.AnchorPoint.Y) + o.Position.YOffset + pYOffset
        return pX, pY, sX, sY
    end
    
    function o:Stencil(parent)
        if parent == nil then
            return
        end

        
        
        if parent then
            if parent.MaskChildren == true then
                pX, pY, sX, sY = parent:GetDrawingCoordinates()
                
                love.graphics.stencil(function ()
                    love.graphics.rectangle("fill", pX, pY, sX, sY, o.CornerRoundness or 0, o.CornerRoundness or 0)
                end, "replace", 1)
                love.graphics.setStencilTest("greater", 0)
            else
                o:Stencil(parent.Parent)
            end
        else
            return
        end
    end
    
    function o:Draw()
        local pX, pY, sX, sY = o:GetDrawingCoordinates()
        
        love.graphics.rectangle("line", pX, pY, sX, sY)
    end
    
    function o:SetParent(element)

        table.insert(element.Children, o)
        
        o.Parent = element
    end

    function o:GetChild(elementName)
        for i, child in pairs(o.Children) do
            if child.Parent ~= o then
                table.remove(i, o.Children)
            end
            
            if child.Name == elementName then
                return child
            end
        end
        
        return nil
    end
    
    function o:GetAncestor(elementName)
        if o.Parent.Name == elementName then
            return o.Parent
        else
            return o.Parent:GetAncestor(elementName)
        end
    end
    
    function o:GetDescendant(elementName)
        if #o.Children == 0 then return nil end

        for i, child in ipairs(o.Children) do
            if child.Parent ~= o then
                table.remove(i, o.Children)
            end
            if child.Name == elementName then
                return child
            else
                local dillyDally = child:GetDescendant(elementName) -- thanks josh for giving me this awesome variable name, i appreciate it
                
                if dillyDally ~= nil then
                    return dillyDally
                end
            end
        end
    end

    function o:ApplyTheme(theme)
        if o.Type ~= "Image" and o.Type ~= "ImageButton" then
            o.Color = theme.Color
        end
       
        if o.Type == "TextButton" or o.Type == "TextInput" or o.Type == "Dropdown" then
            function o:MouseEnterDefault()
                o.Color = theme.HoverColor
            end
            
            function o:MouseLeaveDefault()
                o.Color = theme.Color
            end
    
            function o:MouseDownDefault()
                o.Color = theme.SelectedColor
            end
    
            function o:MouseUpDefault()
                o.Color = theme.Color
            end
        end

        if o.Type == "Label" or o.Type == "TextButton" or o.Type == "TextInput" then
            o.TextColor = theme.TextColor

            if theme.Font ~= nil then
                o.Font = love.graphics.newFont(theme.Font, o.TextSize)
            end
        end

        if o.Type == "TextInput" then
            o.PlaceholderTextColor = theme.PlaceholderTextColor
        end

        if o.CornerRoundness ~= nil then
            o.CornerRoundness = theme.CornerRoundness
        end

        if o.Type == "Scrollable" then
            o.ScrollbarColor = theme.ScrollbarColor
            o.ScrollbarWidth = theme.ScrollbarWidth
        end
    end

    return o
end

return guiBase