module(..., package.seeall)
local CommonShopUI = require("src/ui/CommonShopUI")
setmetatable(_M, {__index = CommonShopUI})
local GuildShop = require("src/modules/guild/shop/GuildShop")
local GuildShopConstConfig = require("src/config/GuildShopConstConfig").Config
local BagData = require("src/modules/bag/BagData")
local ItemConfig = require("src/config/ItemConfig").Config
local VipLogic = require("src/modules/vip/VipLogic")

function new()
	local ctrl = CommonShopUI.new()
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	Instance = ctrl
	return ctrl
end

function uiEffect()
	local temp = {
	[UIManager.UI_EFFECT.kGray] = true,
	[UIManager.UI_EFFECT.kLabel] = true,
	}
	return temp
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function onRefresh()
	local itemId = GuildShopConstConfig[1].itemId
	local num = BagData.getItemNumByItemId(itemId)
	local content
	--if num > 0 then
	--	local cfg = ItemConfig[itemId]
	--	content = string.format("是否消耗刷新货物？",cfg.name)
	--else
	local refreshTimes = GuildShop.getRefreshTimes()
	local leftTimes = VipLogic.getVipAddCount("guildShopCount") - refreshTimes
	if leftTimes <= 0 then
		Common.showMsg("今日的刷新次数已用完咯")
		return
	end
	local price = getPriceByTimes(refreshTimes+1)
	content = string.format("是否消耗%d钻石刷新货物？\n（今日还可以刷新%d次）",price,leftTimes)
	--end
	local tipsUI = TipsUI.showTips(content)
	tipsUI:addEventListener(Event.Confirm,function(self,event)
		if event.etype == Event.Confirm_yes then
			Network.sendMsg(PacketID.CG_GUILD_SHOP_REFRESH)
			WaittingUI.create(PacketID.GC_GUILD_SHOP_REFRESH)
		end
	end)
end

function onBuy(shopId)
	Network.sendMsg(PacketID.CG_GUILD_SHOP_BUY,shopId)
end

function getOwnMoney()
	local fame = Master.getInstance().guildCoin
	return fame
end

function setItemNum(self)
	local itemId = GuildShopConstConfig[1].itemId
	local num = BagData.getItemNumByItemId(itemId)
	--self.xcgxsj.txtcs:setString(num)
end

function init(self)
	CommonShopUI.init(self)	
	self:setTitle("guild")
	local mainui = Stage.currentScene:getUI()
	mainui:setCoin("guildbig")

	setItemNum(self)
	refreshTimes(self)
	self.name = "GuildShopUI"
	Network.sendMsg(PacketID.CG_GUILD_SHOP_QUERY)
	WaittingUI.create(PacketID.GC_GUILD_SHOP_QUERY)
	Bag.getInstance():addEventListener(Event.BagRefresh,setItemNum,self)
end

function setShopItemCoin(jbicon)
	CommonGrid.setCoinIcon(jbicon,"guild")
end

function refreshQuery()
	Network.sendMsg(PacketID.CG_GUILD_SHOP_QUERY)
end
--function setTitle(self)
--	self.title = "公会商店"
--end

--function setRefreshTime(self)
--	self.nextTime = 12
--end

function clear(self)
	local mainui = Stage.currentScene:getUI()
	mainui:setCoin()
	Bag.getInstance():removeEventListener(Event.BagRefresh,setItemNum)
	Instance = nil
	Control.clear(self)
end

function refreshTimes(self)
	local times = GuildShop.getRefreshTimes()
	local price = getPriceByTimes(times+1)
	--self.xcgxsj.txtxh:setString(string.format("消耗刷新令或%d金币",price))
end

function getPriceByTimes(times)
	local cfg = GuildShopConstConfig[1]
	local price = 0
	for i = #cfg.cost,1,-1 do
		if times >= cfg.cost[i][1] then
			price = cfg.cost[i][2]
			break
		end
	end
	return price
end
