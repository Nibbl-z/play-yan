local screen = {}
local instance = require("yan.instance.instance")
screen.__index = instance

local utils = require("yan.utils")
local uimanager = require("yan.uimanager")

function screen:New()
    local o = instance:New()
    setmetatable(o, self)
    
    o.Type = "Screen"
    o.Enabled = true
    o.Elements = {}
    o.ZIndex = 1

    o.KeyboardInput = false

    function o:AddElement(element)
        table.insert(o.Elements, element)
    end
    
    local hovered = {}
    local clicked = {}
    
    local function ClickableCheck(clickable, element)
        if element.Visible == false then return end
        if element.IsDropdownElement ~= true then
            if (element.Type ~= "TextButton" and element.Type ~= "ImageButton" and element.Type ~= "TextInput" and element.Type ~= "Dropdown" and element.Type ~= "Slider") then return false end
        end
        
        
        
        local isDown = love.mouse.isDown(1)

        if clickable then
            if utils:TableFind(hovered, element) == false then
                if element.IsDropdownElement == true then
                    if element.Parent.Parent.Dropdown.ItemMouseEnter ~= nil  then
                        element.Parent.Parent.Dropdown.ItemMouseEnter(element)
                    end
                end

                if element.MouseEnter ~= nil then
                    element.MouseEnter()
                end
                
                if element.MouseEnterDefault ~= nil then
                    element.MouseEnterDefault()
                end
                
                table.insert(hovered, element)
            end
            
            if utils:TableFind(clicked, element) == false then
                if isDown then
                    
                    if element.IsDropdownElement == true then
                        if element.Parent.Parent.Dropdown.ItemMouseDown ~= nil  then
                            element.Parent.Parent.Dropdown.ItemMouseDown(element)
                        end
                        
                        element.Parent.Parent.Dropdown.IsOpened = false
                        
                        table.insert(clicked, element)
                    end

                    if element.MouseDown ~= nil then
                        element.MouseDown()
                        if element.Type == "TextInput" then
                            element.IsTyping = true
                        end
                        if element.Type == "Dropdown" then
                           
                            element.IsOpened = not element.IsOpened
                        end
                        
                        table.insert(clicked, element)
                    end

                    if element.MouseDownDefault ~= nil then
                        element.MouseDownDefault()

                        if element.Type == "TextInput" then
                            element.IsTyping = true
                        end
                        if element.Type == "Dropdown" then
                            element.IsOpened = not element.IsOpened
                        end
                        
                        if element.MouseDown == nil then table.insert(clicked, element) end
                    end
                end
            elseif utils:TableFind(clicked, element) ~= false then
                if not isDown then
                    if element.IsDropdownElement == true then
                        if element.Parent.Parent.Dropdown.ItemMouseUp ~= nil  then
                            element.Parent.Parent.Dropdown.ItemMouseUp(element)
                        end
                    end

                    if element.MouseUpDefault ~= nil then
                        element.MouseUpDefault()
                    end

                    if element.MouseUp ~= nil then
                        element.MouseUp()
                    end

                    
                    
                    if element.MouseEnter ~= nil then
                        element.MouseEnter()
                    end

                    if element.MouseEnterDefault ~= nil then
                        element.MouseEnterDefault()
                    end
                    
                    table.remove(clicked, utils:TableFind(clicked, element))
                end
            end
        else
            if utils:TableFind(hovered, element) ~= false then
                if utils:TableFind(clicked, element) ~= false then
                    if element.IsDropdownElement == true then
                        if element.Parent.Parent.Dropdown.ItemMouseUp ~= nil  then
                            element.Parent.Parent.Dropdown.ItemMouseUp(element)
                        end
                    end

                    if element.MouseUpDefault ~= nil then
                        element.MouseUpDefault()
                    end

                    if element.MouseUp ~= nil then
                        element:MouseUp()
                        table.remove(clicked, utils:TableFind(clicked, element))
                    end

                    
                end
                
                if element.IsDropdownElement == true then
                    if element.Parent.Parent.Dropdown.ItemMouseLeave ~= nil  then
                        element.Parent.Parent.Dropdown.ItemMouseLeave(element)
                    end
                end

                if element.MouseLeave ~= nil then
                    element.MouseLeave()
                end

                if element.MouseLeaveDefault ~= nil then
                    element.MouseLeaveDefault()
                end
                
                table.remove(hovered, utils:TableFind(hovered, element))
            end
            
            if isDown and element.Type == "TextInput" then
                element.IsTyping = false
            end
        end

        return true
    end

    function o:Update()
        if o.Enabled == false then return end
        local mX, mY = love.mouse.getPosition()
        
        local interactableElements = {}
        
        for _, element in ipairs(o.Elements) do
            local pX, pY, sX, sY = element:GetDrawingCoordinates()
            
            if element.Parent ~= nil and element.Parent.MaskChildren == true then

                    local ppX, ppY, psX, psY = element.Parent:GetDrawingCoordinates()
                    if utils:CheckCollision(mX, mY, 1, 1, ppX, ppY, psX, psY) == true then
                       
                        if utils:CheckCollision(mX, mY, 1, 1, pX, pY, sX, sY) == true then
                            table.insert(interactableElements, element)
                        end  
                    else
                        ClickableCheck(false, element)
                    end
            
            else
                if utils:CheckCollision(mX, mY, 1, 1, pX, pY, sX, sY) == true then
                    table.insert(interactableElements, element)
                else
                    ClickableCheck(false, element)
                end  
            end

            
        end
        
        table.sort(interactableElements, function(a,b) 
            return (a.ZIndex or 0) > (b.ZIndex or 0) 
        end)

        if #interactableElements >= 1 then
            
            local falsify = false
            
            for i, v in ipairs(interactableElements) do
                --local element = interactableElements[1]
                local pX, pY, sX, sY = v:GetDrawingCoordinates()
                
                if falsify then
                    ClickableCheck(false, v)
                else
                    local result = ClickableCheck(utils:CheckCollision(mX, mY, 1, 1, pX, pY, sX, sY), v)
                
                    if result == true then
                        falsify = true
                    end
                end
            end
        end

    end
    
    function o:TextInput(t)
        for _, element in ipairs(o.Elements) do
            if element.Type == "TextInput" then
                element:TextInput(t)
            end
        end
    end

    function o:KeyPressed(key, scancode, rep)
        for _, element in ipairs(o.Elements) do
            if element.Type == "TextInput" then
                element:KeyPressed(key, scancode, rep)
            end
        end
    end
    
    function o:WheelMoved(x, y)
        for _, element in ipairs(o.Elements) do
            if element.Type == "Scrollable" then
                element:WheelMoved(x, y)
            end
        end
    end

    function o:Draw()
        if o.Enabled == false then return end
        if o.SceneEnabled == false then return end
        
        local elements = o.Elements
        table.sort(elements, function(a,b) 
            return (a.ZIndex or 0) < (b.ZIndex or 0) 
        end)
        
        for _, element in ipairs(elements) do
            if element.Visible == true then
                if element.Type ~= "Image" and element.Type ~= "ImageButton" then -- excluding these because they need the stencil in the stencil for rounded corners or whatever
                    element:Stencil()
                end
                element:Draw()
                love.graphics.setStencilTest()
            end
        end
    end

    uimanager:AddScreen(o)
    
    return o
end

return screen