module(..., package.seeall)

local worldBossData = require("src/modules/worldBoss/WorldBossData").getInstance()
local Define = require("src/modules/worldBoss/WorldBossDefine")
local Monster = require("src/modules/hero/Monster")
local Logic = require("src/modules/worldBoss/WorldBossLogic")

function onGCWorldBossQuery(hasStart, countDownTime, coolTime, hurt)
	worldBossData:setCountDownTime(countDownTime)
	worldBossData:setCoolTime(coolTime)
	worldBossData:setMyHurt(hurt)

	local panel = Stage.currentScene:getUI():getChild("WorldBoss")
	if panel then
		if hasStart == 1 then
			panel:refreshOpen()
		else
			panel:refreshClose()
		end
	end
end

function onGCWorldBossEnter(retCode, hp, heroNameList)
	if retCode == Define.ERR_CODE.ENTER_SUCCESS then
		local panel = Stage.currentScene:getUI():getChild("WorldBossFightUI")
		if panel then
			panel:doTeamFight()
			Logic.refreshBossHp(hp)
			Logic.startBattle()
		end
	end
	Common.showMsg(Define.ERR_TXT[retCode] or "操作失败")
end

function onGCWorldBossRank(rankList)
	worldBossData:setRankList(rankList)
	local panel = Stage.currentScene:getUI():getChild("WorldBoss")
	if panel then
		panel:refreshRank()
		local rankPanel = panel:getChild("WorldBossRank")
		if rankPanel then
			rankPanel:refreshList()
		end
	end
end

function onGCWorldBossCheckTeam(rank, fighting, flowerCount, heroList)
	local panel = Stage.currentScene:getUI():getChild("WorldBoss")
	if panel then
		local rankPanel = panel:getChild("WorldBossRank")
		if rankPanel then
			rankPanel:showTeamUI(rank, fighting, flowerCount, heroList)
		end
	end
end

function onGCWorldBossRefreshHp(hp)
	Logic.refreshBossHp(hp)
end

function onGCWorldBossOpen()
	worldBossData:setCountDownTime(0)
	local sceneName = Stage.currentScene.name
	if sceneName == "main" then
		local panel = Stage.currentScene:getUI():getChild("WorldBoss")
		if panel then
			panel:refreshOpen()
		end
	end
end

function onGCWorldBossEnd(endType)
	Logic.endBattle()
	if endType == Define.BOSS_END_DIE then 
		Logic.refreshBossHp(0)
	else
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
		scene:addEventListener(Event.InitEnd, function()
			TipsUI.showTipsOnlyConfirm("世界BOSS活动时间结束，BOSS未击退，请到邮件领取奖励！")
		end)
	end
end
