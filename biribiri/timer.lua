---@class Timer
---@field Duration number: How long the timer lasts
---@field Looped boolean: Should the timer loop when it ends?
---@field Start function: Starts the timer
---@field Pause function: Pause the timer
---@field Unpause function: Unpause the timer

local timer = {}

function timer:New(duration, call, loop)
    o = {
        Duration = duration,
        Function = call,
        Looped = loop,
        
        Started = false,
        StartTime = 0,
        Paused = false,
        Finished = false,
        PauseStart = 0,
        PausedDuration = 0
    }
    
    setmetatable(o, self)
    self.__index = self
    
    return o
end

---Starts the timer
---@return nil
function timer:Start()
    if self.Started == true then return end
    
    self.Started = true
    self.StartTime = love.timer.getTime()
end

function timer:Pause()
    self.Paused = true
    self.PauseStart = love.timer.getTime()
end

function timer:Unpause()
    self.Paused = false
    self.PausedDuration = self.PausedDuration + love.timer.getTime() - self.PauseStart
end

return timer