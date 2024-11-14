local videoplayback = {}

local common = require("common")
local Video = require("scenes.video")
local playbackTime = require("objects.playbacktime")

require "yan"
require "biribiri"

local overrideShowControls = false
local flashProgress = false
local playbackState = "play"
local adjustingVolumeV = false

function videoplayback:Initialize()
    -- Flash progress bar
    biribiri:CreateAndStartTimer(0.5, function ()
        flashProgress = true
        biribiri:CreateAndStartTimer(0.1, function ()  
            flashProgress = false
        end)
    end, true)

    hideVolumeTimerV = biribiri:CreateTimer(2, function ()
        adjustingVolumeV = false
    end)
end

function videoplayback:KeyReleased(key)
    if key == "left" or key == "right" then
        if Video.videos[Video.currentMedia].canControl == false then return end
        if common.Scene == "videoplayback" then
            playbackState = "play"
            local pos = Video.videos[Video.currentMedia].video:tell()
            Video.videos[Video.currentMedia].video = love.graphics.newVideo("video/"..Video.videos[Video.currentMedia].name)
            Video.videos[Video.currentMedia].video:seek(pos)
            
            Video.videos[Video.currentMedia].video:play()
        end
    end
end

function videoplayback:KeyPressed(key)
    if key == "escape" then
        Video.stopAutoplay = true
        Video.videos[Video.currentMedia].video:pause()
        
        common.Scene = "video"
        common.ToggleRendering = true
        
        Video:OpenVideos()
        
        biribiri:CreateAndStartTimer(0.15, function ()
            common.ToggleRendering = false
        end)
    end
    if key == "space" then
        if Video.videos[Video.currentMedia].canControl == false then return end
        if Video.videos[Video.currentMedia].video:isPlaying() then
            Video.videos[Video.currentMedia].video:pause()
        else
            Video.videos[Video.currentMedia].video:play()
        end
    elseif key == "w" then     
        if Video.videos[Video.currentMedia].video:getSource() ~= nil then
            adjustingVolumeV = true
            common.Volume = math.clamp(common.Volume + 1, 0, 36)
            hideVolumeTimerV.Started = false
            hideVolumeTimerV:Start()
            
            Video.videos[Video.currentMedia].video:getSource():setVolume(common.Volume / 36)
        end
    elseif key == "s" then
        if Video.videos[Video.currentMedia].video:getSource() ~= nil then
            adjustingVolumeV = true
            common.Volume = math.clamp(common.Volume - 1, 0, 36)
            hideVolumeTimerV.Started = false
            hideVolumeTimerV:Start()
            
            Video.videos[Video.currentMedia].video:getSource():setVolume(common.Volume / 36)
        end
    end
end

function videoplayback:Update(dt)
    if Video.videos[Video.currentMedia].canControl == true then
        local video = Video.videos[Video.currentMedia].video
        if love.keyboard.isDown("left") then
            playbackState = "rewind"
            video:pause()
            if love.keyboard.isDown("lshift") then
                video:seek(video:tell() - dt * 18)
            else
                video:seek(video:tell() - dt * 6)
            end
            
        elseif love.keyboard.isDown("right") then
            playbackState = "ff"
            video:pause()
            if love.keyboard.isDown("lshift") then
                video:seek(video:tell() + dt * 18)
            else
                video:seek(video:tell() + dt * 6)
            end
        end
    end
end

function videoplayback:Draw()
    local vw, vh = Video.videos[Video.currentMedia].video:getDimensions()
    local video = Video.videos[Video.currentMedia].video
    local maxWidth, maxHeight = 240, 160
    local bestRatio = math.min(maxWidth / vw, maxHeight / vh)
    
    love.graphics.draw(video, (240 - (vw * bestRatio)) / 2, (160 - (vh * bestRatio)) / 2, 0, bestRatio, bestRatio, 0, 0)
    
    if adjustingVolumeV then
        local extraSize = 0
        for i = 1, common.Volume do
            if i % 3 == 0 then
                extraSize = extraSize + 1
            end
        end

        love.graphics.draw(assets["img/volume.png"], 2 - common.Camera.X, 30 - common.Camera.Y)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", 7 - common.Camera.X, 48 - common.Camera.Y, 4, -common.Volume - extraSize + 47)
        love.graphics.setColor(1,1,1)
    end
    
    if not video:isPlaying() or overrideShowControls then
        love.graphics.draw(assets["img/video_progress.png"])
        love.graphics.draw(assets[flashProgress and "img/progressvideo_flash.png" or "img/progressvideo.png"], 5 + 224 * (video:tell() / video:getSource():getDuration()), 152)
        love.graphics.draw(assets["img/"..playbackState.."_video.png"], 108, 66)
        playbackTime:Render(video:tell(), 207, 144)
    end
end

return videoplayback