module("Swf", package.seeall)
setmetatable(Swf, {__index = Control}) 
UI_SWF_TYPE = "Swf"

function new(name,fileUrl)
	local swf = {
		name = name,
		uiType = UI_SWF_TYPE,
		_ccnode = CCSWFNode:create(fileUrl),
		_running = false,
		_repeat = true,
		_rptBegin = 0, -- 帧数从0开始
		_rptEnd = 0,
		_preFrame = -1,
	}
	setmetatable(swf,{__index=Swf})
	swf.frameCount = swf._ccnode:getFrameCount() 
	print("--swf frameCount:",swf.name,swf.frameCount)
	swf._rptEnd = swf.frameCount - 1 -- 默认最大帧 
	print("--swf _rptEnd:",swf.name,swf._rptEnd)
	swf:init()
	return swf
end

function init(self)
	self.touchEnabled = false
	self:openTimer()
	self:addEventListener(Event.Frame, onFrameEvent)
end

function onFrameEvent(self, event)
	if self._running then
		local curFrame = self:getCurrentFrame()
		if self._preFrame < curFrame then
			for i = self._preFrame + 1, curFrame do
				self:dispatchEvent(Event.PlayFrame,{etype=Event.PlayFrame,frame=i} )
			end
			self._preFrame = curFrame
		end

		if curFrame == self.frameCount - 1 then --播到尾了
			if self._repeat then
				self:gotoFrame(self._rptBegin)
				self:play()
			else
				self:stop()
				self:dispatchEvent(Event.PlayEnd,{etype=Event.PlayEnd} )
				return
			end
		end
		if curFrame >= self._rptEnd - 1 then
			if self._repeat then
				self:gotoFrame(self._rptBegin)
				self:play()
			else
				self:stop()
				self:dispatchEvent(Event.PlayEnd,{etype=Event.PlayEnd} )
				return
			end
		end
		self._ccnode:advance(event.delay)
	end
end

function setRepeat(self, isRepeat, repeatBegin, repeatEnd)
	self._repeat =  isRepeat and true or false
	if repeatBegin and repeatEnd 
		and repeatBegin < repeatEnd 
		and repeatBegin >= 0 
		and repeatEnd < self.frameCount then
		self._rptBegin = repeatBegin
		self._rptEnd = repeatEnd
	end
end

function getCurrentFrame(self)
	return self._ccnode:getCurrentFrame()
end

function getFrameCount(self)
	return self.frameCount
end

function gotoFrame(self, frame)
	self:stop()
	self._ccnode:gotoFrame(frame)
	self._preFrame = frame - 1
end

function play(self)
	self._ccnode:setRunning(true)
	self._running = true
end

function stop(self)
	self._ccnode:setRunning(false)
	self._running = false 
end

function setFlipX(self, flipX)
	self._ccnode:setFlipX(flipX)
end


