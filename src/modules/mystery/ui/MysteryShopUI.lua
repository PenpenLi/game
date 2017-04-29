module(..., package.seeall)
local CommonShopUI = require("src/ui/CommonShopUI")
setmetatable(_M, {__index = CommonShopUI})
local MysteryShop = require("src/modules/mystery/MysteryShop")
local MysteryShopConstConfig = require("src/config/MysteryShopConstConfig").Config
local MysteryShopConfig= require("src/config/MysteryShopConfig").Config
local BagData = require("src/modules/bag/BagData")
local ItemConfig = require("src/config/ItemConfig").Config
local VipLogic = require("src/modules/vip/VipLogic")
local MysteryShopDefine = require("src/modules/mystery/MysteryShopDefine")
local Shop = require("src/modules/shop/Shop")
local ShopDefine = require("src/modules/shop/ShopDefine")
local ShopConfig = require("src/config/ShopConfig").Config
local kCol = 4

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
	self:setPositionY(Stage.uiBottom)
end

function onRefresh(self)
	local itemId = MysteryShopConstConfig[1].itemId
	local num = BagData.getItemNumByItemId(itemId)
	local content
	if num > 0 then
		local cfg = ItemConfig[itemId]
		content = string.format("是否消耗%d刷新货物？",cfg.name)
	else
		local refreshTimes = MysteryShop.getRefreshTimes(self.tag)
		local price = getPriceByTimes(refreshTimes+1)
		local leftTimes = VipLogic.getVipAddCount("mysteryShopCount") - refreshTimes
		if leftTimes <= 0 then
			Common.showMsg("今日的刷新次数已用完咯")
			return
		end
		content = string.format("是否消耗%d钻石刷新货物？\n（今日还可以刷新%d次）",price,leftTimes)
	end
	local tipsUI = TipsUI.showTips(content)
	tipsUI:addEventListener(Event.Confirm,function(s,event)
		if event.etype == Event.Confirm_yes then
			Network.sendMsg(PacketID.CG_MYSTERY_SHOP_REFRESH,self.tag)
			WaittingUI.create(PacketID.GC_MYSTERY_SHOP_REFRESH)
		end
	end)
end

function onBuy(shopId,self)
	Network.sendMsg(PacketID.CG_MYSTERY_SHOP_BUY,shopId,self.tag)
end

function onBuy2(shopId,event,target)
	if event.etype == Event.Touch_ended then
		UIManager.addChildUI("src/modules/shop/ui/ShopTipsUI",shopId)
	end
end

function refreshCntBuy(self)
	if self.channel["region2"]:getSelected() == true then
		local list = self.shopList
		local cap = list:getItemCount() * kCol
		for i = 1,cap do
			local ctrl = list:getItemByNum(math.ceil(i/kCol))
			local item 
			if i%kCol == 0 then
				item = ctrl["grid"..kCol]
			else
				item = ctrl["grid"..i%kCol]
			end
			item.shouxinicon:setVisible(false)
			item.status2:setVisible(false)
			if item.id then
				local limited = ShopConfig[item.id].daylimited
				local cnt = Shop.getBuyCnt(item.id)
				if limited > 0 then
					item.txttab:setVisible(true)
					item.txttab.txtsz:setString(string.format("限购%d/%d",limited - cnt,limited))
				else
					item.txttab:setVisible(false)
				end
			end
		end
	end
end

function setItemNum(self)
	local itemId = MysteryShopConstConfig[1].itemId
	local num = BagData.getItemNumByItemId(itemId)
	--self.xcgxsj.txtcs:setString(num)
end

function onSelectTag(self,id)
	self.tag = id
	if id == MysteryShopDefine.K_SHOP_TAG1 then
		self.txtsj:setVisible(true)
		self.shuaxin:setVisible(true)
		Network.sendMsg(PacketID.CG_MYSTERY_SHOP_QUERY,id)
		WaittingUI.create(PacketID.GC_MYSTERY_SHOP_QUERY)
	elseif id == MysteryShopDefine.K_SHOP_TAG2 then
	--elseif id == MysteryShopDefine.K_SHOP_TAG3 then
		self.txtsj:setVisible(false)
		self.shuaxin:setVisible(false)
		local data = Shop.getConfigByTag(2)
		local shopIds = {}
		for k,v in pairs(data) do
			table.insert(shopIds,v.id)
		end
		Shop.cntQuery(shopIds)
		self:refreshShopData2(data)
	end
end

function refreshShopData2(self,shopData)
	local list = self.shopList
	list:removeAllItem()
	local cap = #shopData
	local cols = math.ceil(cap / kCol)
	list:setItemNum(cols)
	for i = 1,cap do
		local ctrl = list:getItemByNum(math.ceil(i / kCol))
		local data = shopData[i]
		--local item = i%4 == 0 and ctrl.right or ctrl.left
		local item
		if i%kCol == 0 then
			item = ctrl["grid"..kCol]
		else
			item = ctrl["grid"..i%kCol]
		end
		--item.txtmz:setFontSize(18)
		self:refreshItem2(item, data)
		if i == cap and cap%kCol ~= 0 then
			for j = cap%kCol+1,kCol do
				ctrl["grid"..j]:setVisible(false)
			end
		end
	end
end

function refreshItem2(self, item, data)
	local cfg = ItemConfig[data.itemId]
	local grid = item.gezi
	CommonGrid.bind(grid)
	grid:setItemIcon(data.itemId,"descIcon")
	--grid:setItemNum(data.cnt)

	--item.txtname:setDimensions(150, 0)
	--item.txtname:setHorizontalAlignment(Label.Alignment.Center)
	item.id = data.id
	item.txtname:setAnchorPoint(0.5,0)
	item.txtname:setString(cfg.name)
	item.txtprice:setString(data.price)
	item.tab:setVisible(false)
	item.shouxinicon:setVisible(false)
	item.status2:setVisible(false)
	if data.mtype == ShopDefine.K_SHOP_BUY_MONEY then
		CommonGrid.setCoinIcon(item.jinbi,"money")
	elseif data.mtype == ShopDefine.K_SHOP_BUY_RMB then
		CommonGrid.setCoinIcon(item.jinbi,"rmb")
	elseif data.mtype == ShopDefine.K_SHOP_BUY_POWER then
		CommonGrid.setCoinIcon(item.jinbi,"power")
	end
	if data.daylimited > 0 then
		local cnt = Shop.getBuyCnt(item.id)
		item.txttab:setVisible(true)
		item.txttab.txtsz:setString(string.format("限购%d/%d",data.daylimited - cnt,data.daylimited))
	else
		item.txttab:setVisible(false)
	end
	if not item:hasEventListener(Event.TouchEvent,onBuy2) then
		item:addEventListener(Event.TouchEvent,onBuy2,data.id)
	end
	--if data.buy == 0 then
	--	--item:setState(Button.UI_BUTTON_NORMAL)
	--	--if not item:hasEventListener(Event.TouchEvent,self.onBuy) then
	--		item.data = data
	--		item:addEventListener(Event.TouchEvent, onBuyTouch, self)
	--	--end
	--	item.shouxinicon:setVisible(false)
	--	item.status2:setVisible(false)
	--else
	--	item.shouxinicon:setVisible(true)
	--	item.status2:setVisible(true)
	--	--item:shader(Shader.SHADER_TYPE_GRAY)
	--	--item:setState(Button.UI_BUTTON_DISABLE, false, true)
	--end
end

function init(self)
	CommonShopUI.init(self)	
	--self:setTitle("mystery")
	self.channel:setVisible(true)
	local function onSelectOption(self,event,target)
		self:onSelectTag(target.regionId)
	end
	for i = 1,2 do
		self.channel["region"..i]:addEventListener(Event.Click,onSelectOption,self)
		self.channel["region"..i].regionId = i
	end
	self.channel["region3"]:setVisible(false)
	self:onSelectTag(1)
	self.channel.region1:setSelected(true)

	setItemNum(self)
	refreshTimes(self,self.tag)
	self.name = "MysteryShopUI"
	--Network.sendMsg(PacketID.CG_MYSTERY_SHOP_QUERY)
	--WaittingUI.create(PacketID.GC_MYSTERY_SHOP_QUERY)
	Bag.getInstance():addEventListener(Event.BagRefresh,setItemNum,self)
end

function setShopItemCoin(jbicon,id)
	if MysteryShopConfig[id] and MysteryShopConfig[id].mtype == 1 then
		CommonGrid.setCoinIcon(jbicon,"rmb")
	else
		CommonGrid.setCoinIcon(jbicon,"money")
	end
end

function refreshQuery(self)
	Network.sendMsg(PacketID.CG_MYSTERY_SHOP_QUERY,self.tag)
end

function startCountDown(self)
	local now = os.time()
	local cd = 7200 - now % 7200
	self:setRefreshTime(cd)
end

function clear(self)
	Bag.getInstance():removeEventListener(Event.BagRefresh,setItemNum)
	Instance = nil
	Control.clear(self)
end

function refreshTimes(self,mtype)
	--local times = MysteryShop.getRefreshTimes(mtype)
	--local price = getPriceByTimes(times+1)
	self:startCountDown()
	--self.xcgxsj.txtxh:setString(string.format("消耗刷新令或%d金币",price))
end

function getPriceByTimes(times)
	local cfg = MysteryShopConstConfig[1]
	local price = 0
	for i = #cfg.cost,1,-1 do
		if times >= cfg.cost[i][1] then
			price = cfg.cost[i][2]
			break
		end
	end
	return price
end
