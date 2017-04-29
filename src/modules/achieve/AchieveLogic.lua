module(..., package.seeall)

local Config = require("src/config/AchieveConfig").Config
local achieveData = require("src/modules/achieve/AchieveData").getInstance()
local Define = require("src/modules/achieve/AchieveDefine")
local Common = require("src/core/utils/Common")
local Hero = require("src/modules/hero/Hero")
local Weapon = require("src/modules/weapon/Weapon")
local PartnerData = require("src/modules/partner/PartnerData")

function conmposeData(unfinishList, commitList, finishList)
	local tab = {}
	for _,id in pairs(finishList) do
		tab[id] = 1
	end
	achieveData:setFinishList(tab)

	tab = {}
	for _,id in pairs(commitList) do
		tab[id] = {id = id}
	end
	achieveData:setCommitList(tab)

	tab = {}
	for _,obj in pairs(unfinishList) do
		tab[obj.id] = obj
	end
	achieveData:setUnfinishList(tab)

	filterAchieve()

	if #commitList > 0 then
		achieveData:setAchieveRefresh(true)
	else
		achieveData:setAchieveRefresh(false)
	end
end

function filterAchieve()
	for _,config in pairs(Config) do
		local preObj = config.preNeed
		--符合开启条件
		if (preObj.preId == nil or achieveData:getCommit(preObj.preId) ~= nil or achieveData:getFinish(preObj.preId) ~= nil)
			and (preObj.lv == nil or Master.getInstance().lv >= preObj.lv) 
			and (achieveData:getCommit(config.id) == nil and achieveData:getFinish(config.id) == nil)
			and achieveData:getUnfinish(config.id) == nil then
			local isFinish,str = hasAchieveFinish(config.id)
			if isFinish == false then
				--是否有目标数据
				achieveData:addUnfinish({id = config.id, targetList = {}})
			else
				achieveData:addCommit(config.id)
			end
		end
	end
end

function hasAchieveFinish(configId)
	local progressStr = ""
	local isFinish = (achieveData:getCommit(configId) ~= nil)
	local config = Config[configId]
	local preObj = config.preNeed
	if (preObj.preId == nil or achieveData:getCommit(preObj.preId) ~= nil or achieveData:getFinish(preObj.preId) ~= nil)
		and (preObj.lv == nil or Master.getInstance().lv >= preObj.lv) 
		and (achieveData:getCommit(configId) == nil and achieveData:getFinish(configId) == nil) then
		isFinish = true
		local targetParam = config.param
		for _,target in pairs(targetParam) do
			local fun = FUN_LIST[target[Define.ACHIEVE_PARAM_TYPE]]
			isFinish,progressStr = fun(config, target)
			if isFinish == false then
				--有未完成目标则为未完成成就
				break
			end
		end
	end
	return isFinish,progressStr
end

function teamLv(config, target)
	local targetLv = target[Define.ACHIEVE_PARAM_COUNT]
	return (Master.getInstance().lv >= targetLv),(Master.getInstance().lv .. "/" .. targetLv)
end

function collect(config, target)
	local quality = target[Define.ACHIEVE_PARAM_ID]
	local targetCount = target[Define.ACHIEVE_PARAM_COUNT]
	local curCount = Hero.getHeroCountByQuality(quality)
	return (curCount >= targetCount),(curCount .. "/" .. targetCount)
end

function activate(config, target)
	local curCount = Common.GetTbNum(PartnerData.PartnerData)
	local targetCount = target[Define.ACHIEVE_PARAM_COUNT]
	return (curCount >= targetCount),(curCount .. "/" .. targetCount)
end

function heroLvUp(config, target)
	local lv = target[Define.ACHIEVE_PARAM_ID]
	local targetCount = target[Define.ACHIEVE_PARAM_COUNT]
	local curCount = 0
	local heroList = Hero.heroes
	for _,hero in pairs(heroList) do
		if hero.lv >= lv then
			curCount = curCount + 1
		end
	end
	return (curCount >= targetCount),(curCount .. "/" .. targetCount)
end

function arena(config, target)
	return false,""
end

function power(config, target)
	return false,""
end

function weapon(config, target)
	local targetCount = target[Define.ACHIEVE_PARAM_COUNT]
	local curCount = Weapon.getSumLv()
	return (curCount >= targetCount),(curCount .. "/" .. targetCount)
end

function copy(config, target)
	return commonCompare(config, target, Define.ACHIEVE_COPY)
end

function orochi(config, target)
	return commonCompare(config, target, Define.ACHIEVE_OROCHI)
end

function trial(config, target)
	return commonCompare(config, target, Define.ACHIEVE_TRIAL)
end

function expedtion(config, target)
	return commonCompare(config, target, Define.ACHIEVE_EXPEDITION)
end

function commonCompare(config, target, type)
	local isFinish = false
	local str = ""

	local tab = achieveData:getUnfinish(config.id)
	if tab ~= nil then
		local targetList = tab.targetList
		local id = target[Define.ACHIEVE_PARAM_ID]
		local count = target[Define.ACHIEVE_PARAM_COUNT]

		local targetObj = nil
		for _,obj in pairs(targetList) do
			if obj.param[Define.ACHIEVE_PARAM_TYPE] == type
				and obj.param[Define.ACHIEVE_PARAM_ID] == id then
				targetObj = obj
				break
			end
		end

		if targetObj == nil then
			str = str ..  "0/" .. count .. " "
		else
			if targetObj.param[Define.ACHIEVE_PARAM_COUNT] >= count then
				isFinish = true
			end
			str = str .. targetObj.param[Define.ACHIEVE_PARAM_COUNT] .. "/" .. count .. " "
		end
	end
	return isFinish,str
end

FUN_LIST = {
	[Define.ACHIEVE_TEAM_LV] 	= teamLv,
	[Define.ACHIEVE_COLLECT] 	= collect,
	[Define.ACHIEVE_ACTIVATE] 	= activate,
	[Define.ACHIEVE_LV_UP] 		= heroLvUp,
	[Define.ACHIEVE_COPY]		= copy,
	[Define.ACHIEVE_OROCHI]		= orochi,
	[Define.ACHIEVE_TRIAL]		= trial,
	[Define.ACHIEVE_EXPEDITION]	= expedtion,
	[Define.ACHIEVE_ARENA]		= arena,
	[Define.ACHIEVE_POWER]		= power,
	[Define.ACHIEVE_WEAPON]		= weapon,
}
