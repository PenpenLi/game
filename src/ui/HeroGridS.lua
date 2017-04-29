module("HeroGridS",package.seeall)
setmetatable(_M,{__index = Control})
local HeroDefine = require("src/modules/hero/HeroDefine")

function new(bg,pos)
	local ctrl = Control.new(require("res/common/HeroGridSSkin"),{"res/common/HeroGridS.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "HeroGridS"..(pos or 0)
	ctrl:init(bg,pos)
	return ctrl
end

function init(self,bg,pos)
	CommonGrid.bind(self.headBG)
	for i = 1,4 do
		if i == pos then
			self["no"..i]:setVisible(true)
		else
			self["no"..i]:setVisible(false)
		end
	end
	if bg then
		bg._parent:addChild(self)
		self:setPositionX(bg:getPositionX()-5)
		self:setPositionY(bg:getPositionY())
	end
end

function setHero(self,hero)
	if not hero then
		self:setVisible(false)
		return 
	end
	self:setVisible(true)
	local career = HeroDefine.DefineConfig[hero.name].career
	for i = 1,5 do
		if i == career then
			self["careersicon"..i]:setVisible(true)
		else
			self["careersicon"..i]:setVisible(false)
		end
	end
	--for i = 2,6 do
	--	self["xsz"..i]:setVisible(false)
	--end
	--if hero.quality > 1 and self["xsz"..hero.quality] then
	--	print("hero.quality::"..hero.quality)
	--	self["xsz"..hero.quality]:setVisible(true)
	--end
	for i = 1,6 do
		self["star"..i]:setVisible(false)
	end
	if hero.quality then
		for i = 1,hero.quality do
			if i <= HeroDefine.MAX_QUALITY then
				self["star"..i]:setVisible(true)
			end
		end
	end
	self.txtshuzi:setString(hero.lv)
	local transferLv = 1
	--if hero.transferLv then
	--	transferLv = hero.transferLv + 1
	--elseif hero.strength then
	--	transferLv = hero.strength.transferLv + 1
	--end
	if hero.quality then
		transferLv = hero.quality
	end
	self.headBG:setHeroIcon(hero.name,nil,nil,transferLv)
end

return HeroGridS
