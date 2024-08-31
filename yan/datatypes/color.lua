local Color = {}
Color.__index = Color

local utils = require("yan.utils")

function Color.new(r, g, b, a)
    local c = {R = r, G = g, B = b, A = a}
    setmetatable(c, Color)
    return c
end

function Color.__add(a, b)
    return Color.new(
        a.R + b.R,
        a.G + b.G,
        a.B + b.B,
        a.A + b.A
    )
end

function Color.__sub(a, b)
    return Color.new(
        a.R - b.R,
        a.G - b.G,
        a.B - b.B,
        a.A - b.A
    )
end

function Color.__mul(a, b)
    return Color.new(
        a.R * b,
        a.G * b,
        a.B * b,
        a.A * b
    )
end

function Color.__tostring(v)
    return tostring(v.R).." "..tostring(v.G).." "..tostring(v.B).." "..tostring(v.A)
end

function Color:GetColors()
    return self.R, self.G, self.B, self.A
end

return Color