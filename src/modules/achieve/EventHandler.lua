module(..., package.seeall)

local Logic = require("src/modules/achieve/AchieveLogic")
local Common = require("src/core/utils/Common")
local Define = require("src/modules/achieve/AchieveDefine")

function onGCAchieveList(unfinishList, commitList, finishList)
	Logic.conmposeData(unfinishList, commitList, finishList)
	local achieveUI = Stage.currentScene:getUI():getChild("Target")
	if achieveUI then
		achieveUI:refreshAchieveList()
	end
end

function onGCAchieveGet(ret, id, rewardList)
	if ret == Define.ERR_CODE.GetSuccess then
		Network.sendMsg(PacketID.CG_ACHIEVE_LIST)
	end
end
