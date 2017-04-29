module(..., package.seeall)
local CommonShopUI = require("src/ui/CommonShopUI")
setmetatable(_M, {__index = CommonShopUI})
local MainUI = require("src/modules/master/ui/MainUI")
local ExchangeShopData = require("src/modules/shop/ExchangeShopData")
local ExchangeShopRefreshConfig = require("src/config/ExchangeShopRefreshConfig").Config
local VipLogic = require("src/modules/vip/VipLogic")

function new()
	local ctrl = CommonShopUI.new()
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	Instance = ctrl
	return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP_LABEL
end

function addStage(self)
end

function onRefresh()
	local refreshTimes = ExchangeShopData.getRefreshTimes()
	local leftTimes = VipLogic.getVipAddCount("exchangeShopCount") - refreshTimes
	if leftTimes <= 0 then
		--Common.showMsg(string.format(ArenaDefine.ARENA_REFRESH_TIPS[1]))
		Common.showMsg("今日的刷新次数已用完咯")
		return
	end
	local cfg = ExchangeShopRefreshConfig[refreshTimes + 1]
	local content = string.format("是否消耗%d钻石刷新货物？\n(今天还可以刷新%d次)",cfg.cost,leftTimes)
	local tipsUI = TipsUI.showTips(content)
	tipsUI:addEventListener(Event.Confirm, function(self,event) 
		if event.etype == Event.Confirm_yes then
			Network.sendMsg(PacketID.CG_EXCHANGE_SHOP_REFRESH)
			WaittingUI.create(PacketID.GC_EXCHANGE_SHOP_REFRESH)
		end
	end,self)
end

function onBuy(shopId)
	Network.sendMsg(PacketID.CG_EXCHANGE_SHOP_BUY,shopId)
end

function init(self)
	CommonShopUI.init(self)	
	self:setTitle("exchange")
	local mainui = Stage.currentScene:getUI()
	mainui:setCoin("exchangebig")
	self.name = "ExchangeShop"
	Network.sendMsg(PacketID.CG_EXCHANGE_SHOP_QUERY)
	WaittingUI.create(PacketID.GC_EXCHANGE_SHOP_QUERY)
end

function refreshQuery()
	Network.sendMsg(PacketID.CG_EXCHANGE_SHOP_QUERY)
end

function clear(self)
	local mainui = Stage.currentScene:getUI()
	mainui:setCoin()
	Instance = nil
	Control.clear(self)
end

function setShopItemCoin(jbicon)
	CommonGrid.setCoinIcon(jbicon,"exchange")
end
