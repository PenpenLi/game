module(..., package.seeall)
local CommonShopUI = require("src/ui/CommonShopUI")
setmetatable(_M, {__index = CommonShopUI})
local ArenaShopData = require("src/modules/arena/ArenaShopData")
local ArenaDefine = require("src/modules/arena/ArenaDefine")
local ArenaShopRefreshConfig = require("src/config/ArenaShopRefreshConfig").Config
local MainUI = require("src/modules/master/ui/MainUI")
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
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 5, groupId = GuideDefine.GUIDE_ARENA})
end

function onRefresh()
	local refreshTimes = ArenaShopData.getRefreshTimes()
	local leftTimes = VipLogic.getVipAddCount("arenaShopCount") - refreshTimes
	if leftTimes <= 0 then
		--Common.showMsg(string.format(ArenaDefine.ARENA_REFRESH_TIPS[1]))
		Common.showMsg("今日的刷新次数已用完咯")
		return
	end
	local cfg = ArenaShopRefreshConfig[refreshTimes + 1]
	local content = string.format("是否消耗%d钻石刷新货物？\n(今天还可以刷新%d次)",cfg.cost,leftTimes)
	local tipsUI = TipsUI.showTips(content)
	tipsUI:addEventListener(Event.Confirm, function(self,event) 
		if event.etype == Event.Confirm_yes then
			Network.sendMsg(PacketID.CG_ARENA_SHOP_REFRESH)
			WaittingUI.create(PacketID.GC_ARENA_SHOP_REFRESH)
		end
	end,self)
end

function onBuy(shopId)
	Network.sendMsg(PacketID.CG_ARENA_SHOP_BUY,shopId)
end

function getOwnMoney()
	local fame = Master.getInstance().fame
	return fame
end

function setArenaCoin(self)
	local fame = Master.getInstance().fame
	--self.moneyLabel.txtmoney:setString(fame)

	local mainui = Stage.currentScene:getUI()
	CommonGrid.setCoinIcon(mainui.up.jbicon,"arenabig")
	mainui.up.artMoney:setString(fame)
end

function init(self)
	CommonShopUI.init(self)	
	self:setTitle("arena")
	local mainui = Stage.currentScene:getUI()
	mainui:setCoin("arenabig")
	self.name = "ArenaShopUI"
	Network.sendMsg(PacketID.CG_ARENA_SHOP_QUERY)
	WaittingUI.create(PacketID.GC_ARENA_SHOP_QUERY)
end

function setShopItemCoin(jbicon)
	CommonGrid.setCoinIcon(jbicon,"arenabig")
end

function refreshQuery()
	Network.sendMsg(PacketID.CG_ARENA_SHOP_QUERY)
end

function clear(self)
	local mainui = Stage.currentScene:getUI()
	mainui:setCoin()
	Instance = nil
	Control.clear(self)
end
