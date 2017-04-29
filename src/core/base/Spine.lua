module("Spine", package.seeall)
setmetatable(Spine, {__index = Control})
UI_SPINE_TYPE = "Spine"

function new(name, json, atlas)
	if not atlas then
		atlas = json:sub(1, -5) .. "atlas"
	end
	local spine = {
		name = name,
		uiType = UI_SPINE_TYPE,
		_ccSkeleton = CCSkeletonAnimation:createWithFile(json,atlas),
		_ccnode = nil,
		actionName = "",
		frame = 0,
		loop = false,
		playEnd = false,
	}
	setmetatable(spine, {__index = Spine})
	spine:init()
	return spine
end

function init(self)
	self._ccnode = self._ccSkeleton
	self:openEventListener()
end

function clear(self)
	self:closeEventListener()
	Control.clear(self)
end

function getStates(self)
    if self._ccnode.states:size() > 0 then
        return self._ccnode.states[0]
    else
        return false
    end
end

function openEventListener(self)
	-- self:openTimer()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	self.timerId = scheduler:scheduleScriptFunc(function(dt) self:onFrameEvent(dt) end,0,false)
	--self:addEventListener(Event.Frame, onFrameEvent)
end

function closeEventListener(self)
	-- self:closeTimer()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	scheduler:unscheduleScriptEntry(self.timerId)
end

function onFrameEvent(self, dt)
	local state = self:getStates()
	if not state then
		return
	else
		local curTime = state.time
		curTime = curTime - curTime%0.01
		local curframe = self.frame
		if curTime ~= self.lastTime then
			self.frame = self.frame + 1
		end
		
		-- print("骨骼动画时间:", self.name, curTime, curframe)
		if not self.playEnd then
			self:dispatchEvent(Event.PlayFrame, {etype=Event.PlayFrame, time=curTime, frame = curframe})
		end

		if self:isComplete() and not self.playEnd then
			self:dispatchEvent(Event.PlayEnd, {etype=Event.PlayEnd, time=curTime, frame = curframe})
			if not self.loop then
				self.playEnd = true
			else
				state.time = 0
				self.frame = 0
			end
		end
	end
end

function setFlipX(self, flip)
	local scale = 1
	if flip then
		scale = -1
	end
	self._ccnode:setScaleX(scale)
end

function setAnchorPoint(self, anX, anY)
	self._ccnode:setAnchorPoint(ccp(anX, anY))
end

function setAnimation(self, name, loop, stateIndex)
	self.frame = 0
	self:getStates().time = 0
	self.loop = loop or false
	self.playEnd = false
	self.actionName = name
	self._ccnode:setAnimation(name,loop,stateIndex)
end

function isComplete(self)
    if not self:getStates() then
        return false
    end
	return AnimationState_isComplete(self:getStates()) == 1
end

function setSkin(self, skinName)
	self._ccnode:setSkin(skinName)
end