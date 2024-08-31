local UIVector = {}
UIVector.__index = UIVector

function UIVector.new(scale, offset)
    local v = {Scale = scale, Offset = offset}

    setmetatable(v, UIVector)
    return v
end

function UIVector.__add(a, b)
    return UIVector.new(
        a.Scale + b.Scale,
        a.Offset + b.Offset
    )
end

function UIVector.__sub(a, b)
    return UIVector.new(
        a.Scale - b.Scale,
        a.Offset - b.Offset
    )
end

function UIVector.__mul(a, b)
    return UIVector.new(
        a.Scale * b,
        a.Offset * b
    )
end

function UIVector.__tostring(v)
    return tostring(v.Scale).." "..tostring(v.Offset)
end

return UIVector