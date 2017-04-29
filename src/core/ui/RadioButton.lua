module("RadioButton", package.seeall)
setmetatable(RadioButton, {__index = Button}) 

UI_RADIOBUTTON_TYPE = "RadioButton"
UI_RADIOBUTTON_DEFAULT_STATE = "normal"
UI_RADIOBUTTON_DEFAULT_SKIN = {
	name="myRadioButton",type="RadioButton",x=0,y=0,width=76,height=26,
	children=
	{
		{name="myImage",type="Image",x=0,y=0,width=76,height=26,
			down={img="anniu1",x=0,y=0,width=76,height=26},
			normal ={img="anniu",x=0,y=0,width=76,height=26},},
		{name="myText",type="Label",x=16,y=7,width=45,height=12,
			normal={txt="单选按钮",font="SimSun",size=12,bold=false,italic=false,color={0,0,0}},},
	}
}

isRadioButton = true

function new(skin)
	local bt = { 
		uiType = UI_RADIOBUTTON_TYPE,
		name = skin.name,
		_state = UI_RADIOBUTTON_DEFAULT_STATE,
		_skin = skin, 
		_ccnode = nil,
		_selected = false,
		_data = nil,
		_image = nil,
		_label= nil,
	}
	setmetatable(bt, {__index = RadioButton})
	bt:init(skin)
	bt:createChildren(skin)
	bt:initChildren(skin)
	bt:setEnabled(true)
	return bt 
end

function getData(self)
	return self._data
end

function setData(self, value)
	self._data = value
end

function getSelected(self)
	return self._selected
end

function setSelected(self, value)
	local value = value and true or false
	if self._selected ~= value then
		self._selected = value
		if value then
			self._image:setState("down", true)
			local ev = {etype = Event.Selected, target = self}
			self:dispatchEvent(Event.Selected, ev) 
		else
			self._image:setState("normal", true)
		end
		local ev = {etype = Event.Change, target = self}
		self:dispatchEvent(Event.Change, ev) 
	end
end

function onTouchEvent(self, event)
--	Button.onTouchEvent(self, event)

	if self._image._state == "disable" then 
		return
	end

	if event.etype == Event.Click then
		if self._parent and self._parent.isRadioButtonGroup then
			self._parent:onChildTouch(self)
		else
			self:setSelected(not self._selected)
		end
	end
end



