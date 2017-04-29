module("Layer", package.seeall)
setmetatable(Layer, {__index = Control}) 
UI_LAYER_TYPE = "Layer"

isLayer = true

function new(name) 
	local layer = { 
		name = name,
		uiType = UI_LAYER_TYPE,
		_ccnode = nil,
	}
	setmetatable(layer, {__index = Layer})
	layer:init()
	return layer
end 

function init(self)
	local layer = cc.Layer:create()
	local function onTouch(eventType, x, y)
		self:touch({etype = eventType, p = cc.p(x,y), x = x, y = y})
		return true
	end
	layer:registerScriptTouchHandler(onTouch)
	layer:setTouchEnabled(true)
	self._ccnode = layer
end

