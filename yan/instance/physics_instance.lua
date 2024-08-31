local physicsInstance = {}



local instance = require("yan.instance.instance")
physicsInstance.__index = instance

function physicsInstance:New(world, bodyType, shape, size, restitution, damping)
    local o = instance:New()
    setmetatable(o, self)
    o.Type = "PhysicsInstance"
    o.body = love.physics.newBody(world, o.Position.X, o.Position.Y, bodyType)
    
    if shape == "rectangle" then
        o.shape = love.physics.newRectangleShape(size.X, size.Y)
    end
    
    o.fixture = love.physics.newFixture(o.body, o.shape)
    o.fixture:setUserData(o.Name)
    o.fixture:setRestitution(restitution)
    o.body:setLinearDamping(damping)
    
    function o:Update()
        if self.SceneEnabled == false then return end

        self.Position.X = self.body:getX()
        self.Position.Y = self.body:getY()
    end 

    function o:ApplyForce(x, y)
        if self.SceneEnabled == false then return end
        self.body:applyForce(x, y)
    end

    function o:ApplyLinearImpulse(x, y, maxX, maxY)
        if self.SceneEnabled == false then return end
        self.body:applyLinearImpulse(x, y)
        
        if maxX and maxY then
            local vX, vY = self.body:getLinearVelocity()

            if vX > maxX then 
                vX = maxX
            elseif vX < -maxX then 
                vX = -maxX 
            end

            self.body:setLinearVelocity(vX, vY)
        end
    end
    
    return o
end

return physicsInstance