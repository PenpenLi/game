module("RadioButtonGroup", package.seeall)
setmetatable(RadioButtonGroup, {__index = Control}) 

UI_RADIOBUTTONGROUP_TYPE = "RadioButtonGroup"
UI_RADIOBUTTONGROUP_DEFAULT_STATE = "normal"

isRadioButtonGroup = true

function new(skin)
	local tab = { 
		uiType = UI_RADIOBUTTONGROUP_TYPE,
		name = skin.name,
		_state = UI_RADIOBUTTONGROUP_DEFAULT_STATE,
		_skin = skin, 
		_ccnode = nil,
	}
	setmetatable(tab, {__index = RadioButtonGroup})
	tab:init(skin)
	tab:createChildren(skin)
	return tab 
end

function onChildTouch(self, child)
	if not child._selected then
		if not child.closed then
			for k, v in ipairs(self._children) do
				if v.isRadioButton then
					if v == child then
						v:setSelected(true)
					else
						v:setSelected(false)
					end
				end
			end
		end
		self:dispatchEvent(Event.Change,{etype = Event.Change, target = child})
	end
end
