module(...,package.seeall)
local ArenaData = require("src/modules/arena/ArenaData")
local ArenaDefine = require("src/modules/arena/ArenaDefine")
local FightControl = require("src/modules/fight/FightControl")
local FightDefine = require("src/modules/fight/Define")
local ArenaShopData = require("src/modules/arena/ArenaShopData")
local Hero = require("src/modules/hero/Hero")
local HeroFightListUI = require("src/ui/HeroFightListUI")
local OpenLv = require("src/config/FightOpenLvConfig").Config[1].openlv

function onGCArenaQuery(rank,fightList,leftTimes,maxTimes,nextTime,enemyData)
	ArenaData.setArenaData(rank,fightList,leftTimes,maxTimes,nextTime,enemyData)
	local ArenaUI = Stage.currentScene:getUI():getChild("Arena")
	if ArenaUI then
		if rank <= 0 then
			--local fightlist = Hero.expedition
			--ArenaUI.tiaozhan.rec:dispatchEvent(Event.Click,{etype=Event.Click})
			local fightlist = {}
			if not next(fightlist) then
				HeroFightListUI.setDefaultHeroList(nil,fightlist)
			end
			local ret = {}
			local lv = Master.getInstance().lv
			local index = 1
			for i = 1,4 do
				if not OpenLv[i] or lv >= OpenLv[i] then
					if index == #fightlist then
						table.insert(ret,{name = fightlist[index],pos = 4})
					else	
						table.insert(ret,{name = fightlist[index],pos = i})
					end
					index = index + 1
					if index > #fightlist then
						break
					end
				end
			end
			Network.sendMsg(PacketID.CG_ARENA_CHANGE_HERO,ret)
		end
		local changeTeamUI = ArenaUI:getChild("ChangeTeamUI")
		if changeTeamUI then
			UIManager.removeUI(changeTeamUI)
		end
		ArenaUI:refreshArena()
	end
end

function onGCArenaChangeHero(fightList)
	ArenaData.setArenaFightList(fightList)
	local ArenaUI = Stage.currentScene:getUI():getChild("Arena")
	if ArenaUI then
		local changeTeamUI = ArenaUI:getChild("ChangeTeamUI")
		if changeTeamUI then
			UIManager.removeUI(changeTeamUI)
		end
		ArenaUI:refreshHeroList()
	end
end

function onGCArenaChangeEnemy(enemyList)
	ArenaData.setArenaEnemyList(enemyList)
	local ArenaUI = Stage.currentScene:getUI():getChild("Arena")
	if ArenaUI then
		ArenaUI:refreshEnemyList()
	end
end

function onGCArenaFightRecord(recordData)
	local ArenaUI = Stage.currentScene:getUI():getChild("Arena")
	if ArenaUI then
		local FightRecordUI = ArenaUI:getChild("FightRecord")
		if FightRecordUI then
			FightRecordUI:refreshInfo(recordData)
		end
	end
end

function onGCArenaFightBegin(ret,enemyPos)
	if ArenaDefine.ARENA_BEGIN.kOk == ret then
		local myHeroList = ArenaData.getHeroList()
		local enemyList = ArenaData.getEnemyHeroList(enemyPos)
		local fightControl = FightControl.new(myHeroList, enemyList)
		local scene = require("src/scene/FightScene").new(fightControl,FightDefine.FightModel.autoA_autoB,FightDefine.FightType.arena)
		scene:addEventListener(Event.FightEnd,function(self,event)
			if event.winer == 'A' then
				Network.sendMsg(PacketID.CG_ARENA_FIGHT_END,ArenaDefine.WIN,enemyPos)
			else
				Network.sendMsg(PacketID.CG_ARENA_FIGHT_END,ArenaDefine.LOSE,enemyPos)
			end
		end,self)
		Stage.replaceScene(scene)
	else
		local content = ArenaDefine.ARENA_BEGIN_TIPS[ret]
		Common.showMsg(string.format(content))
	end
end

function onGCArenaFightEnd(result,rewards)
	UIManager.addUI('src/modules/arena/ui/SettlementUI',result,rewards)
end

function onGCArenaShopQuery(shopData,refreshTimes)
	ArenaShopData.setShopData(shopData,refreshTimes)
	--local ArenaUI = Stage.currentScene:getUI():getChild("Arena")
	--if ArenaUI then
	--	local ArenaShopUI = ArenaUI:getChild("ArenaShopUI")
	--	if ArenaShopUI then
	--		ArenaShopUI:refreshShopData(shopData)
	--	end
	--end
	--local ArenaShopUI = Stage.currentScene:getUI():getChild("ArenaShopUI")
	--if ArenaShopUI then
	--	ArenaShopUI:refreshShopData(shopData)
	--end
	local ArenaShopUI = require("src/modules/arena/ui/ArenaShopUI").Instance
	if ArenaShopUI then
		ArenaShopUI:refreshShopData(shopData)
	end
end

function onGCArenaShopBuy(shopId,retCode)
	local content = ArenaDefine.ARENA_BUY_TIPS[retCode]
	Common.showMsg(string.format(content))
	if retCode == ArenaDefine.ARENA_BUY.kOk then
		--local ArenaUI = Stage.currentScene:getUI():getChild("Arena")
		--if ArenaUI then
		--	local ArenaShopUI = ArenaUI:getChild("ArenaShopUI")
		--	if ArenaShopUI then
		--		ArenaShopUI:setShopItemBuyState(shopId,Button.UI_BUTTON_DISABLE)
		--	end
		--end
		--local ArenaShopUI = Stage.currentScene:getUI():getChild("ArenaShopUI")
		--if ArenaShopUI then
		--	ArenaShopUI:setShopItemBuyState(shopId,Button.UI_BUTTON_DISABLE)
		--end
		local ArenaShopUI = require("src/modules/arena/ui/ArenaShopUI").Instance
		if ArenaShopUI then
			ArenaShopUI:setShopItemBuyState(shopId,Button.UI_BUTTON_DISABLE)
		end
	end
end

function onGCArenaShopRefresh(retCode)
	local content = ArenaDefine.ARENA_REFRESH_TIPS[retCode]
	Common.showMsg(string.format(content))
end

function onGCArenaResetCd(retCode)
	local content = ArenaDefine.ARENA_RESETCD_TIPS[retCode]
	Common.showMsg(string.format(content))
end
