local scenemgr = {}

scenemgr.Scenes = {}

function scenemgr:NewScene(name)
    local o = {
        Name = name,
        Instances = {},
        Enabled = true
    }
    
    self.Scenes[name] = o

    return o
end

function scenemgr:SetSceneEnabled(sceneName, enabled)
    self.Scenes[sceneName].Enabled = enabled

    for _, instance in ipairs(self.Scenes[sceneName].Instances) do
        instance.SceneEnabled = enabled
    end
end

function scenemgr:AddToScene(sceneName, instances)
    for _, instance in ipairs(instances) do
        table.insert(self.Scenes[sceneName].Instances, instance)
        instance.Scene = sceneName
        instance.SceneEnabled = self.Scenes[sceneName].Enabled
    end
end

return scenemgr