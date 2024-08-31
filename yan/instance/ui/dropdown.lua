local dropdown = {}
local guibase = require("yan.instance.ui.guibase")
local UIVector2 = require("yan.datatypes.uivector2")
local UIVector = require("yan.datatypes.uivector")
local Scrollable = require("yan.instance.ui.scrollable")
local List = require("yan.instance.ui.list")
local Vector2 = require("yan.datatypes.vector2")
local Color = require("yan.datatypes.color")
dropdown.__index = guibase
function dropdown:New(screen, defaultElement, elementList)
    local o = guibase:New(screen)
    setmetatable(o, self)
    o.Type = "Dropdown"
    o.DefaultElement = defaultElement
    o.ElementList = {}
    o.CornerRoundness = 0
    
    o.IsOpened = true
    o.ItemsScrollable = Scrollable:New(screen, "vertical")
    o.ItemsList = List:New(screen, 5, "left", "vertical")
    
    o.ItemsScrollable.Dropdown = o
    o.ItemsList.Parent = o.ItemsScrollable
    o.ItemsScrollable.MaskChildren = true
    o.ItemsScrollable.Visible = false
    o.ItemsList.Visible = false
    o.DropdownContentSize = UIVector.new(3, 0)
    o.ItemsScrollable.ScrollSize = o.DropdownContentSize
    o.DropdownSize = UIVector.new(0.4, 0)
    

    o.ItemsScrollable.ZIndex = o.ZIndex + 1
    o.ItemsList.ZIndex = o.ZIndex + 2
    o.ItemsList.Color = Color.new(0,0,0,0)
    
    o.ElementSize = UIVector.new(0,50)
    
    for i, element in ipairs(elementList) do
        element.Size = UIVector2.new(1, 0, o.ElementSize.Scale, o.ElementSize.Offset)
        
        element.ZIndex = element.ZIndex + 3
        element.LayoutOrder = i
        element.IsDropdownElement = true
        
        element:SetParent(o.ItemsList)
        table.insert(o.ElementList, element)
    end
    
    function o:AddToElementList(element)
        table.insert(o.ElementList, element)
        
        element.Parent = o.ItemsList
    end
    
    function o:Draw()
        local pX, pY, sX, sY = o:GetDrawingCoordinates()
        
        love.graphics.setColor(o.Color:GetColors())
        
        love.graphics.rectangle("fill", pX, pY, sX, sY, o.CornerRoundness, o.CornerRoundness)
        
        if o.IsOpened then
            for _, element in ipairs(elementList) do
                element.Visible = true
            end
            if defaultElement ~= nil then
                defaultElement.Size = UIVector2.new(0, sX, 0, sY)
                defaultElement.Position = UIVector2.new(0, pX, 0, pY)
                defaultElement.ZIndex = o.ZIndex + 1
            end

            o.ItemsScrollable.Visible = true
            o.ItemsList.Visible = true
            
            o.ItemsScrollable.Position = UIVector2.new(0, pX, 0, pY + sY)
            
            o.ItemsScrollable.Size = UIVector2.new(0, sX, o.DropdownSize.Scale, o.DropdownSize.Offset)
            o.ItemsScrollable.ScrollSize = o.DropdownContentSize
        else
            for _, element in ipairs(elementList) do
                element.Visible = false
            end
            o.ItemsScrollable.Visible = false
            o.ItemsList.Visible = false
            if defaultElement ~= nil then
                defaultElement.Size = UIVector2.new(0, sX, 0, sY)
                defaultElement.Position = UIVector2.new(0, pX, 0, pY)
                defaultElement.ZIndex = o.ZIndex + 1
            end
        end
        
        love.graphics.setColor(1,1,1,1)
    end

    return o
end

return dropdown