module(..., package.seeall)
setmetatable(_M, {__index = Control}) 
local Define = require("src/modules/fight/Define")
local Helper = require("src/modules/fight/KofHelper")

UI_FLYER_TYPE = "Flyer"
DIRECTION_RIGHT = -1
DIRECTION_LEFT = 1

STATE_NONE = 0
STATE_START = 1
STATE_LOOP = 2
STATE_END = 3

flyerCnt = 1
function new(argList)
	flyerCnt = flyerCnt + 1
	local o = { 
		state = STATE_NONE,
		name = UI_FLYER_TYPE .. flyerCnt, 
		uiType = UI_FLYER_TYPE,
		stateName = argList.stateName,
		startName = argList.startName,
		loopName = argList.loopName,
		endName = argList.endName,
		speed = argList.speed or 900,
		direction = argList.direction or DIRECTION_LEFT,
		master = argList.master,
		enemy = argList.enemy,
		offsetX = argList.offsetX,
		offsetY = argList.offsetY,
	}

	setmetatable(o, {__index = _M})

	o:init()
    return o
end

function init(self)
	local node = cc.Node:create()
	--node:setPosition(self.offsetX,self.offsetY)
	node:setPosition(self.offsetX,Define.heroBottom)
    node:setAnchorPoint(0, 0)
	self._ccnode = node 

    self.animation =ccs.Armature:create(self.master.heroName)
	self.animation:setAnchorPoint(cc.p(0.5,0.5))
	self.animation:setPosition(cc.p(0,0))
	
	self._ccnode:addChild(self.animation)

    self:setDirection(self.direction)

    self.animation:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) self:onAnimationEvent(armatureBack,movementType,movementID) end)

	self:openTimer()
	self:addEventListener(Event.Frame,onFrameEvent,self)

	self:play(STATE_START)
end

function setDirection(self,direction)
	self.direction = direction
    self.animation:setScaleX(direction == DIRECTION_LEFT and 1  or -1 )
end

function getDirection(self)
	return self.direction
end

function onAnimationEvent(self,armatureBack,movementType,movementID)
	--print('-------------------------:armatureBack,movementType,movementID:',armatureBack,movementType,movementID)
	if movementType == ccs.MovementEventType.complete then
		if self.state == STATE_START then
			self:play(STATE_LOOP)
		elseif self.state == STATE_LOOP then
		elseif self.state == STATE_END then
			Stage.currentScene.arenaFlyerList[self] = true
		end
	end
end

function play(self,state)
	if state == STATE_START and not self.startName then
		state = STATE_LOOP
	end

	if state == STATE_END and (not self.endName or self.master.enemy.curState.lock == Define.AttackLock.defense) then
		Stage.currentScene.arenaFlyerList[self] = true
		return
	end

	self.state = state
	if state == STATE_START then
		self.animation:getAnimation():play(self.startName,-1,0)
	elseif state == STATE_LOOP then
		self.animation:getAnimation():play(self.loopName,-1,1)
	elseif state == STATE_END then
		self.animation:getAnimation():play(self.endName,-1,0)
	end
end

function onFrameEvent(self,event)
	if self.state ~= STATE_LOOP then
		return
	end
    local dx = -self:getDirection() * self.speed  * 0.0167 --event.delay
	local nx = self:getPositionX() + dx
    self:setPositionX(nx)

	if nx < -100 or nx > Stage.currentScene.mapWidth + 100 then
		Stage.currentScene.arenaFlyerList[self] = true
		return
	end

	local rect = self.enemy:getBodyBoxReal()
	local box = self.animation:getBone("受击框"):getDisplayManager():getBoundingBox()
	local realBox = self:changeToRealRect(box)

	local ret,minx,miny,maxx,maxy = Helper.isIntersect(rect,realBox)
	if ret then
		self:play(STATE_END)
		--redo
		--local x,y = self:getPosition()
		local st = self.master.config[self.stateName]
		local cfg = st.hitEvent[0]
		cfg.cnt = cfg.cnt or st.hitEvent.cnt
		self.master:handleHit(cfg,true,(minx + maxx) / 2,(miny + maxy) / 2,{stateName = self.stateName})
		if self.master.isAssist then
			self.enemy:doAfterBeat()
		else
			self.enemy:doAfterBeatByAssist()
		end
	end

end

function changeToRealRect(self,boundBox)
	local x,y = self._ccnode:getPosition()
	local minX = x + boundBox.x * self:getDirection()
	local maxX = x + (boundBox.x + boundBox.width) * self:getDirection()
	if minX > maxX then
		minX,maxX = maxX,minX
	end
	local minY = y + boundBox.y
	local maxY = y + boundBox.y + boundBox.height
	return cc.rect(minX,minY,maxX-minX,maxY-minY)
end
