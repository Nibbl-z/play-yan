require "yan"
require "biribiri"

local common = require("common")

local scenes = {
    loading = require("scenes.loading"),
    menu = require("scenes.menu"),
    music = require("scenes.music"),
    video = require("scenes.video"),
    videoplayback = require("scenes.videoplayback")
}

function Blip()
    assets["sfx/blip.mp3"]:clone():play()
end

function love.load()
    love.window.setTitle("Play-Yan")
    love.window.setIcon(love.image.newImageData("/img/icon.png"))

    love.filesystem.setIdentity("play-yan")
    love.filesystem.createDirectory("music")
    love.filesystem.createDirectory("video")
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(love.graphics.newFont("W95FA.otf", 14, "mono"))
    love.window.setMode(720, 480)
    
    biribiri:LoadAudio("music", "stream")
    biribiri:LoadAudio("sfx", "static")
    biribiri:LoadSprites("img")
    
    for n, scene in pairs(scenes) do
        scene:Initialize()
    end
end

function love.keyreleased(key)
    pcall(function() scenes[common.Scene]:KeyReleased(key) end)
end

function love.keypressed(key)
    pcall(function() scenes[common.Scene]:KeyPressed(key) end)
end

function love.update(dt)
    yan:Update(dt)
    biribiri:Update(dt)
    
    pcall(function()
        scenes[common.Scene]:Update(dt)
    end)
end

function love.draw()
    if common.ToggleRendering then return end
    love.graphics.push()
    love.graphics.scale(3, 3)

     scenes[common.Scene]:Draw()

    
    love.graphics.setColor(0,0,0,common.Fade.Alpha)
    love.graphics.rectangle("fill", 0, 0, 1000, 1000)
    love.graphics.setColor(1,1,1,1)
    
    love.graphics.pop()
end