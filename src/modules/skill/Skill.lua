module(...,package.seeall)

local BaseMath = require("src/modules/public/BaseMath")

local SkillConfig = require("src/config/SkillConfig").Config
local SkillGroupConfig = require("src/config/SkillGroupConfig").Config
local SkillDefine = require("src/modules/skill/SkillDefine")

function new(group,skillId,lv,pos)
	local o = {
		name = "",
		type = SkillDefine.TYPE_NORMAL,
		lv = lv,
		pos = pos,
		groupId = group.groupId,
		group = group,
		skillId = skillId,
		atk = 0,
		atkB = 0,
		rageA = 0,		--怒气
		rageD = 0,
		hit = 0,
		actionId = 0,
		damageBase = 0,
		isCrtHit = false, --暴击
		isBlock = false,	--被格挡
		bufferType = "",
		isDebuffer = false,
		buffer = 0,		--
		assist = 0,		--援助属性
		extra = 1,
		finalExtra = 1,
	}
	setmetatable(o,{__index=_M})
	o:init()
	return o
end

function init(self)
	local pos = self.pos
	local conf = SkillGroupConfig[self.groupId]
	assert(conf,"lost skill conf==>" .. self.skillId .. "==>goupId=" .. self.groupId)
	self.conf = conf
	self.type = conf.type
	self.name = conf.name
	assert(conf.atk[pos],"skill conf atk error===>groupId=" .. self.groupId)
	assert(conf.atkBase[pos],"skill conf atkBase error===>groupId=" .. self.groupId)
	assert(conf.rageA[pos],"skill conf rageA error===>groupId=" .. self.groupId)
	assert(conf.rageD[pos],"skill conf rageD error===>groupId=" .. self.groupId)
	assert(conf.damageBase[pos],"skill conf damageBase error===>groupId=" .. self.groupId)
	self.damageBase = conf.damageBase[pos]
	self.damageBaseB = conf.damageBaseB[pos]
	self.atk = BaseMath.getSkillAttr(self.lv,conf.atk[pos],conf.atkBase[pos])
	self.atkB = BaseMath.getSkillAttr(self.lv,conf.atkB[pos],conf.atkBaseB[pos])
	self.rageA = BaseMath.getSkillAttr(self.lv,conf.rageA[pos],conf.rageABase[pos])
	self.rageD = BaseMath.getSkillAttr(self.lv,conf.rageD[pos],conf.rageDBase[pos])
	self.bufferType = conf.bufferType
	self.isDebuffer = conf.isDebuffer == 1
	if conf.bufferType ~= "" and conf.bufferType ~= "none" then
		--buffer
		assert(conf.buffer[pos],"skill conf buffer error===>groupId=" .. self.groupId)
		assert(conf.bufferBase[pos],"skill conf bufferBase error===>groupId=" .. self.groupId)
		self.buffer = BaseMath.getSkillAttr(self.lv,conf.buffer[pos],conf.bufferBase[pos])
	end
end

function randomActionId(self)
	--self.actionId = SkillLogic.skillId2ActionId(self.skillId)	
	self.actionId = SkillConfig[self.skillId].action[math.random(1,#SkillConfig[self.skillId].action)]
end

function getActionId(self)
	return self.actionId
end

function getGroupName(self)
	return SkillGroupConfig[self.groupId].groupName
end

--伤害
function getAtk(self)
	--return self.atk + self.damageBase * val
	return self.atk 
end

function copyDyAttr(fighter)
	local hero = fighter.hero
	local dest = {}	
	for k,v in pairs(hero.dyAttr) do
		dest[k] = fighter:getDyAttr(k) 
	end
	return dest
end

local randomBuffer = {crthit=true,antiCrthit=true,block=true,antiBlock=true,rageR=true}
--最终伤害
--攻方最终造成的伤害=｛攻方技能参数*【pow（攻方攻击值+攻方技能攻击值），2】/（攻方攻击值+攻方技能攻击值+守方防御值）+攻方真实伤害｝*if（攻方触发暴击，1.5，1）*if（守方触发格挡，0.5，1）
--攻方最终造成的伤害=｛攻方技能参数A*【pow（攻方攻击值+攻方技能攻击值），2】/（攻方攻击值+攻方技能攻击值+守方防御值）+攻方技能参数B*【pow（攻方必杀攻击值+攻方技能必杀攻击值B），2】/（攻方必杀攻击值+攻方技能必杀攻击值+守方必杀防御值）+攻方真实伤害｝*if（攻方触发暴击，1.5，1）*if（守方触发格挡，0.5，1）
--攻方最终造成的伤害=｛攻方技能参数A*（攻方攻击值+攻方技能攻击值A）*2000/(2000+守方技能防御值）+攻方技能参数B*（攻方必杀攻击值+攻方技能攻击值B）*2000/(2000+守方必杀防御值）+攻方真实伤害｝*if（攻方触发暴击，1.5，1）*if（守方触发格挡，0.5，1）
function getHarm(self,fighter)
	if fighter.master then
		--援助英雄使用召唤者本身的属性
		fighter = fighter.master 
	end
	local hero = fighter.hero
	local dyAttr = copyDyAttr(fighter)
	local eDyAttr = copyDyAttr(fighter.enemy)
	if self:isOpposite(fighter.enemy.hero) and not randomBuffer[self.bufferType] then
		--克制
		self:setBuffer(fighter,dyAttr,eDyAttr)
	end
	local tmpSkillAttr = fighter.tmpSkillAttr
	tmpSkillAttr.assistSkillAtk = tmpSkillAttr.assistSkillAtk or 0
	tmpSkillAttr.assistSkillDef = tmpSkillAttr.assistSkillDef or 0
	--print("getHarm==>bufferType=============>",tmpSkillAttr.assistSkillAtk,tmpSkillAttr.assistSkillDef)
	dyAttr.atk = dyAttr.atk + tmpSkillAttr.assistSkillAtk
	dyAttr.finalAtk = dyAttr.finalAtk + tmpSkillAttr.assistSkillAtk
	eDyAttr.def = eDyAttr.def + tmpSkillAttr.assistSkillDef
	eDyAttr.finalDef = eDyAttr.finalDef + tmpSkillAttr.assistSkillDef
	local baseHarm = self.damageBase * (dyAttr.atk+self.atk) * SkillDefine.DefFactor / (SkillDefine.DefFactor+eDyAttr.def)
	baseHarm = baseHarm + self.damageBaseB * (dyAttr.finalAtk+self.atkB) * SkillDefine.DefFactor / (SkillDefine.DefFactor+eDyAttr.finalDef)
	--local baseHarm = self.damageBase * math.pow(dyAttr.atk+skillAtk,2) / (dyAttr.atk+skillAtk+eDyAttr.def )
	--baseHarm = baseHarm + self.damageBaseB * math.pow(dyAttr.finalAtk+self.atkB,2) / (dyAttr.finalAtk+self.atkB+eDyAttr.finalDef) 
	baseHarm = baseHarm + hero.dyAttr.damage
	if self.isCrtHit then
		baseHarm = baseHarm * 1.5
	end
	if self.isBlock then
		baseHarm = baseHarm * 0.667
	end
	baseHarm = baseHarm * self.extra * self.finalExtra
	if hero.harmFunc then
		baseHarm = hero.harmFunc(self,baseHarm,fighter)
	end
	--天赋
	--接招加成
	if self.type == SkillDefine.TYPE_COMBO then
		baseHarm = baseHarm + fighter:getDyAttr("combo") 
		baseHarm = baseHarm * (1 + fighter:getDyAttr("comboR"))
	elseif self.type == SkillDefine.TYPE_BROKE then
		baseHarm = baseHarm + fighter:getDyAttr("break")
		baseHarm = baseHarm * (1 + fighter:getDyAttr("breakR"))
	elseif self.type == SkillDefine.TYPE_FINAL then
		print('--------------------------------type_final:',baseHarm,fighter:getDyAttr("pow"))
		baseHarm = baseHarm + fighter:getDyAttr("pow")
		baseHarm = baseHarm * (1 + fighter:getDyAttr("powR"))
	elseif self.type == SkillDefine.TYPE_NORMAL then
		baseHarm = baseHarm * (1 + (fighter:getDyAttr("addHarmR")))
		baseHarm = baseHarm * (1 - (fighter.enemy:getDyAttr("decHarmR")))
	end

	
	return baseHarm
end

--攻方暴击率=（攻方暴击值-守方防暴值）/暴击参数
--守方格挡率=（守方格挡值-攻方破挡值）/格挡参数
function randomHarm(self,fighter)
	fighter.tmpSkillAttr = fighter.tmpSkillAttr or {}
	local tmpSkillAttr = fighter.tmpSkillAttr
	if self.group.type == SkillDefine.TYPE_COMBO then
		--print("randomHarm==============>",tmpSkillAttr.comboSkillCounter)
		--接招克制属性继承上级
		self.isDebuffer = tmpSkillAttr.isDebuffer
		self.bufferType = tmpSkillAttr.bufferType
		self.group.career = tmpSkillAttr.skillCareer
		--计算第几次接招
		tmpSkillAttr.comboSkillCounter = tmpSkillAttr.comboSkillCounter or 0
		tmpSkillAttr.comboSkillCounter = tmpSkillAttr.comboSkillCounter + 1
		--Common.showMsg(fighter.name .. "接招+1===》" .. tmpSkillAttr.comboSkillCounter)
	else
		tmpSkillAttr.isDebuffer = self.isDebuffer
		tmpSkillAttr.bufferType = self.bufferType
		tmpSkillAttr.skillCareer = self.group.career
		if not tmpSkillAttr.lastSkillGroupId or tmpSkillAttr.lastSkillGroupId ~= self.group.groupId then
			self.extra = 1
			tmpSkillAttr.comboSkillCounter = 0
			tmpSkillAttr.lastSkillGroupId = self.group.groupId
			--Common.showMsg(fighter.name .. "重置接招计数！！！")
			--print("randomHarm reset==============>",tmpSkillAttr.comboSkillCounter)
		end
	end

	local dyAttr = copyDyAttr(fighter)
	local eDyAttr = copyDyAttr(fighter.enemy)
	if self:isOpposite(fighter.enemy.hero) and randomBuffer[self.bufferType] then
		self:setBuffer(fighter,dyAttr,eDyAttr)
	end
	if self.group.type == SkillDefine.TYPE_COMBO then
		--接招很吊，前面的技能暴击它就会爆
		self.isCrtHit = tmpSkillAttr.isCrtHit
		self.isBlock = tmpSkillAttr.isBlock 
	else
		--reset
		self.isCrtHit = false
		self.isBlock = false
	end
	--暴击
	if not self.isCrtHit and math.random(1,100) <= math.min(1,(math.max(0,(dyAttr.crthit - eDyAttr.antiCrthit)) / 2000)) * 100 then
		self.isCrtHit = true 
	end
	--天赋
	if fighter.gift.isCrtHit then
		self.isCrtHit = true
		fighter.gift.isCrtHit = nil
	end
	--格挡
	if not self.isBlock and math.random(1,100) <= math.min(0.75,(math.max(0,(eDyAttr.block - dyAttr.antiBlock)) / 2000)) * 100 then
		self.isBlock = true
	end
	--天赋
	if fighter.enemy.gift.isBlock then
		self.isBlock = true
		fighter.enemy.gift.isBlock = nil
	end
	tmpSkillAttr.isCrtHit = self.isCrtHit
	tmpSkillAttr.isBlock = self.isBlock
	local conf = SkillConfig[tmpSkillAttr.lastSkillGroupId]
	local lastSkillType 
	if conf then
		lastSkillType = conf.type
	end
	if lastSkillType == SkillDefine.TYPE_FINAL and tmpSkillAttr.comboSkillCounter == 1 then
		--大招后接招加成
		self.extra = 1.25
	elseif tmpSkillAttr.comboSkillCounter >= 2 then
		--接招衰减
		self.extra = math.max((1 - 0.1 * (tmpSkillAttr.comboSkillCounter-1)),0.5)
	end
	if self.type == SkillDefine.TYPE_FINAL then
		self.extra = self.extra * (1 + (fighter.gift.followFinalAtk or 0))
		fighter.gift.followFinalAtk = nil
	end
	--[[
	if self.type == SkillDefine.TYPE_FINAL then
		if fighter:isHiting() then
			self.finalExtra = 1.25
		else
			self.finalExtra = 1
		end
	end
	--]]
end

function getRage(self,fighter)
	return self.rageA,self.rageD
end

function setBuffer(self,fighter,aDyAttr,bDyAttr)
	local target = fighter
	local value = self.buffer
	local dyAttr = aDyAttr
	if self.isDebuffer then 
		target = fighter.enemy
		value = -self.buffer
		dyAttr = bDyAttr
	end
	if self.bufferType == "rageR" then
		--怒气
		target:getInfo():addPower(value)
	elseif dyAttr[self.bufferType] then
		dyAttr[self.bufferType] = dyAttr[self.bufferType] * (1+value)
		if self.bufferType == 'atk' then
			dyAttr['finalAtk'] = dyAttr['finalAtk'] * (1+value)
		elseif self.bufferType == 'def' then
			dyAttr['finalDef'] = dyAttr['finalDef'] * (1+value)
		end
	end
end


function isOpposite(self,enemy)
	if self.group:getIsOpenOppo() then
		return enemy.career == self.group.career
	else
		return false
	end
end

function getAssistType(self)
	local conf = self.conf.assist
	return conf.eType
end

--使用援助技能assist
function use(self,fighter)
	local scene = Stage.currentScene 
	if scene.name ~= "fight" then
		return
	end
	fighter.tmpSkillAttr = fighter.tmpSkillAttr or {}
	local tmpSkillAttr = fighter.tmpSkillAttr
	local dyAttr = fighter.hero.dyAttr
	local enemy = fighter.enemy
	local conf = self.conf.assist
	local isHurt = enemy:isHiting() 
	local fightVal = 0
	if fighter.name == "heroA" then
		fightVal = Stage.currentScene.fightControl:getAssistA():getFight() --战斗力
	else
		fightVal = Stage.currentScene.fightControl:getAssistB():getFight() --战斗力
	end
	local scale = fightVal / SkillDefine.AssistFight + 1
	local value = 0
	local value1
	if conf.eType == "atk" then
		--召唤攻击
		if enemy:getInfo():getHp() < (enemy.hero.dyAttr.maxHp * conf.f1) then
			self.extra = 1 + conf.f2
		else
			self.extra = 1 + conf.f3
		end
	elseif conf.eType == "hp" then
		--瞬加血
		local factor = BaseMath.getSkillAttr(self.lv,conf.v1,conf.f1) 
		factor = factor * scale
		value = dyAttr.maxHp * factor 
		fighter:getInfo():addHp(value)
		value = factor 
	elseif conf.eType == "rageA" then
		--瞬加怒
		if not enemy:isHiting() then
			--己方非受击
			--value = conf.v1 + self.lv * conf.f1
			value = BaseMath.getSkillAttr(self.lv,conf.v1,conf.f1)
		else
			--己方受击
			--value = conf.v2 + self.lv * conf.f2
			value = BaseMath.getSkillAttr(self.lv,conf.v2,conf.f2)
		end
		value = value * scale
		fighter:getInfo():addPower(value)
	elseif conf.eType == "rageD" then
		--瞬减怒
		if not fighter:isHiting() then
			--value = conf.v1 + self.lv * conf.f1
			value = BaseMath.getSkillAttr(self.lv,conf.v1,conf.f1)
		else
			--敌方受击
			--value = conf.v2 + self.lv * conf.f2
			value = BaseMath.getSkillAttr(self.lv,conf.v2,conf.f2)
		end
		value = value * scale
		fighter.enemy:getInfo():addPower(-value)
	elseif conf.eType == "atkBuf" then
		--加攻击BUF
		if fighter:getInfo():getHp() < (dyAttr.maxHp * conf.f1) then
			value = dyAttr.atk * BaseMath.getSkillAttr(self.lv,conf.v1,conf.f2) 
		else
			--value = dyAttr.atk * (conf.v2+self.lv*conf.f3)
			value = dyAttr.atk * BaseMath.getSkillAttr(self.lv,conf.v2,conf.f3) 
		end
		value = value * scale
		tmpSkillAttr.assistSkillAtk = value 
		scene:addTimer(function() 
			tmpSkillAttr.assistSkillAtk = 0 
		end,conf.it,1)
		value1 = conf.it
	elseif conf.eType == "timeA" then
		--控制时间
		--value = conf.v1 + self.lv * f1
		value = BaseMath.getSkillAttr(self.lv,conf.v1,conf.f1)
		Stage.currentScene.ui:addCDTime(value)
	elseif conf.eType == "timeD" then
		--控制时间
		--value = conf.v1 + self.lv * f1
		value = BaseMath.getSkillAttr(self.lv,conf.v1,conf.f1)
		Stage.currentScene.ui:addCDTime(-value)
	elseif conf.eType == "hpR" then
		--缓慢加血 
		assert(conf.lt,"assist conf error==>lt=>" .. self.group.groupId)
		assert(conf.it,"assist conf error==>it=>" .. self.group.groupId)
		--value = conf.v1 + self.lv * f1
		value = BaseMath.getSkillAttr(self.lv,conf.v1,conf.f1)
		fighter:getInfo():addHp(value)
		local maxTimes = math.floor(conf.lt / conf.it)
		scene:addTimer(function() 
			fighter:getInfo():addHp(value)
		end,conf.it,maxTimes)
	elseif conf.eType == "defD" then
		--减少敌方防御BUF
		value = -enemy.hero.dyAttr.def * BaseMath.getSkillAttr(self.lv,conf.v1,conf.f1)
		value = value * scale
		tmpSkillAttr.assistSkillDef = value
		scene:addTimer(function() 
			tmpSkillAttr.assistSkillDef = 0 
		end,conf.it,1)
		value1 = conf.it
	end
	return conf.eType,value,value1
end

function getAssistVal(self,lv)
	local conf = self.conf.assist
	local value = 0
	if conf.eType == "atk" then
		value = BaseMath.getSkillAttr(lv,conf.f1,conf.f2)
	elseif conf.eType == "hp" then
		--瞬加血
		value = BaseMath.getSkillAttr(lv,conf.v1,conf.f1)
	elseif conf.eType == "rageA" then
		value = BaseMath.getSkillAttr(lv,conf.v1,conf.f1)
	elseif conf.eType == "rageD" then
		value = BaseMath.getSkillAttr(lv,conf.v1,conf.f1)
	elseif conf.eType == "atkBuf" then
		value = BaseMath.getSkillAttr(lv,conf.v1,conf.f2) 
	elseif conf.eType == "timeA" then
		--控制时间
		value = BaseMath.getSkillAttr(lv,conf.v1,conf.f1)
	elseif conf.eType == "timeD" then
		value = BaseMath.getSkillAttr(lv,conf.v1,conf.f1)
	elseif conf.eType == "hpR" then
		value = BaseMath.getSkillAttr(lv,conf.v1,conf.f1)
	elseif conf.eType == "defD" then
		value = BaseMath.getSkillAttr(lv,conf.v1,conf.f1)
	end
	return value
end



















