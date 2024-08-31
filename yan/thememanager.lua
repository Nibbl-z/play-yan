local thememanager = {}

local Color = require("yan.datatypes.color")

function thememanager:NewTheme()
    local theme = {
        Color = Color.new(1,1,1,1),
        HoverColor = Color.new(0.7,0.7,0.7,1),
        SelectedColor = Color.new(0.5,0.5,0.5,1),
        ScrollbarColor = Color.new(0,0,0,0.5),
        ScrollbarWidth = 16,

        Font = nil,
        TextColor = Color.new(0,0,0,1),
        PlaceholderTextColor = Color.new(0.3,0.3,0.3,1),

        CornerRoundness = 16
    }

    return theme
end

return thememanager