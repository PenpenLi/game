module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Def = require("src/modules/activity/ActivityDefine")
local Activity = require('src/modules/activity/Activity')
local LoginActConfig = require('src/config/LoginActivityConfig').Config
local LevelActConfig = require("src/config/LevelActivityConfig").Config
local PhysicsActConfig = require("src/config/PhysicsActivityConfig").Config

showAct = 1
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

-- function hideActivity(self)
-- 	self.loginactpanel:setVisible(false)
-- 	self.levelactpanel:setVisible(false)
-- end

function refreshActivity(self,activityId)
	-- local actCnt = #Def.ActivityList
	-- for i=1,actCnt do
	-- 	if self['actpanel'..i]:isVisible() then
	-- 		self:showActivity(i)
	-- 	end
	-- end
	self:showActivity(activityId)
	local mainUI = require("src/modules/master/ui/MainUI").Instance
	if mainUI then
		Dot.check(mainUI.mainBtn1.exercise,"activityDot")
	end
	self:addDot()
	-- if self.activity[tostring(Def.DAY_ACT)]:getSelected() then
	-- 	self:showLoginActivity()
	-- elseif self.activity[tostring(Def.LEVEL_ACT)]:getSelected() then
	-- 	self:showLevelActivity()
	-- end
end
function sendReward(self,event,target)
	Activity.sendReward(target.activityId,target.id)
end

function getShowItem(self,actId,cnt)
	local no = 1
	for i=1,cnt do
		if Activity.getActivityStatus(Def.DAY_ACT,i)  == Def.STATUS_COMPLETED then
			no = i
			break
		end
	end
	if no > 1 then
		no = no -1
	end
	return no
end

function addLoginActivityItem(self,i)
	local no = self['actpanel'..Def.DAY_ACT].loginlist:addItem()
	local item = self['actpanel'..Def.DAY_ACT].loginlist.itemContainer[no]
	hide(item)
	item.days['ts'..i]:setVisible(true)
	local reward =LoginActConfig[i].reward
	for j=1,4 do 
		CommonGrid.bind(item['grid'..j],true)
		item['grid'..j]:setItemIcon()
	end
	local n = 0
	for itemId,cnt in pairs(reward) do
		n = n + 1
		if n <= 4 then
			item['grid'..n]:setItemIcon(itemId)
			item['grid'..n]:setItemNum(cnt)
		end
	end
	local status = Activity.getActivityStatus(Def.DAY_ACT,i)
	if Activity.getActivityStatus(Def.DAY_ACT,i)  == Def.STATUS_REWARDED then
		item.loginget:setVisible(false)
		item.txtrewarded:setVisible(true)
		item.txtuncompleted:setVisible(false)
		-- item.txtget:setString("已领取")
	elseif Activity.getActivityStatus(Def.DAY_ACT,i)  == Def.STATUS_NOTCOMPLETED then
		item.loginget:setVisible(false)
		item.txtrewarded:setVisible(false)
		item.txtuncompleted:setVisible(true)
		-- item.txtget:setString("未达成")
	elseif Activity.getActivityStatus(Def.DAY_ACT,i)  == Def.STATUS_COMPLETED then
		item.loginget:setVisible(true)
		item.loginget.activityId = Def.DAY_ACT
		item.loginget.id= i
		item.loginget:addEventListener(Event.Click,sendReward,self)
		item.txtrewarded:setVisible(false)
		item.txtuncompleted:setVisible(false)
	else
		item.loginget:setVisible(false)
		item.txtrewarded:setVisible(false)
		item.txtuncompleted:setVisible(true)
		-- item.txtget:setString("未达成")
	end
end

function showLoginActivity(self)
	-- self:hideActivity()
	self['actpanel'..Def.DAY_ACT]:setVisible(true)
	function hide(item)
		for i=1,7 do
			item.days['ts'..i]:setVisible(false)
		end
	end
	self['actpanel'..Def.DAY_ACT].loginlist:setItemNum(0)
	self['actpanel'..Def.DAY_ACT].loginlist:setBgVisiable(false)
	self.loginJumpFlag = false
	self.loginItemNoForFrame = 1
	-- for i=1,7 do
	-- 	local no = self['actpanel'..Def.DAY_ACT].loginlist:addItem()
	-- 	local item = self['actpanel'..Def.DAY_ACT].loginlist.itemContainer[no]
	-- 	hide(item)
	-- 	item.days['ts'..i]:setVisible(true)
	-- 	local reward =LoginActConfig[i].reward
	-- 	for j=1,4 do 
	-- 		CommonGrid.bind(item['grid'..j],true)
	-- 		item['grid'..j]:setItemIcon()
	-- 	end
	-- 	local n = 0
	-- 	for itemId,cnt in pairs(reward) do
	-- 		n = n + 1
	-- 		if n <= 4 then
	-- 			item['grid'..n]:setItemIcon(itemId)
	-- 			item['grid'..n]:setItemNum(cnt)
	-- 		end
	-- 	end
	-- 	local status = Activity.getActivityStatus(Def.DAY_ACT,i)
	-- 	if Activity.getActivityStatus(Def.DAY_ACT,i)  == Def.STATUS_REWARDED then
	-- 		item.loginget:setVisible(false)
	-- 		item.txtget:setString("已领取")
	-- 	elseif Activity.getActivityStatus(Def.DAY_ACT,i)  == Def.STATUS_NOTCOMPLETED then
	-- 		item.loginget:setVisible(false)
	-- 		item.txtget:setString("未达成")
	-- 	elseif Activity.getActivityStatus(Def.DAY_ACT,i)  == Def.STATUS_COMPLETED then
	-- 		item.loginget:setVisible(true)
	-- 		item.loginget.activityId = Def.DAY_ACT
	-- 		item.loginget.id= i
	-- 		item.loginget:addEventListener(Event.Click,sendReward,self)
	-- 	else
	-- 		item.loginget:setVisible(false)
	-- 		item.txtget:setString("未达成")
	-- 	end

	-- end
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
		item.txtrewarded:setVisible(true)
		item.txtuncompleted:setVisible(false)
		-- item.txtlevelget:setString("已领取")
	elseif Activity.getActivityStatus(Def.LEVEL_ACT,i)  == Def.STATUS_NOTCOMPLETED then
		item.get:setVisible(false)
		-- item.txtlevelget:setString("未达成")
		item.txtrewarded:setVisible(false)
		item.txtuncompleted:setVisible(true)
	elseif Activity.getActivityStatus(Def.LEVEL_ACT,i)  == Def.STATUS_COMPLETED then
		item.get:setVisible(true)
		item.get.activityId = Def.LEVEL_ACT
		item.get.id= i
		item.get:addEventListener(Event.Click,sendReward,self)
		item.txtrewarded:setVisible(false)
		item.txtuncompleted:setVisible(false)
	else
		item.get:setVisible(false)
		-- item.txtlevelget:setString("未达成")
		item.txtrewarded:setVisible(false)
		item.txtuncompleted:setVisible(true)
	end
end

function addItemByFrame(self,event,target)
	if self.levelItemNoForFrame <= #LevelActConfig then
		print(self.levelItemNoForFrame)
		self:addLevelActivityItem(self.levelItemNoForFrame)
		self.levelItemNoForFrame = self.levelItemNoForFrame + 1
	elseif self.levelJumpFlag == false then
		self.levelJumpFlag = true
		local no = self:getShowItem(Def.LEVEL_ACT,7)
		self['actpanel'..Def.LEVEL_ACT].levellist:showTopItem(no,true)
	end

	if self.loginItemNoForFrame <= 7 then
		self:addLoginActivityItem(self.loginItemNoForFrame)
		self.loginItemNoForFrame = self.loginItemNoForFrame + 1
	elseif self.loginJumpFlag == false then
		self.loginJumpFlag = true
		local no = self:getShowItem(Def.DAY_ACT,7)
		self['actpanel'..Def.DAY_ACT].loginlist:showTopItem(no,true)
	end

end

function showLevelActivity(self)
	-- self:hideActivity()
	self['actpanel'..Def.LEVEL_ACT]:setVisible(true)
	self['actpanel'..Def.LEVEL_ACT].levellist:setItemNum(0)
	self['actpanel'..Def.LEVEL_ACT].levellist:setDirection(List.UI_LIST_VERTICAL)
	self['actpanel'..Def.LEVEL_ACT].levellist:setBgVisiable(false)
	self.levelJumpFlag = false
	self.levelItemNoForFrame = 1
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

function showPhysicsActivity(self)
	self['actpanel'..Def.PHYSICS_ACT]:setVisible(true)
	self['actpanel'..Def.PHYSICS_ACT].txtrewarded:setVisible(false)
	self['actpanel'..Def.PHYSICS_ACT].receive:setVisible(true)
end

function hidePhysicButton(self)
	self['actpanel'..Def.PHYSICS_ACT].receive:setVisible(false)
	self['actpanel'..Def.PHYSICS_ACT].txtrewarded:setVisible(true)
end


function showFirstChargeActivity(self)
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
			self['actpanel'..Def.FIRSTCHARGE_ACT].recharge.txttitle:setString('领取奖励')
			self['actpanel'..Def.FIRSTCHARGE_ACT].txtget:setVisible(false)
		end
	else
		-- self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setState(Button.UI_BUTTON_NORMAL)
		self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setVisible(true)
		self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:setEnabled(true)
		self['actpanel'..Def.FIRSTCHARGE_ACT].recharge.txttitle:setString('前往充值')
		self['actpanel'..Def.FIRSTCHARGE_ACT].txtget:setVisible(false)
	end
	
	local reward = FirstChargeActConfig[1].reward
	local no = 1
	for itemId,cnt in pairs(reward) do
		if no <= 4 then
			self['actpanel'..Def.FIRSTCHARGE_ACT]['grid'..no]:setItemIcon(itemId)
			self['actpanel'..Def.FIRSTCHARGE_ACT]['grid'..no]:setItemNum(cnt)
		end
		no = no + 1
	end

end


function showActivity(self,activityId)
	showAct = activityId
	local actCnt = #Def.ActivityList
	for i,item in ipairs(self.actlist.itemContainer) do
		if activityId == i then
			item.chosen:setVisible(true)
			self['actpanel'..i]:setVisible(true)
			if i == Def.DAY_ACT then
				self:showLoginActivity()
			elseif i == Def.LEVEL_ACT then
				self:showLevelActivity()
			elseif i == Def.PHYSICS_ACT then
				self:showPhysicsActivity()
			elseif i == Def.FIRSTCHARGE_ACT then
				self:showFirstChargeActivity()
			end
		else
			item.chosen:setVisible(false)
			self['actpanel'..i]:setVisible(false)
		end
	end
end

function addDot(self)
	-- db()
	for i,item in pairs(self.actlist.itemContainer) do
		Dot.check(item,"activityDot",i)
		Dot.setDotAlignment(item,"rBottom",{x=20,y=20})
	end
end

function init(self)
	-- self.loginactpanel:setVisible(false)

	local function onClose(self,event,target) 
		showAct = 1
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
	local actCnt = #Def.ActivityList
	for i=1,actCnt do
		local no = self.actlist:addItem()
		local item = self.actlist.itemContainer[no]
		for i=1,10 do
			if item['act'..i] then
				item['act'..i]:setVisible(false)
			end
		end
		for j=1,actCnt do
			if i == j then
				item['act'..j]:setVisible(true)
			else
				item['act'..j]:setVisible(false)
			end
		end
		-- item['act'..i]:setVisible(false)
		item.activityId = i
		item:addEventListener(Event.TouchEvent,onClick,self)
	end

	
	self:addDot()

	-- for i=1,4 do
	-- 	CommonGrid.bind(self['actpanel'..Def.FIRSTCHARGE_ACT]['grid'..i],true)
	-- end


	-- local function onCharge(self,event,target)
	-- 	local recharge = Master:getInstance().recharge
	-- 	if recharge > 0 then
	-- 		Activity.sendReward(Def.FIRSTCHARGE_ACT,1)
	-- 	else
	-- 		Common.showRechargeTips("首次充值有丰厚奖励哦",false)
	-- 	end
	-- end	
	-- self['actpanel'..Def.FIRSTCHARGE_ACT].recharge:addEventListener(Event.Click,onCharge,self)


	local function onPhysics(self,event,target)
		Activity.sendReward(Def.PHYSICS_ACT)
	end
	self['actpanel'..Def.PHYSICS_ACT].receive:addEventListener(Event.Click,onPhysics,self)

	for i=1,10 do
		if self['actpanel'..i] then
			self['actpanel'..i]:setVisible(false)
		end
	end

	self.levelItemNoForFrame = #LevelActConfig
	self.loginItemNoForFrame = 7
	self:openTimer()
	-- self:addTimer(addItemByFrame,0.5,-1)
	self:addEventListener(Event.Frame,addItemByFrame,self)


	self:showActivity(showAct)



	--local function onTurnPage(self,event,target)
	--	if target.name == 'left' then
	--		self.levelactpanel.levellist:turnPage(List.UI_LIST_PAGE_LEFT)
	--	else
	--		self.levelactpanel.levellist:turnPage(List.UI_LIST_PAGE_RIGHT)
	--	end
	--end
	--self.levelactpanel.left:addEventListener(Event.Click,onTurnPage,self)
	--self.levelactpanel.right:addEventListener(Event.Click,onTurnPage,self)
end
