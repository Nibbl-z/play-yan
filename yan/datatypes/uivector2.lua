local UIVector2 = {}
UIVector2.__index = UIVector2

function UIVector2.new(xScale, xOffset, yScale, yOffset)
    local v = {XOffset = xOffset, XScale = xScale, YOffset = yOffset, YScale = yScale}
    
    setmetatable(v, UIVector2)
    return v
end

function UIVector2.__add(a, b)
    return UIVector2.new(
        a.XScale + b.XScale,
        a.XOffset + b.XOffset,
        a.YScale + b.YScale,
        a.YOffset + b.YOffset
    )
end

function UIVector2.__sub(a, b)
    return UIVector2.new(
        a.XScale - b.XScale,
        a.XOffset - b.XOffset,
        a.YScale - b.YScale,
        a.YOffset - b.YOffset
    )
end

function UIVector2.__mul(a, b)
    return UIVector2.new(
        a.XScale * b,
        a.XOffset * b,
        a.YScale * b,
        a.YOffset * b
    )
end

function UIVector2.__tostring(v)
    return tostring(v.XScale).." "..tostring(v.XOffset).." "..tostring(v.YScale).." "..tostring(v.YOffset)
end

return UIVector2