module(..., package.seeall)
local TaskUI = require("src/modules/task/ui/TaskUI")
setmetatable(_M, {__index = TaskUI})

local Define = require("src/modules/task/TaskDefine")
local Config = require("src/config/TaskConfig").Config
local Logic = require("src/modules/task/TaskLogic")
Instance = nil

function new(skin)
    local ctrl = Control.new(skin)
	ctrl.name = "TimeTask"
    setmetatable(ctrl,{__index = _M})
    ctrl:init()
	Instance = ctrl
    return ctrl
end

function init(self)
	self:openTimer()
	self.cdTimer = self:addTimer(onTimerCB,1,-1,self)
end

function onJoin(self,id,evt)
	Network.sendMsg(PacketID.CG_TASK_JOIN, id)
	self:refreshTime()
end

function getDataList(self)
	local list = Logic.getTaskList(3,0)
	--完成←进行中←可接取←已失效	
	table.sort(list,function(a,b) 
		if a.status == b.status then
			return a.taskId < b.taskId
		elseif a.status == Define.Status.Finish or b.status == Define.Status.Finish then
			return a.status == Define.Status.Finish
		elseif a.status == Define.Status.CanDo or b.status == Define.Status.CanDo then
			return a.status == Define.Status.CanDo
		elseif a.status == Define.Status.CanJoin or b.status == Define.Status.CanJoin then
			return a.status == Define.Status.CanJoin
		elseif a.status == Define.Status.Failure or b.status == Define.Status.Failure then
			return a.status == Define.Status.Failure
		end
	end)
	return list
end


function onTimerCB( self,evt )
	for i=1,self.achieveList:getItemCount() do
		local item = self.achieveList:getItemByNum(i)

		if item.time then 
			item.time = item.time - 1
			if item.time < 0 then 
				item.timelimitTxt:setVisible(false)
				item.go:setVisible(false)
				item.get:setVisible(false)
				item.got:setVisible(false)
				item.ysxicon:setVisible(true)
			else
				item.timelimitTxt:setString(string.format("任务限时:%d分%d秒",math.floor(item.time/60),item.time%60))
			end
		end
	end
end


function refreshList(self)
	if self.dataLen and self.curIndex <= self.dataLen then
		local data = self.dataList[self.curIndex]
		self:refreshItem(data)
		self.curIndex = self.curIndex + 1
	end
end

function refreshItem(self,data)
		print ("refreshItem")
		local conf = Config[data.taskId]
		if not conf or conf.taskWay ~= 3 then return end
		local typeConf = Define.TASK_TYPE_CONF[conf.taskType]
		local iData = {}
		local now = os.time()
		iData.iconId = conf.icon
		iData.id = data.taskId
		iData.title = conf.title 
		iData.taskWay = conf.taskWay
		iData.content = conf.content 
		iData.hasFinish = Logic.isTimeFinish(data.taskId)
		iData.hasCanDo = Logic.isTimeConDo(data.taskId)
		iData.hasCanJoin = Logic.isTimeConJoin(data.taskId)
		iData.hasExpired = Logic.isTimeFailure(data.taskId)
		iData.hasOdds = false
		iData.taskSecond = conf.taskSecond
		if iData.hasCanDo and conf.odds == 0 then 
			local int = os.difftime(now,data.time);
			iData.time = conf.taskSecond - int
		end 

		if conf.odds > 0 then
			iData.hasOdds = true
		end
		--[[if typeConf and typeConf.isTime then
			local hour = tonumber(os.date("%H"))
			if hour < conf.param.startH  then
				iData.hasFinish = false
				iData.progressStr = "时间未到"
				if not self.startHour then 
					self.startHour = conf.param.startH
				elseif self.startHour < conf.param.startH then
					return	
				end
			elseif hour >= conf.param.endH then
				return
			end
			iData.canGo = false
		else
			iData.canGo = true
		end]]

		iData.progressStr = string.format("%d/%d",data.objNum,conf.objNum)
		if conf.taskType == Define.TASK_VIP then
			iData.itemNum = VipLogic.getVipAddCount(VipDefine.VIP_CLEAR_TICKET)
		end
		iData.reward = conf.reward
		TaskUI.refreshTimeItem(self,iData)
end

--[[function setItemProgress(self,item, id , hasFinish)
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
]]

function clear(self)
	self:delTimer(self.cdTimer)
end



