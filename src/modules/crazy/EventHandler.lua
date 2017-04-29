module(...,package.seeall)
local Define = require("src/modules/crazy/Define")
local Data = require("src/modules/crazy/Data")
local CrazyDefine = require("src/config/CrazyDefineConfig").Defined

function onGCCrazyNotify(op)
	if op == Define.CrazyNotify.open then
		Data.setOpen(true)
		if MainUI.Instance and Master:getInstance().lv >= CrazyDefine.level then
			MainUI.Instance:selectPanel("src/modules/crazy/ui/CrazyNotifyUI")
		end
		--Data.setLeftTime(ThermaeDefine.lastTime)
		--Data.startTimer()
	elseif op == Define.CrazyNotify.close then
		--[[
		local ThermaeUI = require("src/modules/crazy/ui/CrazuUI").Instance
		if ThermaeUI then
			--UIManager.removeUI(ThermaeUI)
			ThermaeUI:showReward()
		end
		--]]
		Data.setOpen(false)
		--Data.stopTimer()
	end
end

function onGCCrazyQuery(isOpen,harm,rank,boss)
	for k,v in ipairs(boss) do
		v.isDie = (v.isDie == 1)
	end
	Data.setData(isOpen,harm,rank,boss)
	local CrazyUI = require("src/modules/crazy/ui/CrazyUI").Instance
	if CrazyUI then
		CrazyUI:updateInfo()
	end
end

function onGCCrazyRank(rankList)
end

function onGCCrazyFight()
end

function onCrazySumit()
end

function onGCCrazyCheckTeam(rank, fighting, flowerCount, heroList)
	local rankPanel = require("src/modules/crazy/ui/CrazyRankUI").Instance
	if rankPanel then
		rankPanel:showTeamUI(rank, fighting, flowerCount, heroList)
	end
end
