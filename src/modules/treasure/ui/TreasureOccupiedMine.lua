module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Treasure = require("src/modules/treasure/Treasure")
local TDefine = require("src/modules/treasure/TreasureDefine")
local ItemConfig = require("src/config/ItemConfig").Config
local TreasureConfig = require("src/config/TreasureConfig").Config
local ShopDefine = require("src/modules/shop/ShopDefine")
local Shop = require("src/modules/shop/Shop")
local Hero = require("src/modules/hero/Hero")
local HeroGridS = require("src/ui/HeroGridS")
local ShopDefine = require("src/modules/shop/ShopDefine")
function new(mineInfo)
	local ctrl = Control.new(require("res/treasure/TreasureOccupiedMineSkin"),{"res/treasure/TreasureOccupiedMine.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(mineInfo)
	return ctrl
end
function addStage(self)
	self:setPositionY(Stage.uiBottom)
end
function uiEffect(self)
	return UIManager.THIRD_TEMP
end

-- function refresh(self,mineList)
-- 	self.mineList = mineList

-- 	self:showMines()
-- end

function hideMineInfo(self)
	ActionUI.hide(self.mineinfo,"scaleHide")
end

function refreshMineInfo(self,mineInfo)
	Shop.cntQuery({ShopDefine.K_SHOP_VIRTUAL_TREASUREDOUBLE_ID,	ShopDefine.K_SHOP_VIRTUAL_TREASUREEXTEND_ID,ShopDefine.K_SHOP_VIRTUAL_TREASURESAFE_ID})
	self.mineInfo = mineInfo
	self.mineId = mineInfo.mineId
	local cfg = TreasureConfig[self.mineId]

	for i=1,3 do
		if mineInfo.rankId == i then
			self.mineinfo.mineicon['rank'..i]:setVisible(true)
			self.mineinfo.txtrank:setString(TDefine.MINE_RANK[i].name)
		else
			self.mineinfo.mineicon['rank'..i]:setVisible(false)
		end
	end
	if next(mineInfo.reward) then
		self.mineinfo.txtrewardtitle:setString("累积收益:")
		local n = 0
		for i,item in ipairs(mineInfo.reward) do 
			local r = self.mineinfo.reward['r'..i]
			if i <= 8 then
				r:setVisible(true)
				CommonGrid.bind(r.icon)
				r.icon:setItemIcon(item.itemId,"",23)
				r.num:setString("X"..item.cnt)
				n = n + 1
			end
		end
		if n < 8 then
			for i=n+1,8 do
				self.mineinfo.reward['r'..i]:setVisible(false)
			end 
		end
	else
		self.mineinfo.txtrewardtitle:setString("随机产出")
		local items = {}
		for itemId,item in pairs(cfg.fixProduct) do
			table.insert(items,{itemId,item[2]})
		end
		for itemId,item in pairs(cfg.randomProduct) do 
			if itemId ~= "randType" then
				table.insert(items,{itemId,item[3]})
			end  
		end 
		local n = 0
		for i,item in ipairs(items) do
			local r = self.mineinfo.reward['r'..i]
			if i <= 8 then
				r:setVisible(true)
				CommonGrid.bind(r.icon)
				r.icon:setItemIcon(item[1],"",23)
				r.num:setString("X"..item[2])
				n = n + 1
			end
		end
		if n < 8 then
			for i=n+1,8 do
				self.mineinfo.reward['r'..i]:setVisible(false)
			end 
		end
	end

	-- 英雄头像
	self:showGuard(mineInfo.guard)

	self:onRefreshLeftTimes()
	self:showTimes()
	self:refreshBtn()
end
function sendSafe(self)
	if Treasure.safeTimes < TDefine.SAFE_TIMES_PER_DAY then
		Treasure.sendTreasureConsume(TDefine.Consume.SAFE,self.mineId)
	else
		ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_TREASURESAFE_ID,{self.mineId})
	end
end
function sendDouble(self)
	if Treasure.doubleTimes < TDefine.DOUBLE_TIMES_PER_DAY then
		Treasure.sendTreasureConsume(TDefine.Consume.DOUBLE,self.mineId)
	else
		ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_TREASUREDOUBLE_ID,{self.mineId})
	end
end
function sendExtend(self)
	if Treasure.extendTimes < TDefine.EXTEND_TIMES_PER_DAY then
		Treasure.sendTreasureConsume(TDefine.Consume.EXTEND,self.mineId)
	else
		ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_TREASUREEXTEND_ID,{self.mineId})
	end
end

function init(self,mineInfo)
	self.mineInfo = mineInfo
	self.mineId = mineInfo.mineId
	local cfg = TreasureConfig[mineId]
	local function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.close:addEventListener(Event.Click,onClose,self)

	local function onCDTime(self,event)
		self:showTimes()
	end
	self.cdTimer = self:addTimer(onCDTime, 1, -1, self)
	self:openTimer()
	for i=1,8 do
		CommonGrid.bind(self.mineinfo.reward['r'..i])
	end

	for i=1,4 do
		CommonGrid.bind(self.fight['hero'..i])
	end


	local function onAdjust(self,event,target)
		local forbid = Treasure.getForbidHero(self.mineId)
		local fightUI = UIManager.addUI("src/modules/treasure/ui/TreasureFightUI",TDefine.MODE_GUARD,forbid,self.mineId)
		local g = {}
		for _,gg in ipairs(self.mineInfo.guard) do 
			table.insert(g,gg.name)
		end
		fightUI:resetHeroFightList(g)
	end
	self.fight.adjust:addEventListener(Event.Click,onAdjust,self)

	local function onSafe(self,event,target)
		-- if Treasure.safeTimes < TDefine.SAFE_TIMES_PER_DAY then
		-- 	Treasure.sendTreasureConsume(TDefine.Consume.SAFE,self.mineId)
		-- else
		-- 	ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_TREASURESAFE_ID,{self.mineId})
		-- end
		self:sendSafe()
	end
	self.safe:addEventListener(Event.Click,onSafe,self)

	local function onAbandon(self,event,target)
		local tipUI = TipsUI.showTips("还有好多资源未开采呢！确定放弃此宝矿吗？")
		tipUI:setBtnName("确定","取消")
			tipUI:addEventListener(Event.Confirm,function(self,event)
				if event.etype == Event.Confirm_yes then
					Network.sendMsg(PacketID.CG_TREASURE_ABANDON,self.mineId)
				end
			end,self)
		
	end
	self.abandon:addEventListener(Event.Click,onAbandon,self)

	local function onDouble(self,event,target)
		-- if Treasure.doubleTimes < TDefine.DOUBLE_TIMES_PER_DAY then
		-- 	Treasure.sendTreasureConsume(TDefine.Consume.DOUBLE,self.mineId)
		-- else
		-- 	ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_TREASUREDOUBLE_ID,{self.mineId})
		-- end
		self:sendDouble()
	end
	self.double:addEventListener(Event.Click,onDouble,self)

	local function onExtend(self,event,target)
		-- if Treasure.extendTimes < TDefine.EXTEND_TIMES_PER_DAY then
		-- 	Treasure.sendTreasureConsume(TDefine.Consume.EXTEND,self.mineId)
		-- else
		-- 	ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_TREASUREEXTEND_ID,{self.mineId})
		-- end
		self:sendExtend()
	end
	self.extend:addEventListener(Event.Click,onExtend,self)

	Master:getInstance():addEventListener(Event.ShopCntRefresh,onRefreshLeftTimes,self)
	Master:getInstance():addEventListener(Event.ShopBuyVirtual,onShopBuyTimes,self)

	self:showExtend()
	self:refreshMineInfo(mineInfo)
end
function showExtend(self)
	if self.mineInfo.extend > 0 then
		self.mineinfo.extendtime:setVisible(true)
	else
		self.mineinfo.extendtime:setVisible(false)
	end
end
function showGuard(self,guard)
	local power = 0
	for i=1,4 do
		local h = guard[i]
		if h and h.name and h.name ~= "" then
			-- CommonGrid.bind(self.fight['hero'..i])
			local hero = Hero.getHero(h.name)
			if self.fight['herox'..i] == nil then
				self.fight['herox'..i] = HeroGridS.new(self.fight['hero'..i],i)
			end
			self.fight['herox'..i]:setHero(hero)
			self.fight['herox'..i]:setScale(72/92)
			-- self.fight['hero'..i]:setHeroIcon(h.name,nil,72/92,h.quality)
		end
		if i < 4 then
			power = power + guard[i].power
		end
	end
	self.fight.power.txtpower:setString(power)
end

function showTimes(self)
	local t = Master.getServerTime()
	if self.mineInfo.safeEndTime > t then
		local cdtime = self.mineInfo.safeEndTime - t
		self.mineinfo.safetime:setVisible(true)
		self.mineinfo.safetime.txtsafetime:setString(Common.getDCTime(cdtime))
	else
		self.mineinfo.safetime:setVisible(false)
	end 

	if self.mineInfo.doubleEndTime > t then
		local cdtime = self.mineInfo.doubleEndTime - t
		self.mineinfo.doubletime:setVisible(true)
		self.mineinfo.doubletime.txtdoubletime:setString(Common.getDCTime(cdtime))
	else
		self.mineinfo.doubletime:setVisible(false)
	end
	if self.mineInfo.endTime > t then
		local txttime = string.format("%s",Common.getDCTime(self.mineInfo.endTime - t))
		self.mineinfo.txttimecontent:setString(txttime)
		self.mineinfo.txttimetitle:setVisible(true)
		self.mineinfo.txttimecontent:setVisible(true)
	else
		self.mineinfo.txttimetitle:setVisible(false)
		self.mineinfo.txttimecontent:setVisible(false)
	end
end

function refreshBtn(self)
	self.extend:setState(Button.UI_BUTTON_NORMAL)
	self.extend:setEnabled(true)

	if self.mineInfo.safeEndTime >= self.mineInfo.endTime then
		self.safe:setState(Button.UI_BUTTON_DISABLE)
		self.safe:setEnabled(false)
	else
		self.safe:setState(Button.UI_BUTTON_NORMAL)
		self.safe:setEnabled(true)
		if self.mineInfo.safeEndTime and self.mineInfo.safeEndTime > self.mineInfo.startTime then
			self.safe.skillzi:setString("延长保护")
		else
			self.safe.skillzi:setString("开启保护")
		end
	end

	if self.mineInfo.doubleEndTime >= self.mineInfo.endTime then
		self.double:setState(Button.UI_BUTTON_DISABLE)
		self.double:setEnabled(false)
	else
		self.double:setState(Button.UI_BUTTON_NORMAL)
		self.double:setEnabled(true)
	end

end

function onRefreshLeftTimes(self,event,target)
	-- local doubleLeftTimes = TDefine.DOUBLE_TIMES_PER_DAY - Treasure.doubleTimes
	-- self.txtleftdouble:setString('剩余'..doubleLeftTimes.."次")
	-- local extendLeftTimes = TDefine.EXTEND_TIMES_PER_DAY - Treasure.extendTimes
	-- self.txtleftextend:setString("剩余"..extendLeftTimes.."次")
	-- local safeLeftTimes = TDefine.SAFE_TIMES_PER_DAY - Treasure.safeTimes
	-- self.txtleftsafe:setString("剩余"..safeLeftTimes.."次")
	-- self:refreshBtn()
end

function onShopBuyTimes(self,event,target)
	local id = event.id
	if id == ShopDefine.K_SHOP_VIRTUAL_TREASUREDOUBLE_ID then
		self:sendDouble()
	elseif id == ShopDefine.K_SHOP_VIRTUAL_TREASUREEXTEND_ID then
		self:sendExtend()
	elseif id == ShopDefine.K_SHOP_VIRTUAL_TREASURESAFE_ID then
		self:sendSafe()
	end
end

function clear(self)
	Control.clear(self)
	if self.cdTimer then
		self:delTimer(self.cdTimer)
		self.cdTimer = nil
	end
	Master:getInstance():removeEventListener(Event.ShopCntRefresh,onRefreshLeftTimes)
	Master:getInstance():removeEventListener(Event.ShopBuyVirtual,onShopBuyTimes)

end



	
