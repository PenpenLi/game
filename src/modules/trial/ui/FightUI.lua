module(..., package.seeall)
local HeroFightListUI = require("src/ui/HeroFightListUI")
setmetatable(_M, {__index = HeroFightListUI}) 

local MonsterConfig = require("src/config/MonsterConfig").Config
local Hero = require("src/modules/hero/Hero")
local HeroDefine = require("src/modules/hero/HeroDefine")
local BaseMath = require("src/modules/public/BaseMath")
local Monster = require("src/modules/hero/Monster")
local Enemy = require("src/modules/hero/Enemy")
local SkillGroup = require("src/modules/skill/SkillGroup")
local SkillDefine = require("src/modules/skill/SkillDefine")
local FightDefine = require("src/modules/fight/Define")
local FightControl = require("src/modules/fight/FightControl")

local Config = require("src/config/TrialConfig").Config
local Logic = require("src/modules/trial/TrialLogic")
local Define = require("src/modules/trial/TrialDefine")

local killCnt = 0
Instance = nil

function new(levelId)
	local list = Logic.getLevelMonster(levelId)
    local ctrl = HeroFightListUI.new(list)
    setmetatable(ctrl,{__index = _M})
    ctrl:init(levelId)
	Instance = ctrl
    return ctrl
end

function init(self,levelId)
	HeroFightListUI.init(self)
	self:resetHeroFightList(Logic.getFightListById(levelId),{2,3})
	self.levelId = levelId
	self.rec:setVisible(true)
	self:addArmatureFrame("res/common/effect/heroRec/HeroRec.ExportJson")
	Common.setBtnAnimation(self.rec._ccnode,"HeroRec","1",{x=-52,y=7})
end

function clear(self)
	HeroFightListUI.clear(self)
	Instance = nil
end


function addStage(self)
	--self:setPositionY(Stage.uiBottom)
end

local clickTime = 0
function onFight(self,event,target)
	if (os.time() - clickTime) < 1 then
		return
	else
		clickTime = os.time()
	end
	if self:canFight() then
		killCnt = 0
		Logic.fight(self.levelId,self.heroFightList)
	end
end

function setMonsters(self)
	local list = Logic.getLevelMonster(self.levelId)
	self.monsters = list
end

function onFightEnd(self,event)
	if event.winer == "A" then
		res = Define.FIGHT_SUCCESS 
	elseif event.winer == "B" then
		res = Define.FIGHT_FAIL
	end
	if event.winer == "" then
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
		scene:addEventListener(Event.InitEnd, function()
			UIManager.replaceUI("src/modules/trial/ui/TrialUI",self.levelId)
		end)
	else
		Logic.fightEnd(res,self.levelId,killCnt)
	end
	--clear
	local heros = self.AHeroes
	for _,hero in ipairs(heros) do
		hero.harmFunc = nil
	end
	for _,h in ipairs(self.enemyFightList) do
		h.harmFunc = nil
	end
end

function onFightDie(self,event)
	if event.winer == "A" then
		killCnt = killCnt + 1
	end
end

function prepareHeroes(self)
	HeroFightListUI.prepareHeroes(self)
	local heros = self.AHeroes
	local conf = Config[self.levelId]
	local list = {}
	for _,hero in ipairs(heros) do
		--local hero = h:copy() 
		hero.harmFunc = function(skill,baseHarm,fighter) return self:doHarm(skill,baseHarm,fighter) end
		--[[
		if conf.type == Define.TYPE_C then
			--金币道场
			for _,v in pairs(conf.param) do
				if v.hero == hero.name then
					hero.dyAttr[v.bufferType] = hero.dyAttr[v.bufferType] * (1+v.buffer)
				end
			end
		end
		--]]
		list[#list+1] = hero
	end
	--怪物属性增强
	local newMonsters = {}
	for i=1,4 do
		local h = self.enemyFightList[i]
		--local h = monster:copy()
		if h then
			h.harmFunc = function(skill,baseHarm,fighter) return self:doHarm(skill,baseHarm,fighter) end
			newMonsters[#newMonsters+1] = h
		end
	end
	self.AHeroes = list
	self.BHeroes = newMonsters 
end

function doHarm(self,skill,baseHarm,fighter)
	local conf = Config[self.levelId]
	local param = conf.param
	--针对英雄
	local isTargetA = false
	if param.heroA then
		for _,name in pairs(param.heroA) do
			if fighter.name == "heroA" and fighter.hero.name == name then
				isTargetA = true
				break
			end
			if fighter.name == "heroB" and fighter.enemy.hero.name == name then
				isTargetA = true
				break
			end
		end
	end
	--连击
	if param.combo and fighter.name == "heroA" then
		if isTargetA then
			for _,v in ipairs(param.combo) do
				if fighter.comboCnt <= v[1] then
					baseHarm = baseHarm * (1+v[2])
					if v[2] ~= skill.comboCntFactor then
						skill.comboCntChk = true
					end
					skill.comboCntFactor = v[2]
					break
				end
			end
		end
	end
	--必杀
	if param.power and fighter.name == "heroA" then
		if skill.type == SkillDefine.TYPE_FINAL then
			for _,v in ipairs(conf.param.power) do
				if fighter:getInfo():getPower() <= v[1] then
					baseHarm = baseHarm * (1+v[2])
					break
				end
			end
		end
	end
	--暴击
	if param.crtHit then
		if not isTargetA and skill.isCrtHit then
			if param.crtHit[1] == "B" and fighter.name == "heroB" then
				baseHarm = baseHarm * param.crtHit[2]
			end
		end
	end
	--增强最终伤害
	if param.finalHarm then
		if fighter.name == "heroA" and param.finalHarm.trend == fighter.hero.trend then
			baseHarm = baseHarm * (1 + param.finalHarm.factor)
		end
	end
	return baseHarm
end

function onClickRecHero(self)
	local conf = Config[self.levelId]
	local ui = HeroFightListUI.onClickRecHero(self)
	ui:setRec(conf.recType,conf.recDesc,conf.recHero)
end

function toFightScene(self,fightType,args)
	self:prepareHeroes()
	local fightControl = FightControl.new(self.AHeroes,self.BHeroes)
	if Stage.currentScene.name == "fight" then
		return Stage.currentScene
	end
	local conf = Config[self.levelId]
	local args = {}
	for _,v in pairs(conf.openSkill) do
		args[v] = true
	end
	local scene = require("src/scene/FightScene").new(fightControl,FightDefine.FightModel.handA_autoB,FightDefine.FightType.trial,args)
	scene:addEventListener(Event.InitEnd,self.onFightInit,self)
	scene:addEventListener(Event.FightEnd,self.onFightEnd,self)
	scene:addEventListener(Event.FightDie,self.onFightDie,self)
	Stage.replaceScene(scene)
	return scene
end











