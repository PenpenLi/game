module("Box2D",package.seeall)

b2_staticBody = 0 --静态刚体
b2_kinematicBody = 1--
b2_dynamicBody = 2--动态刚体

b2_world_bottom = -1
b2_world_top = -2
b2_world_left = -3
b2_world_right = -4


function new()
    local box2D = {
        core = LuaBox2D(),
        bodyManager = {},
        contactCallback = nil,
        wallContactCallback = {},
        id = 1,
    }
    setmetatable(box2D,{__index = _M})
    box2D.core:registerUpdateCallback(function(key,x,y,rotation) box2D:onUpdate(key,x,y,rotation) end)

    return box2D
end

function onContact(self,key1,key2)
    --[[
    print('--------------------------------------------')
    print('key1:',key1)
    print('key2:',key2)
    --]]
    if key1 > key2 then
        key1,key2 = key2,key1
    end
    if key2 < 0 then
        return
    end
    if key1 < 0 then
        if self.wallContactCallback[key1] then
            self.wallContactCallback[key1](key1,self.bodyManager[key2].node)
        end
    else
        if self.contactCallback then
            self.contactCallback(self.bodyManager[key1].node,self.bodyManager[key2].node)
        end
    end
end

function onUpdate(self,key,x,y,rotation)
    local body = self.bodyManager[key]
    if body and body.callback then
        body.callback(body.node,x,y,rotation)
    end
end

function update(self,delay,velocityIterations,positionIterations)
    self.core:update(delay,velocityIterations or 8,positionIterations or 1)
end

function registerWallContactCallback(self,direction,callback)
    self.wallContactCallback[direction] = callback
end

function unRegisterWallContactCallback(self,direction)
    self.wallContactCallback[direction] = nil
end

function registerContactCallback(self,callback)
    self.contactCallback = callback
end

function unRegisterContactCallback(self)
    self.contactCallback = nil
end

function saveBody(self,node,callback,body)
    self.bodyManager[self.id] = {callback = callback,node = node,body=body}
    local bodyId = self.id
    self.id = self.id + 1
    return bodyId
end

function removeBody(self,bodyId)
    if self.bodyManager[bodyId] then
        self.core:removeBody(self.bodyManager[bodyId].body)
        self.bodyManager[bodyId] = nil
    end
end

function removeAllBody(self)
    for k,_ in pairs(self.bodyManager) do
        self:removeBody(k)
    end
end

function initWorld(self,x1,y1,x2,y2,gx,gy)
    self.core:initWorld(x1,y1,x2,y2,gx or 0,gy or -10)
    self.core:registerContactCallback(function(key1,key2) self:onContact(key1,key2) end)
end

function applyLinearImpulse(self,bodyId,x,y)
    if self.bodyManager[bodyId] then
        self.core:applyLinearImpulse(self.bodyManager[bodyId].body,x,y)
    end
end

function setLinearVelocity(self,bodyId,x,y)
    if self.bodyManager[bodyId] then
        self.core:setLinearVelocity(self.bodyManager[bodyId].body,x,y)
    end
end

function createCircleBody(self,node,callback,x,y,r,bodyType,attr)
    local body = self.core:createCircleBody(self.id,x,y,r,bodyType or b2_staticBody,attr or {})
    local bodyId = self:saveBody(node,callback,body)
    if node then
        node.bodyId = bodyId
    end
    return bodyId
end

function createPolygonBody(self,node,callback,x,y,point,bodyType,attr)
    local body = self.core:createPolygonBody(self.id,x,y,point or {},bodyType or b2_staticBody,attr or {})
    local bodyId = self:saveBody(node,callback,body)
    if node then
        node.bodyId = bodyId
    end
    return bodyId
end
