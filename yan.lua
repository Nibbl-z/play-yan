yan = {}

local instance = require("yan.instance.instance")
local physicsInstance = require("yan.instance.physics_instance")
local screen = require("yan.instance.ui.screen")
local label = require("yan.instance.ui.label")
local guiBase = require("yan.instance.ui.guibase")
local textButton = require("yan.instance.ui.textbutton")
local imageButton = require("yan.instance.ui.imagebutton")
local image = require("yan.instance.ui.image")
local list = require("yan.instance.ui.list")
local textinput = require("yan.instance.ui.textinput")
local sceneManager = require("yan.scenemanager")
local uiManager = require("yan.uimanager")
local tweenManager = require("yan.tweenmanager")
local themeManager = require("yan.thememanager")
local scrollable = require("yan.instance.ui.scrollable")
local grid = require("yan.instance.ui.grid")
local frame = require("yan.instance.ui.frame")
local dropdown = require("yan.instance.ui.dropdown")
local slider = require("yan.instance.ui.slider")
UIVector2 = require("yan.datatypes.uivector2")
Vector2 = require("yan.datatypes.vector2")
Color = require("yan.datatypes.color")
EasingStyle = require("yan.datatypes.easingstyle")

yan.Instance = instance.New
yan.PhysicsInstance = physicsInstance.New
yan.Screen = screen.New
yan.Label = label.New
yan.TextButton = textButton.New
yan.ImageButton = imageButton.New
yan.Image = image.New
yan.List = list.New
yan.TextInputter = textinput.New
yan.Scrollable = scrollable.New
yan.Grid = grid.New
yan.Frame = frame.New
yan.Dropdown = dropdown.New
yan.Slider = slider.New

yan.NewTween = tweenManager.NewTween
yan.TweenInfo = tweenManager.NewTweenInfo

yan.NewTheme = themeManager.NewTheme

yan.NewScene = sceneManager.NewScene
yan.AddToScene = sceneManager.AddToScene
yan.SetSceneEnabled = sceneManager.SetSceneEnabled

function yan:Update(dt)
    uiManager:Update()
    tweenManager:Update(dt)
end

function yan:KeyPressed(key, scancode, rep)
    uiManager:KeyPressed(key, scancode, rep)
end

function yan:TextInput(t)
    uiManager:TextInput(t)
end

function yan:WheelMoved(x, y)
    uiManager:WheelMoved(x,y)
end
function yan:Draw()
    uiManager:Draw()
end