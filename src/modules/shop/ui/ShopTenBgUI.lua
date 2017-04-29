module("ShopTenBgUI",package.seeall)
setmetatable(_M,{__index = Control})

function new()
	local ctrl = LayerColor.new("ShopTenBg",0,0,0,0,Stage.winSize.width+1,Stage.winSize.height)
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP_FULL
end

function addStage(self)
	self:setPositionY(-Stage.uiBottom)
end

function init()
end

return ShopTenBgUI
