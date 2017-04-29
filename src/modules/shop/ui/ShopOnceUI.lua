module("ShopOnceUI",package.seeall)
setmetatable(_M,{__index = Control})
local ShopDefine = require("src/modules/shop/ShopDefine")
local ItemConfig = require("src/config/ItemConfig").Config
local BagData = require("src/modules/bag/BagData")
local BagDefine = require("src/modules/bag/BagDefine")
local ShopHeroUI = require("src/modules/shop/ui/ShopHeroUI")
local LotteryConfig = require("src/config/LotteryConfig")
local ShopHeroEffectUI = require("src/modules/shop/ui/ShopHeroEffectUI")

function new(mtype)
	local ctrl = Control.new(require("res/shop/ShopOnceSkin.lua"),{"res/shop/ShopOnce.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(mtype)
	return ctrl
end

function uiEffect()
	return UIManager.SECOND_TEMP_FULL
end

function init(self,mtype)
	self.mtype = mtype
	--local function onClose(self,event,target)
	--	UIManager.removeUI(self)
	--	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SHOP_TREASURE, step = 4})
	--end
	--self.back:addEventListener(Event.Click,onClose,self)
	local function onClose(self,event,target)
		UIManager.removeUI(self)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SHOP_TREASURE, step = 4})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SHOP_TREASURE, step = 6})
	end
	self.back1:addEventListener(Event.Click,onClose,self)
	local function onOnceMore(self,event,target)
		if mtype == ShopDefine.K_SHOP_COMMON_ONCE then
			Network.sendMsg(PacketID.CG_SHOP_COMMON_ONCE)
		else
			Network.sendMsg(PacketID.CG_SHOP_RARE_ONCE)
		end
	end
	self.oncemore:addEventListener(Event.Click,onOnceMore,self)
	--local function onTenMore(self,event,target)
	--	if mtype == ShopDefine.K_SHOP_COMMON_ONCE then
	--		Network.sendMsg(PacketID.CG_SHOP_COMMON_TEN)
	--	else
	--		Network.sendMsg(PacketID.CG_SHOP_RARE_TEN)
	--	end
	--end
	--self.tenmore:addEventListener(Event.Click,onTenMore,self)

	CommonGrid.bind(self.herobg)
	if mtype == ShopDefine.K_SHOP_COMMON_ONCE then
		local cost = LotteryConfig.ConstantConfig[1].commonOnceCost
		self.onceCost:setString(cost)
		local cost2 = LotteryConfig.ConstantConfig[1].commonTenCost
		self.tenCost:setString(cost2)
		CommonGrid.setCoinIcon(self.jbbicon1,"money")
		--CommonGrid.setCoinIcon(self.jbbicon2,"money")
	else
		local cost = LotteryConfig.ConstantConfig[1].onceCost
		self.onceCost:setString(cost)
		local cost2 = LotteryConfig.ConstantConfig[1].tenCost
		self.tenCost:setString(cost2)
		CommonGrid.setCoinIcon(self.jbbicon1,"rmb")
		--CommonGrid.setCoinIcon(self.jbbicon2,"rmb")
	end
	self.jbbicon2:setVisible(false)
	self.tenCost:setString("")
	self.itemName:setAnchorPoint(0.5,0)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.back1, step = 4, groupId = GuideDefine.GUIDE_SHOP_TREASURE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.back1, step = 6, clickFun = function()
		UIManager.reset()
	end,groupId = GuideDefine.GUIDE_SHOP_TREASURE})
end

function clear(self)
	Control.clear(self)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 4, groupId = GuideDefine.GUIDE_SHOP_TREASURE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 6, groupId = GuideDefine.GUIDE_SHOP_TREASURE})
end

function refreshInfo(self,itemId,disFrag)
	local cfg = ItemConfig[itemId]
	self.herobg:setItemIcon(itemId,"descIcon")
	local cfg1 = {}
	self.itemName:setString(cfg.name)
	self.rarebg:setVisible(false)
	self.commonbg:setVisible(false)
	if self.mtype == ShopDefine.K_SHOP_COMMON_ONCE then
		self:playAnimation("成功小抽")
		cfg1 = LotteryConfig.NormalConfig
	else
		self:playAnimation("成功抽取")
		cfg1 = LotteryConfig.RareConfig
	end
	local num = cfg1[itemId] and cfg1[itemId].num or 0
	self.herobg:setItemNum(num)

	local cfg = ItemConfig[itemId]
	if cfg.attr["addHero"] then
		--UIManager.removeUI(self)
		--ShopHeroUI.pushCache({url = "src/modules/shop/ui/ShopOnceUI",params = {self.mtype,itemId}})
		--UIManager.addChildUI("src/modules/shop/ui/ShopHeroUI",itemId,disFrag)
		--ShopHeroEffectUI.pushCache({url = "src/modules/shop/ui/ShopOnceUI",params = {self.mtype,itemId}})
		local name = cfg.attr["addHero"].name
		local ui = UIManager.addChildUI("src/modules/shop/ui/ShopHeroEffectUI",name,cfg.color)
		ui:playEffect()
	else
		UIManager.playMusic("lotteryItem")
	end
end

function refreshBack(self,mtype,itemId)
	local cfg1 = {}
	if self.mtype == ShopDefine.K_SHOP_COMMON_ONCE then
		self.rarebg:setVisible(false)
		self.commonbg:setVisible(true)
		cfg1 = LotteryConfig.NormalConfig
	else
		self.rarebg:setVisible(true)
		self.commonbg:setVisible(false)
		cfg1 = LotteryConfig.RareConfig
	end
	local cfg = ItemConfig[itemId]
	self.herobg:setItemIcon(itemId,"descIcon")
	local num = cfg1[itemId] and cfg1[itemId].num or 0
	self.herobg:setItemNum(num)
	self.itemName:setString(cfg.name)
end

function playAnimation(self,name)
	if name == "成功抽取" then
		if self.ani then
			self.ani:setVisible(false)
		end
		self.herobg:setVisible(false)
		if not self.ani1 then
			self.ani1 = Common.setBtnAnimation(self.oncemore._ccnode,"RareOnce","Animation1",{x=65,y=200})
			self.ani1:getAnimation():setFrameEventCallFunc(function(bonep,evt,originFrameIndex,currentFrameIndex) 
				self.herobg:setVisible(true)
				if not self.ani then
					self.ani = Common.setBtnAnimation(self.oncemore._ccnode,"ShopHero",name,{x=85,y=200})
				else
					self.ani:setVisible(true)
					self.ani:getAnimation():play(name,-1,-1)
				end
			end)
		else
			self.ani1:getAnimation():play("Animation1",-1,-1)
		end
	else
		if not self.ani then
			self.ani = Common.setBtnAnimation(self.oncemore._ccnode,"ShopHero",name,{x=85,y=200})
		else
			self.ani:getAnimation():play(name,-1,-1)
		end
	end
end

return ShopOnceUI
