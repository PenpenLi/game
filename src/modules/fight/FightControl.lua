module(..., package.seeall)
local HeroDefine = require("src/modules/hero/HeroDefine")
local SkillLogic = require("src/modules/skill/SkillLogic")
local SkillConfig = require("src/config/SkillConfig").Config

function new(heroAList,heroBList)
	local o = {
		heroAList = heroAList,
		heroBList = heroBList,
		heroAIndex = 1,
		heroBIndex = 1,
	}
	setmetatable(o,{__index = _M})
	o:init()
	return o
end

function init(self)
	--援助加成
	SkillLogic.calDyAttrByAssist(self)
end

function getRoundNum(self)
	return self.heroAIndex + self.heroBIndex - 1
end

---[[
--report格式
local tmp = {
	--1215,1209,1204,1205
	---[[
	{
		--板奇良 上重脚+站重拳+极限连流拳+飞燕痴风腿
		isAHit= false,
		{skill={actionId = 1222}},
		--{skill=skillObj},
		--{skill=skillObj},
		--{skill=skillObj},
		--{skill=skillObj},
		{skill={actionId = 1209}},
		{skill={actionId = 1204}},
		{skill={actionId = 1205}},
	},
	{
		isAHit= false,
		{skill={actionId = 1222}},
		--{skill=skillObj},
		--{skill=skillObj},
		--{skill=skillObj},
		--{skill=skillObj},
		{skill={actionId = 1209}},
		{skill={actionId = 1204}},
		{skill={actionId = 1205}},
	},
	--]]
	
}
--]]
function compareCareer(self,careerA,careerB)
	--
	--[[
	do
		return true
	end
	--]]
	if HeroDefine.Grams[careerA] == careerB then
		return true
	elseif HeroDefine.Grams[careerB] == careerA then
		return false
	else
		local oa = SkillLogic.getSkillOrderByCareer(self:getHeroA(),careerA) 
		local ob = SkillLogic.getSkillOrderByCareer(self:getHeroB(),careerB)
		if oa ~= ob then
			return oa > ob
		else
			return math.random(1,10) < 5
		end
		--return SkillLogic.getSkillOrderByCareer(self:getHeroA(),careerA) >= SkillLogic.getSkillOrderByCareer(self:getHeroB(),careerB)
	end
end

function createRound(self,isAHit,skillList)
	local round = {
		isAHit = isAHit
	}
	print('======================create=================')
	for _,v in pairs(skillList) do
		v:randomActionId()
		--table.insert(round,{skillId = SkillLogic.skillId2ActionId(v.skillId),skill=v--[[isCombo = v.isCombo--]]})
		table.insert(round,{skill=v})
		print('------------------skillList:',v.group.groupId,v.skillId)
	end
	return round
end
local careerTableA = {
	HeroDefine.CAREER_A,
	HeroDefine.CAREER_B,
	HeroDefine.CAREER_C,
}
local careerTableB = {
	HeroDefine.CAREER_A,
	HeroDefine.CAREER_B,
	HeroDefine.CAREER_C,
}

function createReport(self)
	--[[
	do
		return tmp
	end
	--]]
	local report = {
	}

	local r = math.random(1,2)
	local atkSpeedA = self:getHeroA().dyAttr.atkSpeed
	local atkSpeedB = self:getHeroB().dyAttr.atkSpeed

	local s1 = 1
	local s2 = 1
	while s1 + s2 < 30 do
		local t1 = 10000 * s1 / atkSpeedA
		local t2 = 10000 * s2 / atkSpeedB
		if t1 < t2 then
			local skillList = SkillLogic.getSkillListByRand(self:getHeroA())
			table.insert(report,self:createRound(true,skillList))
			s1 = s1 + 1
		elseif t1 > t2 then
			local skillList = SkillLogic.getSkillListByRand(self:getHeroB())
			table.insert(report,self:createRound(false,skillList))
			s2 = s2 + 1
		else
			r = r + 1
			s1 = s1 + 1
			s2 = s2 + 1
			if r % 2 == 1 then
				local skillList = SkillLogic.getSkillListByRand(self:getHeroA())
				table.insert(report,self:createRound(true,skillList))

				local skillList = SkillLogic.getSkillListByRand(self:getHeroB())
				table.insert(report,self:createRound(false,skillList))
			else
				local skillList = SkillLogic.getSkillListByRand(self:getHeroB())
				table.insert(report,self:createRound(false,skillList))

				local skillList = SkillLogic.getSkillListByRand(self:getHeroA())
				table.insert(report,self:createRound(true,skillList))
			end
		end
	end
	return report



	--[[
	careerTableA[4] = self:getHeroA().career
	careerTableB[4] = self:getHeroB().career
	for _=1,30 do
		local careerA = careerTableA[math.random(1,3)]
		local careerB = careerTableB[math.random(1,3)]
		local ret = self:compareCareer(careerA,careerB)
		if ret then
			local skillList = SkillLogic.getSkillListByRand(self:getHeroA(),careerA)
			table.insert(report,self:createRound(true,skillList))
		else
			local skillList = SkillLogic.getSkillListByRand(self:getHeroB(),careerA)
			table.insert(report,self:createRound(false,skillList))
		end
	end
	--Common.printR(report)
	return report
	--]]
end

function nextHeroA(self)
	if self.heroAIndex < #self.heroAList - 1 then
		self.heroAIndex = self.heroAIndex + 1
		return true
	else
		return false
	end
end

function hasNextHeroA(self)
	return self.heroAIndex < #self.heroAList - 1
end

function nextHeroB(self)
	if self.heroBIndex < #self.heroBList - 1 then
		self.heroBIndex = self.heroBIndex + 1
		return true
	else
		return false
	end
end

function hasNextHeroB(self)
	return self.heroBIndex < #self.heroBList - 1
end

function getHeroA(self)
	return self.heroAList[self.heroAIndex]
end

function getAssistA(self)
	return self.heroAList[#self.heroAList]
end

function getHeroB(self)
	return self.heroBList[self.heroBIndex]
end

function getAssistB(self)
	return self.heroBList[#self.heroBList]
end
