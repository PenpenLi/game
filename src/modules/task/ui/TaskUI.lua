module(..., package.seeall)
local TargetUI = require("src/ui/TargetUI")
setmetatable(_M, {__index = TargetUI})

local Define = require("src/modules/task/TaskDefine")
local Config = require("src/config/TaskConfig").Config
local Logic = require("src/modules/task/TaskLogic")

local ItemCmd = require("src/modules/bag/ItemCmd")
local VipLogic = require("src/modules/vip/VipLogic")
local VipDefine = require("src/modules/vip/VipDefine")

Instance = nil

function new(skin)
    local ctrl = Control.new(skin)
	ctrl.name = "Task"
    setmetatable(ctrl,{__index = _M})
    ctrl:init()
	Instance = ctrl
    return ctrl
end

function init(self)
	Network.sendMsg(PacketID.CG_TASK_CHECK)
	self:refresh() 

	if Logic:hasTimeConJoinTask() then
		Common.showMsg("新的限时任务可领取")
	end
end

function onGet(self,id,evt)
	Network.sendMsg(PacketID.CG_TASK_GET, id)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_TASK, step = 2})
end

function getDataList(self)
	local list = Logic.getTaskList()
	table.sort(list,function(a,b) 
		if a.status == b.status then
			return a.taskId < b.taskId
		elseif a.status == Define.Status.Finish or b.status == Define.Status.Finish then
			return a.status == Define.Status.Finish
		end
	end)
	return list
end

function refreshList(self)
	if self.dataLen and self.curIndex <= self.dataLen then
		local data = self.dataList[self.curIndex]
		self:refreshItem(data)
		self.curIndex = self.curIndex + 1
	end
end

function refreshItem(self,data)
	local conf = Config[data.taskId]
	if not conf then return end
	local typeConf = Define.TASK_TYPE_CONF[conf.taskType]
	local iData = {}
	iData.iconId = conf.icon
	iData.id = data.taskId
	iData.title = conf.title 
	iData.content = conf.content 
	iData.taskWay = conf.taskWay
	iData.hasFinish = Logic.isFinish(data.taskId)
	if typeConf and typeConf.isTime then
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
		iData.progressStr = string.format("%d/%d",data.objNum,conf.objNum)
	end
	if conf.taskType == Define.TASK_VIP then
		iData.itemNum = VipLogic.getVipAddCount(VipDefine.VIP_CLEAR_TICKET)
	end
	iData.reward = conf.reward
	TargetUI.refreshItem(self,iData)

end

function onGo(self,taskId)
	local conf = Config[taskId]
	for k,v in ipairs(conf.clientCmd) do
		for kk,vv in pairs(v) do
			if ItemCmd[kk] then
				ret = ItemCmd[kk](vv)
			end
		end
	end
end

function clear(self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_TASK})
	Instance = nil
end







