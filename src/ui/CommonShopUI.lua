module(..., package.seeall)
setmetatable(_M, {__index = Control})
local ItemConfig = require("src/config/ItemConfig").Config
local BagData = require("src/modules/bag/BagData")
local kCol = 4

function new()
	local ctrl = Control.new(require("res/common/CommonShopSkin"), {"res/common/CommonShop.plist"})
	setmetatable(ctrl,{__index = _M})
	return ctrl
end

function onClose(self)
	UIManager.removeUI(self)
end

function onRefresh(self, evt)
	print("onRefresh")
end

function addStage(self)
	--self:setPositionY(Stage.uiBottom)
end

function startCountDown(self)
	local tab = os.date("*t",os.time())
	tab.hour = 24
	tab.min = 0
	tab.sec = 0
	local cd = os.time(tab) - os.time()
	self:setRefreshTime(cd)
end

function init(self)
	self:setTitle()
	self:startCountDown()
	--self.yzsdzi:setDimensions(self.yzsdzi:getContentSize().width, 0)
	--self.yzsdzi:setHorizontalAlignment(Label.Alignment.Center)
	--self.yzsdzi:setString(self.title)
	self.txtsj:setString("")

	local shoptips = self.shoptips
	CommonGrid.bind(shoptips.grid)
	shoptips:setVisible(false)
	--shoptips.txtname:setAnchorPoint(0.5,0)
	shoptips.txtDesc:setDimensions(shoptips.xbt6:getContentSize().width-10,0)
	shoptips.txtsm:setDimensions(shoptips.xbt6:getContentSize().width-10,0)
	self.txtDescPosY = shoptips.txtDesc:getPositionY()
	self.xbt6PosY = shoptips.xbt6:getPositionY()
	self.txtsmPosY = shoptips.txtsm:getPositionY()

	self.moneyLabel2:setVisible(false)
	--self.xcgxsj:setVisible(false)
	--刷新时间
	--local posX = self.txtgxsj:getPositionX() + self.txtgxsj:getContentSize().width
	--self.txtsj:setPositionX(posX + 10)
	--self.txtsj:setString(self.nextTime .. "时")
	--self.shopList:setDirection(List.UI_LIST_HORIZONTAL)

	self:openTimer()
	self.shopList:setBgVisiable(false)
	self.back:addEventListener(Event.Click, self.onClose, self)
	self.shuaxin:addEventListener(Event.Click, self.onRefresh, self)
	self.moneyLabel:setVisible(false)
	self.channel:setVisible(false)
end

function setTitle(self,name)
	--self.bg.strength:setVisible(false)
	self.bg.expedition:setVisible(false)
	self.bg.guild:setVisible(false)
	self.bg.mystery:setVisible(false)
	self.bg.arena:setVisible(false)
	self.bg.exchange:setVisible(false)
	self.bg.jifen:setVisible(false)
	if name then
		self.bg[name]:setVisible(true)
	end
end

function refreshQuery()
	print("CommonShopUI:refreshQuery")
end

function setRefreshTime(self,cd)
	self.cd = cd + 1
	local function onRefreshTime(self,event)
		self.cd = self.cd - 1
		if self.cd <= 0 then
			self:delTimer(self.cdTimer)
			self.cdTimer = nil
			self:refreshQuery()
		end
		local timeShow = Common.getDCTime(self.cd)
		self.txtsj:setString(timeShow.."后自动刷新")
	end
	if self.cdTimer then
		self:delTimer(self.cdTimer)
	end
	onRefreshTime(self)
	self.cdTimer = self:addTimer(onRefreshTime, 1, cd, self)
end

function getOwnMoney()
	return nil
end

function onBuyTouch(self,evt,target)
	if evt.etype == Event.Touch_ended then
		local data = target.data
		local shoptips = self.shoptips
		if data.buy == 0 then
			local ownMoney = self.getOwnMoney()
			if ownMoney and ownMoney < data.price then
				Common.showMsg("积分不足")
			else
				local cfg = ItemConfig[data.itemId]
				shoptips.grid:setItemIcon(data.itemId,"descIcon")
				shoptips.txtname:setString(cfg.name)
				local num = BagData.getItemNumByItemId(data.itemId)
				if data.itemId == 9901011 then
					num = Master.getInstance().skillRage
				elseif data.itemId == 9901012 then
					num = Master.getInstance().skillAssist
				end
				shoptips.uprice.tabsz:setString(num)
				shoptips.dprice.tabsz:setString(data.price)

				shoptips.txtDesc:setString(cfg.desc)
				local adjustY = shoptips.txtDesc:getContentSize().height-15
				shoptips.txtDesc:setPositionY(self.txtDescPosY-adjustY)
				shoptips.xbt6:setContentSize(cc.size(shoptips.xbt6:getContentSize().width,shoptips.txtDesc:getContentSize().height+20))
				shoptips.xbt6:setPositionY(self.xbt6PosY-adjustY)
				shoptips.txtsm:setString(cfg.extraDesc)
				local adjustY2 = shoptips.txtsm:getContentSize().height-15
				shoptips.txtsm:setPositionY(self.txtsmPosY-adjustY-adjustY2)

				self.setShopItemCoin(shoptips.dprice.jbbicon,data.id)
				ActionUI.show(shoptips,"scale")
				shoptips.buy.id = data.id
				shoptips.buy:removeEventListener(Event.Click, onBuyClick)
				shoptips.buy:addEventListener(Event.Click, onBuyClick, self)
			end
		else
			Common.showMsg("已经购买过")
		end
	end
end

function onBuyClick(self,evt,target)
	ActionUI.hide(self.shoptips,"scaleHide")
	self.onBuy(target.id,self)
end

function onBuy(shopId)
	print("CommonShopUI onBuy")
end

function refreshShop(self)
	local list = self.shopList
	list:removeAllItem()
	local cap = #self.shopData
	local cols = math.ceil(cap / kCol)
	list:setItemNum(cols)
	for i = 1,cap do
		local ctrl = list:getItemByNum(math.ceil(i / kCol))
		local data = self.shopData[i]
		--local item = i%4 == 0 and ctrl.right or ctrl.left
		local item
		if i%kCol == 0 then
			item = ctrl["grid"..kCol]
		else
			item = ctrl["grid"..i%kCol]
		end
		--item.txtmz:setFontSize(18)
		self:refreshItem(item, data)
		if i == cap and cap%kCol ~= 0 then
			for j = cap%kCol+1,kCol do
				ctrl["grid"..j]:setVisible(false)
			end
		end
	end
end

function setShopItemCoin()
end

function refreshItem(self, item, data)
	local cfg = ItemConfig[data.itemId]
	local grid = item.gezi
	CommonGrid.bind(grid)
	grid:setItemIcon(data.itemId,"descIcon")
	grid:setItemNum(data.cnt)

	--item.txtname:setDimensions(150, 0)
	--item.txtname:setHorizontalAlignment(Label.Alignment.Center)
	item.txtname:setAnchorPoint(0.5,0)
	item.txtname:setString(cfg.name)
	item.txtprice:setString(data.price)
	item.txttab:setVisible(false)
	item.tab:setVisible(false)
	self.setShopItemCoin(item.jinbi,data.id)
	if data.buy == 0 then
		--item:setState(Button.UI_BUTTON_NORMAL)
		--if not item:hasEventListener(Event.TouchEvent,self.onBuy) then
			item.data = data
			item:addEventListener(Event.TouchEvent, onBuyTouch, self)
		--end
		item.shouxinicon:setVisible(false)
		item.status2:setVisible(false)
	else
		item.shouxinicon:setVisible(true)
		item.status2:setVisible(true)
		--item:shader(Shader.SHADER_TYPE_GRAY)
		--item:setState(Button.UI_BUTTON_DISABLE, false, true)
	end
end

function refreshShopData(self,shopData)
	self.shopData = shopData
	self:refreshShop()
end

function setShopItemBuyState(self,shopId,state)
	local pos = table.foreachi(self.shopData, function(k, v) if self:isEqual(v, shopId) then return k end end)
	if pos then
		local ctrl = self.shopList:getItemByNum(math.ceil(pos / kCol))
		local item
		if pos%kCol == 0 then
			item = ctrl["grid"..kCol]
		else
			item = ctrl["grid"..pos%kCol]
		end
		item.shouxinicon:setVisible(true)
		item.status2:setVisible(true)
		--item:shader(Shader.SHADER_TYPE_GRAY)
		--item.goumai:setState(state, false, true)
		item.data.buy = 1
	end
end

function isEqual(self, v, id)
	return v.id == id
end

function clear(self)
	Control.clear(self)
	if self.cdTimer then
		self:delTimer(self.cdTimer)
		self.cdTimer = nil
	end
end

