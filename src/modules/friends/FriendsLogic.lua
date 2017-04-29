module(...,package.seeall)
local Logic = require("src/modules/task/TaskLogic")
local Announce = require("src/modules/announce/Announce")

function init()
	if not Master.getInstance():hasEventListener(Event.TeamLvUp,isShow) then
		Master.getInstance():addEventListener(Event.TeamLvUp,isShow)
	end
end

function isShow()
	if hasShowTimeTask() then
		local  announce = {}
		announce.content   = "限时任务已开启，完成可获得丰厚奖励！"
		announce.title   = ""
		Announce.show(announce)
	end 
end 

--任务限时监听加到了好友里面
