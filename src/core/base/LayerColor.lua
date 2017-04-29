module("LayerColor", package.seeall)
setmetatable(LayerColor, {__index = Control}) 
UI_LAYER_COLOR_TYPE = "LayerColor"

isLayerColor = true

function new(name, r, g, b, a, width, height) 
	return new2(name, cc.c4b(r,g,b,a), width, height)
end 

function new2(name, c4b, width, height)
	local layer = { 
		name = name,
		uiType = UI_LAYER_COLOR_TYPE,
		_ccnode = cc.LayerColor:create(c4b, width, height),
	}
	setmetatable(layer, {__index = LayerColor})
	return layer
end

function setColor4(self, r, g, b, a) 
	self._ccnode:setColor(cc.c3b(r, g, b)) 
	self._ccnode:setOpacity(a) 
end

function setColor(self, r, g, b) 
	self._ccnode:setColor(cc.c3b(r, g, b)) 
end 

function setOpacity(self, a) 
	self._ccnode:setOpacity(a) 
end

