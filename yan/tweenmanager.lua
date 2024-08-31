local tweenmanager = {}
activeTweens = {}

local EasingStyle = require("yan.datatypes.easingstyle")
local utils = require("yan.utils")
function tweenmanager:NewTweenInfo(duration, easingStyle)
    local tweenInfo = {
        Duration = duration or 1,
        EasingStyle = easingStyle or EasingStyle.Linear
    }
    
    return tweenInfo
end

function tweenmanager:NewTween(instance, tweeninfo, goal)
    local tween = {
        Instance = instance,
        TweenInfo = tweeninfo,
        Goal = goal,
        
        Progress = 0.0,
        TimePosition = 0.0,
        StartTime = 0.0,
        OriginalProperties = {},
        IsPlaying = false,
        Finished = false
    }
    
    for key, value in pairs(tween.Goal) do
        tween.OriginalProperties[key] = instance[key]
    end
    
    
    
    function tween:Play()
        --[[for _, v in ipairs(activeTweens) do
            if v.Instance == tween.Instance then
                v:Pause()
            end
        end]]
        
        table.insert(activeTweens, tween)
        tween.Index = love.timer.getTime()

        for key, value in pairs(tween.Goal) do
            tween.OriginalProperties[key] = instance[key]
        end
        
        tween.Progress = 0.0
        tween.TimePosition = 0.0
        tween.IsPlaying = true
        tween.Finished = false
        tween.StartTime = love.timer.getTime()
    end
    
    function tween:Pause()
        tween.IsPlaying = false
    end
    
    function tween:Stop()
        tween.Progress = 0.0
        tween.TimePosition = 0.0
        tween.IsPlaying = false
        tween.Finished = true
        
        table.remove(activeTweens, tween.Index)
    end

    return tween
end

local EasingFuncs = {
    [EasingStyle.Linear] = function (x)
        return x
    end,

    [EasingStyle.SineIn] = function (x)
        return 1 - math.cos((x * math.pi) / 2)
    end,
    [EasingStyle.SineOut] = function (x)
        return math.sin((x * math.pi))
    end,
    [EasingStyle.SineInOut] = function (x)
        return -(math.cos(math.pi * x) - 1) / 2
    end,
    
    [EasingStyle.CubicIn] = function (x)
        return x ^ 3
    end,
    [EasingStyle.CubicOut] = function (x)
        return 1 - math.pow(1 - x, 3)
    end,
    [EasingStyle.CubicInOut] = function (x)
        return (x < 0.5) and 4 * (x ^ 3) or 1 - math.pow(-2 * x + 2, 3) / 2
    end,
    
    [EasingStyle.QuintIn] = function (x)
        return x ^ 5
    end,
    [EasingStyle.QuintOut] = function (x)
        return 1 - math.pow(1 - x, 5)
    end,
    [EasingStyle.QuintInOut] = function (x)
        return (x < 0.5) and 16 * (x ^ 5) or 1 - math.pow(-2 * x + 2, 5) / 2
    end,
    
    [EasingStyle.CircularIn] = function (x)
        if x == 1 then return 1 end
        return 1 - math.sqrt(1 - x ^ 2)
    end,
    [EasingStyle.CircularOut] = function (x)
        return math.sqrt(1 - math.pow(x - 1, 2))
    end,
    [EasingStyle.CircularInOut] = function (x)
        return (x < 0.5)
        and (1 - math.sqrt(1 - math.pow(2 * x, 2))) / 2
        or (math.sqrt(1 - math.pow(-2 * x + 2, 2)) + 1) / 2;
    end,

    [EasingStyle.QuadIn] = function (x)
        return x ^ 2
    end,
    [EasingStyle.QuadOut] = function (x)
        return 1 - (1 - x) * (1 - x)
    end,
    [EasingStyle.QuadInOut] = function (x)
        return (x < 0.5) and 2 * x * x or 1 - math.pow(-2 * x + 2, 2) / 2
    end,

    [EasingStyle.QuartIn] = function (x)
        return x ^ 4
    end,
    [EasingStyle.QuartOut] = function (x)
        return 1 - math.pow(1 - x, 4)
    end,
    [EasingStyle.QuartInOut] = function (x)
        return (x < 0.5) and 8 * x ^ 4 or 1 - math.pow(-2 * x + 2, 4) / 2
    end,

    [EasingStyle.ExponentialIn] = function (x)
        return x == 0 and 0 or math.pow(2, 10 * x - 10)
    end,
    [EasingStyle.ExponentialOut] = function (x)
        return x == 1 and 1 or 1 - math.pow(2, -10 * x)
    end,
    [EasingStyle.ExponentialInOut] = function (x)
        if x == 0 then return 0 end
        if x == 1 then return 1 end
        
        return (x < 0.5) and math.pow(2, 20 * x - 10) / 2 or (2 - math.pow(2, -20 * x + 10)) / 2
    end,

    [EasingStyle.BackIn] = function (x)
        local c1 = 1.70158
        local c3 = c1 + 1
        
        return c3 * x ^ 3 - c1 * x ^ 2
    end,
    [EasingStyle.BackOut] = function (x)
        local c1 = 1.70158
        local c3 = c1 + 1
        return 1 + c3 * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2)
    end,
    [EasingStyle.BackInOut] = function (x)
        local c1 = 1.70158
        local c2 = c1 * 1.525
        
        return (x < 0.5) and (math.pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2 or (math.pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
    end,

    [EasingStyle.ElasticIn] = function (x)
        local c4 = (2 * math.pi) / 3
        
        if x == 0 then return 0 end
        if x == 1 then return 1 end

        return -math.pow(2, 10 * x - 10) * math.sin((x * 10 - 10.75) * c4)
    end,
    [EasingStyle.ElasticOut] = function (x)
        local c4 = (2 * math.pi) / 3

        if x == 0 then return 0 end
        if x == 1 then return 1 end

        return math.pow(2, -10 * x) * math.sin((x * 10 - 0.75) * c4) + 1
    end,
    [EasingStyle.ElasticInOut] = function (x)
        local c5 = (2 * math.pi) / 4.5

        if x == 0 then return 0 end
        if x == 1 then return 1 end
        return (x < 0.5) and -(math.pow(2, 20 * x - 10) * math.sin((20 * x - 11.125) * c5)) / 2 or (math.pow(2, -20 * x + 10) * math.sin((20 * x - 11.125) * c5)) / 2 + 1
    end,
    
    [EasingStyle.BounceOut] = function (x)
        local n1 = 7.5625
        local d1 = 2.75
        
        if x < 1 / d1 then
            return n1 * x ^ 2
        elseif x < 2 / d1 then
            x = x - 1.5 / d1
            return n1 * x * x + 0.75
        elseif x < 2.5 / d1 then
            x = x - 2.25 / d1
            return n1 * x * x + 0.9375
        else
            x = x - 2.625 / d1
            return n1 * x * x + 0.984375
        end
    end,
    [EasingStyle.BounceIn] = function (x)
        local function bounceout(x)
            local n1 = 7.5625
            local d1 = 2.75
            
            if x < 1 / d1 then
                return n1 * x ^ 2
            elseif x < 2 / d1 then
                x = x - 1.5 / d1
                return n1 * x * x + 0.75
            elseif x < 2.5 / d1 then
                x = x - 2.25 / d1
                return n1 * x * x + 0.9375
            else
                x = x - 2.625 / d1
                return n1 * x * x + 0.984375
            end
        end
        return 1 - bounceout(1 - x)
    end,
    [EasingStyle.BounceInOut] = function (x)
        local function bounceout(x)
            local n1 = 7.5625
            local d1 = 2.75
            
            if x < 1 / d1 then
                return n1 * x ^ 2
            elseif x < 2 / d1 then
                x = x - 1.5 / d1
                return n1 * x * x + 0.75
            elseif x < 2.5 / d1 then
                x = x - 2.25 / d1
                return n1 * x * x + 0.9375
            else
                x = x - 2.625 / d1
                return n1 * x * x + 0.984375
            end
        end
        
        return (x < 0.5) and (1 - bounceout(1 - 2 * x)) / 2 or (1 + bounceout(2 * x - 1)) / 2
    end
}

local function UpdateTween(tween, dt)
    tween.TimePosition = love.timer.getTime() - tween.StartTime
    tween.Progress = utils:Clamp(tween.TimePosition / tween.TweenInfo.Duration, 0.0, 1.0)
    
    for key, value in pairs(tween.Goal) do
        tween.Instance[key] = tween.OriginalProperties[key] + (value - tween.OriginalProperties[key]) * EasingFuncs[tween.TweenInfo.EasingStyle](tween.Progress)
    end
   
    if tween.Progress >= 1.0 then
        
        --print(#activeTweens)
        for i, v in ipairs(activeTweens) do
            if v.Index == tween.Index then
                table.remove(activeTweens, i)
            end
        end

        --print(#activeTweens)
        tween.Finished = true
        tween.IsPlaying = false
    end
end

function tweenmanager:Update(dt)
    for i, tween in ipairs(activeTweens) do
        if tween.IsPlaying and not tween.Finished then
            UpdateTween(tween, dt)
        end
    end
end

return tweenmanager