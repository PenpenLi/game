module("ShopUI",package.seeall)
setmetatable(_M,{__index = Control})
local Shop = require("src/modules/shop/Shop")
local ItemConfig = require("src/config/ItemConfig").Config
local ShopDefine = require("src/modules/shop/ShopDefine")
local BagData = require("src/modules/bag/BagData")
local LotteryConfig = require("src/config/LotteryConfig")
local ShopConfig = require("src/config/ShopConfig").Config
local ShopVirtual = require("src/config/ShopVirtualConfig").Config
local GoldConfig = require("src/config/GoldConfig")
local GoldConstConfig = GoldConfig.GoldConstConfig
local GoldCntConfig = GoldConfig.GoldCntConfig
local GoldCostConfig = GoldConfig.GoldCostConfig
local GoldData = require("src/modules/gold/GoldData")
local TagName = {"热门","道具","材料","礼包"}

local kCol = 4
local Id2Tag = {}

function new(index)
	local ctrl = Control.new(require("res/shop/ShopSkin.lua"),{"res/shop/Shop.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(index)
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_LABEL
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
	self:adjustTouchBox(0,Stage.uiBottom,0,2*Stage.uiBottom)
end

function init(self,index)
	self:addArmatureFrame("res/shop/effect/common/ShopCommon.ExportJson")
	--self:addArmatureFrame("res/shop/effect/rare/ShopRare.ExportJson")
	--self:addArmatureFrame("res/shop/effect/hero/ShopHero.ExportJson")
	local function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.back:addEventListener(Event.Click,onClose,self)
	--self.goods:setDirection(List.UI_LIST_HORIZONTAL)
	--self.powergoods:setDirection(List.UI_LIST_HORIZONTAL)
	local function onSelectOption(self,event,target)
		self:onSelectTag(target.regionId)
	end
	for i = 1,4 do
		self.region['region'..i]:addEventListener(Event.Click,onSelectOption,self)
		self.region['region'..i].regionId = i
	end
	self.goods:setBgVisiable(false)
	--local function onCommonLottery(self,event,target)
	--	if event.etype == Event.Touch_began then
	--		Common.setBtnAnimation(self._ccnode,"ShopCommon","common")
	--	elseif event.etype == Event.Touch_ended then
	--		Network.sendMsg(PacketID.CG_SHOP_COMMON_ONCE)
	--	end
	--end
	--local function onRareLottery(self,event,target)
	--	local isFree = false
	--	if self.rarefree and self.rarefree <= 0 then
	--		isFree = true
	--	end
	--	UIManager.addChildUI("src/modules/shop/ui/ShopRareUI",isFree)
	--end
	--function onBagRefresh(self,event,target)
	--	self:refreshOwnInfo()
	--end
	--local function onReCharge(self,event,target)
	--	UIManager.addUI("src/modules/vip/ui/VipUI", "Recharge")
	--end
	--self.rechargeBtn:addEventListener(Event.Click,onReCharge)
	----self.draw.common.lotteryc:addEventListener(Event.TouchEvent,onCommonLottery)
	----self.draw.rare.lotteryr:addEventListener(Event.Click,onRareLottery,self)
	--Bag.getInstance():addEventListener(Event.BagRefresh,onBagRefresh,self)
	--self.datelimited.txtdate:setVisible(false)

	local temp = {}
	Id2Tag ={}
	for k,v in pairs(ShopConfig) do
		local tag = v.tags
		if tag <=4 and not temp[tag] then
			table.insert(Id2Tag,tag)
			temp[tag] = true
		end
	end
	table.sort(Id2Tag)
	if #Id2Tag == 1 then
		for i = 1,4 do
			self.region['region'..i]:setVisible(false)
		end
	else
		for i = 1,4 do
			if i > #Id2Tag then
				self.region['region'..i]:setVisible(false)
			else
				local tag = Id2Tag[i]
				if tag then
					self.region['region'..i].tabhot:setString(TagName[tag])
				end
			end
		end
	end

	self:initInfo()
	self:openTimer()
	self:onSelectTag(index or 1)
end

function setPowerCoin(self)
	local power = Master.getInstance().powerCoin
	self.powerLabel.txtmoney:setString(power)
end

function initInfo(self)
	--local res = "res/common/icon/coin/power.png"
	--self.powerLabel.jbicon._ccnode:setTexture(res)
	--self.powerLabel.txtmoney:setAnchorPoint(0.5,0)
	--setPowerCoin(self)
	--Master.getInstance():addEventListener(Event.MasterRefresh,setPowerCoin,self)

	--self.draw.common.txtfree:setString("")
	--self.draw.common.txtfree:setVisible(false)
	--self.draw.common.tabfree:setVisible(false)
	--self.draw.rare.txtfree:setString("")
	--self.draw.rare.txtfree:setVisible(false)
	--self.draw.rare.tabfree:setVisible(false)
	--local onceGold = LotteryConfig.ConstantConfig[1].onceCost
	--local txtgold = string.format("金币：%d",onceGold)
	--self.draw.rare.txtjb:setString(txtgold)
	--self:refreshOwnInfo()
end

function refreshOwnInfo(self)
	--local costItemId = LotteryConfig.ConstantConfig[1].itemId
	--local cfg = ItemConfig[costItemId]
	--local num = BagData.getItemNumByItemId(costItemId)
	--local txt = string.format("消耗：%s(当前拥有%d)",cfg.name,num)
	--self.draw.common.txtxh:setString(txt)
end

function onBuy(shopId,event,target)
	if event.etype == Event.Touch_ended then
		UIManager.addChildUI("src/modules/shop/ui/ShopTipsUI",shopId)
	end
end

function onSale(shopId,event,target)
	if event.etype == Event.Touch_ended then
		UIManager.addChildUI("src/modules/shop/ui/ShopTipsUI",shopId,"sale")
	end
end

function onSelectTag(self,id)
	local tag = Id2Tag[id] or 0
	self.region['region'..id]:setSelected(true)
	local data = Shop.getConfigByTag(tag)
	local shopIds = {}
	for k,v in pairs(data) do
		table.insert(shopIds,v.id)
	end
	--if tag == 0 then
	--	self:setCtrlVisible("draw")
	--elseif tag == 5 then
	--	self:setCtrlVisible("powergoods")
	--	Shop.cntQuery(shopIds)
	--	self:refreshPowerGoods(data)
	--else
	--	self:setCtrlVisible("goods")
	--	Shop.cntQuery(shopIds)
	--	self:refreshGoods(data)
	--end
	Shop.cntQuery(shopIds)
	self:refreshGoods(data)
	--if tag == 0 then
	--	Network.sendMsg(PacketID.CG_SHOP_LOTTERY_QUERY)
	--end
end

function setCtrlVisible(self,name)
	--self.draw:setVisible(false)
	--self.goods:setVisible(false)
	--self.powergoods:setVisible(false)
	--self.powerLabel:setVisible(name == "powergoods")
	--self[name]:setVisible(true)
end

function refreshPowerGoods(self,goods)
	local list = self.powergoods
	list.listBg:setVisible(false)
	local cap = #goods
	local cols = math.ceil(cap/kCol)
	list:removeAllItem()
	list:setItemNum(cols)	
	self.datelimited.txtdate:setVisible(false)
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
		item.txtprice:setAnchorPoint(1,0)
		item.txtprice:setPositionX(item.jbbicon:getPositionX())
		item.txtprice:setString(data.price)
		if data.mtype == ShopDefine.K_SHOP_BUY_MONEY then
			CommonGrid.setCoinIcon(item.jbbicon,"money")
		elseif data.mtype == ShopDefine.K_SHOP_BUY_RMB then
			CommonGrid.setCoinIcon(item.jbbicon,"rmb")
		elseif data.mtype == ShopDefine.K_SHOP_BUY_POWER then
			CommonGrid.setCoinIcon(item.jbbicon,"power")
		end
		--if next(data.datelimited) then
		--	self.datelimited.txtdate:setVisible(true)
		--	self.datelimited.txtdate:setString(string.format("%s~%s",data.datelimited[1],data.datelimited[2]))
		--end
		if data.daylimited > 0 then
			--item.txtlimited:setVisible(true)
			--item.txtlimited:setString(string.format("（限购：%d）",data.daylimited))
		else
			--item.txtlimited:setVisible(false)
		end
		--if not item.buy:hasEventListener(Event.TouchEvent,onBuy) then
		--	item.buy:addEventListener(Event.TouchEvent,onBuy,data.id)
		--end
		--if not item.sale:hasEventListener(Event.TouchEvent,onSale) then
		--	item.sale:addEventListener(Event.TouchEvent,onSale,data.id)
		--end
		if i == cap and cap%kCol ~= 0 then
			for j = cap%kCol+1,kCol do
				ctrl["grid"..j]:setVisible(false)
			end
		end

	end
end

function refreshGoods(self,goods)
	local list = self.goods
	--list.listBg:setVisible(false)
	local cap = #goods
	local cols = math.ceil(cap/kCol)
	list:removeAllItem()
	list:setItemNum(cols)	
	--self.datelimited.txtdate:setVisible(false)
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
		local grid = item.gezi.itembg
		CommonGrid.bind(grid)
		grid:setItemIcon(data.itemId,"descIcon")
		item.txtname:setAnchorPoint(0.5,0)
		item.txtname:setString(cfg.name)
		--item.txtprice:setAnchorPoint(1,0)
		--item.txtprice:setPositionX(item.jinbi:getPositionX())
		item.txtprice:setString(data.price)
		item.id = data.id

		--item.sale:setVisible(false)
		item.tab:setVisible(false)
		--item.txttab:setVisible(false)
		item.shouxinicon:setVisible(false)
		item.status2:setVisible(false)
		if data.daylimited > 0 then
			local cnt = Shop.getBuyCnt(item.id)
			item.txttab:setVisible(true)
			item.txttab.txtsz:setString(string.format("限购%d/%d",data.daylimited - cnt,data.daylimited))
		else
			item.txttab:setVisible(false)
		end
		if data.mtype == ShopDefine.K_SHOP_BUY_MONEY then
			CommonGrid.setCoinIcon(item.jinbi,"money")
		elseif data.mtype == ShopDefine.K_SHOP_BUY_RMB then
			CommonGrid.setCoinIcon(item.jinbi,"rmb")
		elseif data.mtype == ShopDefine.K_SHOP_BUY_POWER then
			CommonGrid.setCoinIcon(item.jinbi,"power")
		end
		--if next(data.datelimited) then
		--	self.datelimited.txtdate:setVisible(true)
		--	self.datelimited.txtdate:setString(string.format("%s~%s",data.datelimited[1],data.datelimited[2]))
		--end
		--if data.daylimited > 0 then
		--	--item.txtlimited:setVisible(true)
		--	--item.txtlimited:setString(string.format("（限购：%d）",data.daylimited))
		--else
		--	--item.txtlimited:setVisible(false)
		--end
		if not item:hasEventListener(Event.TouchEvent,onBuy) then
			item:addEventListener(Event.TouchEvent,onBuy,data.id)
		end
		if i == cap and cap%kCol ~= 0 then
			for j = cap%kCol+1,kCol do
				ctrl["grid"..j]:setVisible(false)
			end
		end
	end
end

function refreshCntBuy(self)
	if self.goods:isVisible() then
		local list = self.goods
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


local costName = {[1]="钻石",[2]="金币",[3]="力量币"}
function virBuy(id,params)
	local cfg = ShopVirtual[id]
	if cfg then
		local cntLeft = Shop.getBuyCntLeft(id)
		if id == ShopDefine.K_SHOP_VIRTUAL_PHY_ID then
			if cntLeft <= 0 then
				Common.showMsg("今日的体力可购买次数已用完咯")
				return
			end
		end
		local cnt = Shop.getBuyCnt(id)
		local price = Shop.getPriceByTimes(id,cnt+1)
		local name = costName[cfg.mtype]
		local desc = cfg.desc
		local tips = TipsUI.showTips(string.format(desc,price,name,cfg.buynum,cntLeft or cnt))
		tips:addEventListener(Event.Confirm,function(self,event) 
			if event.etype == Event.Confirm_yes then
				Network.sendMsg(PacketID.CG_SHOP_BUY_VIRTUAL,id,params)
			end
		end)
	end
end

function moneyBuyByCnt(cnt)
	local i,totalCost,addMoney = getMoneyBuyCntAndCost(cnt)
	local tips = TipsUI.showTips(string.format("花费%d钻石购买%d金币,是否继续?",totalCost,addMoney))
	tips:addEventListener(Event.Confirm,function(self,event) 
		if event.etype == Event.Confirm_yes then
			Network.sendMsg(PacketID.CG_GOLD_BUY_TEN,i)
		end
	end)
end

function getMoneyBuyCntAndCost(money)
	local needMoney = money - Master.getInstance().money
	local addMoney = 0
	--local curCnt = Shop.getBuyCnt(ShopDefine.K_SHOP_VIRTUAL_MONEY_ID)
	local curCnt = GoldData.getData()
	local totalCost = 0
	local onceMoney = GoldConstConfig[1].money
	local i = 0
	while true do
		i = i + 1
		local cnt1 = curCnt + i > #GoldCostConfig and #GoldCostConfig or curCnt + i
		local cost = GoldCostConfig[cnt1].cost
		totalCost = totalCost + cost
		addMoney = addMoney + onceMoney
		if addMoney > needMoney then
			break
		end
	end
	local vipLv = Master.getInstance().vipLv
	local ret = i
	if curCnt + i > GoldCntConfig[vipLv].cnt then
		ret = -1
	end
	return ret,totalCost,addMoney
end

return ShopUI
