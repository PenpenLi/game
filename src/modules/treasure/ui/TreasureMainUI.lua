module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Treasure = require("src/modules/treasure/Treasure")
local TDefine = require("src/modules/treasure/TreasureDefine")
local ItemConfig = require("src/config/ItemConfig").Config
local MineConfig = require("src/config/MineConfig").Config
local ShopDefine = require("src/modules/shop/ShopDefine")
local Shop = require("src/modules/shop/Shop")
Instance = nil



function new()
	local ctrl = Control.new(require("res/treasure/TreasureMainSkin"),{"res/treasure/TreasureMain.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	Instance = ctrl
	return ctrl
end
function addStage(self)
	self:setPositionY(Stage.uiBottom)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_START, {groupId = GuideDefine.GUIDE_TREASURE_ENTER}) 
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, groupId = GuideDefine.GUIDE_TREASURE_ENTER})
end
function uiEffect(self)
	return UIManager.FIRST_TEMP_FULL
end


function onClickMine(self,event,target)

end	

function init(self)
	self.mineList = nil
	self:addArmatureFrame("res/treasure/effect/TreasureSafe.ExportJson")
	self:addArmatureFrame("res/treasure/effect/TreasureMine.ExportJson")
	self:addArmatureFrame("res/treasure/effect/TreasureOccupy.ExportJson")
	local function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.back:addEventListener(Event.Click,onClose,self)
	self["组14"]:setScale(Stage.winSize.height/(self["组14"]:getContentSize().height*Stage.uiScale))
	self["组14"]:setPositionY(-Stage.uiBottom)
	self.bottom:setPositionY(self.bottom:getPositionY() - Stage.uiBottom)
	self.refreshmap:setPositionY(self.refreshmap:getPositionY() - Stage.uiBottom)
	self.diamond:setPositionY(self.diamond:getPositionY() + Stage.uiBottom)
	self.challengetimes:setPositionY(self.challengetimes:getPositionY() + Stage.uiBottom)
	self.income:setPositionY(self.income:getPositionY() + Stage.uiBottom)
	self.rules:setPositionY(self.rules:getPositionY() + Stage.uiBottom)
	Treasure.sendTreasureQueryOccupied()
	local function onCDTime(self,event)
		self:refreshTimes()
	end
	self.cdTimer = self:addTimer(onCDTime, 1, -1, self)
	self:openTimer()

	Common.setLabelCenter(self.challengetimes.txttimes)
	Common.setLabelCenter(self.diamond.txtrmb)

	local function onTouchMine(self,event,target)
		if event.etype == Event.Touch_ended then
			if target.mineId then
				Treasure.sendTreasureMineInfo(target.mineId)
			end
		end
	end
	for i=1,6 do
		self.allmines['mine'..i].mineicon:addEventListener(Event.TouchEvent,onTouchMine,self)
		self.allmines['mine'..i].mineicon.mineId = nil
		self.allmines['mine'..i]:setVisible(false)
	end
	local function onMyMine(self,event,target)
		if event.etype == Event.Touch_ended then
			local mlist = Treasure.getMineList()
			if mlist[target.no] then
				Treasure.sendTreasureMineInfo(mlist[target.no].mineId)
			end
		end
	end
	for i=1,2 do
		local o  = self.bottom['occupied'..i]
		o.no = i
		o:addEventListener(Event.TouchEvent,onMyMine,self)
		o.effect = ccs.Armature:create('TreasureOccupy')
		o._ccnode:addChild(o.effect)
		o.effect:setAnchorPoint(0.5,0.5)
		local size = o:getContentSize()
		o.effect:setPosition(size.width/2,size.height/2)
		-- o.effect:getAnimation():playWithNames({"TreasureOccupy"},0,false)
		o.effect:setVisible(false)
	end

	local function onRefreshMap(self,event,target)
		if Treasure.refreshMapTimes >= TDefine.REFRESH_MAP_PER_DAY then
			ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_TREASUREREFRESHMAP_ID)
		else
			Treasure.sendTreasureMapInfo(1)
		end
	end
	self.refreshmap.refresh:addEventListener(Event.Click,onRefreshMap,self)

	local function onAddFightTimes(self,event,target)
		ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_TREASUREFIGHT_ID)
	end
	self.challengetimes.addbtn:addEventListener(Event.Click,onAddFightTimes,self)

	local function onAddRmb(self,event,target)
		Common.showRechargeTips("",false)
	end
	self.diamond.addBtn:addEventListener(Event.Click,onAddRmb,self)

	local function onInCome(self,event,target)
		Treasure.sendTreasureRecord()
	end
	self.income:addEventListener(Event.Click,onInCome,self)

	function onRule(self,event,target)
		local ui = UIManager.addChildUI("src/ui/RuleScrollUI")
		ui:setId(RuleScrollUI.Treasure)
	end
	self.rules:addEventListener(Event.Click,onRule,self)

	-- Master:getInstance():addEventListener(Event.ShopCntRefresh,onRefreshLeftTimes,self)
	self:refreshTimes()
	onMasterRefresh(self)
	Master:getInstance():addEventListener(Event.MasterRefresh,onMasterRefresh,self)
	self:refreshData()
	self:refreshChar()
	
end

function onMasterRefresh(self,event,target)
	self.diamond.txtrmb:setString(Master.getInstance().rmb)
end
function showBottomEffect(self,mineId)
	for i=1,2 do 
		local o = self.bottom['occupied'..i]
		if o.mineId == mineId then
			o.effect:setVisible(true)
			o.effect:getAnimation():playWithNames({"TreasureOccupy"},0,false)
		end
	end
	-- self.bottom['occupied'..i].effect:getAnimation():playWithNames({"TreasureOccupy"},0,false)
end
function refreshChar(self)
	self.challengetimes.txttimes:setString(math.max(0,TDefine.FIGHT_TIMES_PER_DAY - Treasure.fightTimes))
	self.refreshmap.txtrefreshtime:setString(math.max(0,TDefine.REFRESH_MAP_PER_DAY - Treasure.refreshMapTimes).."/"..TDefine.REFRESH_MAP_PER_DAY)
	local mlist = Treasure.getMineList()
	local reward = {}
	for i,m in ipairs(mlist) do
		for _,item in ipairs(m.reward) do 
			if reward[item.itemId] then
				reward[item.itemId] = reward[item.itemId] + item.cnt
			else
				reward[item.itemId] = item.cnt
			end
		end
	end
	local n = 1
	for itemId,cnt in pairs(reward) do 
		local r = self.bottom.reward['r'..n]
		if n <= 8 then
			r:setVisible(true)
			CommonGrid.bind(r.icon)
			r.icon:setItemIcon(itemId,"",23)
			r.num:setString("X"..cnt)
			n = n + 1
		else
			break
		end
	end
	if n < 8 then
		for i=n,8 do
			self.bottom.reward['r'..i]:setVisible(false)
		end 
	end
	if next(reward) ~= nil then
		self.bottom.txtcl:setString("累积总收益:")
	else
		self.bottom.txtcl:setString("暂无收益呢！")
	end

	for i=1,2 do
		local m = mlist[i]
		local o = self.bottom['occupied'..i]
		if m then

			-- db()
			-- if not o.occupied:isVisible() then
			-- 	o.effect:getAnimation():playWithNames({"TreasureOccupy"},0,false)
			-- end
			o.mineId = m.mineId
			o.occupied:setVisible(true)
			o.nooccupied:setVisible(false)
			for r=1,3 do
				if m.rankId == r then
					o.occupied['srankId'..r]:setVisible(true)
				else
					o.occupied['srankId'..r]:setVisible(false)
				end
			end
			if m.safeEndTime >= Master.getServerTime() then
				o.occupied.safeicon:setVisible(true)
			else
				o.occupied.safeicon:setVisible(false)
			end
			
		else
			o.occupied:setVisible(false)
			o.nooccupied:setVisible(true)
		end
	end
end

-- function setFightTimes(self,fightTimes)
-- 	self.challengetimes.txttimes:setString(fightTimes)
-- end 

-- function setRefreshMapTimes(self,refreshMapTimes)
-- 	self.refreshmap.txtrefreshtime:setString(refreshMapTimes)
-- end

function showMineInfo(self,mineInfo)
	-- UIManager.addChildUI("src/modules/treasure/ui/TreasureOccupiedMine",mineInfo)
	if mineInfo.account == Master.getInstance().account then
		UIManager.addChildUI("src/modules/treasure/ui/TreasureOccupiedMine",mineInfo)
	else
		UIManager.addChildUI("src/modules/treasure/ui/TreasureOthersMine",mineInfo)
	end
end

function refreshTimes(self)
	local t = Master.getServerTime()
	local mapFlag = false
	if self.mineList then
		for i,info in ipairs(self.mineList) do
			local m = self.allmines['mine'..i]
			local safeDur = info.safeEndTime - t
			if safeDur > 0 then
				m.safe:setVisible(true)
				m.safe.time:setString(Common.getDCTime(safeDur))
				m.safeEffect:setVisible(true)
			else
				m.safe:setVisible(false)
				m.safeEffect:setVisible(false)
			end
			-- if (self.mineList[i].endTime == 0 or self.mineList[i].endTime >= t) and self.mineList[i].charName ~= "" then
			-- 	Treasure.sendTreasureMapInfo()
			-- end
		end
	end

	local mlist = Treasure.getMineList()
	for i=1,2 do 
		local o = self.bottom['occupied'..i].occupied
		if mlist[i] and o:isVisible() then
			local endTime = mlist[i].endTime
			o.time:setString(Common.getDCTime(endTime - t))
			if endTime - t <= 0 then
				Treasure.sendTreasureChar()
			end
		end
	end
end

-- function onRefreshLeftTimes(self,event,target)
-- 	local fightLeftTimes = Shop.getBuyCntLeft(ShopDefine.K_SHOP_VIRTUAL_TREASUREFIGHT_ID)
-- 	self.challengetimes.txttimes:setString(fightLeftTimes)
-- 	local mapLeftTimes = Shop.getBuyCntLeft(ShopDefine.K_SHOP_VIRTUAL_TREASUREREFRESHMAP_ID)
-- 	self.refreshmap.txtrefreshtime:setString(mapLeftTimes)
-- 	-- local doubleLeftTimes = Shop.getBuyCntLeft(ShopDefine.K_SHOP_VIRTUAL_TREASUREDOUBLE_ID)
-- 	-- self.mineinfo.my.dgroup.txtdouble:setString('剩余'..doubleLeftTimes.."次")
-- 	-- local extendLeftTimes = Shop.getBuyCntLeft(ShopDefine.K_SHOP_VIRTUAL_TREASUREEXTEND_ID)
-- 	-- self.mineinfo.my.ogroup.txtextend:setString("剩余"..extendLeftTimes.."次")
-- end


function refreshData(self)
	local mapInfoTime = Treasure.mapInfoTime
	local mineList = Treasure.mineList
	self.mapInfoTime = mapInfoTime
	self.mineList = mineList
	for i,m in ipairs(mineList) do
		local mine = self.allmines['mine'..i]
		self.allmines['mine'..i].mineicon.mineId = m.mineId
		self.allmines['mine'..i].mineicon.rankId = m.rankId
		self.allmines['mine'..i]:setVisible(true)
		for j=1,3 do 
			if j ~= m.rankId then
				self.allmines['mine'..i].mineicon['rankId'..j]:setVisible(false)
			else
				self.allmines['mine'..i].mineicon['rankId'..j]:setVisible(true)
			end
			if j ~= m.mineType then
				self.allmines['mine'..i].mineicon['mineType'..j]:setVisible(false)
			else
				self.allmines['mine'..i].mineicon['mineType'..j]:setVisible(true)
			end
		end
		if #m.charName > 0 then
			self.allmines['mine'..i].txttitle:setDimensions(self.allmines['mine'..i].txttitle._skin.width,0)
			self.allmines['mine'..i].txttitle:setHorizontalAlignment(Label.Alignment.Center)
			self.allmines['mine'..i].txttitle:setString(m.charName)
		else
			self.allmines['mine'..i].txttitle:setString("")
		end
		self.allmines['mine'..i].safe:setVisible(false)
		if mine.safeEffect == nil then
			mine.safeEffect = ccs.Armature:create('TreasureSafe')
			local size = mine.mineicon:getContentSize()
			local x, y = mine.mineicon:getPosition()
			mine.safeEffect:setPosition(x+size.width/2,y+size.height/2-5)
			mine.safeEffect:setAnchorPoint(0.5,0.5)
			mine._ccnode:addChild(mine.safeEffect)
			mine.safeEffect:setVisible(false)
		end
		if mine.mineEffect == nil then
			mine.mineEffect = ccs.Armature:create('TreasureMine')
			local size = mine.mineicon:getContentSize()
			local x, y = mine.mineicon:getPosition()
			mine.mineEffect:setPosition(x+size.width/2,y+size.height/2-5)
			mine.mineEffect:setAnchorPoint(0.5,0.5)
			mine._ccnode:addChild(mine.mineEffect)
			mine.mineEffect:setVisible(false);
			-- mine.mineEffect:setVisible(true)
			
		end
	end
	-- self:onRefreshLeftTimes()
end

function refreshEffect(self)
	for i=1,TDefine.MINE_NUM_PER_BATCH do
		local mine = self.allmines['mine'..i]
		if mine.mineEffect then
			mine.mineEffect:setVisible(true)
			mine.mineEffect:getAnimation():playWithNames({"TreasureMine"},0,false)
		end
	end
end

function showOccupied(self)

end

function clear(self)
	Control.clear(self)
	Instance = nil
	if self.cdTimer then
		self:delTimer(self.cdTimer)
		self.cdTimer = nil
	end
	Master:getInstance():removeEventListener(Event.MasterRefresh,onMasterRefresh)

	-- Master:getInstance():removeEventListener(Event.ShopCntRefresh,onRefreshLeftTimes)

end




