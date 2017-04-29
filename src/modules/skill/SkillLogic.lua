module(...,package.seeall)

local Hero = require("src/modules/hero/Hero")

local MonsterConfig = require("src/config/MonsterConfig").Config

local SkillConfig = require("src/config/SkillConfig").Config
local SkillExpConfig = require("src/config/SkillExpConfig").Config
local SkillGroupConfig = require("src/config/SkillGroupConfig").Config
local SkillDefine = require("src/modules/skill/SkillDefine")
local Skill = require("src/modules/skill/Skill")
local SkillGroup = require("src/modules/skill/SkillGroup")
local Bag = require("src/modules/bag/Bag")

function init()
	Bag.getInstance():addEventListener(Event.BagRefresh,function()
		Dot.checkToCache(DotDefine.DOT_C_SKILL)
	end,self)
end
init()

function init(hero)
	local list = {}
	for groupId,v in pairs(SkillGroupConfig) do
		if v.hero == hero.name then
			local group = SkillGroup.new(hero,groupId)
			list[#list+1] = group 
		end
	end
	return list
end

function monsterInit(monster)
	local monsterId = monster.monsterId
	local list = {}
	local monsterConf = MonsterConfig[monsterId]
	for career,name in pairs(SkillDefine.EQUIP_TYPE_MAP) do
		local v = monsterConf["skill" .. career]
		if v then
			local groupId = v[1]
			local group = SkillGroup.new(monster,groupId)
			group:equipSkillList(career)
			--group.lv = v[2]
			group:setLv(1)
			list[#list+1] = group 
		end
	end
	local heroName = monster.name
	local setSkill = function(conf)
		local group = SkillGroup.new(monster,conf[1])
		group:equipSkillList(1)
		group:setLv(conf[2] or 1)
		list[#list+1] = group
	end
	--补位技
	--setSkill(SkillDefine.TYPE_COVER,1)
	--援助技
	setSkill(monsterConf.skillAssist)
	--接招
	setSkill(monsterConf.skillCombo)
	--破招
	setSkill(monsterConf.skillBroke)
	--必杀技
	setSkill(monsterConf.skillFinal)
	return list
end

function getSkillGroupConfByType(heroName,type)
	for groupId,v in pairs(SkillGroupConfig) do
		if v.hero == heroName and v.type == type then
			return v 
		end
	end
end

function enemyInit(obj,skillGroupList)
	obj.skillGroupList = init(obj)
	updateSkillGroupList(obj,skillGroupList)
	return obj.skillGroupList
end

function getSkillGroupById(obj,groupId)
	local groupList = obj:getSkillGroupList()
	for _,v in pairs(groupList) do
		if v.groupId == groupId then
			return v
		end
	end
	return
end

function updateSkillGroupList(obj,skillGroupList)
	for _,v in pairs(skillGroupList) do
		local group = getSkillGroupById(obj,v.groupId)
		if group then
			local conf = SkillGroupConfig[v.groupId]
			group.equipType = v.equipType
			group.isOpen = v.isOpen == 1
			group.exp = v.exp
			group:setLv(v.lv)
		end
	end
	sortSkillGroupList(obj:getSkillGroupList())
end

function sortSkillGroupList(list)
	table.sort(list,function(a,b) 
		return a.groupId < b.groupId 
	end)
	return list
end


function getGroupListByType(obj,type)
	local listData = obj:getSkillGroupList()
	local list = {}
	for _,v in pairs(listData) do
		if v.type == type then
			list[#list+1] = v
		end
	end
	return list
end

function getSkillGroup(obj,type)
	local listData = obj:getSkillGroupList()
	for _,v in pairs(listData) do
		if v.type == type and v:isEquip() then
			return v
		end
	end
	assert(false,"getSkillGroup error===>objname=" .. obj.name .. "==>type="  .. type)
end


function getSkillListByRand(obj)
	local groupList = getEquipSkillGroup(obj,SkillDefine.TYPE_NORMAL)
	local group = groupList[math.random(1,3)]
	if not group then
		--补位技
		group = getSkillGroup(obj,SkillDefine.TYPE_COVER)
	end
	return group:getSkillObjList()
end

function getHeroList()
	local list = Hero.heroes 
	local sortList = {}
	for _,v in pairs(list) do
		sortList[#sortList+1] = v
	end
	local expeditionFirst = function(a,b)
		return a:getExpedition() < b:getExpedition()
	end
	table.sort(sortList,Hero.sortRecruitedHero)
	--table.sort(sortList,expeditionFirst)
	return sortList
end

function getSkillUpExp(groupId,lv)
	local conf = SkillGroupConfig[groupId]
	local typeM = "assist"
	if conf.type == SkillDefine.TYPE_FINAL then
		typeM = "final"
	end
	if not SkillExpConfig[lv] then
		print("=======>",lv)
		return false
	end
	return SkillExpConfig[lv][typeM]
end

--获得所有上阵技能
function getEquipSkillGroup(obj,type)
	local list = {}
	local listData = obj:getSkillGroupList()
	for _,v in ipairs(listData) do
		if (v.type == type or not type) and v:isEquip() then
			list[#list+1] = v
		end
	end
	return list
end

function getGroupListByCtype(obj,ctype,isEquip)
	local list = {}
	local listData = obj:getSkillGroupList()
	for _,v in pairs(listData) do
		if (not isEquip or v:isEquip()) and ctype == v.ctype then
			list[#list+1] = v
		end
	end
	return list
end

function calDyAttrByAssist(fightControl)
	local doCal = function(assistHero)
		local groupList = getGroupListByType(assistHero,SkillDefine.TYPE_ASSISTR)
		local attr = {dyAttr={},dyAttrR={}}
		for _,g in pairs(groupList) do
			if g:getIsOpen() then
				local assistConf = g:getConf().assist
				if assistConf.pct and assistConf.pct == 1 then
					attr.dyAttrR[g:getAssistRBufferType()] = g:getAssistRVal()
				else
					attr.dyAttr[g:getAssistRBufferType()] = g:getAssistRVal()
				end
			end
		end
		return attr
	end
	fightControl.assistRAttrA = doCal(fightControl:getAssistA())
	fightControl.assistRAttrB = doCal(fightControl:getAssistB())
end

function checkCanOpenSkill(hero,ctype)
	local groupList = {}
	if ctype then
		groupList = getGroupListByCtype(hero,ctype,false)
	else
		groupList = hero:getSkillGroupList()
	end
	for _,g in pairs(groupList) do
		if g:getCanOpen() then
			return true
		end
	end
	return false
end







