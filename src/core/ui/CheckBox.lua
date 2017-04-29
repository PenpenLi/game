module("CheckBox",package.seeall)
setmetatable(CheckBox,{__index = Control})

UI_CHECKBOX_TYPE = "CheckBox"
UI_CHECKBOX_DEFAULT_STATE = "normal"
UI_CHECKBOX_DEFAULT_SKIN = {
	{name="myCheckBox",type="CheckBox",x=0,y=0,width=76,height=26,
		down={img="anniu1",x=0,y=0,width=76,height=26},
		normal ={img="anniu",x=0,y=0,width=76,height=26},
	},
}

isCheckBox = true

function new(skin)
	local bt = {
		uiType = UI_CHECKBOX_TYPE,
		name = skin.name,
		_state = UI_CHECKBOX_DEFAULT_STATE,
		_skin = skin, 
		_ccnode = nil,
		_selected = false,
	}
	setmetatable(bt,{__index = CheckBox})
	bt:init(skin)
	return bt 
end

function init(self,skin)
	self.touchChildren = false
	Control.init(self,skin)
	local stateImg = skin.normal
	local image = cc.Sprite:createWithSpriteFrameName(stateImg.img .. ".png")
	image:setPosition(cc.p(stateImg.x,stateImg.y))
	image:setAnchorPoint(cc.p(0,0))
	self._ccnode:addChild(image)
end

function setState(self,state)
	if self._state ~= state and self._skin[state] then
		self._state = state
		if state == "down" then
			self._selected = true
			local stateImg = self._skin[state]
			if not self.chooseImage then
				local imgUrl = stateImg.img .. ".png"
				self.chooseImage = cc.Sprite:createWithSpriteFrameName(imgUrl)
				self.chooseImage:setPosition(cc.p(stateImg.x,stateImg.y))
				self.chooseImage:setAnchorPoint(cc.p(0,0))
				self._ccnode:addChild(self.chooseImage)
			end
		elseif state == "normal" then
			self._selected = false
			if self.chooseImage then
				self._ccnode:removeChild(self.chooseImage,true)
				self.chooseImage = nil
			end
		end
	end
end

function getSelected(self)
	return self._selected
end

function setSelected(self, value)
	local value = value and true or false
	if self._selected ~= value then
		if value == true then
			self:setState("down")
		elseif not value then
			self:setState("normal")
		end
	end
end

function touch(self,event)
	if self.enabled then
		self:onTouchEvent(event)
	end
	self:dispatchEvent(Event.TouchEvent,event)
	return self.touchParent
end

function onTouchEvent(self, event)
	if event.etype == Event.Touch_ended then
		self:setSelected(not self._selected)
	end
end
