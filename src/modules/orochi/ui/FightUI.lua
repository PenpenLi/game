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

local OrochiConfig = require("src/config/OrochiConfig").Config
local Logic = require("src/modules/orochi/OrochiLogic")
local Define = require("src/modules/orochi/OrochiDefine")

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
	self.hadFightHeroList = Logic.getHadFightHeroList()
	HeroFightListUI.init(self)
	self:resetHeroFightList(Logic.Expedition,{2,3})
	self.levelId = levelId
	self.rec:setVisible(false)
	--self:addArmatureFrame("res/common/effect/heroRec/HeroRec.ExportJson")
	--Common.setBtnAnimation(self.rec._ccnode,"HeroRec","1",{x=-52,y=7})
end

function showHeroes(self)
	HeroFightListUI.showHeroes(self)
	for _,heroName in pairs(self.hadFightHeroList) do
		local item = self.heroGridList[heroName]
		item:shader(Shader.SHADER_TYPE_GRAY)
	end
end

function clickHero(self, event, target, hero, hitem)
	if self.hadFightHeroList[hero.name] == hero.name then
		Common.showMsg(string.format("%s","该英雄无法在该层中再次挑战"))
		return
	end
	HeroFightListUI.clickHero(self, event, target, hero, hitem)
end

function getHeroList(self)
	local hlist = HeroFightListUI.getHeroList(self)
	table.sort(hlist,function(a,b) 
		if self.hadFightHeroList[a.name] ==  self.hadFightHeroList[b.name] then
			return a.lv > b.lv
		else
			return not self.hadFightHeroList[a.name] 
		end
	end)
	return hlist
end

function clear(self)
	HeroFightListUI.clear(self)
	Instance = nil
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 5, groupId = GuideDefine.GUIDE_OROCHI})
end


local clickTime = 0
function onFight(self,event,target)
	if (os.time() - clickTime) < 1 then
		return
	else
		clickTime = os.time()
	end
	if self:canFight() then
		Logic.fight(self.levelId,self.heroFightList)
	end
end

--[[
function prepareHeroes(self)
	HeroFightListUI.prepareHeroes(self)
	local conf = OrochiConfig[self.levelId]
	local heros = self.AHeroes
	local list = {}
	for _,h in ipairs(heros) do
		local hero = h:copy() 
		--英雄属性克制
		for k,v in pairs(conf.dyAttr) do
			if hero.career ==  conf.careerA then
				hero.dyAttr[k] = hero.dyAttr[k] * (1+v)
			elseif hero.career ==  conf.careerB then
				boss.dyAttr[k] = boss.dyAttr[k] * (1+v)
			end
		end
		--技能克制增强
		for _,group in ipairs(hero:getSkillGroupList()) do
			for _,skill in pairs(group.skillObjList) do
				skill.buffer = skill.buffer + conf.buffer
			end
		end
		list[#list+1] = hero
	end
	--怪物技能属性增强
	local newMonsters = {}
	for k,monster in ipairs(self.BHeroes) do
		local h = monster:copy()
		h.career = conf.career[k]
		--技能克制增强
		for _,group in ipairs(h:getSkillGroupList()) do
			for _,skill in pairs(group.skillObjList) do
				skill.buffer = skill.buffer + conf.dBuffer[k]
			end
		end
		newMonsters[#newMonsters+1] = h
	end
	self.AHeroes = list
	self.BHeroes = newMonsters 
end
--]]
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
			UIManager.replaceUI("src/modules/orochi/ui/OrochiUI")
		end)
	else
		Network.sendMsg(PacketID.CG_OROCHI_FIGHT_END,res,self.levelId)
	end
end

function toFightScene(self)
	local fightScene = HeroFightListUI.toFightScene(self)
	--fightScene:setCareerVisiable(true)
end

function onClickRecHero(self)
	local conf = OrochiConfig[self.levelId]
	local ui = HeroFightListUI.onClickRecHero(self)
	ui:setRec(conf.recType,conf.recDesc,conf.recHero)
end

