local slider = {}
local guibase = require("yan.instance.ui.guibase")
local Color = require("yan.datatypes.color")
local UIVector = require("yan.datatypes.uivector")
local utils = require("yan.utils")

slider.__index = guibase

function slider:New(screen, minValue, maxValue, defaultValue)
    local o = guibase:New(screen)
    o.Type = "Slider"
    o.Progress = defaultValue / maxValue
    o.Value = defaultValue
    o.CornerRoundness = 8 
    o.Direction = "horizontal"
    o.Style = "bar"
    
    o.SliderColor = Color.new(0.7,0.7,0.7,0.5)
    o.SliderSize = UIVector.new(0,50)

    o.WasSliding = false

    function o.Slide(mX, mY)
        local pX, pY, sX, sY = o:GetDrawingCoordinates()
        
        if o.Direction == "horizontal" then
            o.Progress = utils:Clamp((mX - pX) / sX, 0.0, 1.0)
            o.Value = minValue + (maxValue - minValue) * o.Progress
        else
            o.Progress = -((utils:Clamp((mY - pY) / sY, 0.0, 1.0)) - 1)
            print(o.Progress)
            o.Value = minValue + (maxValue - minValue) * o.Progress
        end
        
        if o.OnSlide ~= nil then
            o.OnSlide(o.Value)
        end
    end
    
    function o:Draw()
        local mX, mY = love.mouse.getPosition()
        local pX, pY, sX, sY = o:GetDrawingCoordinates()
        
        if love.mouse.isDown(1) and (utils:CheckCollision(mX, mY, 1, 1, pX, pY, sX, sY) or o.WasSliding) then
            o.WasSliding = true
            o.Slide(mX, mY)
        end
        
        if not love.mouse.isDown(1) then
            o.WasSliding = false
        end
        
        love.graphics.setColor(o.Color:GetColors())        
        love.graphics.rectangle("fill", pX, pY, sX, sY, o.CornerRoundness, o.CornerRoundness)
        
        love.graphics.setColor(o.SliderColor:GetColors())
        if o.Direction == "horizontal" then
            if o.Style == "bar" then
                love.graphics.rectangle("fill", pX + ((sX - o.SliderSize.Offset) * o.Progress), pY, o.SliderSize.Offset, sY, o.CornerRoundness, o.CornerRoundness)
            elseif o.Style == "fill" then
                if o.Progress > 0 then
                    love.graphics.rectangle("fill", pX, pY, sX * o.Progress, sY, o.CornerRoundness, o.CornerRoundness)
                end
            end
            
        elseif o.Direction == "vertical" then
            if o.Style == "bar" then
                love.graphics.rectangle("fill", pX, pY + ((sY - o.SliderSize.Offset) * -o.Progress) + sY - o.SliderSize.Offset, sX, o.SliderSize.Offset, o.CornerRoundness, o.CornerRoundness)
            elseif o.Style == "fill" then
                if o.Progress > 0 then
                    love.graphics.rectangle("fill", pX, pY + sY * -o.Progress + sY, sX, -(sY * -o.Progress), o.CornerRoundness, o.CornerRoundness)
                end
            end
        end
        
    end
    
    return o
end

return slider