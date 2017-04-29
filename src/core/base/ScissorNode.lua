module("ScissorNode", package.seeall)
setmetatable(ScissorNode, {__index = Control})
UI_SCISSORNODE_TYPE = "ScissorNode"

isScissorNode = true

function new(name)
	local layer = {
		name = name,
		uiType = UI_SCISSORNODE_TYPE,
		_ccnode = nil,
	}
	setmetatable(layer, {__index = ScissorNode})
	layer:init()
	return layer
end

function init(self)
	local node = CCScissorNode:create()
	self._ccnode = node
end
