local textinput = {}
local guibase = require("yan.instance.ui.guibase")
textinput.__index = guibase

local utf8 = require("utf8")
local Color = require("yan.datatypes.color")
function textinput:New(screen, placeholderText, textSize, align, verticalAlign, fontPath)
    local o = guibase:New(screen)
    setmetatable(o, self)
    
    o.PlaceholderText = placeholderText
    o.Text = ""
    o.IsTyping = false
    o.TextSize = textSize
    o.Type = "TextInput"
    o.Align = align
    o.VerticalAlign = verticalAlign
    o.CornerRoundness = 0
    
    if fontPath ~= nil then
        o.Font = love.graphics.newFont(fontPath, o.TextSize)
    else
        o.Font = love.graphics.newFont(o.TextSize)
    end
    
    o.TextColor = Color.new(1,1,1,1)

    o.PlaceholderTextColor = Color.new(0.5,0.5,0.5,1)
    
    function o:TextInput(t)
        if o.IsTyping == false then return end

        o.Text = o.Text..t
    end

    function o:KeyPressed(key, scancode, rep)
        if o.IsTyping == false then
            love.keyboard.setKeyRepeat(false)
            return 
        end
        love.keyboard.setKeyRepeat(true)
        if key == "backspace" then

            local byteoffset = utf8.offset(o.Text, -1)
    
            if byteoffset then
                o.Text = string.sub(o.Text, 1, byteoffset - 1)
            end
        end

        if key == "return" then
            o.IsTyping = false

            if o.OnEnter ~= nil then
                o.OnEnter()
            end
        end
    end
    
    function o:Draw()
        local pX, pY, sX, sY = o:GetDrawingCoordinates()
        
        love.graphics.setColor(o.Color:GetColors())
        
        love.graphics.rectangle("fill", pX, pY, sX, sY, o.CornerRoundness, o.CornerRoundness)
        
        love.graphics.setFont(o.Font)
        
        local yOffset = 0
        
        if o.VerticalAlign == "center" then
            local _, lines = o.Font:getWrap(o.Text, sX)
            yOffset = sY * 0.5 - ((o.Font:getHeight() / 2) * #lines)
        elseif o.VerticalAlign == "bottom" then
            local _, lines = o.Font:getWrap(o.Text, sX)
            yOffset = sY * 1 - ((o.Font:getHeight()) * #lines)
        end
        
        if o.Text == "" and o.IsTyping == false then
            love.graphics.setColor(o.PlaceholderTextColor:GetColors())
            love.graphics.printf(
                o.PlaceholderText, 
                pX,
                pY + yOffset,
                sX,
                o.Align
            )
        else
            love.graphics.setColor(o.TextColor:GetColors())
            if o.IsTyping then
                love.graphics.printf(
                o.Text .. "|", 
                pX,
                pY + yOffset,
                sX,
                o.Align
            )
            else
                love.graphics.printf(
                o.Text, 
                pX,
                pY + yOffset,
                sX,
                o.Align
            )
            end
        end
        
        love.graphics.setColor(1,1,1,1)
    end

    return o
end

return textinput