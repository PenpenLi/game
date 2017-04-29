module("ShopHeroUI",package.seeall)
setmetatable(_M,{__index = Control})
local ShopDefine = require("src/modules/shop/ShopDefine")
local ItemConfig = require("src/config/ItemConfig").Config
local HeroFightDefine = require("src/modules/fight/Define")
local HeroDefine = require("src/modules/hero/HeroDefine")
local cache = {}

function new(itemId,disFrag)
	local ctrl = Control.new(require("res/shop/ShopHeroSkin.lua"),{"res/shop/ShopHero.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(itemId,disFrag)
	return ctrl
end

function uiEffect()
	return UIManager.SECOND_TEMP_FULL
end

function init(self,itemId,disFrag)
	UIManager.playMusic("lotteryHero")
	self.itemId = itemId
	self.yx:setVisible(false)
	local x = self.yx:getPositionX() - 40
	local y = self.yx:getPositionY()
	local cfg = ItemConfig[itemId]
	self.txtydn:setString(cfg.name)
	self.heroName = cfg.attr["addHero"].name

	self.txtdesc:setAnchorPoint(0.5,0)
	self.txtdesc2:setAnchorPoint(0.5,0)
	if disFrag == 1 then
		local qualityName = HeroDefine.HERO_QUALITY[cfg.color].name
		local num = cfg.attr["addHero"].frag
		self.txtdesc:setString(string.format("已拥有该英雄，%s色卡牌转换成该英雄碎片%d个",qualityName,num))
		self.txtdesc2:setString("英雄碎片可提升英雄品质")
	else
		self.txtdesc:setString("")
		self.txtdesc2:setString("")
	end
	Common.setBtnAnimation(self._ccnode,"ShopHero","获得新英雄")
	----armature
	self.armatureCfg = require(string.format("src/config/hero/%sConfig",self.heroName)).Config
	local bigBody = HeroFightDefine.resUrl[self.heroName]
	local loader = AsyncLoader.new()
	loader:addEventListener(loader.Event.Load,function(self,event) 
		if event.etype == AsyncLoader.Event.Finish and self.alive == true then
			self.heroBody = self:loadHeroBody(bigBody,self.heroName,x,y)
			self.heroBody:getAnimation():playWithNames({'胜利','待机'},0,false)
		end
	end,self)
	loader:addArmatureFileInfo(bigBody)
	loader:start()
end

function loadHeroBody(self,resUrl,name,x,y)
	self:addArmatureFrame(resUrl)
	self.heroBody = ccs.Armature:create(name)
	self.heroBody:setAnchorPoint(0,0.5)
	self.heroBody:setPosition(x,y)
	self._ccnode:addChild(self.heroBody,1)
	return self.heroBody
end

function touch(self,event)
	if event.etype == Event.Touch_ended then
		UIManager.removeUI(self)
		if not empty() then
			local data = popCache()
			local ShopOnceUI = UIManager.addChildUI(data.url,unpack(data.params))
			ShopOnceUI:refreshBack(unpack(data.params))
		end
	end
end

function closePanel(self)
	cache = {}
	self:removeFromParent()
end

function empty()
	return #cache <= 0 
end

function pushCache(data)
	cache[#cache+1] = data
end

function topCache()
	return cache[#cache]
end

function popCache()
	local data = topCache()
	cache[#cache] = nil
	return data
end

return ShopHeroUI
