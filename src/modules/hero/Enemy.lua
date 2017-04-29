module(...,package.seeall)
setmetatable(_M, {__index = EventDispatcher}) 
local Def = require("src/modules/hero/HeroDefine")
local SkillLogic = require("src/modules/skill/SkillLogic")
local SkillGroup = require("src/modules/skill/SkillGroup")

function new(name,exp,lv,quality,ctime,dyAttr,skillGroupList,gift)
	local h = {}
	h.name = name
	h.exp = exp
	h.lv = lv
	h.quality = quality
	h.gender = Def.DefineConfig[name].gender
	h.ctime = ctime
	h.career = Def.DefineConfig[name].career
	h.careerName = Def.CAREER_NAMES[h.career]
	h.cname = Def.DefineConfig[name].cname
	h.trend = Def.DefineConfig[name].trend
	h.breakRate = Def.DefineConfig[name].breakRate
	h.trendtxt = Def.TREND_NAMES[h.trend]
    h.dyAttr = processDyAttr(dyAttr)
    h.fightAttr = {hp=nil,rage=nil,assist=nil}
	h.gift = gift
	setmetatable(h,{__index=_M})
	h.skillGroupList = SkillLogic.enemyInit(h,skillGroupList)
	return h
end

function copy(self)
	local hero = new(self.name,self.exp,self.lv,self.quality,self.ctime,{},{})
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

function processDyAttr(dyAttr)
	for _,attr in ipairs(Def.DecimalAttrs) do
		if dyAttr[attr] then
			dyAttr[attr] = dyAttr[attr]/100
		end
	end
	return dyAttr
end

function getSkillList(self)
	return self.skillList
end

function getSkillGroupList(self)
	return self.skillGroupList
end

function getFight(self)
	return 0
end




