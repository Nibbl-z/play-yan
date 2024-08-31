local scrollable = {}
local guibase = require("yan.instance.ui.guibase")
local utils = require("yan.utils")
scrollable.__index = guibase

local UIVector = require("yan.datatypes.uivector")
local Color = require("yan.datatypes.color")
local Vector2 = require("yan.datatypes.vector2")
function scrollable:New(screen, direction)
    local o = guibase:New(screen)
    setmetatable(o, self)
    
    o.Type = "Scrollable"
    o.CornerRoundness = 0
    
    o.ScrollOffset = 0
    o.ScrollSpeed = 20
    o.ScrollSize = UIVector.new(2,0)
    
    o.ScrollbarVisible = true 
    o.ScrollbarColor = Color.new(0, 0, 0, 0.5)
    o.ScrollbarWidth = 16
    o.ScrollbarSize = UIVector.new(0.3,0)
    o.ScrollDirection = direction
    
    o.ScrollbarDrawPosition = Vector2.new(0,0)
    o.ScrollbarDrawSize = {}

    o.MaskChildren = true

    function o:WheelMoved(x, y)
        if o.Scrollable == false then return end
        local pX, pY, sX, sY = o:GetDrawingCoordinates()
        
        local mX, mY = love.mouse.getPosition()
        
        if utils:CheckCollision(mX, mY, 1, 1, pX, pY, sX, sY) then
            if o.ScrollDirection == "vertical" then
                o.ScrollOffset = utils:Clamp(o.ScrollOffset + y * o.ScrollSpeed, 0, -((sY * o.ScrollSize.Scale + o.ScrollSize.Offset)) + sY)
            else
                o.ScrollOffset = utils:Clamp(o.ScrollOffset + y * o.ScrollSpeed, 0, -((sX * o.ScrollSize.Scale + o.ScrollSize.Offset)) + sX)
            end   
        end
    end

    function o:Draw()
        local pX, pY, sX, sY = o:GetDrawingCoordinates()
        
        love.graphics.setColor(o.Color:GetColors())
        love.graphics.rectangle("fill", pX, pY, sX, sY, o.CornerRoundness, o.CornerRoundness)
        
        if o.ScrollbarVisible == true then
            love.graphics.setColor(o.ScrollbarColor:GetColors())
            
            if o.ScrollDirection == "vertical" then
                local scrollbarSize = (sY * o.ScrollbarSize.Scale) + o.ScrollbarSize.Offset
                local maxY = sY - scrollbarSize
                
                o.ScrollbarDrawPosition = {
                    X = pX + sX - o.ScrollbarWidth,
                    Y = pY + maxY * (math.abs(o.ScrollOffset) / (((o.ScrollSize.Scale * sY) + o.ScrollSize.Offset) - sY))
                }
                
                o.ScrollbarDrawSize = {
                    X = o.ScrollbarWidth,
                    Y = scrollbarSize
                }

                love.graphics.rectangle(
                    "fill", 
                    pX + sX - o.ScrollbarWidth, 
                    pY + maxY * (math.abs(o.ScrollOffset) / (((o.ScrollSize.Scale * sY) + o.ScrollSize.Offset) - sY)),
                    o.ScrollbarWidth, 
                    scrollbarSize,
                    8
                ) 
            else
                local scrollbarSize = (sX * o.ScrollbarSize.Scale) + o.ScrollbarSize.Offset
                local maxX = sX - scrollbarSize

                o.ScrollbarDrawPosition = {
                    X = pX + maxX * (math.abs(o.ScrollOffset) / (((o.ScrollSize.Scale * sX) + o.ScrollSize.Offset) - sX)),
                    Y =  pY + sY - o.ScrollbarWidth
                }
                
                o.ScrollbarDrawSize = {
                    X = scrollbarSize,
                    Y = o.ScrollbarWidth
                }
                
                love.graphics.rectangle(
                    "fill", 
                    pX + maxX * (math.abs(o.ScrollOffset) / (((o.ScrollSize.Scale * sX) + o.ScrollSize.Offset) - sX)),
                    pY + sY - o.ScrollbarWidth,
                    scrollbarSize,
                    o.ScrollbarWidth,
                    8
                ) 
            end
            
        end
    end
    
    return o
end

return scrollable