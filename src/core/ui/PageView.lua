--[[**************************************************************************** 
用法：
UI_PageView_DEFAULT_SKIN = {
	name="myPageView",type="PageView",x=0,y=0,width=553,height=364,
	children=
		{
			{name="bg",type="Image",x=0,y=0,width=553,height=364,
			normal={img="scrolltest.bg",x=0,y=0,width=553,height=364},},
			{name="testinner",type="Container",x=116,y=132,width=319,height=112,
				children=
				{
					{name="content",type="Image",x=0,y=0,width=319,height=112,
					normal={img="scrolltest.content",x=0,y=0,width=319,height=112},},
				}
			}
		}
}

默认Skin里面带一个Container和一张Image背景，Container为第一页的内容，背景不响应翻页事件
1、function setDirection(self,direct)，用于设置水平或垂直的方向，第二个参数，0代表水平
，1代表垂直
2、function addUnit(self,skin)，增加翻页数量，第二个参数为空时，新增页的内容与第一页相同，
第二个参数为自定义skin
3、function setUnitNum(self,num,bool)，设置翻页数量
4、通过self.unitContainer[i]:getChild()来获取自己的控件（除背景外）,
如myPageView.unitContainer[1]:getChild("testinner")
5、function setSpeedMulti(self,value)，设置速度参数
****************************************************************************]] 
module("PageView",package.seeall)
setmetatable(PageView,{__index = Control})


UI_PageView_TYPE = "PageView"
UI_PageView_HORIZONTAL = 0
UI_PageView_VERTICAL = 1
UI_PageView_MOVE_DISTANCE = 50
UI_PageView_SPEED_FACTOR = 20
UI_PageView_DISTANCE_LEVEL = 5
UI_PageView_KEEPFRAME_TIMES = 4
UI_PageView_BUFFER_FACTOR = 2

function new(skin)
	local sv = {
	name = skin.name,
	uiType = UI_PageView_TYPE,
	_skin = skin,
	_ccnode = nil,
	_direction = UI_PageView_HORIZONTAL,
	unitContainer = {},
	unitNum = 0,
	currentUnit = 0,
	buffer = false,
	lastPos = {},
	}
	setmetatable(sv,{__index = PageView})
	sv:init(skin)
	sv:createContent(skin)
	return sv
end

function init(self,skin)
	local node = MX.ScissorNode:create()
	node:setContentSize(cc.size(skin.width,skin.height))
	node:setPosition(cc.p(skin.x,skin.y))
	node:setAnchorPoint(cc.p(0,0))
	self._ccnode = node
	local moveSkin = {
		name = "movenode",
		x = 0,
		y = 0,
		width = skin.width,
		height = skin.height,
		children = {},
	}
	local moveNode = Control.new(moveSkin)
	self:addChild(moveNode)
	self.moveNode = moveNode
end

function createContent(self,skin)
	for _, childSkin in ipairs(skin.children) do
		if childSkin.type == "Image" or childSkin.type == "Image9" then
			local node = _G[childSkin.type]
			self:addChild(node.new(childSkin))
			self.moveNode:setTop()
		elseif childSkin.type == "Container" then
			self.childSkin = childSkin
			self:addUnit()
			self.currentUnit = 1
		end
	end
end

function addUnit(self,skin)
	self.unitNum = self.unitNum + 1
	local unitSkin = {
		name = "unit" .. self.unitNum,
		x = 0,
		y = 0,
		width = self._skin.width,
		height = self._skin.height,
		children = {},
	}
	if skin then
		unitSkin.children = {skin}
	else
		if self.childSkin then
			unitSkin.children = {self.childSkin}
		end
	end
	local unit = Control.new(unitSkin)
	self.unitContainer[#self.unitContainer+1] = unit
	self.moveNode:addChild(unit)
	self:setUnitPos(unit,self.unitNum)
end

function removeUnit(self,num)
	if self.unitNum>1 then
		if num and num>=1 and num<=self.unitNum then
			self.unitNum = self.unitNum - 1
			self.moveNode:removeChild(self.unitContainer[num])
			table.remove(self.unitContainer,num)
		elseif not num then
			self.moveNode:removeChild(self.unitContainer[self.unitNum])
			table.remove(self.unitContainer,self.unitNum)
			self.unitNum = self.unitNum-1
			if self._direction == UI_PageView_HORIZONTAL then
				self.moveNode:setContentSize(cc.size(self._skin.width*self.unitNum,self._skin.height))
				action = cc.MoveTo:create(0.2,cc.p((1-self.unitNum)*self._skin.width,0))
				self.moveNode:runAction(action)
			end
		end
	end
end

function resetPageView(self)
	--if self._direction == UI_PageView_VERTICAL
end

function setUnitPos(self,unit,num)
	if self._direction == UI_PageView_HORIZONTAL then
		if num == self.unitNum then
			self.moveNode:setContentSize(cc.size(self._skin.width*self.unitNum,self._skin.height))
		end
		unit:setPosition((num-1)*unit._skin.width,0)
	elseif self._direction == UI_PageView_VERTICAL then
		if num == self.unitNum then
			self.moveNode:setContentSize(cc.size(self._skin.width,self._skin.height*self.unitNum))
		end
		unit:setPosition(0,(1-num)*unit._skin.height)
	end
end

function setDirection(self,direct)
	if direct then
		self._direction = direct
		if self.unitNum > 1 then
			for i=2,self.unitNum do
				self:setUnitPos(self.unitContainer[i],i)
			end
		end
	end
end

function setUnitNum(self,num,skin)
	if num>=0 then
		if num>self.unitNum then
			local uNum = self.unitNum
			for k=uNum+1,num do
				self:addUnit(skin)
			end
		elseif num<self.unitNum then
			for k=num+1,self.unitNum do
				self:removeUnit()
			end
		end
	end
	--[[
	if num>1 then
		for k=2,num do
			self:addUnit(skin)
		end
	end
	--]]
end

function setEnabled(self,value)
	if value then
		self.enabled = true
	else
		self.enabled = false
	end
end

function setSpeedMulti(self,value)
	if value>0 then
		UI_PageView_SPEED_FACTOR = UI_PageView_SPEED_FACTOR*value
	end
end

function touch(self,event)
	if self.enabled then
		self:onTouchEvent(event)
	end
	self:dispatchEvent(Event.TouchEvent, event)
	if event.etype == Event.Touch_out then
		self.moveEvent = nil
	end
	if event.etype == Event.Touch_ended then
		if self.moveEvent == nil then
			return Control.touch(self,event)
		else
			self.moveEvent = nil
			local eventOut = event
			eventOut.etype = Event.Touch_out
			Control.touch(self,eventOut)
			return self.touchParent
		end
	else
		return Control.touch(self,event)
	end
end

function getUnitsPos(self)
	return self.moveNode:getPosition()
end

function getUnitsPosX(self)
	return self.moveNode:getPositionX()
end

function getUnitsPosY(self)
	return self.moveNode:getPositionY()
end

function setUnitsPos(self,x,y)
	self.moveNode:setPosition(x,y)
end

function onTouchEvent(self, event)
	print("bt onTouchEvent ".. event.etype)
	if event.etype == Event.Touch_began then
		self:touchBeganFuc(event)
	elseif event.etype == Event.Touch_moved then
		self:touchMovedFuc(event)
	elseif event.etype == Event.Touch_ended then
		self:touchEndedFuc(event)
	elseif event.etype == Event.Touch_over then
	elseif event.etype == Event.Touch_out then
		self:touchEndedFuc(event)
	end
end

function touchBeganFuc(self,event)
	self.preX,self.preY = self:getUnitsPos()
	self.prePos = event.p
	self.moveNode:stopAllActions()
	if self.prePos then
		if self._direction == UI_PageView_HORIZONTAL then
			self.currentUnit = 1-math.floor(self.preX/self._skin.width+0.5)
		elseif self._direction == UI_PageView_VERTICAL then
			self.currentUnit = math.floor(self.preY/self._skin.height+0.5)+1
		end
	end
end

function touchMovedFuc(self,event)
	self.move = true
	if self.prePos == nil or self.preX == nil or self.preY == nil then
		touchBeganFuc(self,event)
	end
	--是否为手指move事件
	if self.moveEvent == nil then
		if math.abs(event.p.x-self.prePos.x)>UI_PageView_MOVE_DISTANCE or
			math.abs(event.p.y-self.prePos.y)>UI_PageView_MOVE_DISTANCE then
			self.moveEvent = true
		end
	end
	--存储后几帧的位置
	if #self.lastPos < UI_PageView_KEEPFRAME_TIMES then
		table.insert(self.lastPos,event.p)
	else
		table.remove(self.lastPos,1)
		table.insert(self.lastPos,event.p)
	end
	self:followMove(event)
end

function followMove(self,event)
	if self.prePos then
		if self._direction == UI_PageView_HORIZONTAL then
			if self.buffer == false then
				if self.currentUnit == 1 then
					if event.p.x-self.prePos.x > UI_PageView_MOVE_DISTANCE then
						self.buffer = true
						self.preX,self.preY = self:getUnitsPos()
						self.prePos = event.p
					end
				end
				if self.currentUnit == self.unitNum then
					if self.prePos.x-event.p.x > UI_PageView_MOVE_DISTANCE then
						self.buffer = true
						self.preX,self.preY = self:getUnitsPos()
						self.prePos = event.p
					end
				end
			end
			if self.buffer then
				self:setUnitsPos(self.preX+(event.p.x-self.prePos.x)/UI_PageView_BUFFER_FACTOR,self.preY)
			else
				self:setUnitsPos(self.preX+event.p.x-self.prePos.x,self.preY)
			end
		elseif self._direction == UI_PageView_VERTICAL then
			if self.buffer == false then
				if self.currentUnit == 1 then
					if self.prePos.y-event.p.y > UI_PageView_MOVE_DISTANCE then
						self.buffer = true
						self.preX,self.preY = self:getUnitsPos()
						self.prePos = event.p
					end
				end
				if self.currentUnit == self.unitNum then
					if event.p.y-self.prePos.y > UI_PageView_MOVE_DISTANCE then
						self.buffer = true
						self.preX,self.preY = self:getUnitsPos()
						self.prePos = event.p
					end
				end
			end
			if self.buffer then
				self:setUnitsPos(self.preX,self.preY+(event.p.y-self.prePos.y)/UI_PageView_BUFFER_FACTOR)
			else
				self:setUnitsPos(self.preX,self.preY+event.p.y-self.prePos.y)
			end
		end
	end
end

function touchEndedFuc(self,event)
	self.preX = nil
	self.preY = nil
	self.buffer = false
	if self.move == nil then
		return
	end
	if self.unitNum == 0 then
		local action = cc.MoveTo:create(0.3,cc.p(0,0))
		self.moveNode:runAction(action)
	end
	if self.unitNum>0 then
		self:flipUnit(event)
	end
	self.prePos = nil
	self.move = nil
	self.lastPos = {}
end

function nextPage(self)
	self:selectUnit(self.currentUnit+1)
end

function prePage(self)
	self:selectUnit(self.currentUnit-1)
end

function selectUnit(self,index,time)
	if time == nil then
		time = 0.2
	end
	if index <= 0 or index > self.unitNum then
		return 
	end
	local action
	if self._direction == UI_PageView_HORIZONTAL then
		action = cc.MoveTo:create(time,cc.p((1-index)*self._skin.width,0))
	elseif self._direction == UI_PageView_VERTICAL then
		action = cc.MoveTo:create(time,cc.p(0,(index-1)*self._skin.height))
	end
	function callBackFuc()
		local px,py = self:getUnitsPos()
		if self._direction == UI_PageView_HORIZONTAL then
			self.currentUnit = 1-math.floor(px/self._skin.width+0.5)
		elseif self._direction == UI_PageView_VERTICAL then
			self.currentUnit = math.floor(py/self._skin.height+0.5)+1
		end
		local event = {etype=Event.FlipUnitEvent, x=px, y=py, p=cc.p(px,py),currentUnit = self.currentUnit}
		if self._events and self._events[Event.FlipUnitEvent] then 
			for func, listener in pairs(self._events[Event.FlipUnitEvent]) do
				func(listener, event, self, func)
			end
		end
	end
	local callBack=cc.CallFunc:create(callBackFuc)
	self.moveNode:runAction(cc.Sequence:create({action, callBack}))
end

function flipUnit(self,event)
	local action = cc.MoveTo:create(0.2,cc.p(0,0))
	if self._direction == UI_PageView_HORIZONTAL then
		local posX = self:getUnitsPosX()
		local t = math.floor(posX/self._skin.width+0.5)
		if t>0 then
			action = cc.MoveTo:create(0.2,cc.p(0,0))
		elseif t<-self.unitNum+1 then
			action = cc.MoveTo:create(0.2,cc.p((-self.unitNum+1)*self._skin.width,0))
		else
			--快速翻页
			if math.abs(event.p.x-self.prePos.x)>UI_PageView_MOVE_DISTANCE
				and math.abs(self.lastPos[1].x-event.p.x)>UI_PageView_DISTANCE_LEVEL then
				local actionTime = UI_PageView_SPEED_FACTOR/(math.abs(self.lastPos[1].x
				-event.p.x)+UI_PageView_SPEED_FACTOR*2.5)
			--判断快速翻页后
				if event.p.x>self.prePos.x then
					if self.currentUnit<=1 then
						--快速到Page0,self.beginTime = self._timerNow
						action = cc.MoveTo:create(actionTime,cc.p(0,0))
					elseif self.currentUnit > self.unitNum then
						--快速到Page最后
						action = cc.MoveTo:create(actionTime,cc.p((1-self.unitNum)*self._skin.width,0))
					else
						--快速到Page-1
						action = cc.MoveTo:create(actionTime,cc.p((2-self.currentUnit)*self._skin.width,0))
					end
				elseif event.p.x<self.prePos.x then
					if self.currentUnit<1 then
						--快速到Page1
						action = cc.MoveTo:create(actionTime,cc.p(0,0))
					elseif self.currentUnit>=self.unitNum then
						--快速到Page最后
						action = cc.MoveTo:create(actionTime,cc.p((1-self.unitNum)*self._skin.width,0))
					else
						--快速到Page+1
						action = cc.MoveTo:create(actionTime,cc.p((0-self.currentUnit)*self._skin.width,0))
					end
				end
			--慢速翻页
			else
				action = cc.MoveTo:create(0.3,cc.p(t*self._skin.width,0))
			end
		end
	elseif self._direction == UI_PageView_VERTICAL then
		local posY = self:getUnitsPosY()
		local t = math.floor(posY/self._skin.height+0.5)
		if t<0 then
			action = cc.MoveTo:create(0.2,cc.p(0,0))
		elseif t>self.unitNum-1 then
			action = cc.MoveTo:create(0.2,cc.p(0,(self.unitNum-1)*self._skin.height))
		else
			if math.abs(event.p.y-self.prePos.y)>UI_PageView_MOVE_DISTANCE
				and math.abs(self.lastPos[1].y-event.p.y)>UI_PageView_DISTANCE_LEVEL then
				local actionTime = UI_PageView_SPEED_FACTOR/(math.abs(self.lastPos[1].y-event.p.y)
				+UI_PageView_SPEED_FACTOR*2.5)
				if event.p.y<self.prePos.y then
					if self.currentUnit<=1 then
						action = cc.MoveTo:create(actionTime,cc.p(0,0))
					elseif self.currentUnit > self.unitNum then
						action = cc.MoveTo:create(actionTime,cc.p(0,(self.unitNum-1)*self._skin.height))
					else
						action = cc.MoveTo:create(actionTime,cc.p(0,(self.currentUnit-2)*self._skin.height))
					end
				elseif event.p.y>self.prePos.y then
					if self.currentUnit<1 then
						action = cc.MoveTo:create(actionTime,cc.p(0,0))
					elseif self.currentUnit>=self.unitNum then
						action = cc.MoveTo:create(actionTime,cc.p(0,(self.unitNum-1)*self._skin.height))
					else
						action = cc.MoveTo:create(actionTime,cc.p(0,self.currentUnit*self._skin.height))
					end
				end
			else
				action = cc.MoveTo:create(0.3,cc.p(0,t*self._skin.height))
			end
		end
	end
	function callBackFuc()
		local px,py = self:getUnitsPos()
		if self._direction == UI_PageView_HORIZONTAL then
			self.currentUnit = 1-math.floor(px/self._skin.width+0.5)
		elseif self._direction == UI_PageView_VERTICAL then
			self.currentUnit = math.floor(py/self._skin.height+0.5)+1
		end
		local event = {etype=Event.FlipUnitEvent, x=px, y=py, p=cc.p(px,py),currentUnit = self.currentUnit}
		if self._events and self._events[Event.FlipUnitEvent] then 
			for func, listener in pairs(self._events[Event.FlipUnitEvent]) do
				func(listener, event, self, func)
			end
		end
	end
	local callBack=cc.CallFunc:create(callBackFuc)
	self.moveNode:runAction(cc.Sequence:create({action, callBack}))
end

function beginAction(self,action)
	self.unitContainer[1]:runAction(action)
end
