module(..., package.seeall)

local GiftDefine = require("src/modules/gift/GiftDefine")
local GiftLogic = require("src/modules/gift/GiftLogic")

local maxPower = 300
--local perPower = 100
local maxAssist = 500
local perAssist = 100
--local maxHp = 300
function new(maxHp,hp,power,assist)
	maxHp = maxHp or 300
	hp = hp or maxHp
	power = power or 0
	assist = assist or 0
	local data = { 
		maxHp = maxHp, 
	    hp = hp,
	    power = power,   --怒气值
		assist = assist,
	}
	setmetatable(data, {__index = _M})
	data:init()

	for k,v in pairs(data) do
		if type(v) == "number" then
			data[k] = Common.mixVal(v)
		end
	end
	local temp = {coreData=data}
	local mt = {}
	mt.__index = function(t,k)
		local v = t.coreData[k]
		if v and type(v) == "number" then
			v = Common.demixVal(v)
		end
		return v
	end

	mt.__newindex = function(t,k,v)
		if v and type(v) == "number" then
			v = Common.mixVal(v)
		end
		t.coreData[k] = v
	end
	setmetatable(temp, mt)

    return temp
end

function init(self)
	self:setAssist(self.assist)
	self:setPower(self.power)
end

function setHero(self,hero)
	self.hero = hero
end

function calPower(p,perPower)
    return math.floor(p / perPower)
end

function getPowerCnt(self,perPower)
    return calPower(self.power,perPower)
end

function canUsePower(self,perPower)
	return self.power >= perPower
end

function getPowerPercent(self,perPower)
	perPower = perPower or 100
	return 100 * (self.power % perPower) / perPower
	--[[
	if self.power >= maxPower then
		return 100
	else
		return 100 * (self.power % perPower) / perPower
	end
	--]]
end

function getMaxPower(self)
	return maxPower
end

function getPower(self)
	return self.power
end

function setPower(self,p)
	self.power = p
end

function setNoAddPower(self,flag)
	self.noAddPower = flag
end

function addPower(self,p)
	if self.noAddPower then
		return
	end
	if self.hero.gift.noAddPower then
		return
	end
    self.power = math.min(self.power + p,maxPower)
	self.power = math.max(self.power,0)
	GiftLogic.checkGift(self.hero,GiftDefine.ConditionType.pow)
end

function decPower(self,perPower)
	self.power = math.max(0,self.power - perPower)
end

function calAssist(p)
    return math.floor(p / perAssist)
end

function getAssistCnt(self)
    return calAssist(self.assist)
end

function canUseAssist(self)
	return self.assist >= perAssist
end

function getAssistPercent(self)
    return 100 * (self.assist % perAssist ) / perAssist
end

function getAssist(self)
	return self.assist
end

function setAssist(self,p)
	self.assist = math.min(p,maxAssist)
	self.assist = math.max(self.assist,0)
end

function addAssist(self,p)
    self.assist = math.min(self.assist + p,maxAssist)
    self.assist = math.max(self.assist,0)
end

function decAssist(self)
	self.assist = math.max(0,self.assist - perAssist)
end

function setMaxHp(self,hp)
	self.hp = self.hp + math.max(0,hp-self.maxHp)
	self.maxHp = hp
	self.hp = math.min(self.hp,self.maxHp)
end

function setHp(self,hp)
	self.hp = math.max(hp,0)
end

function getMaxHp(self)
	return self.maxHp
end

function getHp(self)
    return self.hp
end

function addHp(self,hp)
	if self:isDie() then
		return
	end
    self.hp = math.min(self.hp + hp,self.maxHp)
	self.hp = math.max(0,self.hp)
end

function decHp(self,hp)
	--hp = 0
    self.hp = math.max(self.hp - hp,0)
	if self.hero.fightAttr and self.hero.fightAttr.noDie then
		self.hp = math.max(self.hp,1)
	end
end

function getHpPercent(self)
    return 100 * self.hp / self.maxHp
end

function isDie(self)
    return self.hp <= 0
end
