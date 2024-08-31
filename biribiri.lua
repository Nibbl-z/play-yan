biribiri = {}

assets = {}

local Timer = require("biribiri.timer")

local activeTimers = {}

--- Creates a timer and then returns it
---@param duration number How many seconds until the function should be called?
---@param call function The function to call after the duration ends
---@param loop boolean? Should the timer loop after ending?
---@return Timer
function biribiri:CreateTimer(duration, call, loop)
    local t = Timer:New(duration, call, loop or false)
    
    table.insert(activeTimers, t)
    
    return t
end

--- Creates a timer, starts it, and then returns it
---@param duration number How many seconds until the function should be called?
---@param call function The function to call after the duration ends
---@param loop boolean? Should the timer loop after ending?
---@return Timer
function biribiri:CreateAndStartTimer(duration, call, loop)
    local t = Timer:New(duration, call, loop or false)
    
    table.insert(activeTimers, t)
    t:Start()
    
    return t
end

--- Updates Biribiri's features. Call this function in `love.update`
---@param dt number Delta Time
function biribiri:Update(dt)
    for _, timer in ipairs(activeTimers) do
        if timer.Started and not timer.Paused and not timer.Finished then
            if love.timer.getTime() >= timer.StartTime + timer.PausedDuration + timer.Duration then
                timer.Function()
                timer.Finished = true
                timer.Started = false
                timer.PausedDuration = 0
                
                if timer.Looped then
                    timer.Finished = false
                    timer:Start()
                end
            end
        end
    end
end

--- Clears a table
--- @param t table The table to clear
table.clear = function (t)
    for _, v in pairs(t) do
        table.remove(t, #t - 1)
    end
    table.remove(t, 1)
end

--- Finds a value inside of a table, returns the index if it is found, and returns nil otherwise
--- @param haystack table The table to search
--- @param needle any The value to look for
--- @return number|nil
table.find = function (haystack, needle)
    for i, v in pairs(haystack) do
        if v == needle then
            return i
        end
    end

    return nil
end

--- Returns number between the min and max boundaries
---@param number number The number to clamp
---@param min number The minimum value of the number
---@param max number The maximum value of the number
---@return number clampedNumber
math.clamp = function (number, min, max)
    if number == nil then
        error("Number was not provided!")
    end
    
    if min > max then

        error("max must be larger than min!")
    end

    return math.max(min, math.min(max, number))
end

--- Rounds the number to the nearest multiple provided or the nearest integer if a multiple is not provided
---@param number number The number to round
---@param multiple? number The multiple to round the number to
---@return number number
math.round = function (number, multiple)
    multiple = multiple or 1
    return math.floor(number / multiple + 0.5) * multiple
end

--- Returns the length of a table. You can use this instead of # on key-value tables because for whatever reason, # doesn't work on key-value tables.
---@param t table Table to get the length of
---@return number count
table.length = function (t)
    local count = 0
    
    for _, _ in pairs(t) do
        count = count + 1
    end

    return count
end

local function TableToString(t)
    local str = "{"
    local index = 1
    
    for key, value in pairs(t) do
        if type(key) ~= "number" then
            str = str..string.format("[\"%s\"] = ", key)
        end
        
        if type(value) == "string" then
            str = str.."\""..tostring(value).."\""
        elseif type(value) == "table" then
            str = str..TableToString(value)
        else
            str = str..tostring(value)
        end
        
        if index == table.length(t) then
            str = str.."}"
        else
            str = str..","
        end

        index = index + 1
    end

    return str
end

--- Serializes the table provided as a string, e.g. to print a table and see it's values instead of the memory location
---@param t table Table to convert to a string
---@return string serializedTable
table.tostring = function(t)
    return TableToString(t)
end

--- Gets the X and Y distance between two XY coordinates.
---@param x1 number X coordinate 1
---@param y1 number Y coordinate 1
---@param x2 number X coordinate 2
---@param y2 number Y coordinate 2
---@return number distance Distance
biribiri.distance = function (x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt (dx * dx + dy * dy)
end

--- Checks if 2 rectangles collide.
---@param x1 number Rectangle 1's X position
---@param y1 number Rectangle 1's Y position
---@param w1 number Rectangle 1's width
---@param h1 number Rectangle 1's height
---@param x2 number Rectangle 2's X position
---@param y2 number Rectangle 2's Y position
---@param w2 number Rectangle 2's width
---@param h2 number Rectangle 2's height
---@return boolean collides Did the two rectangles collide?
biribiri.collision = function (x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2+w2 and
        x2 < x1+w1 and
        y1 < y2+h2 and
        y2 < y1+h1
end

local function LoadSpriteFolder(directory)
    for _, v in ipairs(love.filesystem.getDirectoryItems(directory)) do
        local info = love.filesystem.getInfo(directory.."/"..v)
        
        if info.type == "file" then
            local sprite = nil
            
            local status = pcall(function ()
                sprite = love.graphics.newImage(directory.."/"..v)
            end)

            if status == true then
                print(v, sprite)
                assets[directory.."/"..v] = sprite
            end
        elseif info.type == "directory" then
            LoadSpriteFolder(directory.."/"..v)
        end
    end
end

local function LoadAudioFolder(directory, sourceType)
    for _, v in ipairs(love.filesystem.getDirectoryItems(directory)) do
        local info = love.filesystem.getInfo(directory.."/"..v)
        
        if info.type == "file" then
            local source = nil
            
            local status = pcall(function ()
                source = love.audio.newSource(directory.."/"..v, sourceType)
            end)
            
            if status == true then
                print(v, source)
                assets[directory.."/"..v] = source
            end
        elseif info.type == "directory" then
            LoadAudioFolder(directory.."/"..v, sourceType)
        end
    end
end

local function LoadFontFolder(directory, size)
    size = size or 12
    for _, v in ipairs(love.filesystem.getDirectoryItems(directory)) do
        local info = love.filesystem.getInfo(directory.."/"..v)
        
        if info.type == "file" then
            local font = nil
            
            local status = pcall(function ()
                font = love.graphics.newFont(directory.."/"..v, size)
            end)
            
            if status == true then
                print(v, font)
                assets[directory.."/"..v] = font
            end
        elseif info.type == "directory" then
            LoadFontFolder(directory.."/"..v, size)
        end
    end
end

--- Loads a folder of images into the global `assets` table.
---@param directory string The directory to load images from
function biribiri:LoadSprites(directory)
    LoadSpriteFolder(directory)
end

--- Loads a folder of audios into the global `assets` table.
---@param directory string The directory to load audio from
---@param sourceType "static"|"stream"|"queue" Type of audio source to create
function biribiri:LoadAudio(directory, sourceType)
    LoadAudioFolder(directory, sourceType)
end

--- Sets an audio's source type in the `assets` folder.
---@param path string The source to change the source type
---@param sourceType "static"|"stream"|"queue" Type of audio source to set
function biribiri:SetAudioSourceType(path, sourceType)
    assets[path] = love.audio.newSource(path, sourceType)
end

--- Loads a folder of fonts into the global `assets` table.
---@param directory string The directory to load fonts from
---@param size? number Size for the font
function biribiri:LoadAudio(directory, size)
    LoadFontFolder(directory, size)
end

--- Sets a font's size in the `assets` folder.
---@param path string The font to change the size of
---@param size? number Size for the font
function biribiri:SetFontSize(path, size)
    assets[path] = love.graphics.newFont(path, size)
end