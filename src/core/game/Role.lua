module("Role", package.seeall)
setmetatable(Role, {__index = Control}) 

UI_ROLE_TYPE = "Role"
isRole = true

--角色状态
ROLE_STATUS_NORMAL = 1
ROLE_STATUS_RUN = 2

--动作类型
ACTION_TYPE_STAND = 1  -- 站立
ACTION_TYPE_RUN = 2 -- 跑 

--方向
DIRECTION_LEFT_UP = 1
DIRECTION_LEFT_DOWN = 2
DIRECTION_RIGHT_UP = 3
DIRECTION_RIGHT_DOWN = 4

function new(name)
	local ctrl = { 
		name = name,
		roleName = name, --人物名，妖怪名，npc名。。。。。用这个
		uiType = UI_ROLE_TYPE,
		_ccnode = nil,
		actionType = ACTION_TYPE_STAND,
		_bodyDirty = true 
	}
	setmetatable(ctrl, {__index = Role})
	init(ctrl)
	return ctrl
end

function init(self)
	local node = cc.Node:create()
	node:setAnchorPoint(cc.p(0,0))
	self._ccnode = node 
end

function getActionType(self)
	return self.actionType
end

function setActionType(self, actionType)
	actionType = actionType == ACTION_TYPE_STAND and ACTION_TYPE_STAND or ACTION_TYPE_RUN
	if self.actionType ~= actionType then
		self.actionType = actionType
		self._bodyDirty = true
	end
end

function getDirection(self)
	return self.direction
end

function setDirection(self, direction)
	if direction == DIRECTION_LEFT_UP  or direction == DIRECTION_LEFT_DOWN or
		direction == DIRECTION_RIGHT_UP or direction == DIRECTION_RIGHT_DOWN then
	else
		assert(false, "invalid dirction !")
		direction = DIRECTION_LEFT_DOWN -- 容错
	end
	if self.direction ~= direction then
		self.direction = direction
		self._bodyDirty = true
	end
end

function toDirection(self, x, y, ox, oy)
	if not ox or not oy then
		ox,oy = self:getPosition()
	end

	if x == ox and y == oy then
		return 
	end

	local dir = DIRECTION_LEFT_DOWN
	if x > ox then
		if y > oy then
			dir = DIRECTION_RIGHT_UP
		else
			dir = DIRECTION_RIGHT_DOWN
		end
	else
		if y > oy then
			dir = DIRECTION_LEFT_UP
		else
			dir = DIRECTION_LEFT_DOWN
		end
	end
	self:setDirection(dir)
	return dir 
end

function go(self, x, y)
	local ox,oy = self:getPosition()
	print("=== go:", self.uiType, self.roleName, x, y)

	local paths = MapManager.currentMap:route(ox,oy,x,y)
	if paths then
		self:stopAllActions()
		self:setActionType(Role.ACTION_TYPE_RUN)
		self:render()
		local ary = {}
		for k, v in ipairs(paths) do
			if k ~= 1 then
				local pre = paths[k-1]
				local px, py = Map.convertToSpace(pre.x,pre.y) 
				local tox,toy = Map.convertToSpace(v.x,v.y)
				local useSec = Common.distance(px,py,tox,toy) / self.speed
				table.insert(ary, cc.CallFunc:create(function() 
					self:toDirection(tox,toy,px,py) 
					self:render()
				end))
				table.insert(ary, cc.MoveTo:create(useSec, cc.p(tox,toy)))
			end
		end

		table.insert(ary, cc.CallFunc:create(function() self:goEnd() end))
		self:runAction(cc.Sequence:create(ary))
	else
		print("============= paths nil =====================")
	end
end

function goEnd(self)
	self:setActionType(Role.ACTION_TYPE_STAND)
	self:render()
	self:dispatchEvent(Event.MoveEnded,{etype=Event.MoveEnded})
end

function render(self)
	if self._bodyDirty then
		self._bodyDirty = false
	end
end
