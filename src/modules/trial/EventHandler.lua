module(...,package.seeall)


local Define = require("src/modules/trial/TrialDefine")
local Logic = require("src/modules/trial/TrialLogic")


--查询
function onGCTrialQuery(list,typeCounter)
	Common.printR(list)
	Logic.setTrial(list,typeCounter)
	local instance = require("src/modules/trial/ui/LevelGateUI").Instance
	if instance then
		instance:setLevelData()
	end
end

function onGCTrialFight(ret,levelId)
	if ret == 0 then
		--允许挑战
		local ui = require("src/modules/trial/ui/FightUI").Instance
		if ui then
			ui:doFight()
		end
	else
		Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
	end
end

--挑战结束
function onGCTrialFightEnd(ret, res ,levelId , entryTime , reward,isChief)
	if isChief == 1 then
		isChief = true
	else
		isChief = false
	end
	UIManager.addUI("src/modules/trial/ui/SettlementUI",res,levelId,entryTime,reward,isChief)
end

--霸主榜单
function onGCTrialRankQuery(list,score)
	local ui = UIManager.getUI("Rank")
	if ui then
		ui:setRankData(list,score)
	end
end

function onGCTrialReset(ret)
	if ret == 0 then
		Logic.reset()
	else
		Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
	end
end




