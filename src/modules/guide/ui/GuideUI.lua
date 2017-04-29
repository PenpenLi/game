module(..., package.seeall)
setmetatable(_M, {__index = Control})

function new()
	local ctrl = Control.new(require("res/guide/GuideSkin"), {"res/guide/Guide.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function init(self)
	local posX = self.desTxt:getPositionX()
	local posY = self.desTxt:getPositionY()
	self.desTxt:removeFromParent()
	self.desTxt = RichText2.new()
	self.desTxt:setTextWidth(205)
	self.desTxt:setPositionX(posX)
	self.desTxt:setPositionY(posY + 40)
	self.desTxt:setShadow(false)
	self:addChild(self.desTxt)
end

function setDesc(self, desc)
	self.desTxt:setString(desc)
end
