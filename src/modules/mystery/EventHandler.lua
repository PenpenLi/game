module(...,package.seeall) 
local MysteryShopDefine = require("src/modules/mystery/MysteryShopDefine")
local MysteryShop = require("src/modules/mystery/MysteryShop")
local MysteryShopConfig= require("src/config/MysteryShopConfig").Config
local MysteryShop2Config= require("src/config/MysteryShop2Config").Config
local ShopDefine = require("src/modules/shop/ShopDefine")

function onGCMysteryShopQuery(shopData,refreshTimes,mtype)
	MysteryShop.setRefreshTimes(refreshTimes,mtype)
	--local MysteryShopUI = Stage.currentScene:getUI():getChild("MysteryShopUI")
	local MysteryShopUI = require("src/modules/mystery/ui/MysteryShopUI").Instance
	if MysteryShopUI then
		if MysteryShopUI.channel["region"..mtype]:getSelected() == true then
			MysteryShopUI:refreshShopData(shopData)
			MysteryShopUI:refreshTimes(mtype)
		end
	end
end

function onGCMysteryShopRefresh(retCode,mtype)
	local content = MysteryShopDefine.MYSTERY_REFRESH_RET[retCode]
	Common.showMsg(content)
end

function onGCMysteryShopBuy(id,ret,mtype)
	local content = MysteryShopDefine.MYSTERY_BUY_RET[ret]
	Common.showMsg(content)
	if ret == MysteryShopDefine.MYSTERY_BUY.kOk then
		--local MysteryShopUI = Stage.currentScene:getUI():getChild("MysteryShopUI")
		local mCfg = MysteryShopConfig
		if mtype == MysteryShopDefine.K_SHOP_TAG1 then
		elseif mtype == MysteryShopDefine.K_SHOP_TAG2 then
			mCfg = MysteryShop2Config
		end
		local data = mCfg[id]
		if data and data.mtype == ShopDefine.K_SHOP_BUY_RMB then
			local price = math.floor(data.cost / data.cnt)
			StatisSDK.buy(data.itemId,data.cnt,price)
		end
		local MysteryShopUI = require("src/modules/mystery/ui/MysteryShopUI").Instance
		if MysteryShopUI and MysteryShopUI.channel["region"..mtype]:getSelected() == true then
			MysteryShopUI:setShopItemBuyState(id,Button.UI_BUTTON_DISABLE)
		end
	end
end
