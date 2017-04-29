module(..., package.seeall)

local TaskUI = require("src/modules/task/ui/TaskUI")
local Logic = require("src/modules/task/TaskLogic")
local Common = require("src/core/utils/Common")
local Define = require("src/modules/task/TaskDefine")

function onGCTaskList(taskList,isUpdate)
	--Common.printR(taskList)
	if isUpdate == 1 then
		Logic.updateTaskList(taskList)
	else
		Logic.setTaskList(taskList)
	end
	local ui = UIManager.getUI("Target")
	if ui then
		ui:refreshTaskList()
		ui:refreshTimeTaskList()
	end
	local mainUI = require("src/modules/master/ui/MainUI").Instance
	if mainUI then
		Dot.check(mainUI.mainBtn1.task,"targetRefresh")
		Dot.check(mainUI.activity,"checkNewOpen")
	end
end

function onGCTaskGet(ret, taskId)
	if ret == Define.ERR_CODE.GetSuccess then
		local NewOpenUI = Stage.currentScene:getUI():getChild("NewOpen")
		if NewOpenUI then 
			NewOpenUI:refreshInfo();
		end
		return
	end
	Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
end

function onGCTaskDel(taskId)
	Logic.removeTask(taskId)
	local ui = UIManager.getUI("Target")
	if ui then
		ui:refreshTaskList()
		ui:refreshTimeTaskList()
	end
	local mainUI = require("src/modules/master/ui/MainUI").Instance
	if mainUI then
		Dot.check(mainUI.mainBtn1.task,"targetRefresh")
		Dot.check(mainUI.activity,"checkNewOpen")
	end
end

function onGCTaskJoin(ret,taskId)
	local ui = UIManager.getUI("Target")
	if ui then
		ui:refreshTimeTaskList()
	end
	Common.showMsg("已接取限时任务！")
end


