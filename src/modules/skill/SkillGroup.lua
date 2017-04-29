module(...,package.seeall)

local BaseMath = require("src/modules/public/BaseMath")

local SkillConfig = require("src/config/SkillConfig").Config
local SkillGroupConfig = require("src/config/SkillGroupConfig").Config
local SkillDefine = require("src/modules/skill/SkillDefine")
local Skill = require("src/modules/skill/Skill")
local SkillUpConfig = require("src/config/SkillUpConfig").Config
local BagData = require("src/modules/bag/BagData")
local GiftLogic = require("src/modules/gift/GiftLogic")

function new(hero,groupId)
	local o = {
		hero = hero,
		type = SkillDefine.TYPE_NORMAL,
		ctype = SkillDefine.CTYPE_NORMAL,
		groupId = groupId,
		name = "",
		equipType = SkillDefine.EQUIP_NONE,
		lv = SkillDefine.MIN_SKILL_LV,		--技能等级
		isOpen = false,							--是否已开放
		canOpen = false,					--能否开放
		skillObjList = {},						--技能列表
		exp = 0,
		assistAttr = 0,		--援助属性
	}
	setmetatable(o,{__index=_M})
	o:init()
	return o
end

function init(self)
	local conf = SkillGroupConfig[self.groupId]
	assert(conf,"lost conf===>" .. self.groupId)
	self.conf = conf
	self.name = conf.groupName
	self.type = conf.type
	self.fight = conf.fight
	self.career = conf.career
	if self.type == SkillDefine.TYPE_COVER then
		self.isOpen = true
	elseif self.type == SkillDefine.TYPE_NORMAL then
		self.ctype = SkillDefine.CTYPE_NORMAL
	elseif self.type == SkillDefine.TYPE_FINAL or self.type == SkillDefine.TYPE_COMBO or self.type == SkillDefine.TYPE_BROKE then
		self.ctype = SkillDefine.CTYPE_RAGE
	elseif self.type == SkillDefine.TYPE_ASSIST or self.type == SkillDefine.TYPE_ASSISTR then
		self.ctype = SkillDefine.CTYPE_ASSIST
		if self.type == SkillDefine.TYPE_ASSISTR then self.equipType = conf.equipType end
	end
end

function open(self)
	self.isOpen = true
end

function setLv(self,lv)
	self.lv = lv
	self.skillObjList = self:initSkillList(lv)
end

function initSkillList(self,lv)
	lv = lv or self.lv
	local conf = self:getConf()
	local list = {}
	for pos,skillId in ipairs(self.conf.skill) do
		local skill = Skill.new(self,skillId,lv,pos)
		list[#list+1] = skill
	end
	return list
end

function getIsOpen(self)
	return self.isOpen
end

--装备
function equipSkillList(self,equipType)
	self.equipType = equipType
end

function isEquip(self)
	return self.equipType ~= SkillDefine.EQUIP_NONE
end

function incLv(self)
	self.lv = self.lv + 1
end

--伤害
function getAtk(self,lv)
	lv = lv or self.lv
	local objList = self:getSkillObjList(lv)
	local atk = 0
	for _,v in ipairs(objList) do
		atk = atk + v.atk + v.atkB
	end
	local len = #self.conf.skill
	if len > 0 then atk = atk/len end	
	return math.ceil(atk)
end

--伤害B
function getAtkB(self,lv)
	lv = lv or self.lv
	local objList = self:getSkillObjList(lv)
	local atk = 0
	for _,v in ipairs(objList) do
		atk = atk + v.atkB
	end
	return atk
end

--克制
function getOppo(self,lv)
	lv = lv or self.lv
	local objList = self:getSkillObjList(lv)
	local val = 0
	for _,v in ipairs(objList) do
		if v.bufferType ~= "rageR" then
			val = v.buffer * 100
			val = val .. "%"
			break
		end
		val = val + v.buffer
	end
	return val 
end

--
function getAssistVal(self,lv,isCName)
	lv = lv or self.lv
	local objList = self:getSkillObjList(lv)
	local val = 0
	for _,v in ipairs(objList) do
		val = v:getAssistVal(lv) 
	end
	local assistConf = self.conf.assist
	if isCName and assistConf.pct and assistConf.pct == 1 then
		val = (val * 100) .. "%"
	end
	return val 
end

--被动援助技
function getAssistRVal(self,lv,isCName)
	lv = lv or self.lv
	local assistConf = self.conf.assist
	if assistConf[1] and assistConf[1].bufferType == "atk" then
		--攻击
		val = BaseMath.getSkillAttr(lv,assistConf[1].buffer,assistConf[1].factor)
	else
		val = BaseMath.getSkillAttr(lv,assistConf.buffer,assistConf.factor)
	end
	if isCName and assistConf.pct and assistConf.pct == 1 then
		val = (val * 100) .. "%"
	end
	return val 
end

--被动技能buffer类型
function getAssistRBufferType(self)
	local assistConf = self:getConf().assist
	if assistConf[1] and assistConf[1].bufferType == "atk" then
		return "atk"
	else
		return assistConf.bufferType
	end
end


function getLv(self)
	return self.lv
end

--技能升级花费
function getUpgradeCost(self,lv)
	local typeConf = SkillDefine.TYPE_CONF[self.type]
	lv = lv or self.lv
	if self.type == SkillDefine.TYPE_ASSISTR then
		local upType = typeConf.upType .. self.equipType
		return SkillUpConfig[lv][upType] or 0
	else
		return SkillUpConfig[lv][typeConf.upType]
	end
end

function getSkillObjList(self,lv)
	if lv and (lv ~= self.lv or lv == 1) then
		return self:initSkillList(lv)
	end
	return self.skillObjList
end

function getConf(self)
	local conf = SkillGroupConfig[self.groupId]
	assert(conf,"lost skill conf=====>" .. self.groupId)
	return conf
end

function getFight(self)
	return self.fight * self.lv
end

--主动技
--[[
function isAttack(self)
	return self:getConf().assist.isAtk
end
--]]

--效果
function getEffectDesc(self)
	local conf = self:getConf()
	local desc = conf.desc or ""
	if self.type == SkillDefine.TYPE_NORMAL then
		desc = string.format(desc,self:getOppo())
		--desc = string.format("造成100%%+%s的伤害",self:getOppo())
	elseif self.type == SkillDefine.TYPE_ASSIST then
		desc = string.format(desc,self:getAssistVal(nil,true))
	elseif self.type == SkillDefine.TYPE_ASSISTR then
		desc = string.format(desc,self:getAssistRVal(nil,true))
	end
	print("=========>",desc)
	return desc
end

function getCanOpen(self)
	if self.isOpen then
		return false
	end
	if self.type == SkillDefine.TYPE_ASSISTR then
		return false
	end
	local conf = self:getConf()
	for itemId,itemNum in pairs(conf.openItem) do
		if BagData.getItemNumByItemId(itemId) < itemNum then
			return false
		end
	end
	return true
end

--是否已开启技能克制
function getIsOpenOppo(self)
	return GiftLogic.isActivate(self.hero,2)
end







