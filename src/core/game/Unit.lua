module("Unit", package.seeall)
setmetatable(Unit, {__index = Control}) 
UI_UNIT_TYPE = "Unit"

isUnit = true

function new(name)
	local ctrl = { 
		name = name,
		uiType = UI_UNIT_TYPE,
		_ccnode = nil,
	}
	setmetatable(ctrl, {__index = Unit})
	init(ctrl)
	return ctrl
end

function init(self)
	local node = cc.Node:create()
    node:setAnchorPoint(cc.p(0,0))
	self._ccnode = node 
end
