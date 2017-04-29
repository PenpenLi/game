module("Button", package.seeall)
setmetatable(Button, {__index = Control}) 

UI_BUTTON_TYPE = "Button"
UI_BUTTON_DEFAULT_STATE = "normal"
UI_BUTTON_DEFAULT_SKIN = {
	name="myButton",type="Button",x=0,y=0,width=76,height=26,
	children=
	{
		{name="myImage",type="Image",x=0,y=0,width=76,height=26,
			down={img="anniu1",x=0,y=0,width=76,height=26},
			over={img="anniu2",x=0,y=0,width=76,height=26},
			normal ={img="anniu",x=0,y=0,width=76,height=26},},
		{name="myText",type="Label",x=16,y=7,width=45,height=12,
		 normal={txt="按钮",font="SimSun",size=12,bold=false,italic=false,color={0,0,0}},},
	}
}

UI_BUTTON_NORMAL = "normal"
UI_BUTTON_DOWN = "down"
UI_BUTTON_DISABLE = "disable"

isButton = true

local _beganTouch = nil

function new(skin)
	local bt = { 
		name = skin.name,
		uiType = UI_BUTTON_TYPE,
		_state = UI_BUTTON_DEFAULT_STATE,
		_skin = skin, 
		_ccnode = nil,
		_image = nil,
		_label= nil,
	}
	setmetatable(bt, {__index = Button})
	bt:init(skin)
	bt:createChildren(skin)
	bt:initChildren(skin)
	bt:setEnabled(true)
	return bt 
end

function init(self, skin)
	self.touchChildren = false
	Control.init(self, skin)
	--猥琐拓宽点击区
	if self.name == "close" or self.name == "back" then
		self:adjustTouchBox(10)
	end
end

function initChildren(self, skin)
	self._image = self:getChildByType(Image.UI_IMAGE_TYPE)
	self._image = self._image or self:getChildByType(Image9.UI_IMAGE9_TYPE)
	self._image:setState(self._state, true)
	self._label = self:getChildByType(Label.UI_LABEL_TYPE)
end

function setEnabled(self, value)
	if value then
		self.enabled = true 
		self.touchEnabled = true 
--		self:addEventListener(Event.TouchEvent, self.onTouchEvent)
	else
		self.enabled = false 
		self.touchEnabled = false 
--		self:removeEventListener(Event.TouchEvent, self.onTouchEvent)
	end
end

function shader(self, shaderName, ...)
	Shader.setShader(self._image._ccnode, shaderName, ...)
end

function touch(self,event)
	if self.touchEnabled and self:isVisible() then
		self:onTouchEvent(event)
		self:dispatchEvent(Event.TouchEvent, event)

		if event.etype == Event.Touch_began then
			_beganTouch = self
		elseif event.etype == Event.Touch_ended then
			if _beganTouch == self then
				_beganTouch = nil
				local ev = {etype=Event.Click, x=event.x, y=event.y, p=event.p}
				if self.name == "close" or self.name == "back" then
					UIManager.playMusic("btnClose")
				else
					UIManager.playMusic("btnClick")
				end
				self:onTouchEvent(ev)
				self:dispatchEvent(Event.Click, ev)
			end
		end
	end
	return self.touchParent
end

function getState(self)
	return self._image:getState()
end

function setState(self, state, force, isUseNormal)
	local isSet = self._image:setState(state, force, isUseNormal)
	if state == UI_BUTTON_DISABLE then
		self:shader(Shader.SHADER_TYPE_GRAY)
		-- self:setEnabled(false)
	else
		self:shader()
		-- self:setEnabled(true)
	end
	return isSet
end

function onTouchEvent(self, event)
	print("bt onTouchEvent ".. event.etype)
	if self._image._state == "disable" then 
		return
	end

	if event.etype == Event.Touch_began then
		self:setState("down", true)
	elseif event.etype == Event.Touch_moved then
		self:setState("over")
	elseif event.etype == Event.Touch_ended then
		self:setState("normal")
	elseif event.etype == Event.Touch_over then
		self:setState("down", true)
	elseif event.etype == Event.Touch_out then
		self:setState("normal")
	end
end

