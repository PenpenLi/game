module("ShopTipsUI",package.seeall)
setmetatable(_M,{__index = Control})
local ItemConfig = require("src/config/ItemConfig").Config
local Shop = require("src/modules/shop/Shop")
local ShopDefine = require("src/modules/shop/ShopDefine")
local BagData = require("src/modules/bag/BagData")

function new(id,mtype)
	local ctrl = Control.new(require("res/shop/ShopTipsSkin.lua"),{"res/shop/ShopTips.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(id,mtype)
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function addStage(self)
	self:adjustTouchBox(0,Stage.uiBottom,0,2*Stage.uiBottom)
end

function init(self,id,mtype)
	self.id = id
	self.mtype = mtype
	local shoptips = self.shoptips
	shoptips.txtDesc:setDimensions(shoptips.xbt6:getContentSize().width-10,0)
	shoptips.txtsm:setDimensions(shoptips.xbt6:getContentSize().width-10,0)
	self.shopTipsTxtDescY = shoptips.txtDesc:getPositionY()
	self.shopTipsXbt6Y = shoptips.xbt6:getPositionY()
	self.shopTipsTxtsmY = shoptips.txtsm:getPositionY()
	shoptips.txtnum:setString(1)
	local function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.close1:addEventListener(Event.Click,onClose,self)
	function onIncReal(id)
		local data = Shop.getShopConfigById(self.id)
		local num = tonumber(shoptips.txtnum:getString()) + 1
		if data.daylimited > 0 then
			num = math.min(num,data.daylimited)
		end
		if data.mtype == ShopDefine.K_SHOP_BUY_RMB then
			local rmb = Master.getInstance().rmb
			num = math.min(math.floor(rmb / data.price),num)
		elseif data.mtype == ShopDefine.K_SHOP_BUY_MONEY then
			local money = Master.getInstance().money
			num = math.min(math.floor(money / data.price),num)
		end
		num = math.max(num,1)
		shoptips.txtnum:setString(num)
		local cnt = Shop.getBuyCnt(self.id)
		if num + cnt >= data.daylimited then
			setIncEnabled(self,false)
		end
		shoptips.dprice.tabsz:setString(data.price * num)
	end
	function onInc(self,event,target)
		if event.etype == Event.Touch_ended then
			onIncReal(id)
			if self.timer then
				self:delTimer(self.timer)
				self.timer = nil
			end
		elseif event.etype == Event.Touch_out then
			if self.timer then
				self:delTimer(self.timer)
				self.timer = nil
			end
		elseif event.etype == Event.Touch_began then
			self.timer = self:addTimer(onIncReal,0.3,-1,self)
		end
		local data = Shop.getShopConfigById(self.id)
		local num = tonumber(shoptips.txtnum:getString())
		local num1 = 0
		if data.mtype == ShopDefine.K_SHOP_BUY_RMB then
			local rmb = Master.getInstance().rmb
			num1 = math.floor(rmb / data.price)
		elseif data.mtype == ShopDefine.K_SHOP_BUY_MONEY then
			local money = Master.getInstance().money
			num1 = math.floor(money / data.price)
		end
		if num >= num1 then
			setIncEnabled(self,false)
		else
			local cnt = Shop.getBuyCnt(self.id)
			if num + cnt >= data.daylimited then
				setIncEnabled(self,false)
			end
		end
	end
	function onMax(self,event,target)
		local data = Shop.getShopConfigById(self.id)
		if data.daylimited > 0 then
			local cnt = Shop.getBuyCnt(self.id)
			local num = data.daylimited - cnt
			if data.mtype == ShopDefine.K_SHOP_BUY_RMB then
				local rmb = Master.getInstance().rmb
				num = math.min(math.floor(rmb / data.price),num)
			elseif data.mtype == ShopDefine.K_SHOP_BUY_MONEY then
				local money = Master.getInstance().money
				num = math.min(math.floor(money / data.price),num)
			end
			num = math.max(num,1)
			shoptips.txtnum:setString(num)
			shoptips.dprice.tabsz:setString(data.price * num)
			setIncEnabled(self,false)
		end
	end
	function onDecReal(self)
		local num = math.max(tonumber(shoptips.txtnum:getString()) - 1,1)
		shoptips.txtnum:setString(num)
		local data = Shop.getShopConfigById(self.id)
		local cnt = Shop.getBuyCnt(self.id)
		if num + cnt < data.daylimited then
			setIncEnabled(self,true)
		end
		shoptips.dprice.tabsz:setString(data.price * num)
	end
	function onDec(self,event,target)
		if event.etype == Event.Touch_ended then
			onDecReal(self)
			if self.decTimer then
				self:delTimer(self.decTimer)
				self.decTimer = nil
			end
		elseif event.etype == Event.Touch_out then
			if self.decTimer then
				self:delTimer(self.decTimer)
				self.decTimer = nil
			end
		elseif event.etype == Event.Touch_began then
			self.decTimer = self:addTimer(onDecReal,0.3,-1,self)
		end
	end
	function onBuy(self,event,target)
		local buynum = tonumber(shoptips.txtnum:getString())
		local data = Shop.getShopConfigById(self.id)
		local cnt = Shop.getBuyCnt(self.id)
		local num = data.daylimited - cnt
		if data.daylimited > 0 and buynum > num then
			ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_RESETBUYCNT_ID,{[1]=self.id})
		else
			Network.sendMsg(PacketID.CG_SHOP_BUY,self.id,buynum)
		end
	end
	function onSell(self,event,target)
		local num = tonumber(shoptips.txtnum:getString())
		Network.sendMsg(PacketID.CG_SHOP_SELL,self.id,num)
	end
	function onShopTips(self,event,target)
	end
	--shoptips.txtname:setAnchorPoint(0.5,0)
	--shoptips.txtnum:setAnchorPoint(0.5,0)
	shoptips.inc:addEventListener(Event.TouchEvent,onInc,self)
	shoptips.zuida:addEventListener(Event.TouchEvent,onMax,self)
	shoptips.dec:addEventListener(Event.TouchEvent,onDec,self)
	shoptips.buy:addEventListener(Event.Click,onBuy,self)
	shoptips.sell:addEventListener(Event.Click,onSell,self)
	shoptips:addEventListener(Event.TouchEvent,onShopTips,self)
	local data = Shop.getShopConfigById(self.id)
	if data.tags == ShopDefine.K_SHOP_POWER then
		local flag = mtype == "sale"
		shoptips.sell:setVisible(flag)
		shoptips.buy:setVisible(not flag)
		--shoptips.buy:setAnchorPoint(-0.5,0)
		--shoptips.sell:setAnchorPoint(0.5,0)
	else
		shoptips.sell:setVisible(false)
		shoptips.buy:setVisible(true)
		--shoptips.buy:setAnchorPoint(0,0)
	end
	CommonGrid.bind(shoptips.grid)
	--shoptips.uprice.ybbicon:setVisible(false)
	--shoptips.dprice.jbbicon:setVisible(false)
	local data = Shop.getShopConfigById(self.id)
	local cnt = Shop.getBuyCnt(self.id)
	if cnt + 1 >= data.daylimited then
		setIncEnabled(self,false)
	end
	self:openTimer()
	self:refreshInfo()
end

function clear(self)
	Control.clear(self)
	if self.timer then
		self:delTimer(self.timer)
		self.timer = nil
	end
	if self.decTimer then
		self:delTimer(self.decTimer)
		self.decTimer = nil
	end
end

function touch(self,event)
	local child = self:getTouchedChild(event.p)
	if child then
		Control.touch(self,event)
	else
		if event.etype == Event.Touch_ended then
			UIManager.removeUI(self)
		end
	end
end

function refreshInfo(self)
	local data = Shop.getShopConfigById(self.id)
	local cnt = Shop.getBuyCnt(self.id)
	local cfg = ItemConfig[data.itemId]
	local shoptips = self.shoptips
	shoptips.grid:setItemIcon(cfg.id,"descIcon")
	shoptips.txtname:setString(cfg.name)
	local price = data.price
	if self.mtype == "sale" then
		price = data.sellprice
	end
	local num = BagData.getItemNumByItemId(data.itemId)
	shoptips.uprice.tabsz:setString(num)
	shoptips.dprice.tabsz:setString(price)
	shoptips.txtDesc:setString(cfg.desc)
	local adjustY = shoptips.txtDesc:getContentSize().height-15
	shoptips.txtDesc:setPositionY(self.shopTipsTxtDescY -adjustY)
	shoptips.xbt6:setContentSize(cc.size(shoptips.xbt6:getContentSize().width,shoptips.txtDesc:getContentSize().height+20))
	shoptips.xbt6:setPositionY(self.shopTipsXbt6Y - adjustY)
	shoptips.txtsm:setString(cfg.extraDesc)
	local adjustY2 = shoptips.txtsm:getContentSize().height-15
	shoptips.txtsm:setPositionY(self.shopTipsTxtsmY-adjustY-adjustY2)
	--if data.daylimited > 0 then
	--	shoptips.txtlimited:setVisible(true)
	--	shoptips.txtlimited:setString(string.format("（限购：%d/%d）",cnt,data.daylimited))
	--else
	--	shoptips.txtlimited:setVisible(false)
	--end
	local cnt = Shop.getBuyCnt(self.id)
	local num1 = tonumber(shoptips.txtnum:getString())
	if data.daylimited and num1 + cnt >= data.daylimited then
		setIncEnabled(self,false)
	else
		setIncEnabled(self,true)
	end
	shoptips.txtlimited:setVisible(false)
	shoptips.txtnum:setString(1)
	local name = "rmb"
	if data.mtype == ShopDefine.K_SHOP_BUY_RMB then
	elseif data.mtype == ShopDefine.K_SHOP_BUY_MONEY then
		name = "money"
	elseif data.mtype == ShopDefine.K_SHOP_BUY_POWER then
		name = "power"
	end
	--CommonGrid.setCoinIcon(shoptips.uprice.jbbicon,name)
	CommonGrid.setCoinIcon(shoptips.dprice.jbbicon,name)
end

function setIncEnabled(self,flag)
	local shoptips = self.shoptips
	if flag then
		shoptips.inc:setState(Button.UI_BUTTON_NORMAL)
		shoptips.zuida:setState(Button.UI_BUTTON_NORMAL)
		shoptips.inc.touchEnabled = true
		shoptips.zuida.touchEnabled = true
	else
		shoptips.inc:setState(Button.UI_BUTTON_DISABLE)
		shoptips.zuida:setState(Button.UI_BUTTON_DISABLE)
		shoptips.inc.touchEnabled = false
		shoptips.zuida.touchEnabled = false
	end
end

return ShopTipsUI
