module("NewOpenUI",package.seeall)
setmetatable(_M,{__index = Control})
local NewOpenData = require("src/modules/newopen/NewOpenData")
local TaskLogic= require("src/modules/task/TaskLogic")
local NewOpenConfig = require("src/config/NewOpenConfig").Config
local TaskConfig = require("src/config/TaskConfig").Config
local NewOpenConstConfig = require("src/config/NewOpenConstConfig").Config
local TargetUI = require("src/ui/TargetUI")
local TaskUI = require("src/modules/task/ui/TaskUI")
local Define = require("src/modules/task/TaskDefine")

function new()
	local ctrl = Control.new(require("res/newopen/NewOpenSkin.lua"),{"res/newopen/NewOpen.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP_RAW
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function onTimerCB(self,event)
	local timeData = NewOpenData.getTimeData()
	local t = timeData.endTime - os.time()
	if t >= 0 then
		local d,h,m,s = Common.getDHMSByTime(t)
		local str = string.format("距离活动结束：%d天%d小时%d分%d秒",d,h,m,s)
		self.txtAct:setString(str)
	end

	local t = timeData.getEndTime - os.time()
	if t >= 0 then
		local d,h,m,s = Common.getDHMSByTime(t)
		local str = string.format("距离领奖结束：%d天%d小时%d分%d秒",d,h,m,s)
		self.txtGet:setString(str)
	end
end

function setRmb(self)
	local rmb = Master.getInstance().rmb
	self.rmb.artRmb:setString(rmb)
end

function init(self)
	local function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.back:addEventListener(Event.Click,onClose,self)
	CommonGrid.setCoinIcon(self.rmb.zuanshiicon,"rmbbig")
	self.rmb.vipBtn:addEventListener(Event.Click,function(self,event)
		UIManager.addUI("src/modules/vip/ui/VipUI")
	end,self)
	self.rmb.rmbLabel:setVisible(false)
	local rmbLabel = cc.LabelBMFont:create(tostring(0),  "res/master/charLv.fnt")
	rmbLabel:setPositionX(self.rmb.rmbLabel:getPositionX())
	rmbLabel:setPositionY(self.rmb.rmbLabel:getPositionY()+3)
	rmbLabel:setAnchorPoint(1,0.5)
	self.rmb._ccnode:addChild(rmbLabel)
	self.rmb.artRmb = rmbLabel
	setRmb(self)
	Master.getInstance():removeEventListener(Event.MasterRefresh,setRmb)
	Master.getInstance():addEventListener(Event.MasterRefresh,setRmb,self)

	self.discount:adjustTouchBox(0,0,0,-42)
	self.txtAct:setString("")
	self.txtGet:setString("")
	for i = 1,4 do
		CommonGrid.bind(self.welfare.loginRewards["grid"..i],"tips")
		CommonGrid.bind(self.welfare.recharge["grid"..i],"tips")
		CommonGrid.bind(self.discount["grid"..i],"tips")
	end
	self.welfare.recharge.gorecharge:addEventListener(Event.Click,function(self,event) 
		UIManager.addUI("src/modules/vip/ui/VipUI")
	end,self)
	self.welfare.recharge.get:addEventListener(Event.Click,function(self,event)
		Network.sendMsg(PacketID.CG_NEW_RECHARGE_GET,self.selectDay)
	end,self)
	self.welfare.loginRewards.get:addEventListener(Event.Click,function(self,event)
		Network.sendMsg(PacketID.CG_NEW_LOGIN_GET,self.selectDay)
	end,self)
	self.discount.buy:addEventListener(Event.Click,function(self,event)
		Network.sendMsg(PacketID.CG_NEW_DISCOUNT_BUY,self.selectDay)
	end,self)
	self:openTimer()
	self.cdTimer = self:addTimer(onTimerCB,1,-1,self)
	onTimerCB(self)

	self.selectDay = 1
	self.selectBtn = 1
	self.isFirst = true
	for i = 1,4 do
		self.btnTag["tag"..i]:addEventListener(Event.Click,onSelectOption,self)
		self.btnTag["tag"..i].id = i
	end
	self.btnTag["tag1"]:dispatchEvent(Event.Click,{etype=Event.Click})
	self.btnTag["tag1"]:setSelected(true)
	for i = 1,7 do
		self.dayTag["day"..i]:addEventListener(Event.Click,onSelectDay,self)
		self.dayTag["day"..i].id = i
	end
	self.dayTag["day1"]:dispatchEvent(Event.Click,{etype=Event.Click})
	self.dayTag["day1"]:setSelected(true)
	self.discount.ysxicon:setVisible(false)
	Network.sendMsg(PacketID.CG_NEW_OPEN_QUERY)
	WaittingUI.create(PacketID.GC_NEW_OPEN_QUERY)
	self.task.nullText:setVisible(false);
end

local tag2name = {
	[1] = "welfare",
	[2] = "task",
	[3] = "task",
	[4] = "discount",
}
local tag2func = {
	[1] = "refreshWelfare",
	[2] = "refreshTask",
	[3] = "refreshRestTask",
	[4] = "refreshDiscount",
}
function onSelectOption(self,event,target)
	self.selectBtn = target.id
	self.discount:setVisible(false)
	self.task:setVisible(false)
	self.welfare:setVisible(false)
	self[tag2name[target.id]]:setVisible(true)
	self[tag2func[target.id]](self)
end

function onSelectDay(self,event,target)
	local data= NewOpenData.getData()
	if target.id > (data.day or 1) then
		Common.showMsg("尚未开放")
		self.dayTag["day"..target.id]:setSelected(false)
		self.dayTag["day"..self.selectDay]:setSelected(true)
	else
		self.selectDay = target.id
		self.btnTag["tag"..self.selectBtn]:dispatchEvent(Event.Click,{etype=Event.Click})
		Dot.check(self.btnTag["tag1"],"checkNewOpenWelfare",self.selectDay)
		Dot.check(self.btnTag["tag2"],"checkNewOpenTask",self.selectDay)
		Dot.check(self.btnTag["tag3"],"checkNewOpenRestTask",self.selectDay)
		Dot.check(self.btnTag["tag4"],"checkNewOpenDiscount",self.selectDay)
	end
end

function refreshInfo(self)
	if self.isFirst then
		local data= NewOpenData.getData()
		local day = data.day <= 7 and data.day or 7
		self.dayTag["day"..day]:dispatchEvent(Event.Click,{etype=Event.Click})
		self.dayTag["day1"]:setSelected(false)
		self.dayTag["day"..day]:setSelected(true)
		self.isFirst = false
	else
		self.dayTag["day"..self.selectDay]:dispatchEvent(Event.Click,{etype=Event.Click})
	end
	for i = 1,7 do
		Dot.check(self.dayTag["day"..i],"checkNewOpenDay",i)
	end
end

function refreshWelfare(self)
	print("refreshWelfare")
	print(self.selectDay)
	self.welfare.loginRewards.txtjrdl:setString("今日赠送")
	local cfg = NewOpenConfig[self.selectDay]
	local i = 1
	for k,v in pairs(cfg.loginReward) do
		self.welfare.loginRewards["grid"..i]:setItemIcon(k)
		self.welfare.loginRewards["grid"..i]:setItemNum(v)
		i = i + 1
		if i > 4 then
			break
		end
	end
	for a = i,4 do
		self.welfare.loginRewards["grid"..a]:setItemIcon()
		self.welfare.loginRewards["grid"..a]:setItemNum(0)
	end
	local j = 1
	for k,v in pairs(cfg.rechargeReward) do
		self.welfare.recharge["grid"..j]:setItemIcon(k)
		self.welfare.recharge["grid"..j]:setItemNum(v)
		j = j + 1
		if j > 4 then
			break
		end
	end
	for a = j,4 do
		self.welfare.recharge["grid"..a]:setItemIcon()
		self.welfare.recharge["grid"..a]:setItemNum(0)
	end
	local data = NewOpenData.getData()
	if data.rewards then
		local rewards = data.rewards[self.selectDay]
		if rewards.loginGet == 0 then
			self.welfare.loginRewards.get:setVisible(true)
			self.welfare.loginRewards.txtrewarded:setVisible(false)
			self.welfare.loginRewards.get:setState(Button.UI_BUTTON_DISABLE)
			self.welfare.loginRewards.get.touchEnabled = false
		elseif rewards.loginGet == 1 then
			self.welfare.loginRewards.get:setVisible(true)
			self.welfare.loginRewards.txtrewarded:setVisible(false)
			self.welfare.loginRewards.get:setState(Button.UI_BUTTON_NORMAL)
			self.welfare.loginRewards.get.touchEnabled = true
		elseif rewards.loginGet == 2 then
			self.welfare.loginRewards.get:setVisible(false)
			self.welfare.loginRewards.txtrewarded:setVisible(true)
		end
		if rewards.rechargeNum >= cfg.rechargeNum then
			self.welfare.recharge.gorecharge:setVisible(false)
			if rewards.rechargeGet == 0 then
				self.welfare.recharge.get:setVisible(true)
				self.welfare.recharge.txtrewarded:setVisible(false)
			elseif rewards.rechargeGet == 1 then
				self.welfare.recharge.get:setVisible(false)
				self.welfare.recharge.txtrewarded:setVisible(true)
			end
		else
			self.welfare.recharge.gorecharge:setVisible(true)
			self.welfare.recharge.txtrewarded:setVisible(false)
		end
		self.welfare.recharge.txtljcz:setString(string.format("累计充值%d元(%d/%d)",cfg.rechargeNum,rewards.rechargeNum,cfg.rechargeNum))
	end
end

function refreshRestTask(self)
	print("refreshRestTask")
	local data = TaskLogic.getTaskList(2,self.selectDay);
	table.sort(data, function(a,b) return a.taskId<b.taskId end )
	
	local list = self.task.zhuxian
	list:removeAllItem()
	local rows = math.ceil(#data)
	list:setItemNum(rows)

	if rows < 1 then
		self.task.zhuxian:setVisible(false);
		self.task.nullText:setVisible(true);
	else 
		self.task.zhuxian:setVisible(true);
		self.task.nullText:setVisible(false);
	end

	for i = 1,rows do
		local conf =  TaskConfig[data[i].taskId]
		local item = list:getItemByNum(i)
		local reward = conf.reward
		local x = 1
		for k,v in pairs(reward) do
			if type(k) == "number" then
				CommonGrid.bind(item["grid"..x],"tips")
				item["grid"..x]:setItemIcon(k)
				item["grid"..x]:setItemNum(v[1])
				x=x+1;
			end
		end
		item.txtljcz:setString(string.format("%s(%d/%d)",conf.content,data[i].objNum,conf.objNum));	
		setItemProgress(self,item,data[i].taskId,TaskLogic.isFinishWay(data[i].taskId,2,self.selectDay));
	end
end

function refreshTask(self)
	print("refreshTask")
	local data = TaskLogic.getTaskList(1,self.selectDay);
	table.sort(data, function(a,b) return a.taskId<b.taskId end )
	Common.printR(data);
	
	local list = self.task.zhuxian
	list:removeAllItem()
	local rows = math.ceil(#data)
	list:setItemNum(rows)

	if rows < 1 then
		self.task.zhuxian:setVisible(false);
		self.task.nullText:setVisible(true);
	else 
		self.task.zhuxian:setVisible(true);
		self.task.nullText:setVisible(false);
	end

	for i = 1,rows do
		local conf =  TaskConfig[data[i].taskId]
		local item = list:getItemByNum(i)
		local reward = conf.reward
		local x = 1
		for k,v in pairs(reward) do
			if type(k) == "number" then
				CommonGrid.bind(item["grid"..x],"tips")
				item["grid"..x]:setItemIcon(k)
				item["grid"..x]:setItemNum(v[1])
				x=x+1;
			end
		end
		item.txtljcz:setString(string.format("%s(%d/%d)",conf.content,data[i].objNum,conf.objNum));	
		setItemProgress(self,item,data[i].taskId,TaskLogic.isFinishWay(data[i].taskId,1,self.selectDay));
	end
end

function setItemProgress(self,item, id , hasFinish)
	--Common.setLabelCenter(item.countTxt)
	print("================setItemProgress",hasFinish)
	if hasFinish then
		item.go:setVisible(false)
		item:addEventListener(Event.TouchEvent, function(self, evt) 
			if evt.etype == Event.Touch_ended then
				TaskUI:onGet(id, evt) 
			end
		end, self)
	else
		if Common.getServerDay() > 7 then
			item.go.skillzi:setString("过期")
			item.go:setState(Button.UI_BUTTON_DISABLE)
			item.go.touchEnabled = false
		end
		item.get:setVisible(false)
		item.go:setVisible(true)
		item.go:addEventListener(Event.TouchEvent, function(self, evt) 
				if evt.etype == Event.Touch_ended then
					TaskUI:onGo(id, evt) 
				end
			end, self)
	end
end

function refreshDiscount(self)
	print("refreshDiscount")
	self.discount.ysxicon:setVisible(false)
	local cfg = NewOpenConfig[self.selectDay]
	local i = 1
	for k,v in pairs(cfg.discount) do
		self.discount["grid"..i]:setItemIcon(k)
		self.discount["grid"..i]:setItemNum(v)
		i = i + 1
		if i > 4 then
			break
		end
	end
	self.discount.oldPriceTxt:setString("原价："..cfg.oldprice)
	self.discount.newPriceTxt:setString("现价："..cfg.newprice)
	local data = NewOpenData.getData()
	if data.rewards then
		local rewards = data.rewards[self.selectDay]
		if rewards.discountGet == 0 then
			self.discount.ygmicon:setVisible(false)
			self.discount.buy:setVisible(true)
			if self.selectDay > data.day then
				self.discount.buy:setState(Button.UI_BUTTON_DISABLE)
				self.discount.buy.touchEnabled = false
			else
				self.discount.buy:setState(Button.UI_BUTTON_NORMAL)
				self.discount.buy.touchEnabled = true
			end
		else
			self.discount.buy:setVisible(false)
			self.discount.ygmicon:setVisible(true)
		end
		self.discount.txtsm:setString(string.format("仅限前%d人购买（剩余%d件）",cfg.limit,math.max(cfg.limit - rewards.discountNum,0)))
		if cfg.limit - rewards.discountNum <= 0 then
			self.discount.ysxicon:setVisible(true)
			self.discount.buy:setVisible(false)
			self.discount.ygmicon:setVisible(false)
		end
	end
end

function clear(self)
	Master.getInstance():removeEventListener(Event.MasterRefresh,setRmb)
	Control.clear(self)
end

return NewOpenUI
