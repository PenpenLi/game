module("StrengthShopUI",package.seeall)
setmetatable(_M,{__index = Control})
local Shop = require("src/modules/shop/Shop")
local ItemConfig = require("src/config/ItemConfig").Config
local MainUI = require("src/modules/master/ui/MainUI")
local ShopDefine = require("src/modules/shop/ShopDefine")
local kCol = 3

function new()
	local ctrl = Control.new(require("res/shop/StrengthShopSkin.lua"),{"res/shop/StrengthShop.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(index)
	return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP_LABEL
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function setPowerCoin(self)
	local fame = Master.getInstance().powerCoin
	local mainui = Stage.currentScene:getUI()
	CommonGrid.setCoinIcon(mainui.up.jbicon,"powerbig")
	--mainui.up.moneyLabel:setString(fame)
	mainui.up.artMoney:setString(fame)
end

function init(self)
	local function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.close:addEventListener(Event.Click,onClose,self)
	Master.getInstance():removeEventListener(Event.MasterRefresh,MainUI.setAttr)
	local mainui = Stage.currentScene:getUI()
	mainui.up.addMoney:removeEventListener(Event.Click,MainUI.onGoldPanel)
	self.moneyLabel:setVisible(false)
	self.moneyLabel2:setVisible(false)
	self.txtsj:setVisible(false)
	self.shuaxin:setVisible(false)
	local data = Shop.getConfigByTag(5)
	self:refreshPowerGoods(data)
	setPowerCoin(self)
	Master.getInstance():addEventListener(Event.MasterRefresh,setPowerCoin,self)
end

function onBuy(data,event,target)
	if event.etype == Event.Touch_ended then
		local fame = Master.getInstance().powerCoin
		if fame >= data.price then
			UIManager.addChildUI("src/modules/shop/ui/ShopTipsUI",data.id)
		else
			Common.showMsg(ShopDefine.SHOP_BUY_RET_TIPS[8])
		end
	end
end

function onSale(shopId,event,target)
	if event.etype == Event.Touch_ended then
		UIManager.addChildUI("src/modules/shop/ui/ShopTipsUI",shopId,"sale")
	end
end

function refreshPowerGoods(self,goods)
	local list = self.powergoods
	list.listBg:setVisible(false)
	local cap = #goods
	local cols = math.ceil(cap/kCol)
	list:removeAllItem()
	list:setItemNum(cols)	
	for i = 1,cap do
		local ctrl = list:getItemByNum(math.ceil(i/kCol))
		local data = goods[i]
		local item 
		if i%kCol == 0 then
			item = ctrl["grid"..kCol]
		else
			item = ctrl["grid"..i%kCol]
		end
		local cfg = ItemConfig[data.itemId]
		local grid = item.grid
		CommonGrid.bind(grid)
		grid:setItemIcon(data.itemId,"descIcon")
		item.txtname:setString(cfg.name)
		--item.txtprice:setAnchorPoint(1,0)
		--item.txtprice:setPositionX(item.jbbicon:getPositionX())
		item.txtprice:setString(data.price)
		if not item.buy:hasEventListener(Event.TouchEvent,onBuy) then
			item.buy:addEventListener(Event.TouchEvent,onBuy,data)
		end
		if not item.sale:hasEventListener(Event.TouchEvent,onSale) then
			item.sale:addEventListener(Event.TouchEvent,onSale,data.id)
		end
		if i == cap and cap%kCol ~= 0 then
			for j = cap%kCol+1,kCol do
				ctrl["grid"..j]:setVisible(false)
			end
		end

	end
end

function clear(self)
	local mainui = Stage.currentScene:getUI()
	CommonGrid.setCoinIcon(mainui.up.jbicon,"moneybig")
	mainui:setAttr()
	Master.getInstance():addEventListener(Event.MasterRefresh,MainUI.setAttr,mainui)
	mainui.up.addMoney:addEventListener(Event.Click,MainUI.onGoldPanel,mainui)
	Master.getInstance():removeEventListener(Event.MasterRefresh,setPowerCoin)
	Control.clear(self)
end

return StrengthShopUI
