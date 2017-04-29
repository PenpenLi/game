module(...,package.seeall)
local ShopDefine = require("src/modules/shop/ShopDefine")
local Shop = require("src/modules/shop/Shop")
local ExchangeShopData = require("src/modules/shop/ExchangeShopData")
local LotteryConfig = require("src/config/LotteryConfig")
local ShopVirtual = require("src/config/ShopVirtualConfig").Config

function onGCShopQuery(shopCnt)
	Shop.setBuyCnt(shopCnt)
	local ShopUI = Stage.currentScene:getUI():getChild("Shop")
	if ShopUI then
		ShopUI:refreshCntBuy()
		local ShopTipsUI = ShopUI:getChild("ShopTips")
		if ShopTipsUI then
			ShopTipsUI:refreshInfo()
		end
	end
	local MysteryShopUI = require("src/modules/mystery/ui/MysteryShopUI").Instance
	if MysteryShopUI then
		MysteryShopUI:refreshCntBuy()
		local ShopTipsUI = MysteryShopUI:getChild("ShopTips")
		if ShopTipsUI then
			ShopTipsUI:refreshInfo()
		end
	end
	Master.getInstance():dispatchEvent(Event.ShopCntRefresh,{etype=Event.ShopCntRefresh})
end

function onGCShopBuyVirtual(shopId,ret)
	if ret == ShopDefine.SHOP_BUY_RET.kNotRmb then
		Common.showRechargeTips()
	elseif shopId == ShopDefine.K_SHOP_PHY_ID
		and ret == ShopDefine.SHOP_BUY_RET.kDayLimited then
		local tips = TipsUI.showTips("今日购买次数用完了，成为VIP家族可突破体力限制!")
		tips:addEventListener(Event.Confirm,function(self,event) 
			if event.etype == Event.Confirm_yes then
				UIManager.addUI("src/modules/vip/ui/VipUI")
			end
		end)
	else
		if ret ~= ShopDefine.SHOP_BUY_RET.kOk then
			local content = ShopDefine.SHOP_BUY_RET_TIPS[ret]
			Common.showMsg(content)
		else
			local data = ShopVirtual[shopId]
			if data and data.mtype == ShopDefine.K_SHOP_BUY_RMB then
				StatisSDK.buy(data.itemId,1,data.price[1][2])
			end
			Master.getInstance():dispatchEvent(Event.ShopBuyVirtual,{etype=Event.ShopBuyVirtual,id = shopId})
		end
	end
end

function onGCShopBuy(shopId,ret)
	if ret == ShopDefine.SHOP_BUY_RET.kNotRmb then
		Common.showRechargeTips()
	else
		local data = Shop.getShopConfigById(shopId)
		if data and data.mtype == ShopDefine.K_SHOP_BUY_RMB then
			StatisSDK.buy(data.id,1,data.price)
		end
		if ret ~= ShopDefine.SHOP_BUY_RET.kOk then
			local content = ShopDefine.SHOP_BUY_RET_TIPS[ret]
			Common.showMsg(content)
		end
	end
end

function onGCShopSell(ret)
	local content = ShopDefine.SHOP_SELL_RET_TIPS[ret]
	Common.showMsg(content)
end

function onGCShopLotteryQuery(commonfree,rarefree,raretimes,commonFreeTimes)
	Shop.setRareTimes(raretimes)
	Shop.addDot(commonfree,rarefree,commonFreeTimes)
	--local LotteryUI = Stage.currentScene:getUI():getChild("Lottery")
	local LotteryUI = require("src/modules/shop/ui/LotteryUI").Instance
	if LotteryUI then
		LotteryUI:refreshLottery(commonfree,rarefree,commonFreeTimes)
	end
end

function onGCShopCommonOnce(retCode,itemId)
	if retCode == ShopDefine.COMMON_ONCE_RET.kOk then
		--local LotteryUI = Stage.currentScene:getUI():getChild("Lottery")
		local LotteryUI = require("src/modules/shop/ui/LotteryUI").Instance
		if LotteryUI then
			local ShopTenUI = LotteryUI:getChild("ShopTen")
			if ShopTenUI then
				UIManager.removeUI(ShopTenUI)
			end
			local ShopOnceUI = LotteryUI:getChild("ShopOnce")
			if ShopOnceUI then
				ShopOnceUI:refreshInfo(itemId)
			else
				ShopOnceUI = UIManager.addChildUI("src/modules/shop/ui/ShopOnceUI",ShopDefine.K_SHOP_COMMON_ONCE)
				ShopOnceUI:refreshInfo(itemId)
			end
		end
	else
		local content = ShopDefine.COMMON_ONCE_RET_TIPS[retCode]
		Common.showMsg(content)
	end
end

function onGCShopCommonTen(retCode,items)
	if retCode == ShopDefine.COMMON_TEN_RET.kOk then
		--local LotteryUI = Stage.currentScene:getUI():getChild("Lottery")
		local LotteryUI = require("src/modules/shop/ui/LotteryUI").Instance
		if LotteryUI then
			local ShopOnceUI = LotteryUI:getChild("ShopOnce")
			if ShopOnceUI then
				UIManager.removeUI(ShopOnceUI)
			end
			--local ShopTenUI = LotteryUI:getChild("ShopTen")
			--if ShopTenUI then
			--	local rItems = randomItems(items)
			--	ShopTenUI:refreshInfo(rItems)
			--else
			--	local ui = UIManager.addChildUI("src/modules/shop/ui/ShopTenUI",items,nil,"common")
			--	ui:refreshInfo(items,nil,"common")
			--end
			--local ShopTenUI = LotteryUI:getChild("ShopTen")
			--if ShopTenUI then
			--	local rItems = randomItems(items)
			--	ShopTenUI:refreshInfo(rItems)
			--else
			--	local ui = UIManager.addChildUI("src/modules/shop/ui/ShopTenUI",items)
			--	local bone = Common.setBtnAnimation(ui._ccnode,"ShopTenBg","1",{y=-100})
			--	bone:getAnimation():setFrameEventCallFunc(function(bonep,evt,originFrameIndex,currentFrameIndex) 
			--		ui:refreshInfo(items)
			--	end)
			--end
			local ShopTenUI = require("src/modules/shop/ui/ShopTenUI").Instance
			if ShopTenUI then
				UIManager.removeUI(ShopTenUI)
			end
			local ShopTenBgUI = UIManager.addChildUI("src/modules/shop/ui/ShopTenBgUI")
			local bone = Common.setBtnAnimation(LotteryUI._ccnode,"ShopTenBg","1",{y=-200})
			bone:getAnimation():setFrameEventCallFunc(function(bonep,evt,originFrameIndex,currentFrameIndex) 
				UIManager.removeUI(ShopTenBgUI)
				local ui = UIManager.addChildUI("src/modules/shop/ui/ShopTenUI",items,nil,"common")
				ui:refreshInfo(items,nil,"common")
			end)

		end
	else
		local content = ShopDefine.COMMON_TEN_RET_TIPS[retCode]
		Common.showMsg(content)
	end
end

function randomItems(items)
	local ret = {}
	while(true) do
		local i = math.random(1,#items)
		table.insert(ret,items[i])
		table.remove(items,i)
		if #items <= 0 then
			break
		end
	end
	return ret
end

function onGCShopRareOnce(retCode,item)
	if retCode == ShopDefine.RARE_ONCE_RET.kOk then
		--local LotteryUI = Stage.currentScene:getUI():getChild("Lottery")
		local onceGold = LotteryConfig.ConstantConfig[1].onceCost
		StatisSDK.buy(item.id,1,onceGold)
		local LotteryUI = require("src/modules/shop/ui/LotteryUI").Instance
		if LotteryUI then
			local ShopTenUI = LotteryUI:getChild("ShopTen")
			if ShopTenUI then
				UIManager.removeUI(ShopTenUI)
			end
			local ShopOnceUI = LotteryUI:getChild("ShopOnce")
			if ShopOnceUI then
				ShopOnceUI:refreshInfo(item.id,item.disFrag)
			else
				ShopOnceUI = UIManager.addChildUI("src/modules/shop/ui/ShopOnceUI",ShopDefine.K_SHOP_RARE_ONCE)
				ShopOnceUI:refreshInfo(item.id,item.disFrag)
			end
		end
	else
		local content = ShopDefine.RARE_ONCE_RET_TIPS[retCode]
		Common.showMsg(content)
	end
end

function onGCShopRareTen(retCode,items)
	if retCode == ShopDefine.RARE_TEN_RET.kOk then
		--local LotteryUI = Stage.currentScene:getUI():getChild("Lottery")
		local tenGold = LotteryConfig.ConstantConfig[1].tenCost
		local onceGold = math.floor(tenGold/10)
		for i = 1,#items do
			StatisSDK.buy(items[i].id,items[i].num,onceGold)
		end
		local LotteryUI = require("src/modules/shop/ui/LotteryUI").Instance
		if LotteryUI then
			local ShopOnceUI = LotteryUI:getChild("ShopOnce")
			if ShopOnceUI then
				UIManager.removeUI(ShopOnceUI)
			end
			--local ShopTenUI = LotteryUI:getChild("ShopTen")
			--if ShopTenUI then
			--	local rItems = randomItems(items)
			--	ShopTenUI:refreshInfo(rItems)
			--else
			--	local ui = UIManager.addChildUI("src/modules/shop/ui/ShopTenUI",items)
			--	local bone = Common.setBtnAnimation(ui._ccnode,"ShopTenBg","1",{y=-100})
			--	bone:getAnimation():setFrameEventCallFunc(function(bonep,evt,originFrameIndex,currentFrameIndex) 
			--		ui:refreshInfo(items)
			--	end)
			--end
			local ShopTenUI = require("src/modules/shop/ui/ShopTenUI").Instance
			if ShopTenUI then
				UIManager.removeUI(ShopTenUI)
			end
			local ShopTenBgUI = UIManager.addChildUI("src/modules/shop/ui/ShopTenBgUI")
			local bone = Common.setBtnAnimation(LotteryUI._ccnode,"ShopTenBg","1",{y=-200})
			bone:getAnimation():setFrameEventCallFunc(function(bonep,evt,originFrameIndex,currentFrameIndex) 
				UIManager.removeUI(ShopTenBgUI)
				local ui = UIManager.addChildUI("src/modules/shop/ui/ShopTenUI",items)
				local rItems = randomItems(items)
				ui:refreshInfo(rItems)
			end)
		end
	else
		local content = ShopDefine.RARE_TEN_RET_TIPS[retCode]
		Common.showMsg(content)
	end
end

function onGCExchangeShopQuery(shopData,refreshTimes)
	ExchangeShopData.setShopData(shopData,refreshTimes)
	local ExchangeShopUI = require("src/modules/shop/ui/ExchangeShopUI").Instance
	if ExchangeShopUI then
		ExchangeShopUI:refreshShopData(shopData)
	end
end

function onGCExchangeShopRefresh(retCode)
	local content = ShopDefine.EXCHANGE_REFRESH_RET_TIPS[retCode]
	Common.showMsg(string.format(content))
end

function onGCExchangeShopBuy(id,retCode)
	local content = ShopDefine.EXCHANGE_BUY_RET_TIPS[retCode]
	Common.showMsg(string.format(content))
	if retCode == ShopDefine.EXCHANGE_BUY_RET.kOk then
		local ExchangeShopUI = require("src/modules/shop/ui/ExchangeShopUI").Instance
		if ExchangeShopUI then
			ExchangeShopUI:setShopItemBuyState(id,Button.UI_BUTTON_DISABLE)
		end
	end
end
