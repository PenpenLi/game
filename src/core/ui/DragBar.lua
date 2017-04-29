module("DragBar",package.seeall)
setmetatable(DragBar, {__index = Control}) 

UI_DRAG_BAR_TYPE = "DragBar"

function new(skin)
	local node = { 
		name = skin.name,
		uiType = UI_DRAG_BAR_TYPE, 
		isBtnDown = false,
		moveX = 0,
		moveY = 0,
		_skin = skin, 
		_ccnode = nil,
	}
	setmetatable(node, {__index = DragBar})
	node:init(skin)
	--node:createChildren(skin)
	return node 
end

function init(self, skin)
	local node = CCNode:create()
	node:setPosition(cc.p(skin.x, skin.y))            
	node:setAnchorPoint(cc.p(0,0))
	node:setContentSize(cc.size(skin.width,skin.height))
	self._ccnode = node 
end

function touch(self,event)
    if event.etype == 'began' then
        self.isBtnDown = true
        self.moveX = event.x
        self.moveY = event.y
        local parent = self._parent
        if parent then
            parent:setTop()
        end
    elseif event.etype == 'ended' then
        self.isBtnDown = false 
    elseif event.etype == 'moved' then
        if self.isBtnDown then
            local parent = self._parent
            if parent then
                local dx = event.x - self.moveX
                local dy = event.y - self.moveY
                self.moveX = event.x
                self.moveY = event.y
                local nx,ny = parent._ccnode:getPosition()
                parent._ccnode:setPosition(nx + dx, ny + dy)
            end
        end
    end
    return self.touchParent
end
