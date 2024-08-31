local uimanager = {}

uimanager.Screens = {}

function uimanager:AddScreen(screen)
    table.insert(self.Screens, screen)
end

function uimanager:Draw()
    local screens = self.Screens

    table.sort(screens, function(a,b) 
        return (a.ZIndex or 0) < (b.ZIndex or 0) 
    end)

    for _, screen in ipairs(screens) do
        screen:Draw()
    end
end

function uimanager:Update()
    for _, screen in ipairs(self.Screens) do
        screen:Update()
    end
end

function uimanager:TextInput(t)
    for _, screen in ipairs(self.Screens) do
        screen:TextInput(t)
    end
end

function uimanager:KeyPressed(key, scancode, rep)
    for _, screen in ipairs(self.Screens) do
        screen:KeyPressed(key, scancode, rep)
    end
end

function uimanager:WheelMoved(x, y)
    for _, screen in ipairs(self.Screens) do
        screen:WheelMoved(x, y)
    end
end

return uimanager