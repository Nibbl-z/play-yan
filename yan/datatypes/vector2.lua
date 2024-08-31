local Vector2 = {}
Vector2.__index = Vector2

function Vector2.new(x, y)
    local v = {X = x, Y = y}

    setmetatable(v, Vector2)
    return v
end

function Vector2.__add(a, b)
    return Vector2.new(
        a.X + b.X,
        a.Y + b.Y
    )
end

function Vector2.__sub(a, b)
    return Vector2.new(
        a.X - b.X,
        a.Y - b.Y
    )
end

function Vector2.__mul(a, b)
    return Vector2.new(
        a.X * b,
        a.Y * b
    )
end

function Vector2.__tostring(v)
    return tostring(v.X).." "..tostring(v.Y)
end

return Vector2