module(..., package.seeall)

--report格式
local tmp = {
	{
		isAHit= false,
		{skillId = 1108,isCombo = false},
	},
	{
		isAHit= true,
		{skillId = 1106,isCombo = false},
	},
	--一组技能 
	{
		isAHit= true,
		{skillId = 1122,isCombo = false},
		{skillId = 1111,isCombo = false},
		{skillId = 1103,isCombo = false},
	},
	--...
	{
		isAHit= false,
		{skillId = 1122,isCombo = false},
		{skillId = 1109,isCombo = false},
		{skillId = 1103,isCombo = false},
	},
	{
		isAHit= false,
		{skillId = 1124,isCombo = false},
		{skillId = 1102,isCombo = false},
	},
	{
		isAHit= true,
		{skillId = 1124,isCombo = false},
		{skillId = 1111,isCombo = false},
		{skillId = 1105,isCombo = false},
	},
	{
		isAHit= false,
		{skillId = 1111,isCombo = false},
		{skillId = 1110,isCombo = false},
		{skillId = 1104,isCombo = false},
		{skillId = 1101,isCombo = false},
	},
	{
		isAHit= true,
		{skillId = 1101,isCombo = false},
	},
	{
		isAHit= true,
		{skillId = 1104,isCombo = false},
	},
	{
		isAHit= false,
		{skillId = 1105,isCombo = false},
	},
}
function new(report)
	local o = {
		roundIndex = 1,			--当前播放到第几个回合
		comboIndex = 1,		--当前播到该回拿的第几个技能
		report = report,	--根据英雄产生的有效战报
		record = {},		--播放战斗记录
	}

	setmetatable(o,{__index = _M})

	o:init()
	return o
end

function init(self)
	--self.report = tmp	--test
end

function setReport(self,report)
	self.report = report
end

function isAHit(self)
	return self.report[self.roundIndex].isAHit
end

function isDef(self)
	return self.report[self.roundIndex].isDef
end

function getCurrentSkill(self)
	return self.report[self.roundIndex][self.comboIndex].skill
end

function getCurrentSkillId(self)
	return self.report[self.roundIndex][self.comboIndex].skill.actionId
end

function isFirstSkill(self)
	return self.comboIndex == 1
end

function isLastSkill(self)
	return self.comboIndex == #self.report[self.roundIndex]
end

function isCombo(self)
	return not self.report[self.roundIndex].isDef and self.report[self.roundIndex][self.comboIndex].isCombo
end

function nextCombox(self)
	self.comboIndex = self.comboIndex + 1
	if not self.report[self.roundIndex][self.comboIndex] then
		self.comboIndex = 1
		self.roundIndex = self.roundIndex + 1
		if not self.report[self.roundIndex] then
			self.roundIndex = 1
			Stage.currentScene:dispatchEvent(Event.FightReport, {etype=Event.FightReport})
			return false
		end
		return false
	end
	return true
end

function getNextSkillId(self)
end

function nextRound(self)
	self.roundIndex = self.roundIndex + 1
	if not self.report[self.roundIndex] then
		self.roundIndex = 1
		Stage.currentScene:dispatchEvent(Event.FightReport, {etype=Event.FightReport})
	end
	self.comboIndex = 1
	return true
end
