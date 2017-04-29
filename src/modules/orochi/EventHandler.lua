module(...,package.seeall)


local Define = require("src/modules/orochi/OrochiDefine")
local Logic = require("src/modules/orochi/OrochiLogic")
local OrochiConfig = require("src/config/OrochiConfig").Config

--查询
function onGCOrochiQuery(counter,list,isUpdate,curDayLevelId)
	if isUpdate == 1 then
		isUpdate = true
	else
		isUpdate = false
	end
	--Common.printR(list)
	Logic.setOrochiList(list,isUpdate,curDayLevelId)
	Logic.setResetCounter(counter)
	local ui = UIManager.getUI("Orochi")
	if ui then
		ui:setLevelData()
	end
end

function onGCOrochiFight(ret,levelId)
	if ret == 0 then
		--允许挑战
		local ui = require("src/modules/orochi/ui/FightUI").Instance
		if ui then
			ui:doFight()
		end
	else
		Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
	end
end

--挑战结束
function onGCOrochiFightEnd(ret, res ,levelId , entryTime , reward,isChief)
	if isChief == 1 then
		isChief = true
	else
		isChief = false
	end
	UIManager.addUI("src/modules/orochi/ui/SettlementUI",res,levelId,entryTime,reward,isChief)
end

--霸主榜单
function onGCOrochiRankQuery(list)
	local ui = require("src/modules/orochi/ui/OrochiRankUI")
	if ui.Instance then
		ui.Instance:setRankData(list)
	end
end

function onGCOrochiReset()
	local ui = UIManager.getUI("Orochi")
	if ui then
		ui:onBack()
		UIManager.replaceUI("src/modules/orochi/ui/OrochiUI")
		--ui:setLevelData()
	end
end

function onGCOrochiWipe(levelList,rewardList)
	local wipeList = {}
	for k,levelId in ipairs(levelList) do
		local conf = OrochiConfig[levelId]
		wipeList[#wipeList+1] = {
			reward = rewardList[k],
			title = string.format("第%d层 %s",conf.parentId,conf.showName),
		} 
	end
	local ui = UIManager.addChildUI("src/ui/WipeRewardUI")
	ui:addEventListener(Event.Confirm,function() 
		local ui = UIManager.getUI("Orochi")
		if ui then
			ui:onBack()
			UIManager.replaceUI("src/modules/orochi/ui/OrochiUI")
		end
	end)
	ui:refreshReward("大蛇八杰",wipeList)
end









