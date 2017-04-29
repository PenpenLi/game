module(..., package.seeall)
local HeroFightListUI = require("src/ui/HeroFightListUI")
setmetatable(_M, {__index = HeroFightListUI})
local Def = require("src/modules/hero/HeroDefine")
local Hero = require("src/modules/hero/Hero")
local FightControl = require("src/modules/fight/FightControl")
local LevelConfig = require("src/config/LevelConfig").Config
local Monster = require("src/modules/hero/Monster")
local ChapterDefine = require("src/modules/chapter/ChapterDefine")
local Common = require("src/core/utils/Common")
local Chapter = require("src/modules/chapter/Chapter")

function new(levelId,difficulty)
	local monster = Monster.getMonsterObjectByLevelId(levelId,difficulty)
	local ctrl = HeroFightListUI.new(monster)
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "HeroExpeditionUI"
	ctrl:init(levelId,difficulty)
	return ctrl
end

function onFightEnd(self,event)
	local fightHeroes = {}
	for i=1,4 do
		if self.heroFightList[i] then
			fightHeroes[i] = self.heroFightList[i]
		else
			fightHeroes[i] = ''
		end
	end

	if event.winer == 'A' then
		Network.sendMsg(PacketID.CG_CHAPTER_FB_END,self.levelId,self.difficulty,ChapterDefine.WIN,fightHeroes)
	else
		Network.sendMsg(PacketID.CG_CHAPTER_FB_END,self.levelId,self.difficulty,ChapterDefine.DEFEATED,fightHeroes)
	end
end


function init(self,levelId,difficulty)
	self.levelId = levelId
	self.difficulty = difficulty
	HeroFightListUI.init(self)
	self:resetHeroFightList(Hero.expedition)
end


-- 	-- local scene = require("src/scene/FightScene").new()
-- 	-- Stage.replaceScene(scene)
-- end
