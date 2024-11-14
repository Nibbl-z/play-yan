local Video = {}

local common = require("common")
require "yan"
require "biribiri"

Video.videos = {}
Video.currentMedia = 1

local positions = {
    {X = 24, Y = 4},
    {X = 96, Y = 8},
    {X = 168, Y = 12},
    {X = 4, Y = 74},
    {X = 76, Y = 78},
    {X = 148, Y = 82}
}
local videoPage = 1
local selectionAnimFrame = 1
local arrowState = {
    next = "", prev = "", show = true
}
local hideSelect = false
Video.stopAutoplay = false

function Video:LoadVideoFolder()
    local files = {}
    
    for _, file in ipairs(love.filesystem.getDirectoryItems("video")) do
        table.insert(files, {
            name = file,
            sprite = "img/video.png",
            doorSprite = "img/garagedoor_1.png",
            openDoor = function (f)
                for i = 1, 9 do
                    biribiri:CreateAndStartTimer(0.02 * i, function ()
                        if i ~= 9 then
                            f.doorSprite = "img/garagedoor_"..tostring(i)..".png"
                        else
                            f.doorSprite = ""
                        end
                    end)
                end
            end,
            closeDoor = function (f)
                local x = 1
                for i = 9, 1, -1 do
                    x = x + 1
                    biribiri:CreateAndStartTimer(0.02 * x, function ()
                        if i ~= 9 then
                            f.doorSprite = "img/garagedoor_"..tostring(i)..".png"
                        else
                            f.doorSprite = ""
                        end
                    end)
                end
            end,
            video = love.graphics.newVideo("video/"..file),
            canControl = false
        })
    end
    
    for _, v in ipairs(files) do
        table.insert(self.videos, v)
    end
    
    if #self.videos >= 7 then
        for y = 1, math.ceil(#self.videos / 6) do
            for i = 1, 6 do
                print(i, y)
                local positionClone = {X = positions[i].X, Y = positions[i].Y + 300 * y}
                table.insert(positions, positionClone)
            end
        end
    end
end

function Video:OpenVideos()
    for i, video in ipairs(self.videos) do
        video.doorSprite = "img/garagedoor_1.png"
        video.video = love.graphics.newVideo("video/"..video.name)

        if video.video:getSource() ~= nil then
            video.video:getSource():setVolume(0)
        end
        biribiri:CreateAndStartTimer(0,function ()
            video.video:play()
        end)
        
        biribiri:CreateAndStartTimer(0.2,function ()
            if video.video:getSource() ~= nil then
                video.video:getSource():setVolume(common.Volume / 36)
            end
            video.video:pause()
        end)
       
        biribiri:CreateAndStartTimer(0.1 * i - (0.6 * (videoPage - 1)) + 0.3, function ()
            
            video.openDoor(video)
        end)
    end
end

function Video:NextVideoPage()
    arrowState.show = false
    videoPage = videoPage + 1
    
    for _, video in ipairs(self.videos) do
        video.closeDoor(video)
    end
    
    biribiri:CreateAndStartTimer(0.3, function ()
        yan:NewTween(common.Camera, yan:TweenInfo(0.3), {Y = common.Camera.Y - 300}):Play()
    end)
    
    biribiri:CreateAndStartTimer(0.6, function ()
        arrowState.show = true
        for i, video in ipairs(self.videos) do
            if i >= (videoPage - 1) * 6 and i <= (videoPage - 1) * 6 + 6 then
                biribiri:CreateAndStartTimer(0.1 * i - (0.6 * (videoPage - 1)), function ()
                    video.openDoor(video)
                end)
            end
        end
    end)
end

function Video:PreviousVideoPage()
    arrowState.show = false
    videoPage = videoPage - 1
    for _, video in ipairs(self.videos) do
        video.closeDoor(video)
    end

    biribiri:CreateAndStartTimer(0.3, function ()
        yan:NewTween(common.Camera, yan:TweenInfo(0.3), {Y = common.Camera.Y + 300}):Play()
    end)
    
    biribiri:CreateAndStartTimer(0.6, function ()
        arrowState.show = true
        for i, video in ipairs(self.videos) do
            if i >= (videoPage - 1) * 6 and i <= (videoPage - 1) * 6 + 6 then
                biribiri:CreateAndStartTimer(0.1 * i - (0.6 * (videoPage - 1)), function ()
                    video.openDoor(video)
                end)
            end
        end
    end)
end

function Video:Initialize()
    print("???")
    -- Make next arrow bop
    self:LoadVideoFolder()

    biribiri:CreateAndStartTimer(1, function ()
        arrowState.next = "bop1"
        biribiri:CreateAndStartTimer(0.05, function ()
            arrowState.next = "bop2"
        end)
        biribiri:CreateAndStartTimer(0.1, function ()
            arrowState.next = ""
       end)
    end, true)
    
    -- Make previous arrow bop
    biribiri:CreateAndStartTimer(0.5, function ()
        biribiri:CreateAndStartTimer(1, function ()
            arrowState.prev = "bop1"
            biribiri:CreateAndStartTimer(0.05, function ()
                arrowState.prev = "bop2"
            end)
            biribiri:CreateAndStartTimer(0.1, function ()
                arrowState.prev = ""
           end)
        end, true)
    end)
    
    -- Cycle through frames for animated selection border
    biribiri:CreateAndStartTimer(0.04, function ()
        selectionAnimFrame = selectionAnimFrame + 1
        if selectionAnimFrame == 5 then selectionAnimFrame = 1 end
    end, true)
end

function Video:KeyPressed(key)
    if key == "escape" then
        Blip()
        hideSelect = true
        for _, video in ipairs(self.videos) do
            video.closeDoor(video)
        end
        
        yan:NewTween(common.Fade, yan:TweenInfo(0.5), {Alpha = 1}):Play()

        biribiri:CreateAndStartTimer(0.5, function ()
            yan:NewTween(common.Fade, yan:TweenInfo(0.5), {Alpha = 0}):Play()
            hideSelect = false
            videoPage = 1
            self.currentMedia = 1
            common.Camera.Y = 0
            common.Scene = "menu"
            MenuEnter()
        end)
    end

    if key == "a" then
        if math.ceil(self.currentMedia / 6) ~= math.ceil((math.clamp(self.currentMedia - 1, 1, #self.videos) - 1) / 6 + 0.01) then
            self:PreviousVideoPage()
        end

        Blip()
        self.currentMedia = math.clamp(self.currentMedia - 1, 1, #self.videos)
    end

    if key == "d" then
        if math.ceil(self.currentMedia / 6) ~= math.ceil((math.clamp(self.currentMedia + 1, 1, #self.videos) - 1) / 6 + 0.01) then
            self:NextVideoPage()
        end

        Blip()
        self.currentMedia = math.clamp(self.currentMedia + 1, 1, #self.videos)
    end
    
    if key == "w" then
        Blip()
        if math.ceil(self.currentMedia / 6) ~= math.ceil((math.clamp(self.currentMedia - 3, 1, #self.videos) - 1) / 6 + 0.01) then
            self:PreviousVideoPage()
        end
        self.currentMedia = self.currentMedia - 3
        if self.currentMedia < 1 then self.currentMedia = self.currentMedia + 3 end
    end
    
    if key == "s" then
        Blip()
        if math.ceil(self.currentMedia / 6) ~= math.ceil((math.clamp(self.currentMedia + 3, 1, #self.videos) - 1) / 6 + 0.01) then
            self:NextVideoPage()
        end
        self.currentMedia = self.currentMedia + 3
        if self.currentMedia > #self.videos then self.currentMedia = self.currentMedia - 3 end
    end

    if key == "space" then
        self.stopAutoplay = false
        Blip()
        common.ToggleRendering = true
        self.videos[self.currentMedia].video = love.graphics.newVideo("video/"..self.videos[self.currentMedia].name)
        self.videos[self.currentMedia].canControl = false
        biribiri:CreateAndStartTimer(0.5, function ()
            common.Scene = "videoplayback"
            common.ToggleRendering = false
        end)
        
        biribiri:CreateAndStartTimer(1.5, function ()
            if self.stopAutoplay then return end
            yan:NewTween(common.Fade, yan:TweenInfo(1), {Alpha = 1}):Play()
        end)

        biribiri:CreateAndStartTimer(2.51, function ()
            common.Fade.Alpha = 0
            if self.stopAutoplay then return end
            self.videos[self.currentMedia].video:play()
            self.videos[self.currentMedia].canControl = true
        end)
    end
end

function Video:Draw()
    love.graphics.translate(common.Camera.X, common.Camera.Y)    
    
    local pages = math.ceil(#self.videos / 6)
    for i, video in ipairs(self.videos) do
        for i = 1, pages do
            if arrowState.show then
                love.graphics.draw(assets["img/exit.png"], 209, 146 + (i - 1) * 300)
            end
        end

        if pages > 1 and arrowState.show then
            if videoPage < pages then
                for i = 1, pages do
                    love.graphics.draw(assets["img/next"..arrowState.next..".png"], 218, 110 + (i - 1) * 300)
                end
            end
            
            if videoPage > 1 then
                for i = 1, pages do
                    love.graphics.draw(assets["img/prev"..arrowState.prev..".png"], 2, 7 + (i - 1) * 300)
                end
            end
        end
        
        if self.currentMedia ~= i or arrowState.show == false or hideSelect then
            love.graphics.draw(assets[video.sprite], positions[i].X, positions[i].Y)
        else
            love.graphics.draw(assets["img/video_selected"..tostring(selectionAnimFrame)..".png"], positions[i].X, positions[i].Y)
        end
        local vw, vh = video.video:getDimensions()
        love.graphics.setColor(1,1,1)
        love.graphics.draw(video.video, positions[i].X + 3, positions[i].Y + 18, 0, 60/vw, 40/vh)

        if self.currentMedia ~= i or arrowState.show == false or hideSelect then
            love.graphics.setColor(46/255, 101/255, 122/255)
        else
            love.graphics.setColor(112/255, 214/255, 241/255)
        end
        if video.doorSprite ~= "" then
            love.graphics.draw(assets[video.doorSprite], positions[i].X + 1, positions[i].Y)
        end
        if self.currentMedia ~= i then
            love.graphics.setColor(98/255, 171/255, 186/255)
        else
            love.graphics.setColor(1,1,1)
        end
        love.graphics.stencil(function ()
            love.graphics.rectangle("fill", positions[i].X + 4, positions[i].Y + 3, 58, 11)
        end, "replace", 1)
        love.graphics.setStencilTest("greater", 0)
        love.graphics.print(video.name, positions[i].X + 5, positions[i].Y + 2)
        love.graphics.setColor(1,1,1)
        love.graphics.setStencilTest()
        if self.currentMedia == i and arrowState.show then
            for i = 1, pages do
                love.graphics.printf(video.name, 0, 145 + (i - 1) * 300, 240, "center")
            end
        end
    end
end


return Video