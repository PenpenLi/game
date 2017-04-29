module(..., package.seeall)
setmetatable(_M, {__index = Control}) 

local Define = require("src/modules/fight/Define")


function new(isLeft,hero)
	local skin = require("res/fight/FightHeroAttrSkin").children[isLeft and 2 or 1]
    local ctrl = Control.new(skin)
    setmetatable(ctrl,{__index = _M})
    ctrl:init(isLeft,hero)
	ctrl:setScale(Stage.uiScale)
    return ctrl
end

function init(self,isLeft,hero)
	self:setPosition(0,0)
	self:setAnchorPoint(0.5,0.5)

	self._ccnode:setCascadeOpacityEnabled(true)
	self._ccnode:setCascadeColorEnabled(true)

	Common.setLabelCenter(self.name,"center")
	self.name:setString(hero.cname)

	local res = "res/hero/micon/" .. hero.name .. ".png"
	self.icon._ccnode:setTexture(res)
	if not isLeft then
		local size = self.icon:getContentSize()
		self.icon:setScaleX(-1)
		self.icon:setPositionX(self.icon:getPositionX() + size.width)
	end
	self.icon._ccnode:setScaleY(1)

	self.atkSpeed:setString(hero.dyAttr.atkSpeed)
	self.hp:setString(hero.dyAttr.maxHp)
	self.powerR:setString(hero.dyAttr.rageR .. "/s")
end
