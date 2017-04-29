module(...,package.seeall)

local TDefine = require("src/modules/treasure/TreasureDefine")
local Treasure = require("src/modules/treasure/Treasure")
local ItemConfig = require("src/config/ItemConfig").Config
local Enemy = require("src/modules/hero/Enemy")
local Hero = require("src/modules/hero/Hero")
local FightControl = require("src/modules/fight/FightControl")
local PublicLogic = require("src/modules/public/PublicLogic")
local ShopDefine = require("src/modules/shop/ShopDefine")
function onGCTreasureMapInfo(result,refresh,mapInfoTime,mineList)
	if result == TDefine.RET_OK then
		-- local ui = UIManager.replaceUI("src/modules/treasure/ui/TreasureMainUI",regionId,districtList)
		-- Treasure.setMapInfo(mapInfoTime,mineList)
		Treasure.mapInfoTime = mapInfoTime
		Treasure.mineList = mineList
		if Stage.currentScene.name == "main" then
			local ui = UIManager.getUI("TreasureMain")
			if not ui then
				ui = UIManager.replaceUI("src/modules/treasure/ui/TreasureMainUI")
			else
				ui:refreshData()
				if refresh == 1 then
					ui:refreshEffect()
				end
			end
		end
	elseif result == TDefine.RET_LEVEL then
		-- TipsUI.showTipsOnlyConfirm()
		Common.showMsg('战队'..PublicLogic.getOpenLv('treasure').."级开放夺宝功能")
	end
end

function onGCTreasureMineInfo(result,mineInfo)
	if result == TDefine.RET_OK then
		if mineInfo.account == Master.getInstance().account then
			Treasure.mine[mineInfo.mineId] = mineInfo
		end
		local ui = UIManager.getUI("TreasureMain")
		if ui then
			local child = ui:getChild("TreasureOccupiedMine")
			if child then
				child:refreshMineInfo(mineInfo)
				child:showExtend()
			else
				ui:showMineInfo(mineInfo)
			end

		end
		Treasure.refreshMineInfo(mineInfo)

	end
end

function onGCTreasureGuard(result,mineId,guard)
	if result == TDefine.RET_OK then
		local mine = Treasure.mine[mineId]
		if mine then
			mine.hero = guard
			local ui = UIManager.getUI("TreasureMain")
			if ui then 
				ui:refreshData()
				Treasure.sendTreasureMineInfo(mineId)
				-- local mui = UIManager.addChildUI("src/modules/treasure/ui/TreasureOccupiedMine",mine)
			end
		end
	else
		Common.showMsg("无法调整阵容")
	end
end

-- function onGCTreasureMoreTime(result,remainTimes)
-- 	if result == TDefine.RET_OK then
-- 		TipsUI.showTipsOnlyConfirm("延长了占领时间"..TDefine.EXTEND_HOUR.."小时，消耗了"..TDefine.EXTEND_RMB.."颗钻石")
-- 		local ui = UIManager.getUI("TreasureMain")
-- 		if ui and ui.mineinfo:isVisible() then
-- 			ui.mineinfo.my.txtextend:setString("剩余"..remainTimes.."次")
-- 		end
-- 	elseif result == TDefine.RET_LIMITED then
-- 		TipsUI.showTipsOnlyConfirm("超过每日次数限制")
-- 	elseif result == TDefine.RET_NOTENOUGH then
-- 		TipsUI.showTipsOnlyConfirm("钻石不足")
-- 	else
-- 		TipsUI.showTipsOnlyConfirm("延长占领时间失败")
-- 	end
-- end


function onGCTreasureDoubleReward(result,remainTimes)
	if result == TDefine.RET_OK then
		TipsUI.showTipsOnlyConfirm("开启了双倍收益，消耗了"..TDefine.DOUBLE_RMB.."颗钻石")
		local ui = UIManager.getUI("TreasureMain")
		if ui and ui.mineinfo:isVisible() then
			ui.mineinfo.my.dgroup.txtdouble:setString("剩余"..remainTimes.."次")
		end
	elseif result == TDefine.RET_LIMITED then
		TipsUI.showTipsOnlyConfirm("超过每日次数限制")
	elseif result == TDefine.RET_NOTENOUGH then
		TipsUI.showTipsOnlyConfirm("钻石不足")
	else
		TipsUI.showTipsOnlyConfirm("开启双倍收益失败")
	end
end


function onGCTreasureAbandon(result,mineId)
	if result == TDefine.RET_OK then
		Common.showMsg("此宝矿已离你而去，分手费（累计收益）将包邮送回！")
		local ui = UIManager.getUI("TreasureMain")
		if ui then
			local child = ui:getChild("TreasureOccupiedMine")
			if child then
				UIManager.removeUI(child)
			end
		end
	elseif result == TDefine.RET_LIMITED then
	elseif result == TDefine.RET_NOTENOUGH then
	else
	end
end


-- function onGCTreasureSafe(result,safeStartTime,safeEndTime)
-- 	if result == TDefine.RET_OK then
-- 		Treasure.safeStartTime = safeStartTime
-- 		Treasure.safeEndTime = safeEndTime
-- 		local ui = UIManager.getUI("TreasureMain")
-- 		if ui then
-- 			ui.districtList[d].mineList[m].safe = 1
-- 			local rb = ui.districtsv.districtgroup['district'..d]
-- 			if rb then
-- 				rb:dispatchEvent(Event.Click,{etype=Event.Click})
-- 				rb:setSelected(true)
-- 			end
-- 		end
-- 	end
-- end


-- function onGCTreasureHero(result,operation)
-- 	if result == TDefine.RET_OK then
-- 		if operation == "dispatch" or operation == "change" then
-- 			local ui = UIManager.getUI("TreasureGuard")
-- 			if ui and ui.guard:isVisible() then
-- 				ui:showGuard()
-- 			end
-- 		elseif operation == "assistreturn" then
-- 			local ui = UIManager.getUI("TreasureGuard")
-- 			if ui and ui.assist:isVisible() then
-- 				ui:showAssist()
-- 			end
-- 		end
-- 	end

-- end
function onGCTreasurePrepareOccupy(result,mineId,guard)
	if result == TDefine.RET_OK then
		local ui = UIManager.getUI("TreasureMain")
		if ui then
			-- local regionId = ui.mineinfo.regionId
			local forbid = Treasure.getForbidHero(mineId)
			
			if #guard == 0 then
				UIManager.addUI("src/modules/treasure/ui/TreasureFightUI",TDefine.MODE_FIGHT,forbid,mineId)
				-- Network.sendMsg(PacketID.CG_TREASURE_END_OCCUPY,TDefine.WIN,regionId,districtId,mineId,{"Terry"})
			else
				UIManager.addUI("src/modules/treasure/ui/TreasureFightUI",TDefine.MODE_FIGHT,forbid,mineId,guard)
				-- Network.sendMsg(PacketID.CG_TREASURE_END_OCCUPY,TDefine.WIN,regionId,districtId,mineId,{"Terry"})
			end
		end
	elseif result == TDefine.RET_TARGETPROTECTED then
		-- TipsUI.showTipsOnlyConfirm()
		Common.showMsg("对方开启了保护，无法占领")
	elseif result == TDefine.RET_OCCUPYING then
		Common.showMsg("灰常激烈啊，此宝矿正被抢夺中")
	elseif result == TDefine.RET_LIMITED then
		-- TipsUI.showTipsOnlyConfirm()
		Common.showMsg("您占领的宝藏数量已达上限，每个玩家只能同时占领两个宝藏")
	elseif result == TDefine.RET_FIGHTTIMES then
		local tips = TipsUI.showTips("挑战次数不足，是否购买？")
		tips:addEventListener(Event.Confirm,function(self,event) 
			if event.etype == Event.Confirm_yes then
				ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_TREASUREFIGHT_ID)
			end
		end)
	else
		-- TipsUI.showTipsOnlyConfirm()
		Common.showMsg("无法占领")
	end
end
function onGCTreasureStartOccupy(result,mineId,guard)
	if result == TDefine.RET_OK then
		local ui = UIManager.getUI("TreasureFightUI")
		if ui then
			ui:goFight()
		end
	elseif result == TDefine.RET_TARGETPROTECTED then
		Common.showMsg("对方开启了保护，无法占领")
	elseif result == TDefine.RET_OCCUPYING then
		Common.showMsg("灰常激烈啊，此宝矿正被抢夺中")
	elseif result == TDefine.RET_LIMITED then
		Common.showMsg("您占领的宝藏数量已达上限，每个玩家只能同时占领两个宝藏")
	elseif result == TDefine.RET_FIGHTTIMES then
		local tips = TipsUI.showTips("挑战次数不足，是否购买？")
		tips:addEventListener(Event.Confirm,function(self,event) 
			if event.etype == Event.Confirm_yes then
				ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_TREASUREFIGHT_ID)
			end
		end)
	elseif result == TDefine.RET_PREPARE then
		Common.showMsg("来晚一步了，此宝矿已被其他玩家占领")
	else
		-- TipsUI.showTipsOnlyConfirm()
		Common.showMsg("无法占领")
	end
end


function onGCTreasureEndOccupy(result,result2,mineId,heroes)
	if result == TDefine.RET_OK then
		local msg = ''

		if result2 == TDefine.WIN then
			msg = "成功占领宝藏"
		else
			msg = "占领失败"
		end
		UIManager.addUI("src/modules/treasure/ui/SettlementUI",result2,mineId,heroes)
		-- local tipUI = TipsUI.showTipsOnlyConfirm(msg)
		-- tipUI:addEventListener(Event.Confirm,function(self,event) 
		-- 	if event.etype == Event.Confirm_known then
		-- 		local scene = require("src/scene/MainScene").new()
		-- 		Stage.replaceScene(scene)
		-- 		scene:addEventListener(Event.InitEnd, function()
		-- 			local ui = UIManager.replaceUI("src/modules/treasure/ui/TreasureMainUI")
		-- 			-- ui:refreshData()

		-- 			Treasure.sendTreasureMineInfo(mineId)
		-- 		end)
		-- 	end
		-- end,self)

	end
end

-- function onGCTreasureStartRob(result,guard,assist)
-- 	if result == TDefine.RET_OK then
-- 		local ui = UIManager.getUI("TreasureMain")
-- 		if ui then
-- 			local districtId = ui.mineinfo.districtId
-- 			local mineId = ui.mineinfo.mineId
-- 			UIManager.addUI("src/modules/treasure/ui/TreasureFightUI",PacketID.CG_TREASURE_END_ROB,districtId,mineId,{},guard,assist)
-- 				-- Network.sendMsg(PacketID.CG_TREASURE_END_OCCUPY,TDefine.WIN,regionId,districtId,mineId,{"Terry"})
-- 		end
-- 	elseif result == TDefine.ret_ASSIST then
-- 		TipsUI.showTipsOnlyConfirm("正在协助的宝藏，无法抢夺")
-- 	else

-- 		TipsUI.showTipsOnlyConfirm("无法抢夺")
-- 	end
-- end

-- function onGCTreasureEndRob(result,result2,districtId,mineId)
-- 	if result == TDefine.RET_OK then
-- 		local msg = ''
-- 		if result2 == TDefine.WIN then
-- 			msg = "成功掠夺宝藏，请到邮箱中查看收获"
-- 		else
-- 			msg = "掠夺失败"
-- 		end
-- 		local tipUI = TipsUI.showTipsOnlyConfirm(msg)
-- 		tipUI:addEventListener(Event.Confirm,function(self,event) 
-- 			if event.etype == Event.Confirm_known then
-- 				local scene = require("src/scene/MainScene").new()
-- 				Stage.replaceScene(scene)
-- 				UIManager.replaceUI("src/modules/treasure/ui/TreasureMainUI",Treasure.districtList,districtId)
-- 			end
-- 		end,self)
-- 	end	
-- end

--[[取消协助
function onGCTreasureAssist(result,districtId,mineId,heroName)
	if result == TDefine.RET_OK  then
		local ui = UIManager.getUI("TreasureMain")
		if ui then 
			local guardUI = ui:getChild('TreasureGuard')
			if guardUI and guardUI.assist:isVisible() then
				guardUI:showAssist()
			end
		end
	elseif result == TDefine.RET_LIMITED then
		-- local tip = TipsUI.showTipsOnlyConfirm()
		Common.showMsg("本宝藏协助名额已满")
	elseif result == TDefine.RET_ASSIST then
		-- local tip = TipsUI.showTipsOnlyConfirm()
		Common.showMsg("无法协助自己的宝藏")
	elseif result == TDefine.ret_INASSIST then
		-- local tip = TipsUI.showTipsOnlyConfirm()
		Common.showMsg("你已有其他英雄协助本宝藏")
	else
		-- TipsUI.showTipsOnlyConfirm()
		Common.showMsg("无法协助")
	end
end
--]]


-- function onGCTreasureEndAssist(result,districtId,mineId,assistNo)
-- 	local msg = ''
-- 	if result == TDefine.WIN then
-- 		msg = "成功抢夺协助"
-- 	else
-- 		msg = "抢夺协助失败"
-- 	end
-- 	local tipUI = TipsUI.showTipsOnlyConfirm(msg)
-- 	tipUI:addEventListener(Event.Confirm,function(self,event) 
-- 		if event.etype == Event.Confirm_known then
-- 			local scene = require("src/scene/MainScene").new()
-- 			Stage.replaceScene(scene)
-- 			UIManager.replaceUI("src/modules/treasure/ui/TreasureMainUI",Treasure.districtList,districtId)
-- 		end
-- 	end,self)
-- end


function onGCTreasureChar(fightTimes,extendTimes,safeTimes,doubleTimes,refreshMapTimes,mineList)
	Treasure.fightTimes = fightTimes
	Treasure.extendTimes = extendTimes
	Treasure.safeTimes = safeTimes
	Treasure.doubleTimes = doubleTimes
	Treasure.refreshMapTimes = refreshMapTimes
	Treasure.mine = {}
	local ui = UIManager.getUI("TreasureMain")
	for _,m in ipairs(mineList) do
		Treasure.mine[m.mineId] = m
	end
	
	if ui then
		ui:refreshChar(self)
		local child = ui:getChild("TreasureOccupiedMine")
		if child then
			child:onRefreshLeftTimes()
		end
	end
end

-- function onGCTreasureStatus(result)
-- 	if result == TDefine.RET_OK then
-- 		local ui = UIManager.getUI('TreasureFightUI')
-- 		if ui then
-- 			ui:startFight()
-- 		end
-- 	elseif result == TDefine.RET_OCCUPYING then
-- 		local ui = UIManager.getUI('TreasureFightUI')
-- 		if ui then
-- 			UIManager.removeUI(ui)
-- 		end
-- 		-- TipsUI.showTipsOnlyConfirm()
-- 		Common.showMsg("来晚了，宝藏正在被其他玩家占领")
-- 	end
-- end

function onGCTreasureQueryOccupied(result,mineList)
	if result == TDefine.RET_OK then
		if #mineList > 0 then
			for i,mineInfo in ipairs(mineList) do
				Treasure.mine[mineInfo.mineId] = mineInfo
			end
			local ui = UIManager.getUI("TreasureMain")
			if ui then
				ui:showOccupied()
			end
		end

	end

end

function onGCTreasureRecord(recordList)
	local ui = UIManager.getUI("TreasureMain")
	if ui then
		UIManager.addChildUI("src/modules/treasure/ui/TreasureRecord",recordList)
	end
end

function onGCTreasureMsg(msg)
	local ui = UIManager.getUI("TreasureMain")
	if ui then
		Common.showMsg(msg)
	end
end

function onGCTreasureConsume(result,consumeId,mineId)
	local ui = UIManager.getUI("TreasureMain")
	local mineUI = nil
	if ui then
		mineUI = ui:getChild("TreasureOccupiedMine")
	end
	if result == TDefine.RET_OCCUPYING then
		Common.showMsg("本宝藏正在遭到他玩家攻击，无法继续操作")
	end
	Treasure.sendTreasureMineInfo(mineId)
end