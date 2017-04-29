module(..., package.seeall)

local Hero = require("src/modules/hero/Hero")
local Weapon = require("src/modules/weapon/Weapon")

local Config = require("src/config/TaskConfig").Config
local Define = require("src/modules/task/TaskDefine")

function setTaskList(taskList)
	print ("setTaskList============")
	Master.getInstance().taskList = taskList
end

function getTaskList(taskWay,day)
	local ret = {}
	taskWay = taskWay or 0
	day = day or 0
	for _,v in pairs(Master.getInstance().taskList) do
		local conf = Config[v.taskId]
		if conf and conf.taskWay == taskWay and day == conf.taskDay then
			table.insert(ret,v)
		end
	end
	return ret
end

function removeTask(taskId)
	local list = Master.getInstance().taskList
	local pos
	for index,v in pairs(list) do
		if v.taskId == taskId then
			pos = index
			break
		end
	end
	if pos then
		table.remove(list,pos)
	end
end

function updateTaskList(taskList)
	print ("updateTaskList============")
	local list = getTaskList()
	for _,v in pairs(taskList) do
		local task = getTaskById(v.taskId)
		if task then
			print("updateTaskList",v.status)
			task.status = v.status
			task.objNum = v.objNum
		else
			list[#list+1] = v
		end
	end
end

function getTaskById(taskId)
	local list = Master.getInstance().taskList
	for _,v in pairs(list) do
		if v.taskId == taskId then
			return v
		end
	end
end

function isFinish(taskId)
	local list = getTaskList()
	for _,v in pairs(list) do
		if v.taskId == taskId then
			return v.status == Define.Status.Finish
		end
	end
end

function isTimeFinish(taskId)
	local list = getTaskList(3,0)
	for _,v in pairs(list) do
		if v.taskId == taskId then
			return v.status == Define.Status.Finish
		end
	end
end

function isTimeConDo(taskId)
	local list = getTaskList(3,0)
	for _,v in pairs(list) do
		if v.taskId == taskId then
			return v.status == Define.Status.CanDo
		end
	end
end

function isTimeConJoin(taskId)
	local list = getTaskList(3,0)
	for _,v in pairs(list) do
		if v.taskId == taskId then
			return v.status == Define.Status.CanJoin
		end
	end
end

function isTimeFailure(taskId)
	local list = getTaskList(3,0)
	for _,v in pairs(list) do
		if v.taskId == taskId then
			return v.status == Define.Status.Failure
		end
	end
end

function isFinishWay(taskId,taskWay,day)
	local list = getTaskList(taskWay,day)
	for _,v in pairs(list) do
		if v.taskId == taskId then
			return v.status == Define.Status.Finish
		end
	end
end

function hasFinishTask()
	local list = getTaskList()
	for _,v in pairs(list) do
		if  v.status == Define.Status.Finish then
			return true
		end
	end
	return false
end

function hasTimeFinishTask()
	local list = getTaskList(3,0)
	for _,v in pairs(list) do
		if  v.status == Define.Status.Finish then
			return true
		end
	end
	return false
end

function hasTimeConJoinTask()
	local list = getTaskList(3,0)
	for _,v in pairs(list) do
		if  v.status == Define.Status.CanJoin then
			return true
		end
	end
	return false
end

function hasShowTimeTask()
	local list = getTaskList(3,0)
	if #list > 0 then 
		return true
	end 
	return false
end

