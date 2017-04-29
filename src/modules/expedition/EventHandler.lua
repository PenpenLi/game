module(...,package.seeall)

local PacketID = require("src/PacketID")
local Define = require("src/modules/expedition/ExpeditionDefine")
local Common = require("src/core/utils/Common")
local expeditionData = require("src/modules/expedition/ExpeditionData").getInstance()
local FightControl = require("src/modules/fight/FightControl")
local Hero = require("src/modules/hero/Hero")
local Logic = require("src/modules/expedition/ExpeditionLogic")
local EndUI = require("src/modules/expedition/ui/ExpeditionEndUI")
local BagDefine = require("src/modules/bag/BagDefine")

function onGCExpeditionQuery(id, gemCount, resetCount, hasBuyCount, hasResetCount, passId, hasGetList)
	expeditionData:setCurId(id)
	expeditionData:setGemCount(gemCount)
	expeditionData:setResetCount(resetCount)
	expeditionData:setTreasureList(hasGetList)
	expeditionData:setBuyResetCount(hasBuyCount)
	expeditionData:setHasResetCount(hasResetCount)
	expeditionData:setPassId(passId)

	local panel = Stage.currentScene:getUI():getChild("Expedition")
	if panel then
		panel:refresh()
	end
end

function onGCExpeditionBuyCount(ret)
	if ret == Define.ERR_CODE.BuySuccess then
		expeditionData:setResetCount(expeditionData:getResetCount() + 1)
		expeditionData:setBuyResetCount(expeditionData:getBuyResetCount() + 1)
		local panel = Stage.currentScene:getUI():getChild("Expedition")
		if panel then
			panel:refresh()
		end
	end
	Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
end

function onGCExpeditionGetTreasure(ret, id, money, gem, itemList)
	if ret == Define.ERR_CODE.GetTreasureSuccess then
		expeditionData:addHasGetTreasure(id)

		local panel = Stage.currentScene:getUI():getChild("Expedition")
		if panel then
			--panel:showTreasureUI(id, money, gem, itemList[1])
			panel:refresh()
			local tb = {}
			if money > 0 then
				local moneyItem = {title='巡回赛奖励', id=BagDefine.ITEM_ID_MONEY, num=money}
				table.insert(tb, moneyItem)
			end
			for k,v in ipairs(itemList) do
				local item = {title='巡回赛奖励', id=v.itemId, num=v.count}
				table.insert(tb, item)
			end
			local ui = RewardTips.show(tb)
			if ui then
				ui:setAnchorPoint(0.5, 0.5)
				ui:setPosition(ui:getContentSize().width/2,ui:getContentSize().height/2)
				ui.touchParent = false
			end
		end
	else
		Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
	end
end

function onGCExpeditionReset(ret, param)
	if ret == Define.ERR_CODE.ResetSuccess then
		expeditionData:setCurId(1)
		expeditionData:setResetCount(expeditionData:getResetCount() - 1)
		expeditionData:setHasResetCount(expeditionData:getHasResetCount() + 1)
		expeditionData:resetTreasureList()

		local panel = Stage.currentScene:getUI():getChild("Expedition")
		if panel then
			panel:refresh()
		end
	elseif ret == Define.ERR_CODE.ResetHasTreasureNotGet then
		
	end
	Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
end

function onGCExpeditionChallange(name, lv, icon, guildName, rage, assist, enemyList, next)
	table.sort(enemyList, function(a,b)
		return a.pos < b.pos
	end)
	expeditionData:setEnemyList(enemyList)
	expeditionData:setEnemyRage(rage)
	expeditionData:setEnemyAssist(assist)
	Logic.composeEnemyList()
	if next == Define.NEXT_NO then
		local panel = Stage.currentScene:getUI():getChild("Expedition")
		if panel then
			panel:showChallangeUI(name, lv, icon, guildName)
		end
	end
end

function onGCExpeditionHeroList(rage, assist, heroList)
	expeditionData:setHeroList(heroList)
	expeditionData:setHeroRage(rage)
	expeditionData:setHeroAssist(assist)
	Logic.composeHeroList()
	local panel = Stage.currentScene:getUI():getChild("Expedition")
	if panel then
		panel:refreshHeroSelUI()
	end
end

function onGCExpeditionEnter(ret, orderList)
	if ret == Define.ERR_CODE.EnterSuccess then
		-- local terry = Hero.getHero("Terry")
		-- --自己
		-- local myHeroList = {}
		-- for _,order in pairs(orderList) do
		-- 	local hero = expeditionData:getMyHeroList()[order.name]
		-- 	table.insert(myHeroList, hero)
		-- end
		-- table.insert(myHeroList, terry)

		-- --敌方
		-- local enemyList = {}
		-- for _,hero in pairs(expeditionData:getEnemyHeroList()) do
		-- 	table.insert(enemyList, hero)
		-- end
		-- table.insert(enemyList, terry)

		-- local fightControl = FightControl.new(myHeroList, enemyList)
		-- local scene = require("src/scene/FightScene").new(fightControl)
		-- scene:addEventListener(Event.FightEnd,function(listener,event)
		-- 	local result = Define.COPY_END_FAIL
		-- 	if event.winer == 'A' then
		-- 		result = Define.COPY_END_SUCCESS
		-- 	end
		-- 	Network.sendMsg(PacketID.CG_EXPEDITION_END, result, 
		-- 		event.infoA.power, event.infoA.assist, expeditionData:getMyHeroHpList(),
		-- 		event.infoB.power, event.infoB.assist, expeditionData:getEnemyHeroHpList())
		-- end)
		-- Stage.replaceScene(scene)
	end
	--Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
end

function onGCExpeditionEnd(ret)
	if ret == Define.ERR_CODE.CopyEndSuccess then
		local endUI = EndUI.new()
		Stage.currentScene:getUI():addChild(endUI)
		endUI:showSuccessUI()
		endUI:runAction(cc.Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create(function()
			endUI:hideAll()
		end)))
	else
		local fun = function()
			local scene = require("src/scene/MainScene").new()
			Stage.replaceScene(scene)
			scene:addEventListener(Event.InitEnd, function()
				UIManager.replaceUI("src/modules/expedition/ui/ExpeditionUI")
			end)
		end
		local loseUI = UIManager.addUI('src/ui/SettlementLoseUI')
		loseUI:init()
		loseUI:setHeroes(expeditionData:getExpeditionList())
		loseUI:setCloseFun(fun)
	end
end

function onGCExpeditionShopList(itemList, refreshTime, refreshCost)
	expeditionData:setShopList(itemList)
	expeditionData:setRefreshTime(refreshTime)
	expeditionData:setRefreshCost(refreshCost)

	local panel = Stage.currentScene:getUI():getChild("Expedition")
	if panel then
		panel:refreshShopData(itemList)
	end
end

function onGCExpeditionBuyItem(ret, id)
	if ret == Define.ERR_CODE.ShopSuccess then
		expeditionData:setShopItemBuy(id)
		local panel = Stage.currentScene:getUI():getChild("Expedition")
		if panel then
			panel:setItemBuy(id, Button.UI_BUTTON_DISABLE)
		end
	end
	Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
end

function onGCExpeditionShopRefresh(ret)
	if ret == Define.ERR_CODE.ShopRefreshSuccess then
	elseif ret == Define.ERR_CODE.ShopRefreshNoMoney then
		Common.showRechargeTips()
	else
		Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
	end
end

function onGCExpeditionClear(ret, passId)
	if ret == Define.ERR_CODE.ClearSuccess then
		local list = Logic.getClearReward(passId)
		local ui = UIManager.addChildUI("src/ui/WipeRewardUI")
		ui:setPosition(ui:getContentSize().width/2, ui:getContentSize().height/2)
		ui:addEventListener(Event.Confirm,function() 
			Network.sendMsg(PacketID.CG_EXPEDITION_QUERY)
			--local expeditionUI = UIManager.getUI("Expedition")
			--if expeditionUI then
			--	UIManager.removeUI(expeditionUI)
			--	UIManager.replaceUI("src/modules/expedition/ui/ExpeditionUI")
			--end
		end)
		ui:refreshReward("世界巡回赛",list)
	else
		Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
	end
end
