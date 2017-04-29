module(..., package.seeall)

local Define = require("src/modules/peak/PeakDefine")
local Data = require("src/modules/peak/PeakData")
local Logic = require("src/modules/peak/PeakLogic")
local PeakConfig = require("src/config/PeakConfig").Config[1]

function onGCPeakTeamCheck(isStart, heroNameList, coolTime, score, resetCost)
	Data.getInstance():setStart(isStart == 1 and true or false)
	Data.getInstance():setHeroNameList(heroNameList)	
	Data.getInstance():setCoolTime(coolTime)
	Data.getInstance():setScore(score)
	Data.getInstance():setResetCost(resetCost)
	local panel = Stage.currentScene:getUI():getChild("Peak")
	if panel then
		panel:refreshTeamCon()
		panel:refreshTimeAbout()
	end
end

function onGCPeakTeamConfirm(retCode, heroNameList)
	if retCode == Define.ERR_CODE.CONFIRM_SUCCESS then
		Data.getInstance():setHeroNameList(heroNameList)	
		local panel = Stage.currentScene:getUI():getChild("Peak")
		if panel then
			panel:refreshTeamGrid()
		end
	else
		Common.showMsg(Define.ERR_TXT[retCode] or "操作失败")
	end
end

function onGCPeakSearch(name, heroList)
	Data.getInstance():setEnemyName(name)
	Data.getInstance():setEnemyHeroInfo(heroList)
	Data.getInstance():setSelectHeroList(Data.getInstance():getHeroNameList())

	local tb = {}
	for _,info in ipairs(heroList) do
		table.insert(tb, info.name)
	end
	Data.getInstance():setSelectEnemyList(tb)

	local panel = Stage.currentScene:getUI():getChild("Peak")
	if panel then
		panel:startSelect()
	end
end

function onGCPeakCancel()
end

function onGCPeakResetSearch(retCode, resetCost)
	if retCode == Define.ERR_CODE.RESET_SUCCESS then
		Data.getInstance():setResetCost(resetCost)
		Data.getInstance():setCoolTime(0)
		local panel = Stage.currentScene:getUI():getChild("Peak")
		if panel then
			panel:refreshTimeAbout()
		end
	end
	Common.showMsg(Define.ERR_TXT[retCode] or "操作失败")
end

function onGCPeakCtrlEnemy(heroNameList)
end

function onGCPeakCtrlEnemyConfirm(isRobot, heroNameList, enemyNameList)
	print('heroNameList ======================================')
	Common.printR(heroNameList)
	print('enemyNameList ====================================')
	Common.printR(enemyNameList)
	Data.getInstance():setSelectHeroList(heroNameList)
	Data.getInstance():setSelectEnemyList(enemyNameList)

	local panel = Stage.currentScene:getUI():getChild("Peak")
	if panel then
		panel:refreshEnemyCon()
	end

	if #heroNameList == Define.TEAM_HERO_SELECT and #enemyNameList == Define.TEAM_HERO_SELECT then
		Logic.composeHeroList(heroNameList)	
		panel:refreshToNextUI()
	end
end

function onGCPeakReadyGo(seed, dir, heroNameList, enemyList)
	local panel = Stage.currentScene:getUI():getChild("PeakFightUI")
	if panel and #heroNameList < Define.TEAM_HERO_SELECT and #enemyList < Define.TEAM_HERO_SELECT then
		Data.getInstance():setDir(dir)
		math.randomseed(seed)
		Logic.composeFightHeroList(heroNameList)
		Logic.composeFightEnemyList(enemyList)
		panel:refreshToFightScene(dir)	
	end
end

function onGCPeakFail()
	if Stage.currentScene.name == 'fight' then
		local fun = function()
			local scene = require("src/scene/MainScene").new()
			Stage.replaceScene(scene)
			scene:addEventListener(Event.InitEnd, function()
				UIManager.replaceUI("src/modules/peak/ui/PeakUI")

				local tip = TipsUI.showTipsOnlyConfirm('对方逃跑了，你获得' .. PeakConfig.successScore .. '积分')
				tip:addEventListener(Event.Confirm,function(self,event) 
				end,self)
			end)
		end
		local panel = Stage.currentScene:getUI()
		if panel and panel.name == 'Fight' then
			panel:stopFight()
			fun()
		else
			Stage.currentScene:addEventListener(Event.InitEnd, function()
				fun()
			end)
		end
	else
		local panel = Stage.currentScene:getUI():getChild("Peak")
		if panel then
			panel:sendMsg()
		else
			UIManager.replaceUI("src/modules/peak/ui/PeakUI")
		end
		local tip = TipsUI.showTipsOnlyConfirm('对方逃跑了，你获得' .. PeakConfig.successScore .. '积分')
			tip:addEventListener(Event.Confirm,function(self,event) 
		end,self)
	end
end

function onGCPeakEnd(isSuccess)
	print('isSuccess ==========' .. isSuccess)
	if isSuccess == Define.END_SUCCESS then
		if Data.getInstance():getDir() == Define.DIR_LEFT then
			local heroA = Stage.currentScene.heroA
			if heroA ~= nil then
				print('heroA ================')
				heroA.fightAttr = {}
				heroA.fightAttr.noDie = true
			end
		else
			local heroB = Stage.currentScene.heroB
			if heroB ~= nil then
				heroB.fightAttr = {}
				print('heroB ================')
				heroB.fightAttr.noDie = true
			end
		end
	else
		if Data.getInstance():getDir() == Define.DIR_LEFT then
			local heroB = Stage.currentScene.heroB
			if heroB ~= nil then
				heroB.fightAttr = {}
				print('heroB ================')
				heroB.fightAttr.noDie = true
			end
		else
			local heroA = Stage.currentScene.heroA
			if heroA ~= nil then
				print('heroA ================')
				heroA.fightAttr = {}
				heroA.fightAttr.noDie = true
			end
		end
	end
end

function onGCPeakFightRecord(recordList)
	local peakUI = Stage.currentScene:getUI():getChild("Peak")
	if peakUI then
		local fightRecordUI = peakUI:getChild("PeakRecordUI")
		if fightRecordUI then
			fightRecordUI:refreshInfo(recordList)
		end
	end
end

function onGCPeakShopList(shopList, refreshTime, refreshCost)
	Data.getInstance():setShopList(shopList)
	Data.getInstance():setRefreshTime(refreshTime)
	Data.getInstance():setRefreshCost(refreshCost)

	local panel = Stage.currentScene:getUI():getChild("Peak")
	if panel then
		local shopPanel = panel:getChild('PeakShop')
		if shopPanel then
			shopPanel:refreshShopData(shopList)
		end
	end
end

function onGCPeakBuyItem(ret, id, score)
	if ret == Define.ERR_CODE.ShopSuccess then
		Data.getInstance():setShopItemBuy(id)
		Data.getInstance():setScore(score)

		local panel = Stage.currentScene:getUI():getChild("Peak")
		if panel then
			panel:refreshScore()
			local shopPanel = panel:getChild('PeakShop')
			if shopPanel then
				shopPanel:setShopItemBuyState(id, Button.UI_BUTTON_DISABLE)
			end
		end
	end
	Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
end

function onGCPeakShopRefresh(ret)
	if ret == Define.ERR_CODE.ShopRefreshSuccess then
	elseif ret == Define.ERR_CODE.ShopRefreshNoMoney then
		Common.showRechargeTips()
	else
		Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
	end
end
