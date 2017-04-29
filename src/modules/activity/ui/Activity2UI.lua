module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Def = require("src/modules/activity/ActivityDefine")
local Activity = require('src/modules/activity/Activity')
local ActivityConfig = require("src/config/ActivityConfig").Config
local MonthCardActConfig = require('src/config/MonthCardActivityConfig').Config
local FirstChargeActConfig = require("src/config/FirstChargeActivityConfig").Config
local VipRechargeConfig = require("src/config/VipRechargeConfig").Config
local SingleRechargeConfig = require("src/config/SingleRechargeActivityConfig").Config
local WheelActivityConfig = require("src/config/WheelActivityConfig").Config
local FoundationConfig = require("src/config/FoundationActivityConfig").Config

local ItemConfig = require("src/config/ItemConfig").Config

local VipConfig = require("src/config/VipActivityConfig").Config
local LevelActConfig = require("src/config/LevelActivityConfig").Config
local RechargeConfig = require("src/config/RechargeConfig").Config
local RechargeConstConfig = require("src/config/RechargeConstConfig").Config
local RechargeLogic = require("src/modules/recharge/RechargeLogic")
showAct = 0
function new()
	local ctrl = Control.new(require("res/activity/ActivitySkin"),{"res/activity/Activity.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl	
end

function uiEffect(self)
	return UIManager.FIRST_TEMP
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function refreshActivity(self,activityId)
	self:showActivity(activityId)
	local mainUI = require("src/modules/master/ui/MainUI").Instance
	if mainUI then
		Dot.check(mainUI.mainBtn1.exercise,"activityDot")
	end
	self:addDot()
end

function refreshDot(self)
	local mainUI = require("src/modules/master/ui/MainUI").Instance
	if mainUI then
		Dot.check(mainUI.mainBtn1.exercise,"activityDot")
	end
	self:addDot()
end

function sendReward(self,event,target)
	Activity.sendReward(target.activityId,target.id)
end


-- function showFirstChargeActivity(self)
-- 	self['actpanel'..Def.FIRSTCHARGE_ACT]:setVisible(true)
-- 	local recharge = Master:getInstance().recharge
-- 	if recharge > 0 then
-- 		local status =  Activity.getActivityStatus(Def.FIRSTCHARGE_ACT,1)
-- 		if status == Def.STATUS_REWARDED then
-- 			-- self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setState(Button.UI_BUTTON_DISABLE)
-- 			self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setEnabled(false)
-- 			self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setVisible(false)
-- 			self['actpanel'..Def.FIRSTCHARGE_ACT].txtget:setVisible(true)
-- 		else
-- 			-- self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setState(Button.UI_BUTTON_NORMAL)
-- 			self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setVisible(true)
-- 			self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setEnabled(true)
-- 			self['actpanel'..Def.FIRSTCHARGE_ACT].recharge.txttitle:setString('领取奖励')
-- 			self['actpanel'..Def.FIRSTCHARGE_ACT].txtget:setVisible(false)
-- 		end
-- 	else
-- 		-- self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setState(Button.UI_BUTTON_NORMAL)
-- 		self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setVisible(true)
-- 		self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setEnabled(true)
-- 		self['actpanel'..Def.FIRSTCHARGE_ACT].recharge.txttitle:setString('前往充值')
-- 		self['actpanel'..Def.FIRSTCHARGE_ACT].txtget:setVisible(false)
-- 	end
	
-- 	local reward = FirstChargeActConfig[1].reward
-- 	local no = 1
-- 	for itemId,cnt in pairs(reward) do
-- 		if no <= 4 then
-- 			self['actpanel'..Def.FIRSTCHARGE_ACT]['grid'..no]:setItemIcon(itemId)
-- 			self['actpanel'..Def.FIRSTCHARGE_ACT]['grid'..no]:setItemNum(cnt)
-- 		end
-- 		no = no + 1
-- 	end

-- end


function showActivity(self,activityId)
	showAct = activityId
	for i,item in ipairs(self.actlist.itemContainer) do
		if item.activityId == activityId then
			item.chosen:setVisible(true)
		else
			item.chosen:setVisible(false)
		end
	end
	if self['actpanel'..activityId] == nil then
		self['node'..activityId] = Control.new(require(string.format("res/activity/ActivityPanel%dSkin",activityId)),{string.format("res/activity/ActivityPanel%d.plist",activityId),"res/common/an.plist"})
		

		self['actpanel'..activityId] = self['node'..activityId].panel
		self['actpanel'..activityId].name = 'actpanel'..activityId
		self['actpanel'..activityId]._ccnode:retain()
		self['node'..activityId]:removeChild(self['actpanel'..activityId],false)
		self:addChild(self['actpanel'..activityId])
		self['actpanel'..activityId]._ccnode:release()

		_M['initAct'..activityId](self)
	end
	for i,_ in pairs(Def.ActivityDefineList) do
		if i == activityId and self['actpanel'..i] then
			self['actpanel'..i]:setVisible(true)
		elseif self['actpanel'..i] then
			self['actpanel'..i]:setVisible(false)
		end
	end

	_M['showAct'..activityId](self)
	-- if activityId == Def.FIRSTCHARGE_ACT then
	-- 	self:showFirstChargeActivity()
	-- elseif activityId == Def.MONTHCARD_ACT then
	-- 	self:showMonthCardActivity()
	-- elseif activityId == Def.SINGLERECHARGE_ACT then
	-- 	self:showSingleRecharge()
	-- elseif activityId == Def.FOUNDATION_ACT then
	-- 	self:showFoundation()
	-- elseif activityId == Def.PHYSICS_ACT then
	-- 	self:showPhysicsActivity()
	-- elseif activityId == Def.LEVEL_ACT then
	-- 	self:showLevelActivity()
	-- elseif activityId == Def.ACCU_ACT then
	-- 	self:showAccuActivity()
	-- end
	showAct = activityId
end

function addDot(self)
	for i,item in pairs(self.actlist.itemContainer) do
		Dot.check(item,"activityDot",item.id)
		Dot.setDotAlignment(item,"rBottom",{x=20,y=20})
	end
end



function initAct14(self)

end

-- 首充活动
function initAct4(self)
	for i=1,4 do
		CommonGrid.bind(self['actpanel'..Def.FIRSTCHARGE_ACT]['grid'..i],true)
	end
	local reward = FirstChargeActConfig[1].reward
	local no = 1
	for itemId,cnt in pairs(reward) do
		if no <= 4 then
			self['actpanel'..Def.FIRSTCHARGE_ACT]['grid'..no]:setItemIcon(itemId)
			self['actpanel'..Def.FIRSTCHARGE_ACT]['grid'..no]:setItemNum(cnt)
			if itemId ==1401228 then
				self['actpanel'..Def.FIRSTCHARGE_ACT]['grid'..no]:setGridEffect(2)
			end
		end
		no = no + 1
	end

	local function onCharge(self,event,target)
		local recharge = Master:getInstance().recharge
		if recharge > 0 then
			Activity.sendReward(Def.FIRSTCHARGE_ACT,1)
		else
			Common.showRechargeTips("首次充值有丰厚奖励哦",false)
		end
	end	
	self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:addEventListener(Event.Click,onCharge,self)
end

function showAct4(self)
	self['actpanel'..Def.FIRSTCHARGE_ACT]:setVisible(true)
	local recharge = Master:getInstance().recharge
	if recharge > 0 then
		local status =  Activity.getActivityStatus(Def.FIRSTCHARGE_ACT,1) 
		if status == Def.STATUS_REWARDED then
			-- self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setState(Button.UI_BUTTON_DISABLE)
			self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setEnabled(false)
			self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setVisible(false)
			self['actpanel'..Def.FIRSTCHARGE_ACT].txtget:setVisible(true)
		else
			-- self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setState(Button.UI_BUTTON_NORMAL)
			self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setVisible(true)
			self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setEnabled(true)
			self['actpanel'..Def.FIRSTCHARGE_ACT].recharge.get:setVisible(true)
			self['actpanel'..Def.FIRSTCHARGE_ACT].recharge.charge:setVisible(false)
			self['actpanel'..Def.FIRSTCHARGE_ACT].txtget:setVisible(false)
		end
	else
		-- self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setState(Button.UI_BUTTON_NORMAL)
		self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setVisible(true)
		self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setEnabled(true)
		self['actpanel'..Def.FIRSTCHARGE_ACT].recharge.get:setVisible(false)
		self['actpanel'..Def.FIRSTCHARGE_ACT].recharge.charge:setVisible(true)
		self['actpanel'..Def.FIRSTCHARGE_ACT].txtget:setVisible(false)
	end
end



-- 单笔充值活动
function initAct10(self)
	local panel = self['actpanel'..Def.SINGLERECHARGE_ACT]
	local rewardList = panel.rewardlist
	rewardList:setItemNum(0)
	local stime,etime,s,e = Activity.getActivityPeriod(Def.SINGLERECHARGE_ACT)
	if stime and etime and s and e then
		panel.txttime:setString(string.format("活动时间:%d.%d.%d - %d.%d.%d",s.year,s.month,s.day,e.year,e.month,e.day))
	else
		panel.txttime:setString()
	end

	for i,cfg in ipairs(SingleRechargeConfig) do
		local no = rewardList:addItem()
		local item = rewardList.itemContainer[no]
		item.txtrmb:setString(cfg.min .. "-" .. cfg.max.."元")
		local n = 0
		for itemId,cnt in pairs(cfg.reward) do
			n = n + 1
			if n <= 4 then
				CommonGrid.bind(item['grid'..n],true)
				item['grid'..n]:setItemIcon(itemId)
				item['grid'..n]:setItemNum(cnt)
			end
		end
		item.get:addEventListener(Event.Click,sendReward,self)
		item.get.activityId = Def.SINGLERECHARGE_ACT
		item.get.id= i
	end
	local function onRecharge(self,event,target)
		Common.showRechargeTips("首次充值有丰厚奖励哦",false)
	end
	panel.recharge:addEventListener(Event.Click,onRecharge,self)
	rewardList:setBgVisiable(false)
end

function showAct10(self)
	for i,item in ipairs(self['actpanel'..Def.SINGLERECHARGE_ACT].rewardlist.itemContainer) do
		local status = Activity.getActivityStatus(Def.SINGLERECHARGE_ACT,i)
		if status  == Def.STATUS_REWARDED then
			item.get:setVisible(false)
			item.rewarded:setVisible(true)
		elseif status  == Def.STATUS_NOTCOMPLETED then
			item.get:setVisible(true)
			item.get:setState(Button.UI_BUTTON_DISABLE)
			item.get:setEnabled(false)
			item.rewarded:setVisible(false)
		elseif status  == Def.STATUS_COMPLETED then
			item.get:setVisible(true)
			item.get:setState(Button.UI_BUTTON_NORMAL)
			item.get:setEnabled(true)
			item.get.activityId = Def.SINGLERECHARGE_ACT
			item.get.id= i
			item.rewarded:setVisible(false)
		else
			item.get:setVisible(false)
			item.rewarded:setVisible(false)
		end
	end
end

-- vip特权礼包活动
function initAct13(self)
	local panel = self['actpanel'..Def.VIP_ACT]
	local function onSelectVip(self,event,target)
		local cfg = target.cfg
		panel.cfg = cfg
		for _,item in ipairs(panel.vipList.itemContainer) do
			if item.vipBtn.cfg.vipLv ~= cfg.vipLv then
				item.vipBtn.normalIcon:setVisible(true)
			else
				item.vipBtn.normalIcon:setVisible(false)
			end
		end
		_M['showAct'..Def.VIP_ACT](self)
		panel.buyBtn.cfg = cfg

	end
	local function onBuy(self,event,target)
		local cfg = target.cfg
		local master = Master.getInstance()
		if master.vipLv >= cfg.vipLv then
			if master.rmb >= cfg.price then
				Network.sendMsg(PacketID.CG_ACTIVITY_VIP_BUY,cfg.id)
			else
				Common.showRechargeTips("钻石不足,是否充值",true)
			end
		else
			Common.showRechargeTips("",false)
		end
	end
	panel.vipList:setBgVisiable(false)
	panel.buyBtn:addEventListener(Event.Click,onBuy,self)
	panel.lvTxt = cc.Label:createWithBMFont("res/common/VipNum.fnt", "0")
	panel.lvTxt:setAnchorPoint(0, 0.5)
	panel.vipLvCon._ccnode:addChild(panel.lvTxt)
	panel.lvTxt:setPositionX(panel.vipLvCon.vipzi:getPositionX() + 40)
	panel.lvTxt:setPositionY(panel.vipLvCon.vipzi:getPositionY() + 5)
	Common.setLabelCenter(panel.buyBtn.txttitle)

	for _,cfg in ipairs(VipConfig) do 
		local no = panel.vipList:addItem()
		local item = panel.vipList:getItemByNum(cfg.vipLv)
		item.vipBtn:addEventListener(Event.Click,onSelectVip,self)
		item.vipBtn.cfg = cfg
		local lvTxt = cc.Label:createWithBMFont("res/common/VipNum.fnt", "0")
		lvTxt:setAnchorPoint(0, 0.5)
		item.vipBtn._ccnode:addChild(lvTxt)
		lvTxt:setPositionX(item.vipBtn.vipzi:getPositionX() + 40)
		lvTxt:setPositionY(item.vipBtn.vipzi:getPositionY() + 5)
		lvTxt:setString(cfg.vipLv)
		if cfg.id== 1 then
			item.vipBtn:dispatchEvent(Event.Click,{etype=Event.Click})
		end
	end
	local stime,etime,s,e = Activity.getActivityPeriod(Def.VIP_ACT)
	if stime and etime and s and e then
		panel.txttime:setString(string.format("活动时间:%d.%d.%d-%d.%d.%d",s.year,s.month,s.day,e.year,e.month,e.day))
	else
		panel.txttime:setString()
	end
end

function showAct13(self)
	local panel = self['actpanel'..Def.VIP_ACT]
	local cfg = panel.cfg
	panel.lvTxt:setString(cfg.vipLv)
	local n = 0
	for itemId,cnt in pairs(cfg.reward) do
		n = n + 1
		if n <= 8 then
			CommonGrid.bind(panel['grid'..n],true)
			panel['grid'..n]:setItemIcon(itemId)
			panel['grid'..n]:setItemNum(cnt)
		end
	end
	panel.txtfixedprice:setString("原价:"..cfg.fixedPrice)
	panel.txtdiscountprice:setString("特价:"..cfg.price)
	local status = Activity.vipGift[cfg.id] or 1
	if status == 1 then
		panel.ygmicon:setVisible(true)
		panel.buyBtn:setVisible(false)
	else
		panel.ygmicon:setVisible(false)
		panel.buyBtn:setVisible(true)
	end
	local master = Master.getInstance()
	if master.vipLv >= cfg.vipLv then
		panel.buyBtn.txttitle:setString("购买")
	else
		panel.buyBtn.txttitle:setString("升级VIP")
	end
end

-- 开服基金活动
function initAct11(self)
	local panel = self['actpanel'..Def.FOUNDATION_ACT]
	panel.txtrmb:setString(ActivityConfig[Def.FOUNDATION_ACT].args.fundInvest)
	local function onBuy(self,event,target)
		if Activity.foundationBuy == 0 then
			if Master.getInstance().rmb < ActivityConfig[Def.FOUNDATION_ACT].args.fundInvest then
				Common.showRechargeTips("钻石不足 是否充值?",true)
			else
				Activity.sendFoundationBuy()
			end
		end
	end
	panel.buy:addEventListener(Event.Click,onBuy,self)
	for i,cfg in ipairs(FoundationConfig) do
		local no = panel.fundlist:addItem()
		local item = panel.fundlist.itemContainer[no]
		item.txtintro:setString("达到"..cfg.lv.."级即可领取")
		if Master.getInstance().lv < cfg.lv then
			item.txtintro:setColor(255,0,0)
		end
		local diamond = 0
		local diamondItemId
		for id,cnt in pairs(cfg.reward) do
			diamond = diamond + cnt
			diamondItemId = id
		end
		item.txtdiamond:setString(diamond.."钻石")
		item.get:addEventListener(Event.Click,sendReward,self)
		item.get.activityId = Def.FOUNDATION_ACT
		item.get.id = i
		CommonGrid.bind(item.grid)
		item.grid:setItemIcon(diamondItemId)
		item.grid:setItemNum(diamond)
	end
	local master = Master.getInstance()
	panel.gm1.txtlimitvip:setString("vip"..ActivityConfig[Def.FOUNDATION_ACT].args.fundVipLv)
	panel.fundlist:setBgVisiable(false)
end

function showAct11(self)
	local panel = self['actpanel'..Def.FOUNDATION_ACT]
	local rewardRmb,remainRmb = Activity.getFoundationRmb()
	panel.gm2.txt1:setString("已领取:"..rewardRmb.."钻石")
	panel.gm2.txt2:setString("还可领取:"..remainRmb.."钻石")
	if Activity.foundationBuy == 1 then
		panel.bought:setVisible(true)
		panel.buy:setVisible(false)
		panel.gm1:setVisible(false)
		panel.gm2:setVisible(true)
	else
		panel.bought:setVisible(false)
		panel.buy:setVisible(true)
		panel.gm1:setVisible(true)
		panel.gm2:setVisible(false)
	end

	for i,item in ipairs(self['actpanel'..Def.FOUNDATION_ACT].fundlist.itemContainer) do
		local status = Activity.getActivityStatus(Def.FOUNDATION_ACT,i)
		if Activity.foundationBuy ~= 1 then
			status = Def.STATUS_NOTCOMPLETED
		end
		if status  == Def.STATUS_REWARDED then
			item.get:setVisible(false)
			item.rewarded:setVisible(true)
		elseif status  == Def.STATUS_NOTCOMPLETED then
			item.get:setVisible(true)
			item.get:setState(Button.UI_BUTTON_DISABLE)
			item.get:setEnabled(false)
			item.rewarded:setVisible(false)
		elseif status  == Def.STATUS_COMPLETED then
			item.get:setVisible(true)
			item.get:setState(Button.UI_BUTTON_NORMAL)
			item.get:setEnabled(true)
			item.get.activityId = Def.FOUNDATION_ACT
			item.get.id= i
			item.rewarded:setVisible(false)
		else
			item.get:setVisible(false)
			item.rewarded:setVisible(false)
		end
	end
	local master = Master.getInstance()
	panel.gm1.txtcurvip:setString("vip"..master.vipLv)
end



-- 月卡活动
function initAct9(self)
	local panel = self['actpanel'..Def.MONTHCARD_ACT]
	local function onBuy(self,event,target)
		if event.etype == Event.Touch_began or event.etype == Event.Touch_moved or event.etype == Event.Touch_out then
			local monthCard = target.monthCard
			if panel['monthcard'..monthCard].buy.txttitle:getString() == "今日已领取" then
				panel['monthcard'..monthCard].buy:setState(Button.UI_BUTTON_DISABLE)
			else
				panel['monthcard'..monthCard].buy:setState(Button.UI_BUTTON_NORMAL)
			end
		elseif event.etype == Event.Touch_ended then
			local a= Activity.monthCardInfo
			local monthCard = target.monthCard
			if Activity.monthCardInfo[monthCard] == nil or Activity.monthCardInfo[monthCard].monthCardEndDay == nil or Activity.monthCardInfo[monthCard].monthCardEndDay == 0 or Activity.monthCardInfo[monthCard].lastReceiveTime > Activity.monthCardInfo[monthCard].monthCardEndDay then
				local cfg = VipRechargeConfig[Def.MONTHCARD_RECHARGE_ID[monthCard]]
				--local waitUI = WaittingUI.create(-1,10)
				local master = Master.getInstance()
				local payInfo = {}
				--payInfo.serverId = master.svrName 
				payInfo.roleId = master.pAccount
				payInfo.name = master.name
				payInfo.productId = cfg.id
				payInfo.extra = ""
				UserSDK.charge(cfg.name,cfg.cash*100,1,payInfo)
				--Network.sendMsg(PacketID.CG_ACTIVITY_MONTHCARDBUY,activityId,id)
			else
				if panel['monthcard'..monthCard].buy.txttitle:getString() == "今日已领取" then
					panel['monthcard'..monthCard].buy:setState(Button.UI_BUTTON_DISABLE)
				else
					panel['monthcard'..monthCard].buy:setState(Button.UI_BUTTON_NORMAL)
				end
				if Activity.monthCardInfo[monthCard].lastReceiveTime <= Common.GetTodayTime() then
					Network.sendMsg(PacketID.CG_ACTIVITY_MONTHCARD_RECEIVE,target.monthCard)
				end
			end
		end
	end
	_M['showAct'..Def.MONTHCARD_ACT](self)
	for i=1,2 do
		local buyBtn = self['actpanel'..Def.MONTHCARD_ACT]['monthcard'..i].buy
		buyBtn.monthCard = i
		buyBtn.txttitle:setDimensions(buyBtn.txttitle._skin.width,0)
		buyBtn.txttitle:setHorizontalAlignment(Label.Alignment.Center)
		buyBtn:addEventListener(Event.TouchEvent,onBuy,self)
	end
	-- self['actpanel'..Def.MONTHCARD_ACT].monthcard2.buy.monthCard = 2
	-- Common.setLabelCenter(self['actpanel'..Def.MONTHCARD_ACT].monthcard2.buy.txttitle)
	-- self['actpanel'..Def.MONTHCARD_ACT].monthcard2.buy:addEventListener(Event.Click,onBuy,self)
end
function refreshMonthCardInfo(self)
	for i=1,2 do
		if Activity.monthCardInfo[i] == nil or Activity.monthCardInfo[i].monthCardEndDay == nil or Activity.monthCardInfo[i].monthCardEndDay == 0 then
			self['actpanel'..Def.MONTHCARD_ACT]['monthcard'..i].txttime:setString("持续赠送30天")
		else
			local days = (Activity.monthCardInfo.monthCardEndDay - Activity.monthCardInfo.monthCardRewardDay)/24/3600
			self['actpanel'..Def.MONTHCARD_ACT]['monthcard'..i].txttime:setString("还可以领取"..days.."天")
		end
	end
end

function showAct9(self)
	-- local cfg = VipRechargeConfig[Def.MONTHCARD_RECHARGE_ID]
	-- self['actpanel'..Def.MONTHCARD_ACT].rmb:setString(cfg.dayRmb)
	-- self['actpanel'..Def.MONTHCARD_ACT].price:setString(cfg.cash.."元")
	-- self['actpanel'..Def.MONTHCARD_ACT].txtad1:setString("购买即送"..cfg.rmb.."钻")
	local panel = self['actpanel'..Def.MONTHCARD_ACT]
	for i=1,2 do
		local a = Activity
		local info = Activity.monthCardInfo[i]
		if info == nil or info.monthCardEndDay == nil or info.monthCardEndDay == 0 or info.lastReceiveTime >= info.monthCardEndDay then
			panel['monthcard'..i].txttime:setString("持续赠送30天")
			panel['monthcard'..i].buy.txttitle:setString("购买")
			panel['monthcard'..i].buy:setState(Button.UI_BUTTON_NORMAL)
			-- panel['monthcard'..i].buy:setEnabled(true)
		else
			local rt = Activity.monthCardInfo[i].lastReceiveTime
			if rt < Common.GetTodayTime() then
				rt = Common.GetTodayTime()
			end
			local days = (Activity.monthCardInfo[i].monthCardEndDay - rt)/24/3600
			if Activity.monthCardInfo[i].lastReceiveTime > Common.GetTodayTime() then
				panel['monthcard'..i].buy.txttitle:setString("今日已领取")
				panel['monthcard'..i].buy:setState(Button.UI_BUTTON_DISABLE)
				-- panel['monthcard'..i].buy:setEnabled(false)
			else
				panel['monthcard'..i].buy.txttitle:setString("领取")
				panel['monthcard'..i].buy:setState(Button.UI_BUTTON_NORMAL)
				-- panel['monthcard'..i].buy:setEnabled(true)
			end
				
			panel['monthcard'..i].txttime:setString("还可以领取"..days.."天")
		end
	end

end

-- 体力大餐
function initAct3(self)
	local function onPhysics(self,event,target)
		Activity.sendReward(Def.PHYSICS_ACT)
	end
	self['actpanel'..Def.PHYSICS_ACT].receive:addEventListener(Event.Click,onPhysics,self)

end
function hidePhysicButton(self)
	self['actpanel'..Def.PHYSICS_ACT].receive:setVisible(false)
	self['actpanel'..Def.PHYSICS_ACT].txtrewarded:setVisible(true)
end
function showAct3(self)
	local panel = self['actpanel'..Def.PHYSICS_ACT]
	local function getPeriod()
		local t = Master.getServerTime()
		local pno = 1
		for i,p in ipairs(Def.PHYSICS_PERIODS) do
			if t <= Common.getTimeByStr(p.etime) then
				pno = i
				break
			end
		end
		return pno
	end
	panel:setVisible(true)
	panel.txtrewarded:setVisible(false)
	panel.receive:setVisible(true)
	local p = getPeriod()
	for i=1,3 do
		if i== p then
			panel['tlc'..i]:setVisible(true)
			panel['skillNameLabel'..i]:setVisible(true)
		else
			panel['tlc'..i]:setVisible(false)
			panel['skillNameLabel'..i]:setVisible(false)
		end
	end

end


function getShowItem(self,actId,cnt)
	local no = 1
	for i=1,cnt do
		if Activity.getActivityStatus(actId,i)  == Def.STATUS_COMPLETED then
			no = i
			break
		end
	end
	if no > 1 then
		no = no -1
	end
	return no
end
function addItemByFrame(self,event,target)
	if self['actpanel'..Def.LEVEL_ACT] and self.levelItemNoForFrame <= #LevelActConfig then
		self:addLevelActivityItem(self.levelItemNoForFrame)
		self.levelItemNoForFrame = self.levelItemNoForFrame + 1
	elseif self['actpanel'..Def.LEVEL_ACT] and self.levelJumpFlag == false then
		self.levelJumpFlag = true
		local no = self:getShowItem(Def.LEVEL_ACT,#LevelActConfig)
		self['actpanel'..Def.LEVEL_ACT].levellist:showTopItem(no,true)
	end
end
function addLevelActivityItem(self,i)
	local no = self['actpanel'..Def.LEVEL_ACT].levellist:addItem()
	local item = self['actpanel'..Def.LEVEL_ACT].levellist.itemContainer[no]
	local lv = LevelActConfig[i].lv
	item.lv.lvnum:setVisible(false)
	local lvnum = cc.LabelBMFont:create("",  "res/common/lvnumsmall.fnt")
	lvnum:setString(tostring(lv))
	lvnum:setAnchorPoint(0,0)
	item.lv._ccnode:addChild(lvnum)
	lvnum:setPosition(item.lv.lvnum:getPosition())
	local reward = LevelActConfig[i].reward
	for j=1,6 do
		CommonGrid.bind(item['grid'..j],true)
		item['grid'..j]:setItemIcon()
	end
	local n = 0
	for itemId,cnt in pairs(reward) do
		n = n + 1
		if n <= 6 then
			item['grid'..n]:setItemIcon(itemId)
			item['grid'..n]:setItemNum(cnt)
		end
	end
	if Activity.getActivityStatus(Def.LEVEL_ACT,i) == Def.STATUS_REWARDED then
		item.get:setVisible(false)
		item.rewarded:setVisible(true)
		item.uncompleted:setVisible(false)
	elseif Activity.getActivityStatus(Def.LEVEL_ACT,i)  == Def.STATUS_NOTCOMPLETED then
		item.get:setVisible(false)
		item.rewarded:setVisible(false)
		item.uncompleted:setVisible(true)
	elseif Activity.getActivityStatus(Def.LEVEL_ACT,i)  == Def.STATUS_COMPLETED then
		item.get:setVisible(true)
		item.get.activityId = Def.LEVEL_ACT
		item.get.id= i
		item.get:addEventListener(Event.Click,sendReward,self)
		item.rewarded:setVisible(false)
		item.uncompleted:setVisible(false)
	else
		item.get:setVisible(false)
		item.rewarded:setVisible(false)
		item.uncompleted:setVisible(true)
	end
end

function initAct2(self)
	local panel = self['actpanel'..Def.LEVEL_ACT]
	panel.levellist:setItemNum(0)
	panel.levellist:setDirection(List.UI_LIST_VERTICAL)
	panel.levellist:setBgVisiable(false)
	self.levelJumpFlag = false
	self.levelItemNoForFrame = 1
end

function showAct2(self)
	-- self:hideActivity()
	local panel = self['actpanel'..Def.LEVEL_ACT]
	panel:setVisible(true)
	-- panel.levellist:setItemNum(0)
	-- panel.levellist:setDirection(List.UI_LIST_VERTICAL)
	-- panel.levellist:setBgVisiable(false)

	-- self.levelJumpFlag = false
	-- self.levelItemNoForFrame = 1
	for i,item in ipairs(panel.levellist.itemContainer) do
		if Activity.getActivityStatus(Def.LEVEL_ACT,i) == Def.STATUS_REWARDED then
			item.get:setVisible(false)
			item.rewarded:setVisible(true)
			item.uncompleted:setVisible(false)
		elseif Activity.getActivityStatus(Def.LEVEL_ACT,i)  == Def.STATUS_NOTCOMPLETED then
			item.get:setVisible(false)
			item.rewarded:setVisible(false)
			item.uncompleted:setVisible(true)
		elseif Activity.getActivityStatus(Def.LEVEL_ACT,i)  == Def.STATUS_COMPLETED then
			item.get:setVisible(true)
			item.rewarded:setVisible(false)
			item.uncompleted:setVisible(false)
		else
			item.get:setVisible(false)
			item.rewarded:setVisible(false)
			item.uncompleted:setVisible(true)
		end
	end
	-- for i=1,#LevelActConfig do 
	-- 	local no = self['actpanel'..Def.LEVEL_ACT].levellist:addItem()
	-- 	local item = self['actpanel'..Def.LEVEL_ACT].levellist.itemContainer[no]
	-- 	local lv = LevelActConfig[i].lv
	-- 	item.lv.lvnum:setVisible(false)
	-- 	local lvnum = cc.LabelBMFont:create("",  "res/common/lvnumsmall.fnt")
	-- 	lvnum:setString(tostring(lv))
	-- 	lvnum:setAnchorPoint(0,0)
	-- 	item.lv._ccnode:addChild(lvnum)
	-- 	lvnum:setPosition(item.lv.lvnum:getPosition())
	-- 	--item.txtsmm:setString('达到'..lv..'级')
	-- 	local reward = LevelActConfig[i].reward
	-- 	for j=1,6 do
	-- 		CommonGrid.bind(item['grid'..j],true)
	-- 		item['grid'..j]:setItemIcon()
	-- 	end
	-- 	local n = 0
	-- 	for itemId,cnt in pairs(reward) do
	-- 		n = n + 1
	-- 		if n <= 6 then
	-- 			item['grid'..n]:setItemIcon(itemId)
	-- 			item['grid'..n]:setItemNum(cnt)
	-- 		end
	-- 	end
	-- 	if Activity.getActivityStatus(Def.LEVEL_ACT,i) == Def.STATUS_REWARDED then
	-- 		item.get:setVisible(false)
	-- 		item.txtlevelget:setString("已领取")
	-- 	elseif Activity.getActivityStatus(Def.LEVEL_ACT,i)  == Def.STATUS_NOTCOMPLETED then
	-- 		item.get:setVisible(false)
	-- 		item.txtlevelget:setString("未达成")
	-- 	elseif Activity.getActivityStatus(Def.LEVEL_ACT,i)  == Def.STATUS_COMPLETED then
	-- 		item.get:setVisible(true)
	-- 		item.get.activityId = Def.LEVEL_ACT
	-- 		item.get.id= i
	-- 		item.get:addEventListener(Event.Click,sendReward,self)
	-- 	else
	-- 		item.get:setVisible(false)
	-- 		item.txtlevelget:setString("未达成")
	-- 	end
	-- end
end

function initAct14(self)


end

function showAct14(self)
	self['actpanel'..Def.ACCU_ACT]:setVisible(true)
	local list = self['actpanel'..Def.ACCU_ACT].duihuanlist
	list:setBgVisiable(false)
	local row = #RechargeConfig
	list:setItemNum(row)
	for i = 1,row do
		local ctrl = list:getItemByNum(i)
		local data = RechargeConfig[i]
		local j = 0
		for k,v in pairs(data.item) do
			j = j + 1
			CommonGrid.bind(ctrl["grid"..j].bg,"tips")
			ctrl["grid"..j].bg:setItemIcon(k)
			ctrl["grid"..j].bg:setItemNum(v)
		end
		for n = j+1,5 do
			ctrl["grid"..n].bg:setVisible(false)
		end
		ctrl.recharge:setVisible(false)
		ctrl.get:setVisible(false)
		ctrl.txtuncompleted:setVisible(false)
		ctrl.txtrewarded:setVisible(false)
		ctrl.get.id = data.id
		function onGet(self,event,target)
			Network.sendMsg(PacketID.CG_RECHARGE_GET,target.id)
		end
		function onOpen(self,event,target)
			local ui = UIManager.addUI("src/modules/vip/ui/VipUI")
			ui:showRecharge()
		end
		ctrl.get:addEventListener(Event.Click,onGet,self)
		ctrl.recharge:addEventListener(Event.Click,onOpen,self)
	end
	Network.sendMsg(PacketID.CG_RECHARGE_QUERY)
	function refreshAccuActTime(self,event,target)
		local getEndTime = RechargeLogic.getEndTime
		-- print("getEndTime::"..getEndTime)
		-- print("os.time()::"..os.time())
		if getEndTime > os.time() then
			local t = getEndTime - os.time()
			local d,h,m,s = Common.getDHMSByTime(t)
			self['actpanel'..Def.ACCU_ACT].txthdsj:setString(string.format("距离活动结束：\n%d天%d小时%d分%d秒",d,h,m,s))
		else
			if self.accuTimer then
				self:delTimer(self.accuTimer)
			end
		end
	end
	self.accuTimer = self:addTimer(refreshAccuActTime,1,-1,self)
	refreshAccuActTime(self)
end

function refreshAccuActInfo(self,num,status)
	local list = self['actpanel'..Def.ACCU_ACT].duihuanlist
	for i = 1,#status do
		local ctrl = list:getItemByNum(i)
		local data = RechargeConfig[i]
		local num1 = math.max(0,data.recharge - num)
		ctrl.zcz:setString(string.format("再充值%d元可领取",num1))
		local state = status[i].state
		if state == 1 then
			ctrl.recharge:setVisible(true)
			ctrl.get:setVisible(false)
			ctrl.txtrewarded:setVisible(false)
		elseif state == 2 then
			ctrl.recharge:setVisible(false)
			ctrl.get:setVisible(true)
			ctrl.txtrewarded:setVisible(false)
		elseif state == 3 then
			ctrl.recharge:setVisible(false)
			ctrl.get:setVisible(false)
			ctrl.txtrewarded:setVisible(true)
		end
	end
end

-- 转轮活动
function initAct12(self)
	local panel = self['actpanel'..Def.WHEEL_ACT]
	local stime,stimeTable = Common.getTimeByString(ActivityConfig[Def.WHEEL_ACT].startTime)
	local etime,etimeTable = Common.getTimeByString(ActivityConfig[Def.WHEEL_ACT].endTime)
	panel.txttime:setString(string.format("活动时间:%d.%d.%d - %d.%d.%d",stimeTable.year,stimeTable.month,stimeTable.day,etimeTable.year,etimeTable.month,etimeTable.day))
	panel.cizi:setVisible(false)
	--panel.rmbLabel:setColor(245, 177, 51)
	panel.rmbLabel:setColor(159, 230, 35)
	panel.rmbLabel:setString("50/次")

	for i,cfg in ipairs(WheelActivityConfig) do
		local grid = panel.daoju['' .. i].cjiconbg
		if grid then
			local id, cnt = next(cfg.reward) 
			CommonGrid.bind(grid, true)
			grid:setItemIcon(id, nil, 54) 
			--grid:setItemIconBySize(id, 48)
			grid:setItemNum(cnt)
		end
	end

	panel.choujiang:addEventListener(Event.Click,function()   
		Network.sendMsg(PacketID.CG_WHEEL_OPEN)
		self:initWheelFx()
		end,self)
	Network.sendMsg(PacketID.CG_WHEEL_QUERY)
end

function showAct12(self)

end

function initWheelFx(self)
	local panel = self['actpanel'..Def.WHEEL_ACT]
	if not panel.wheelfx then
		self:addArmatureFrame("res/activity/Wheel.ExportJson")
		local bone = ccs.Armature:create("Wheel")
		local skin = panel.caibg:getSkin()
		bone:setAnchorPoint(0.5,0.5)
		bone:setPosition(skin.width / 2,skin.height / 2)
		bone:getAnimation():play("转盘光",-1,1)
		panel.caibg._ccnode:addChild(bone)
		panel.wheelfx = bone
		panel.wheelfx:setVisible(false)
	end
end

function showWheelRun(self, id)
	self:initWheelFx()
	local panel = self['actpanel'..Def.WHEEL_ACT]
	panel.jiantou:setAnchorPoint(0.5,0)
	local skin = panel.jiantou:getSkin()
	panel.jiantou:setPositionX(skin.x + skin.width / 2)
	panel.wheelfx:setVisible(true)

	local rot = panel.jiantou:getRotation() % 360
	local r = (id - 1) / 8 * 360 
	if r > rot then
		r = r - rot
	else
		r = r + 360 - rot
	end
	local t = math.random(2,5)
	local ary = {}
	local rotate = cc.RotateBy:create(t, r + 360 * t)
	local sine = cc.EaseSineOut:create(rotate)
	table.insert(ary, sine)

	local rare = WheelActivityConfig[id].rare
	table.insert(ary, cc.CallFunc:create(function()
		panel.wheelfx:setVisible(false)
		if rare == 1 then 
			local grid = panel.daoju['' .. id].cjiconbg
			if not grid.hitfx then
				local bone = ccs.Armature:create("Wheel")
				local skin = grid:getSkin()
				bone:setAnchorPoint(0.5,0.5)
				bone:setPosition(skin.width / 2,skin.height / 2 + 10)
				grid.hitfx = bone
				grid._ccnode:addChild(bone)
			end
			grid.hitfx:getAnimation():play("选中奖励",-1,0)
		end
		print("=====> rotation", panel.jiantou:getRotation() % 360, id)
	end))
	if rare == 1 then 
		table.insert(ary, cc.DelayTime:create(1.0))
	end
	table.insert(ary, cc.CallFunc:create(function()
		Network.sendMsg(PacketID.CG_WHEEL_CLOSE)
	end))

	local seq = cc.Sequence:create(ary)
	panel.jiantou:runAction(seq)
end

function showWheelInfo(self, list)
	local panel = self['actpanel'..Def.WHEEL_ACT]
	panel.firstchargetitle:removeAllChildren()
	local skin = panel.firstchargetitle:getSkin()
	for k, v in ipairs(list) do 
		local item = Control.new(skin)
		item.name = item.name .. k
		item:setPosition(0, -(k-1) * 20)
		panel.firstchargetitle:addChild(item)
		item.txtcjxx:setString("")
		local reward = WheelActivityConfig[v.id].reward
		local id, cnt = next(reward) 
		local cfg = ItemConfig[id]
		if cfg then
			local rich = RichText2.new()
			rich:setFontSize(14)
			rich:setString(
			string.format("<font color='0,200,255'>%s</font>抽中了<font color='0,200,255'>%s</font><font color='159,230,35'>*%s</font>",
			v.cname, cfg.name, cnt))
			rich:setPosition(item.txtcjxx._skin.x, item.txtcjxx._skin.y)
			item:addChild(rich)
		end
	end
end

function init(self)
	local function onClose(self,event,target) 
		showAct = 0
		UIManager.removeUI(self)
	end
	self.back:addEventListener(Event.Click,onClose,self)
	-- function onClickRGB(self,event,target)
	-- 	self:showActivity(tonumber(target.name))
	-- end
	-- for _,rb in ipairs(self.activity:getChildren()) do 
	-- 	rb:addEventListener(Event.Click,onClickRGB,self)
	-- end
	-- self.activity[tostring(Def.DAY_ACT)]:dispatchEvent(Event.Click,{etype=Event.Click})
	-- self.activity[tostring(Def.DAY_ACT)]:setSelected(true)

	local function onClick(self,event,target)
		if event.etype == Event.Touch_ended then
			self:showActivity(target.activityId)
		end

	end

	self.actlist:setDirection(List.UI_LIST_HORIZONTAL)
	self.actlist:setBgVisiable(false)



	
	-- self:addDot()
	-- self:initFirstCharge()
	-- self:initMonthCard()
	-- self:initSingleRecharge()
	-- self:initFoundation()
	-- self:initVip()
	-- self:initPhysic()
	-- self:initWheelActivity()
	self.actlist.UI_LIST_BTW_SPACE = 2
	for i,id in ipairs(Def.ActivityListOrder) do
		if Activity.isActivityOpened(id) then
			local no = self.actlist:addItem()
			local item = self.actlist.itemContainer[no]
			item.id = id
			for n,act in ipairs(item:getChildren()) do
				if 'act'..id == act.name then
					act:setVisible(true)
				else
					act:setVisible(false)
				end
			end
			-- item['act'..i]:setVisible(true)
			item.activityId = id
			item:addEventListener(Event.TouchEvent,onClick,self)
			if showAct == 0 then
				showAct = id
			end
			if id == showAct then
				item:dispatchEvent(Event.TouchEvent,{etype=Event.Touch_ended})
			end
		end
	end
	local a= showAct
	self:showActivity(showAct)

	self:openTimer()
	self:addEventListener(Event.Frame,addItemByFrame,self)
	self.levelItemNoForFrame = #LevelActConfig

	self:refreshDot()


	local function onTurnPage(self,event,target)
		if target.name == 'left' then
			self.actlist:turnPage(List.UI_LIST_PAGE_LEFT)
		else
			self.actlist:turnPage(List.UI_LIST_PAGE_RIGHT)
		end
	end
	self.left:addEventListener(Event.Click,onTurnPage,self)
	self.right:addEventListener(Event.Click,onTurnPage,self)

end

function clear(self)
	for i,id in ipairs(Def.ActivityListOrder) do
		if self['node'..id] then
			Control.clear(self['node'..id])
			self['node'..id] = nil
		end
	end
	Control.clear(self)
end
