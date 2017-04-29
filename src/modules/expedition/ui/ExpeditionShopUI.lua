module(..., package.seeall)

local CommonShopUI = require("src/ui/CommonShopUI")
setmetatable(_M, {__index = CommonShopUI})

local Define = require("src/modules/expedition/ExpeditionDefine")
local ShopConfig = require("src/config/ExpeditionShopConfig").Config
local ItemConfig = require("src/config/ItemConfig").Config
local ResetConfig = require("src/config/ExpeditionResetConfig").Config[1]
local expeditionData = require("src/modules/expedition/ExpeditionData").getInstance()

function new()
	local ctrl = CommonShopUI.new()
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "ExpeditionShop"
	ctrl:init()
	return ctrl
end

function init(self)
	CommonShopUI.init(self)
	self:setTitle("expedition")
	self.touchParent = false
	local mainui = Stage.currentScene:getUI()
	mainui:setCoin("tourbig")
end

function setShopItemCoin(jbicon)
	CommonGrid.setCoinIcon(jbicon,"tour")
end

function uiEffect()
	return UIManager.FIRST_TEMP_LABEL
end

function addStage(self)
	Network.sendMsg(PacketID.CG_EXPEDITION_SHOP_LIST)
end

--function setTitle(self)
--	self.title = "世界巡回赛商店"
--end

function startCountDown(self)
	local d = os.date("*t")
	local h = d.hour
	local m = d.min
	local s = d.sec

	local len = #ResetConfig.resetTimeList
	self.nextTime = ResetConfig.resetTimeList[1]
	for i=1,len do
		local t = ResetConfig.resetTimeList[i]
		if h < t then
			self.nextTime = t
			break
		end
	end

	local hGap,mGap,sGap = 0,0,0
	if self.nextTime > h then
		hGap = self.nextTime - h - 1
	else
		hGap = self.nextTime + 24 - h - 1
	end
	mGap = 60 - m
	sGap = 60 - s

	local cd = hGap * 3600 + mGap * 60 + sGap
	self:setRefreshTime(cd)
end

function onRefresh(self, evt)
	local tipsUI = TipsUI.showTips("确认花费" .. expeditionData:getRefreshCost() .. "钻石刷新货物吗？")
	tipsUI:addEventListener(Event.Confirm, function(self,event) 
		if event.etype == Event.Confirm_yes then
			Network.sendMsg(PacketID.CG_EXPEDITION_SHOP_REFRESH)
		end
	end,self)
end

function refreshItem(self, item, data)
	local shopConfig = ShopConfig[data.shopId]
	local t = {}
	t.id = data.shopId
	t.itemId = shopConfig.itemId
	t.cnt = shopConfig.count
	t.price = shopConfig.useGemCount
	t.buy = data.hasBuy
	CommonShopUI.refreshItem(self, item, t)
end

function onBuy(shopId, evt)
	Network.sendMsg(PacketID.CG_EXPEDITION_BUY_ITEM, shopId)
end

function isEqual(self, v, id)
	return v.shopId == id
end

function clear(self)
	local mainui = Stage.currentScene:getUI()
	mainui:setCoin()
	Control.clear(self)
end
