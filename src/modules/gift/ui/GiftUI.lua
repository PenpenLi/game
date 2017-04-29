module(..., package.seeall)
setmetatable(_M, {__index = Control})
local Hero = require("src/modules/hero/Hero")
local GiftLogic = require("src/modules/gift/GiftLogic")
local GiftConfig = require("src/config/GiftConfig").Config
local GiftConditionConfig = require("src/config/GiftConditionConfig").Config
local GiftEffectConfig = require("src/config/GiftEffectConfig").Config
local HeroDefine = require("src/modules/hero/HeroDefine")
local GiftDefine = require("src/modules/gift/GiftDefine")

Instance = nil 
function new(heroName)
	local ctrl = Control.new(require("res/hero/HeroInfoGiftSkin"),{"res/hero/HeroInfoGift.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(heroName)
	Instance = ctrl
	return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP_LABEL
end

function clear(self)
	Instance = nil
	Control.clear(self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 4, groupId = GuideDefine.GUIDE_TALENT})
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 3, groupId = GuideDefine.GUIDE_TALENT})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 5, groupId = GuideDefine.GUIDE_TALENT})
end

function init(self,heroName)
	self.heroName = heroName
	--self.heroIndex = 1
	--self.heroList = Hero.getSortedHeroes()

	for k = 1,GiftDefine.MAX_GIFT do
		local crt = self.minjie["minjie" .. k]
		crt.index = k
		crt:addEventListener(Event.TouchEvent,onSelect,self)
	end

	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.info.activate, step = 4, groupId = GuideDefine.GUIDE_TALENT})
	self.info.activate:addEventListener(Event.TouchEvent,onActivate,self)
	local size = self.info.desc:getContentSize()
	local x,y = self.info.desc:getPosition()
	self.info.descX = x 
	self.info.descY = y + size.height
	--self.info.desc:setAnchorPoint(0,1)
	--self.info.desc:setPositionY(y + size.height)
	self.info.desc:setDimensions(size.width)


	Common.setLabelCenter(self.heroname,"center")

	self.right:addEventListener(Event.TouchEvent,onRight,self)
	self.left:addEventListener(Event.TouchEvent,onLeft,self)

	self.back:addEventListener(Event.TouchEvent,onClose,self)

	local size = self.icon:getContentSize()
	local x,y = self.icon:getPosition()
	self.icon:setAnchorPoint(0.5,0.5)
	self.icon:setPosition(x+size.width/2,y+size.height/2)

	self:addArmatureFrame("res/armature/effect/Finger.ExportJson")
	self.fingerEff = ccs.Armature:create("Finger")
	self.fingerEff:getAnimation():play('特效', -1, 1)
	self.minjie._ccnode:addChild(self.fingerEff)

	self:updateHero()
end

function getHero(self)
	return Hero.getHero(self.heroName)
	--return self.heroList[self.heroIndex]
end

function nextHero(self)
	--[[
	self.heroIndex = self.heroIndex + 1
	if self.heroIndex > #self.heroList then
		self.heroIndex = 1
	end
	--]]
	_,self.heroName = Hero.getNeighbours(self.heroName)	
end

function preHero(self)
	--[[
	self.heroIndex = self.heroIndex - 1
	if self.heroIndex < 1 then
		self.heroIndex = #self.heroList
	end
	--]]
	self.heroName,_ = Hero.getNeighbours(self.heroName)	
end

function updateHero(self)
	local hero = self:getHero()
	self.selectIndex = math.min(#hero.gift + 1,GiftDefine.MAX_GIFT)

	if self.heroIcon then
		self:removeChild(self.heroIcon)
	end

	self.heroIcon = HeroGridS.new(self.chengjiuBG)
	self.heroIcon:setHero(hero)
	self.heroIcon:setScale(0.8)

	--[[
	local icon = "res/hero/icon/" .. hero.name .. ".png"
	self.icon._ccnode:setTexture(icon)
	self.icon._ccnode:setScale(0.8)
	--]]

	--self.heroname:setString(hero.cname)
	hero:showHeroNameLabel(self.heroname)

	local heroGift = GiftLogic.getHeroGift(hero)
	for index,giftId in ipairs(heroGift) do
		if index > GiftDefine.MAX_GIFT then
			break	
		end
		local giftCfg = GiftConfig[giftId]
		local crt = self.minjie["minjie" .. index]
		crt.lv.lv:setString(giftCfg.level)
		local icon = "res/hero/gift/" .. giftCfg.icon 
		crt.icon._ccnode:setTexture(icon)
		if GiftLogic.isActivate(hero,index) then
			--已激活
			crt.icon:shader()
		else
			--未激活
			crt.icon:shader(Shader.SHADER_TYPE_GRAY)
		end
	end 

	local index = math.min(#hero.gift + 1,GiftDefine.MAX_GIFT)
	if not GiftLogic.isActivate(hero,index) and GiftLogic.canActivate(hero,index) then
		self.fingerEff:setVisible(true)
		local x,y = self.minjie["minjie" .. index]:getPosition()
		local size = self.minjie["minjie" .. index]:getContentSize()
		self.fingerEff:setPosition(x + size.width/2,y - 3 + size.height/2)
	else
		self.fingerEff:setVisible(false)
	end

	self:updateSelect()
end

function updateSelect(self)
	local hero = self:getHero()
	local cfg = HeroDefine.DefineConfig[hero.name].giftCondition[self.selectIndex]
	local heroGift = GiftLogic.getHeroGift(hero)
	local crt = self.minjie["minjie" .. self.selectIndex]
	local giftCfg = GiftConfig[heroGift[self.selectIndex]]

	local icon = "res/hero/gift/" .. giftCfg.icon 
	self.info.icon._ccnode:setTexture(icon)
	self.info.mz:setString(giftCfg.name)
	self.info.lv:setString(giftCfg.level)
	self.info.desc:setString(giftCfg.desc)
	local size = self.info.desc:getContentSize()
	self.info.desc:setPositionY(self.info.descY - size.height)
	self.info.daimonCnt:setString(cfg[3])
	self.info.starCnt:setString(cfg[2])
	local ret,star,daimon = GiftLogic.canActivate(hero,self.selectIndex)
	if star then
		self.info.starCnt:setColor(25,196,0)
		self.info.starDesc:setColor(25,196,0)
	else
		self.info.starCnt:setColor(196,25,0)
		self.info.starDesc:setColor(196,25,0)
	end
	if daimon then
		self.info.daimonCnt:setColor(25,196,0)
		self.info.daimonDesc:setColor(25,196,0)
	else
		self.info.daimonCnt:setColor(196,25,0)
		self.info.daimonDesc:setColor(196,25,0)
	end

	for k = 1,GiftDefine.MAX_GIFT do
		self.minjie["minjie"..k].inbornchosen:setVisible(k == self.selectIndex)
	end

	if GiftLogic.isActivate(hero,self.selectIndex) or self.selectIndex ~= #hero.gift + 1 then
		self.info.activate:setVisible(false)
		--[[
		self.info.activate:setEnabled(false)
		self.info.activate:shader(Shader.SHADER_TYPE_GRAY)
		--]]
	else
		self.info.activate:setVisible(true)
		--[[
		self.info.activate:setEnabled(true)
		self.info.activate:shader()
		--]]
	end

	if GiftLogic.isActivate(hero,self.selectIndex) then
		self.info.yjhyz:setVisible(true)
	else
		self.info.yjhyz:setVisible(false)
	end
end

function onSelect(self,event,target)
	if event.etype == Event.Touch_ended then
		self.selectIndex = target.index
		self:updateSelect()
	end
end

function onActivate(self,event)
	if event.etype == Event.Touch_ended then
		local selectIndex = self.selectIndex
		local hero = self:getHero()
		local heroGift = GiftLogic.getHeroGift(hero)
		local giftCfg = GiftConfig[heroGift[selectIndex]]
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_TALENT, step = 4})
		if selectIndex ~= #hero.gift + 1 then
			Common.showMsg("请按顺序激活天赋")
			return
		end
		local cfg = HeroDefine.DefineConfig[hero.name].giftCondition[self.selectIndex]
		if hero.quality < cfg[2] then
			Common.showMsg("英雄星级不够")
			return
		end
		if hero.strength.transferLv < cfg[3] then
			Common.showMsg("英雄宝石阶数不够")
			return
		end
		if Master:getInstance().money < cfg[1] then
			--[[
			local tips = TipsUI.showTips('花费'..giftCfg.money ..'金币激活天赋'..giftCfg.name)
			tips:addEventListener(Event.Confirm, function(self,event) 
				if event.etype == Event.Confirm_yes then
					if Master:getInstance().money <= nextLvMoney then
					--]]
						local t,rmb,m = ShopUI.getMoneyBuyCntAndCost(cfg[1])

						if rmb >= Master.getInstance().rmb then
							-- 钻石不足
							Common.showMsg("钻石不足")
						elseif t < 0 then
							Common.showMsg("购买次数超过限制")
						else
							local rmbTip = TipsUI.showTips('金币不足，是否花费'..rmb..'钻石激活天赋')
							rmbTip:addEventListener(Event.Confirm,function(self,event)
									if event.etype == Event.Confirm_yes then
										Network.sendMsg(PacketID.CG_GIFT_ACTIVATE,hero.name,self.selectIndex,t)
									end
								end,self)
						end
						--[[
				end
			--]]
			return
		end
		Network.sendMsg(PacketID.CG_GIFT_ACTIVATE,hero.name,self.selectIndex,0)
	end
end

function onLeft(self,event)
	if event.etype == Event.Touch_ended then
		self:preHero()
		self:updateHero()
	end
end

function onRight(self,event)
	if event.etype == Event.Touch_ended then
		self:nextHero()
		self:updateHero()
	end
end

function onClose(self,event)
	if event.etype == Event.Touch_ended then
		UIManager.removeUI(self)
	end
end
