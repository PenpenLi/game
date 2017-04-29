module("LotteryUI",package.seeall)
setmetatable(_M,{__index = Control})
local BagData = require("src/modules/bag/BagData")
local LotteryConfig = require("src/config/LotteryConfig")
local ShopDefine = require("src/modules/shop/ShopDefine")
local Shop = require("src/modules/shop/Shop")
local Hero = require("src/modules/hero/Hero")

function new()
	local ctrl = Control.new(require("res/shop/LotterySkin.lua"),{"res/shop/Lottery.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(index)
	Instance = ctrl
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_LABEL
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function onBagRefresh(self,event,target)
	--self:refreshOwnInfo()
end

function refreshOwnInfo(self)
	local costItemId = LotteryConfig.ConstantConfig[1].itemId
	local num = BagData.getItemNumByItemId(costItemId)
	--local txt = string.format("消耗：%s(当前拥有%d)",cfg.name,num)
	--self.draw.common.lotteryc.txtnum:setString("1/"..num)
	--self.draw.common.lotteryc.txtnum:setVisible(true)
end

function init(self)
	self:addArmatureFrame("res/shop/effect/hero/ShopHero.ExportJson")
	self:addArmatureFrame("res/shop/effect/rare/ShopRare.ExportJson")
	self:addArmatureFrame("res/shop/effect/ten/ShopTen.ExportJson")
	self:addArmatureFrame("res/shop/effect/ten/ShopTenCard.ExportJson")
	self:addArmatureFrame("res/shop/effect/ten/ShopTenBg.ExportJson")
	self:addArmatureFrame("res/shop/effect/rare/RareOnce.ExportJson")

	Common.setBtnAnimation(self.draw.rare.rightbg._ccnode,"ShopRare","1")
	Common.setBtnAnimation(self.draw.rare.guangg._ccnode,"ShopRare","2")
	local function onClose(self,event,target)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_EIGHT, step = 5})
		UIManager.removeUI(self)
	end
	self.back:addEventListener(Event.Click,onClose,self)
	local function onCommonLottery(self,event,target)
		Network.sendMsg(PacketID.CG_SHOP_COMMON_ONCE)
	end
	local function onCommonLotteryTen(self,event,target)
		Network.sendMsg(PacketID.CG_SHOP_COMMON_TEN)
	end
	local function onOnce(self,event,target)
		Network.sendMsg(PacketID.CG_SHOP_RARE_ONCE)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SHOP_TREASURE, step = 2})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SHOP_TREASURE, step = 5})
	end
	local function onTence(self,event,target)
		if self.isGuide then
			Network.sendMsg(PacketID.CG_SHOP_RARE_TEN,1)
		else
			Network.sendMsg(PacketID.CG_SHOP_RARE_TEN,0)
		end
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_EIGHT, step = 2})
	end
	self.duihuanshop:addEventListener(Event.Click,function(self,event,target) 
		UIManager.addChildUI("src/modules/shop/ui/ExchangeShopUI")
	end,self)
	self.duihuanshop:setVisible(false)
	self.draw.common.buy1.once:addEventListener(Event.Click,onCommonLottery,self)
	self.draw.common.buy2.tence:addEventListener(Event.Click,onCommonLotteryTen,self)
	self.draw.rare.buy1.once:addEventListener(Event.Click,onOnce,self)
	self.draw.rare.buy2.tence:addEventListener(Event.Click,onTence,self)
	self:initInfo()
	self:openTimer()
	Network.sendMsg(PacketID.CG_SHOP_LOTTERY_QUERY)
	Bag.getInstance():addEventListener(Event.BagRefresh,onBagRefresh,self)
	ActionUI.joint({["left"] = {self.draw.common},["right"] = {self.draw.rare}})

	local mainUI = require("src/modules/master/ui/MainUI").Instance
	if mainUI then
		ActionUI.joint({["up"] = {mainUI.up}})
	end

	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.draw.rare.buy1.once, addFinishFun = function()
		if Hero.getHero('Athena') then	
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SHOP_TREASURE, step = 2})
			Stage.currentScene:getUI():runAction(cc.Sequence:create(
			cc.DelayTime:create(0.1),
			cc.CallFunc:create(function()
				GuideManager.dispatchEvent(GuideDefine.GUIDE_DO_STEP, {groupId = GuideDefine.GUIDE_SIGN_IN, step = 5})	
			end)
			))
		end
	end,step = 2, delayTime = 0.3, groupId = GuideDefine.GUIDE_SHOP_TREASURE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.draw.rare.buy1.once, step = 5, delayTime = 0.3, groupId = GuideDefine.GUIDE_SHOP_TREASURE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.draw.rare.buy2.tence, step = 2, delayTime = 0.3, preFun = function()
		self.isGuide = true
	end,groupId = GuideDefine.GUIDE_CHAPTER_EIGHT})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.back, step = 5, groupId = GuideDefine.GUIDE_CHAPTER_EIGHT})
end

function initInfo(self)
	--self.draw.common.txtfree:setString("")
	--self.draw.common.txtfree:setVisible(false)
	--self.draw.common.tabfree:setVisible(false)
	--self.draw.rare.txtfree:setString("")
	--self.draw.rare.txtfree:setVisible(false)
	--self.draw.rare.tabfree:setVisible(false)
	--CommonGrid.setCoinIcon(self.draw.rare.once.jinbi,"rmb")
	--self.draw.rare.once.jinbi:setScale(0.4)
	--CommonGrid.setCoinIcon(self.draw.rare.tence.jinbi,"rmb")
	--self.draw.rare.tence.jinbi:setScale(0.4)
	--self.draw.common.lotteryc.txtonce:setVisible(false)
	--self.draw.common.lotteryc.icon1:setVisible(false)
	--self.draw.common.lotteryc.txtnum:setVisible(false)
	--self.draw.common.lotteryc.txtfree:setVisible(false)
	--self.draw.rare.once.jinbi:setVisible(false)
	--local onceGold = LotteryConfig.ConstantConfig[1].onceCost
	--self.draw.rare.once.txtjb:setString(onceGold)
	--self.draw.rare.once.txtjb:setVisible(false)
	--self.draw.rare.once.txtonce:setVisible(false)
	--self.draw.rare.once.txtfree:setVisible(false)
	local tenGold = LotteryConfig.ConstantConfig[1].tenCost
	self.draw.rare.buy2.tenPrice:setString(tenGold)
	self.draw.rare.txtfree:setString("")

	local commonTenGold = LotteryConfig.ConstantConfig[1].commonTenCost
	self.draw.common.buy2.txtsz:setString(commonTenGold)

	self.draw.common.buy1.txtmf:setString("")
	self.draw.rare.buy1.txtmf:setString("")
	--self:refreshOwnInfo()
	self.draw.rare.artNum = cc.Label:createWithBMFont("res/common/vipBtnLv.fnt", "0")
	self.draw.rare.artNum:setPositionX(self.draw.rare.descn:getPositionX()+60)
	self.draw.rare.artNum:setPositionY(self.draw.rare.descn:getPositionY()+5)
	self.draw.rare._ccnode:addChild(self.draw.rare.artNum)
end

function refreshLottery(self,commonfree,rarefree,commonFreeTimes)
	print("refreshLottery")
	self.commonFreeTimes = commonFreeTimes
	self:refreshCommonFree(commonfree)
	self:refreshRareFree(rarefree)
	--self.draw.common.txtmfcs:setString(string.format("（今日免费次数：%d）",commonDayCnt-commonFreeTimes))
	
	local rareTimes = ShopDefine.RARE_TEN - Shop.getRareTimes()

	if rareTimes <= 1 then
		self.draw.rare.descn:setVisible(false)
		self.draw.rare.desc:setVisible(true)
		self.draw.rare.artNum:setVisible(false)
	else
		self.draw.rare.descn:setVisible(true)
		self.draw.rare.desc:setVisible(false)
		self.draw.rare.artNum:setVisible(true)
		self.draw.rare.artNum:setString(rareTimes-1)
	end
end

function refreshCommonFree(self,commonfree)
	self.commonfree = commonfree
	self:setFreeTabVisible("common",commonfree)
	local function onCDTime(self,event)
		self.commonfree = self.commonfree - 1
		if self.commonfree > 0 then
			self:setCDTime("common",self.commonfree)
		else
			self:setFreeTabVisible("common",self.commonfree)
			if self.commonTimer then
				self:delTimer(self.commonTimer)
				self.commonTimer = nil
			end
		end
	end
	if self.commonfree > 0 then 
		self:setCDTime("common",self.commonfree)
		if self.commonTimer then
			self:delTimer(self.commonTimer)
		end
		self.commonTimer = self:addTimer(onCDTime, 1, self.commonfree, self)
	end
end

function refreshRareFree(self,rarefree)
	self.rarefree = rarefree
	self:setFreeTabVisible("rare",rarefree)
	local function onCDTime(self,event)
		self.rarefree = self.rarefree - 1
		if self.rarefree > 0 then
			self:setCDTime("rare",self.rarefree)
		else
			self:setFreeTabVisible("rare",self.rarefree)
			if self.rareTimer then
				self:delTimer(self.rareTimer)
				self.rareTimer = nil
			end
		end
	end
	if self.rarefree >0 then
		self:setCDTime("rare",self.rarefree)
		if self.rareTimer then
			self:delTimer(self.rareTimer)
		end
		self.rareTimer = self:addTimer(onCDTime, 1, self.rarefree, self)
	end
end

function setFreeTabVisible(self,tab,time)
	if tab == "common" then
		local onceGold = LotteryConfig.ConstantConfig[1].commonOnceCost
		local txtgold = string.format("%d",onceGold)
		local commonDayCnt = LotteryConfig.ConstantConfig[1].commonDayCnt
		local cnt = 0
		if self.commonFreeTimes then
		print("self.commonFreeTimes::"..self.commonFreeTimes)
			cnt = commonDayCnt - self.commonFreeTimes
		end
		Dot.check(self.draw.common.buy1.once,"lotteryCommon",time,self.commonFreeTimes)
		if time > 0 then
			self.draw.common.buy1.txtmf:setString(txtgold)
		elseif self.commonFreeTimes and cnt <= 0 then
			self.draw.common.buy1.txtmf:setString(txtgold)
			self.draw.common.txtmfcs:setString(string.format("（今日免费次数：%d）",cnt))
		else
			self.draw.common.buy1.txtmf:setString("免费")
			self.draw.common.txtmfcs:setString(string.format("（今日免费次数：%d）",cnt))
		end
	elseif tab == "rare" then
		Dot.check(self.draw.rare.buy1.once,"lotteryRare",time)
		if time > 0 then
			local onceGold = LotteryConfig.ConstantConfig[1].onceCost
			local txtgold = string.format("%d",onceGold)
			self.draw.rare.buy1.txtmf:setString(txtgold)
		else
			self.draw.rare.buy1.txtmf:setString("免费")
			self.draw.rare.txtfree:setString("")
		end
	end
end

function setCDTime(self,tab,time)
	local timeShow = Common.getDCTime(time)
	local content = string.format("%s后免费",timeShow)
	self.draw[tab].txtfree:setString(content)
	if tab == "common" then
		self.draw.common.txtmfcs:setString(content)
	end
end

function clear(self)
	Control.clear(self)
	Instance = nil
	Bag.getInstance():removeEventListener(Event.BagRefresh,onBagRefresh)
	if self.commonTimer then
		self:delTimer(self.commonTimer)
		self.commonTimer = nil
	end
	if self.rareTimer then
		self:delTimer(self.rareTimer)
		self.rareTimer = nil
	end
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_SHOP_TREASURE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 5, groupId = GuideDefine.GUIDE_SHOP_TREASURE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_CHAPTER_EIGHT})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 5, groupId = GuideDefine.GUIDE_CHAPTER_EIGHT})
end

return LotteryUI
