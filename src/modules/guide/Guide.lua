module(..., package.seeall)

local GuideStepConfig = require("src/config/GuideStepConfig").Config

local stepTypeList = {}
local typeList = {}

function init()
	for _,config in pairs(GuideStepConfig) do
		insertStepConfig(config)
		insertTypeConfig(config)
	end
end

function insertStepConfig(config)
	local tab = Common.split(config.id, "_")
	local groupId = tab[GuideDefine.GUIDE_VAL_ID]
	local step = tab[GuideDefine.GUIDE_VAL_STEP]
	local groupTab = stepTypeList[tonumber(groupId)]
	if groupTab == nil then
		groupTab = {}
		stepTypeList[tonumber(groupId)] = groupTab
	end
	groupTab[tonumber(step)] = config
end

function insertTypeConfig(config)
	local tab = typeList[config.type]
	if tab == nil then
		tab = {}
		typeList[config.type] = tab
	end
	table.insert(tab, config)
end

function getConfig(groupId, stepType)
	return stepTypeList[groupId][stepType]
end

function getTypeConfigList(type)
	return typeList[type]
end

init()
