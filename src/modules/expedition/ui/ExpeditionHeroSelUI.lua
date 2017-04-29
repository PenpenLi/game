module(..., package.seeall)

local HeroFightListUI = require("src/ui/HeroFightListUI")
setmetatable(_M, {__index = HeroFightListUI})

local expeditionData = require("src/modules/expedition/ExpeditionData").getInstance()
local Define = require("src/modules/expedition/ExpeditionDefine")
local Hero = require("src/modules/hero/Hero")
local Config = require("src/config/ExpeditionConfig").Config
local FightDefine = require("src/modules/fight/Define")

function new()
	local enemyList = {}
	local index = 1
	for _,hero in ipairs(expeditionData:getEnemyHeroList()) do
		if hero.fightAttr.hp > 0 then
			enemyList[index] = hero
		end
		index = index + 1
	end
	local ctrl = HeroFightListUI.new(enemyList)
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "ExpeditionHeroSelUI"
	ctrl:init()
	return ctrl
end


function init(self)
	HeroFightListUI.init(self)

	self.touchParent = false
	self.rec:setVisible(true)
	self:addArmatureFrame("res/common/effect/heroRec/HeroRec.ExportJson")
	Common.setBtnAnimation(self.rec._ccnode,"HeroRec","1",{x=-52,y=7})
	self:resetHeroFightList(expeditionData:getExpeditionList())
end

function addStage()
end

function setDefaultHeroList(self, list)
	--local defaultHero = {"Mai","Ryo","Terry","Iori"}
	--for i = 1,#defaultHero do
	--	if Hero.heroes[defaultHero[i]] and Hero.heroes[defaultHero[i]].fightAttr.hp > 0 then
	--		table.insert(list, defaultHero[i])
	--	end
	--end
end

function getHeroList()
	local dieList = {}
	local list = {}
	for _,h in pairs(expeditionData:getMyHeroList()) do
		if h.fightAttr.hp > 0 then
			table.insert(list, h)
		else
			table.insert(dieList, h)
		end
	end
	table.sort(list, function(a,b)
		return a.lv > b.lv
	end)	
	for _,v in pairs(dieList) do
		table.insert(list, v)
	end
	return list
end

function setFightHeros(self)
	local fightHeroes = {}
	for _,hname in pairs(self.heroFightList) do
		for _,hero in pairs(expeditionData:getMyHeroList()) do
			if hname == hero.name and hero.fightAttr.hp > 0 then
				table.insert(fightHeroes, hero)
				break
			end
		end
	end
	self.fightHeroes = fightHeroes
end

function toFightScene(self,fightType,args)
	HeroFightListUI.toFightScene(self, FightDefine.FightType.expedition)
end

function sendFightMsg(self)
	local tab = {}
	for _,name in pairs(expeditionData:getExpeditionList()) do
		table.insert(tab, name)
	end
	Network.sendMsg(PacketID.CG_EXPEDITION_ENTER, tab)
end

function prepareHeroes(self)
	HeroFightListUI.prepareHeroes(self)
	--队长携带怒气，援助
	if #self.AHeroes > 0 then
		local hero = self.AHeroes[1]
		hero.fightAttr.rage = expeditionData:getHeroRage()
		hero.fightAttr.assist = expeditionData:getHeroAssist()
		print('A lastRage ============================' .. hero.fightAttr.rage .. ' lastAssist = ' .. hero.fightAttr.assist)
	end
	if #self.BHeroes > 0 then
		local hero = self.BHeroes[1]
		hero.fightAttr.rage = expeditionData:getEnemyRage()
		hero.fightAttr.assist = expeditionData:getEnemyAssist()
		print('B lastRage ============================' .. hero.fightAttr.rage .. ' lastAssist = ' .. hero.fightAttr.assist)
	end
end

function onFightEnd(self,event)
	if event.winer ~= '' then
		local result = Define.COPY_END_FAIL
		Stage.currentScene:getUI().suspend.touchEnabled = false
		Stage.currentScene:getUI().pause:setVisible(false)
		if event.winer == 'A' then
			result = Define.COPY_END_SUCCESS
			event.infoB.power = 0
			event.infoB.assist = 0
			if event.infoA.assist < 500 then
				event.infoA.assist = event.infoA.assist + 100
			end
		end

		local infoA = event.infoA
		local indexA = infoA.index
		local hpA = infoA.hp
		local myHeroHpList = {}
		local index = 0
		for i=1,4 do
			local hname = self.heroFightList[i]
			if hname then
				index = index + 1 
				for _,data in pairs(expeditionData:getMyHeroHpList()) do
					if data.name == hname then
						if index < indexA then
							table.insert(myHeroHpList, {name=hname,hp=0})
							self.heroFightList[i] = nil
						elseif index == indexA then
							table.insert(myHeroHpList, {name=hname,hp=hpA})
							if hpA == 0 then
								self.heroFightList[i] = nil
							end
						else
							table.insert(myHeroHpList, data)
						end
					end
				end
			end
		end
		expeditionData:setExpeditionList(self.heroFightList)

		local infoB = event.infoB
		local indexB = infoB.index
		local hpB = infoB.hp
		local list = expeditionData:getEnemyHeroHpList()
		local enemyHeroHpList = {}
		for i=1,4 do
			local data = list[i]
			if data then
				index = index + 1
				if index < indexB then
					table.insert(enemyHeroHpList, {name=data.name,hp=0})
				elseif index == indexB then
					table.insert(enemyHeroHpList, {name=data.name,hp=hpB})
				else
					table.insert(enemyHeroHpList, data)
				end
			end
		end

		Network.sendMsg(PacketID.CG_EXPEDITION_END, result, 
		event.infoA.power, event.infoA.assist, myHeroHpList,
		event.infoB.power, event.infoB.assist, enemyHeroHpList)
	else
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
		scene:addEventListener(Event.InitEnd, function()
			UIManager.replaceUI("src/modules/expedition/ui/ExpeditionUI")
		end)
	end

	--重置英雄血量
	Hero.resetAllHeroFightAttr()
end

function refreshListItem(self, hitem, hero)
	hitem.dead:setVisible(true)
	hitem.hp:setVisible(true)
	hitem.hpback:setVisible(true)

	if not hero.fightAttr or hero.fightAttr.hp > 0 then
		hitem.dead:setVisible(false)
	else
		hitem.dead._ccnode:setLocalZOrder(100)
		hitem.dead:setVisible(true)
	end

	hitem.hp:setScaleX(hero.fightAttr.hp / hero.dyAttr.maxHp)

	print('fightAttr.hp = ' .. hero.fightAttr.hp ..  ' maxHP = ' .. hero.dyAttr.maxHp)
end

--function showHeroes(self)
--	HeroFightListUI.showHeroes(self)
--
--	self.fightlist.lantiao:setVisible(true)
--	self.fightlist.lantiaobg:setVisible(true)
--	self.fightlist.lantiao:setScaleX(expeditionData:getHeroRage() / 300)
--end

function refresh(self)
	self:showHeroes()
end

function clickHero(self, event, target, h, hitem)
	if h.fightAttr.hp > 0 then
		HeroFightListUI.clickHero(self, event, target, h, hitem)
	else
		Common.showMsg("不能选择阵亡英雄")
	end
end

function doClose(self)
	--重置英雄血量
	Hero.resetAllHeroFightAttr()
end

function onClickRecHero(self)
	local conf = Config[expeditionData:getCurId()]
	local ui = HeroFightListUI.onClickRecHero(self)
	--ui:setPosition(ui._skin.width/2, ui._skin.height/Stage.uiScale/2)
	ui:setRec(conf.recType,conf.recDesc,conf.recHero)
	ui:setPosition(ui:getContentSize().width/2,ui:getContentSize().height/2-Stage.uiBottom)
end
