module(...,package.seeall)

local  Chapter = require("src/modules/chapter/Chapter")
local ChapterDefine = require("src/modules/chapter/ChapterDefine")
local LevelRewardUI = require("src/modules/chapter/ui/LevelRewardUI")

function onGCChapterList(boxList,levelList,fightHeroes)
	local function sortFunc(a,b)
		return a.levelId > b.levelId 
	end
	table.sort(levelList,sortFunc)
	for _,level in ipairs(levelList) do
		local levelId = level.levelId
		local difficulty = level.difficulty
		-- print("~~~~"..levelId.." "..tostring(level.star))
		Chapter.updateLevel(levelId,difficulty,true,true,level.time,level.timesForDay,level.star,level.buyTimes)
	end
	for i,b in ipairs(boxList) do
		Chapter.updateBox(b.chapterId,b.difficulty,b.boxId)
	end
	for i,h in ipairs(fightHeroes) do 
		if h == '' then
			fightHeroes[i] = nil
		end
	end
	Chapter.fightHeroes = fightHeroes
end


function onGCChapterFbStart(levelId,difficulty,result,fb)
	if result == ChapterDefine.RET_CHAPTER_OK then
		-- Network.sendMsg(PacketID.CG_CHAPTER_FB_END,fbId,ChapterDefine.WIN)
		local ui = UIManager.getUI('ChapterFightUI')
		if ui then
			ui:doFight()
		end
		-- UIManager.addUI("src/modules/chapter/ui/ChapterFightUI",levelId,difficulty)
		Chapter.setLastFightLevel(difficulty,levelId)
	elseif result == ChapterDefine.RET_CHAPTER_PHYSICS then
		Common.showMsg("体力不足，无法挑战")
		-- local ui = UIManager.getUI('Level')
		-- if ui then
		-- 	ui:showEnergyTip()
		-- end
	elseif result == ChapterDefine.RET_CHAPTER_LEVEL then
		Common.showMsg("等级不足，无法进入关卡")
	elseif result == ChapterDefine.RET_CHAPTER_TIMES then
		Common.showMsg("超过每日次数限制，无法进入关卡")
	elseif result == ChapterDefine.RET_CHAPTER_OVERFLOW then
		Common.showMsg("上一个难度未通关，无法进入本难度关卡")
	elseif result == ChapterDefine.RET_CHAPTER_NOTOPENED then
		Common.showMsg("本关卡尚未开放")
	else
		Common.showMsg("无法进入关卡")
	end
end

function onGCChapterFbEnd(levelId,difficulty,result,level,reward,star)
	if result == ChapterDefine.WIN then
		local lastLevel = true
		local chapterId = Chapter.getChapterId(levelId)
		local top = Chapter.getTopOpenedLevel(chapterId,difficulty)
		if top == levelId then
			lastLevel = true
		else
			lastLevel = false
		end
		StatisSDK.finishLevel(levelId.."_"..difficulty)
		Chapter.updateLevel(levelId,difficulty,true,true,level.time,level.timesForDay,star)
		UIManager.addUI('src/modules/chapter/ui/SettlementUI',levelId,difficulty,ChapterDefine.WIN,reward,star,lastLevel)
		Master.getInstance():dispatchEvent(Event.ChapterEnd, {["levelId"] = levelId, ["difficulty"] = difficulty})
	elseif result == ChapterDefine.DEFEATED then
		StatisSDK.failLevel(levelId.."_"..difficulty)
		UIManager.addUI('src/modules/chapter/ui/SettlementUI',levelId,difficulty,ChapterDefine.DEFEATED,reward)
	elseif result == ChapterDefine.RET_CHAPTER_NOTOPENED then
		-- local tipUI = TipsUI.showTipsOnlyConfirm()
		Common.showMsg("本关卡尚未开放，无法结算")
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
	elseif result == ChapterDefine.RET_CHAPTER_IGNORED then
		-- just ignore it!
	else
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
	end
end


function onGCChapterFbWipe(levelId,difficulty,result,level,reward)
	if result == ChapterDefine.RET_CHAPTER_OK then
		Chapter.updateLevel(level.levelId,level.difficulty,true,true,level.time,level.timesForDay,level.star,level.buyTimes)
		-- local levelUI = Stage.currentScene:getUI():getChild('Level')
		local levelUI = require("src/modules/chapter/ui/LevelUI").Instance
		if levelUI then
			levelUI:showWipeSettlement(levelId,difficulty,reward)
			levelUI:showLevelInfo(levelUI.levelId,levelUI.difficulty)
		end
		local HeroInfoUI = require("src/modules/hero/ui/HeroInfoUI").Instance
		if HeroInfoUI then
			HeroInfoUI:refreshStrength()
		end
		Chapter.setLastFightLevel(difficulty,levelId)
	elseif result == ChapterDefine.RET_CHAPTER_TICKET then
		Common.showMsg("扫荡券不足")
	elseif result == ChapterDefine.RET_CHAPTER_PHYSICS then
		Common.showMsg("体力不足")
	elseif result == ChapterDefine.RET_CHAPTER_LEVEL then
		Common.showMsg("战队等级不足")
	elseif result == ChapterDefine.RET_CHAPTER_TIMES then
		Common.showMsg("本副本通关次数超过限制")
	elseif result == ChapterDefine.RET_CHAPTER_NOTPASSED then
		-- local tipUI = TipsUI.showTipsOnlyConfirm("未通过本关卡，无法扫荡")
		Common.showMsg("未通过本关卡，无法扫荡")
	elseif result == ChapterDefine.RET_CHAPTER_RMB then
		Common.showRechargeTips()
	elseif result == ChapterDefine.RET_CHAPTER_LILIAN_LEVEL then
		-- local tips = TipsUI.showTipsOnlyConfirm("战队等级达到"..ChapterDefine.LILIAN_LEVEL.."开放扫荡功能")
		Common.showMsg("战队等级达到限制才开放扫荡功能")
	else
		-- tipUI = TipsUI.showTipsOnlyConfirm()
		Common.showMsg("扫荡条件不满足")
	end
end

function onGCChapterBoxReward(result,chapterId,difficulty,boxId)
	if result == ChapterDefine.RET_CHAPTER_OK then

		Chapter.updateBox(chapterId,difficulty,boxId)
		local ui = LevelRewardUI.Instance
		if ui then
			ui['reward'..boxId].receive:setVisible(false)
			ui['reward'..boxId].receivetitle:setString('已领取')
		end
		local levelui = require("src/modules/chapter/ui/LevelUI").Instance
		if levelui then
			levelui:showBoxBlink()
			levelui:refreshDot()
		end

	elseif result == ChapterDefine.RET_CHAPTER_RECEIVED then
		Common.showMsg("领取宝箱无法重复领取")
	elseif result == ChapterDefine.RET_CHAPTER_STAR then
		Common.showMsg("星星不足，无法领取奖励")
	else
		Common.showMsg("领取宝箱奖励失败")
	end
end

function onGCChapterRank(rankList)
	UIManager.addUI("src/modules/chapter/ui/ChapterRankUI",rankList)
end

function onGCChapterDebugflag(flag)
	if flag == 1 then
		Chapter.debugFlag = true
	else
		Chapter.debugFlag = false
	end
end

function onGCChapterBuytimes(result,levelId,difficulty,no)
	if result == ChapterDefine.RET_CHAPTER_OK then
		Chapter.buyTimes(levelId,difficulty,no)
		-- local ui = UIManager.getUI('Level')
		local ui = require("src/modules/chapter/ui/LevelUI").Instance
		if ui then
			ui:showLevelInfo(ui.levelId,ui.difficulty)
		end
	elseif result == ChapterDefine.RET_CHAPTER_BUYTIMES then
		Common.showRechargeTips("今日购买次数已达上限，无法购买。是否升级VIP提升购买次数上限？")
	end
end

-- function onGCChapterClearcd(result,levelId)
-- 	if result == ChapterDefine.RET_CHAPTER_OK then
-- 		Chapter.cdTime = 0
-- 		local ui = UIManager.getUI("Level")
-- 		if ui then
-- 			ui:clearCD()
-- 		end
-- 	elseif result == ChapterDefine.RET_CHAPTER_RMB then
-- 		tipUI = TipsUI.showTipsOnlyConfirm("钻石不足")
-- 	else
-- 		tipUI = TipsUI.showTipsOnlyConfirm("条件不满足")
-- 	end
-- end
