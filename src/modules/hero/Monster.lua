module(...,package.seeall)
setmetatable(_M, {__index = EventDispatcher})


local SkillGroup = require("src/modules/skill/SkillGroup")
local MonsterConfig = require("src/config/MonsterConfig").Config
local Def = require("src/modules/hero/HeroDefine")
local LevelConfig = require("src/config/LevelConfig").Config
-- MonsterList = {}


function new(monsterId)
	local m = {}
	setmetatable(m,{__index=_M})
	local conf = MonsterConfig[monsterId]
	assert(conf,"lost monster conf=>" .. monsterId)
	m.monsterId = monsterId
	m.name = conf.name
	m.cname = Def.DefineConfig[m.name].cname
	m.career = Def.DefineConfig[m.name].career
	m.gender = Def.DefineConfig[m.name].gender
	m.ai = conf.ai
	m.breakRate = conf.breakRate
	m.career = conf.career or 1
	m.quality = conf.quality
	m.careerName = Def.CAREER_NAMES[m.career]
	m.dyAttr = {
		maxHp = conf.maxHp,
		atkSpeed = conf.atkSpeed,
		block = conf.block,
		antiBlock = conf.antiBlock,
		damage = conf.damage,
		atk = conf.atk,
		def = conf.def,
		crthit = conf.crthit,
		antiCrthit = conf.antiCrthit,
		hpR = conf.hpR,
		rageR = conf.rageR,
		assist = conf.assist,
		rageRByHp = conf.rageRByHp,
		rageRByWin = conf.rageRByWin,
		finalAtk = conf.finalAtk,
		finalDef = conf.finalDef,
		initRage = conf.initRage,
	}
	m.lv = conf.lv
	m.fightAttr = {}
	--技能列表
	m.skillGroupList = require("src/modules/skill/SkillLogic").monsterInit(m)
	m.gift = {}
	for k,v in ipairs(conf.gift) do
		m.gift[k] = 1
	end
	return m
end

function copy(self)
	local hero = new(self.monsterId)
	hero.dyAttr = Common.deepCopy(self.dyAttr)
	local cp = {}
	for _,group in ipairs(self.skillGroupList) do
		local newGroup = SkillGroup.new(hero,group.groupId)
		newGroup.equipType = group.equipType
		newGroup:setLv(group.lv)
		cp[#cp+1] = newGroup 
	end
	hero.skillGroupList = cp
	return hero
end

-- for monsterId,conf in pairs(MonsterConfig) do 
-- 	MonsterList[monsterId] = new(monsterId)
-- end

function getSkillGroupList(self)
	return self.skillGroupList
end



function getMonsterObjectByIdList(monsterIdList)
	local mlist = {}
	for i=1,math.max(1,#monsterIdList-1) do
		mlist[i] = new(monsterIdList[i])
	end
	mlist[4] = new(monsterIdList[#monsterIdList])
	return mlist
end

function getMonsterNameByIdList(monsterIdList)
	local idList = getMonsterObjectByIdList(monsterIdList)
	local mlist = {}
	for i,monster in pairs(idList) do
		mlist[i] = monster.name
	end
	return mlist
end
-- 获得某个副本的怪物列表，主要是给出战界面使用
function getMonsterIdListByLevelId(levelId,difficulty)
	if LevelConfig[levelId] and LevelConfig[levelId][difficulty] then
		local mlist = {}
		local monster = LevelConfig[levelId][difficulty].monster
		local assist = monster[#monster]
		for i=1,math.max(1,#monster-1) do
			mlist[i] = LevelConfig[levelId][difficulty].monster[i]
		end
		mlist[4] = assist
		return mlist
	else
		return 
	end
end

function getMonsterNameByLevelId(levelId,difficulty)
	local mlist = {}
	for i,monsterId in pairs(getMonsterIdListByLevelId(levelId,difficulty)) do 
		mlist[i] = MonsterConfig[monsterId].name
	end
	return mlist
end

function getMonsterObjectByLevelId(levelId,difficulty)
	local mlist = {}
	for i,monsterId in pairs(getMonsterIdListByLevelId(levelId,difficulty)) do
		if monsterId then
			mlist[i] = new(monsterId)
		end
	end
	return mlist
end

function getFight(self)
	return 0
end






