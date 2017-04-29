module("DisplayObject", package.seeall)
setmetatable(DisplayObject, {__index = EventDispatcher}) 

touchEnabled = false 
alive = true

function removeFromParent(self)
	if self._parent then
		self._parent:removeChild(self)
	end
end

function getParent(self)
	return self._parent
end

function getPosition(self)
	return self._ccnode:getPosition()
end

function getPositionX(self)
	return self._ccnode:getPositionX()
end

function getPositionY(self)
	return self._ccnode:getPositionY()
end

function setPosition(self, x, y)
	self._ccnode:setPosition(x, y)
end

function setPositionX(self, x)
	self._ccnode:setPositionX(x)
end

function setPositionY(self, y)
	self._ccnode:setPositionY(y)
end

function getAnchorPoint(self)
	local p = self._ccnode:AnchorPoint()
	return p.x, p.y
end

function setAnchorPoint(self, x, y)
	self._ccnode:setAnchorPoint(x, y)
end

function getContentSize(self)
    return self._ccnode:getContentSize()
end

function setContentSize(self,size)
    self._ccnode:setContentSize(size)
end

function getBoundingBox(self)
    return self._ccnode:getBoundingBox()
end

function getScale(self)
	return self._ccnode:getScale()
end

function getScaleX(self)
	return self._ccnode:getScaleX()
end

function getScaleY(self)
	return self._ccnode:getScaleY()
end

function setScale(self,value)
	return self._ccnode:setScale(value)
end

function setScaleX(self,value)
	return self._ccnode:setScaleX(value)
end

function setScaleY(self,value)
	return self._ccnode:setScaleY(value)
end

function setOpacity(self, value)
	self._ccnode:setOpacity(value)
end

function setFlipX(self,flag)
    return self._ccnode:setFlippedX(flag)
end

function getRotation(self)
	return self._ccnode:getRotation()
end

function setRotation(self,value)
	self._ccnode:setRotation(value)
end

function isVisible(self)
		return self._ccnode:isVisible()
end

function setVisible(self, value)
		return self._ccnode:setVisible(value)
end

function shader(self, shaderName)
end

function touch(self, event)
	if self.touchEnabled and self:isVisible() then
	   self:dispatchEvent(Event.TouchEvent, event)
	end
	return self.touchParent
end

function setTop(self)
    local parent = self._parent
    if parent then
		self._ccnode:retain()
		for k, v in ipairs(parent._children) do
			if v == self then
				table.remove(parent._children, k)
				parent._ccnode:removeChild(v._ccnode, false)
			end
		end
		self._parent = nil
        parent:addChild(self)
        self._ccnode:release()
    end
end

function reorder(self,value)
    local parent = self._parent
    if parent then
        parent._ccnode:reorderChild(self._ccnode,value)
    end
end

function runAction(self,action)
    self._ccnode:runAction(action)
end

function stopAction(self,action)
    self._ccnode:stopAction(action)
end

function stopAllActions(self)
    self._ccnode:stopAllActions()
end

function pauseAction(self)
    cc.Director:getInstance():getActionManager():pauseTarget(self._ccnode)
	--cc.ActionManager:pauseTarget(self._ccnode)
end

function resumeAction(self)
	--cc.ActionManager:resumeTarget(self._ccnode)
    cc.Director:getInstance():getActionManager():resumeTarget(self._ccnode)
end

function numberOfRunningActions(self)
    --return self._ccnode:numberOfRunningActions()
	return self._ccnode:getNumberOfRunningActions()
end

--对象被加入舞台的时候调用，可用来做些呈现初始化
function addStage(self)
end

--对象被清理时被调用，用来做些清理工作
function clear(self)
	self.touchEnabled = false
	self.alive = false 
	self._parent = nil
	self._ccnode = nil
end

--切换父容器
function changeParent(self, newParent)
	assert(self._parent)
	local parent = self._parent
	local x, y = self._ccnode:getPosition()
	local worldPoint = parent._ccnode:convertToWorldSpace(cc.p(x,y)) 
	self._ccnode:retain()
	for k, v in ipairs(parent._children) do
		if v == self then
			table.remove(parent._children, k)
			parent._ccnode:removeChild(v._ccnode, true)
		end
	end
	self._parent = nil
	newParent:addChild(self)
	local localPoint = newParent._ccnode:convertToNodeSpace(worldPoint) 
	self._ccnode:release()
	self._ccnode:setPosition(localPoint)
end

function margin(self)
end

--水平居中
function marginCenter(self)
	local parent = self._parent
	if parent then
		local size = self:getContentSize()
		local pSize = parent:getContentSize()
		self:setPositionX((pSize.width - size.width) / 2)
	end
end

--上下居中
function marginMiddle(self)
	local parent = self._parent
	if parent then
		local size = self:getContentSize()
		local pSize = parent:getContentSize()
		self:setPositionY((pSize.height - size.height) / 2)
	end
end

--顶边距
function marginTop(self, value)
	local parent = self._parent
	if parent then
		local size = self:getContentSize()
		local pSize = parent:getContentSize()
		self:setPositionY(pSize.height - size.height - (value or 0))
	end
end

--底边距
function marginBottom(self, value)
	self:setPositionY(value or 0)
end

--左边距
function marginLeft(self, value)
	self:setPositionX(value or 0)
end

--右边距
function marginRight(self, value)
	local parent = self._parent
	if parent then
		local size = self:getContentSize()
		local pSize = parent:getContentSize()
		print("===>parent:"..parent.name)
		print("===>marginRight:"..self.name..","..pSize.width..","..size.width)
		self:setPositionX(pSize.width - size.width - (value or 0))
	end
end

function addTimer(self, func, interval, maxTimes, listener)
	assert(interval > 0)
	assert(maxTimes > 0 or maxTimes == -1)
	if not self._timerEvents then
		self._timerEvents = {}
	end
	local timer = {listener = listener or self, interval = interval, maxTimes = maxTimes}
	local now = self._timerNow or 0
	timer.nextCall = now + interval
	self._timerEvents[func] = timer
	return timer 
end

function delTimer(self,timer)
	for func,v in pairs(self._timerEvents) do
		if timer == v then
			self._timerEvents[func] = nil
			return 
		end
	end
end

function onTimerCallBack(self, delay)
	self._timerNow = self._timerNow + delay 
	if self._timerEvents then
		local clearTable = {}
		for func, ev in pairs(self._timerEvents) do
			if ev.maxTimes == 0 then -- 容错，防止func执行报错后计时器没被移除
				table.insert(clearTable,func)
			elseif ev.nextCall <= self._timerNow then
				--ev.nextCall = self._timerNow + ev.interval
				ev.nextCall = ev.nextCall + ev.interval
				ev.maxTimes = ev.maxTimes - 1
				if ev.maxTimes == 0 then
					table.insert(clearTable,func)
				end
				func(ev.listener, ev, self)--千万注意不要在回调事件里面干掉事件容器self
			end
		end
		for _,func in ipairs(clearTable) do 
			self._timerEvents[func] = nil
		end
	end
end

local evFrame = {etype = Event.Frame, target = nil, delay=1}
function onFrameCallBack(self, delay)
	evFrame.target = self
	evFrame.delay = delay 
	EventDispatcher.dispatchEvent(self, Event.Frame, evFrame)
	onTimerCallBack(self, delay)
end

function openTimer(self)
	local callback = function(delay) 
		if self.alive then
			return self:onFrameCallBack(delay) 
		end
	end
	self._timerNow = self._timerNow or 0
	self._ccnode:scheduleUpdateWithPriorityLua(callback,0)
end

function closeTimer(self)
	self._ccnode:unscheduleUpdate()
	self._timerNow = 0
	self._timerEvents = {} 
end

function setWinCenter(self)
    self:setPosition(0,0)
	local size = self:getContentSize()
    local tx = (Stage.winSize.width - size.width) / 2
    local ty = (Stage.winSize.height - size.height) / 2
    local locationPos = self._ccnode:convertToNodeSpace(cc.p(tx,ty)) 
	self:setPosition(locationPos.x,locationPos.y)
end

function setParentCenter(self)
    if not self._parent then
        return
    end
	local size = self:getContentSize()
    local pSize = self._parent:getContentSize()
	self:setPosition((pSize.width - size.width) / 2,(pSize.height - size.height) /2)
end

function setStageCenter(self)
	self:setPosition((winSize.width - designSize.width) / 2,(winSize.height - designSize.height) / 2)
end

--调整可点击区
function adjustTouchBox(self, dx, dy, dw, dh)
	self.getBoundingBox = function()
		local box = self._ccnode:getBoundingBox()
		box.x = box.x - dx 
		box.y = box.y - (dy or dx)  
		box.width = box.width + (dw or 2 * dx) 
		box.height = box.height + (dh or 2 * dx) 
		return box
	end
end


