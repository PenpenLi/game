module(..., package.seeall)

local GuideModule = require("src/modules/guide/GuideModule")
local GuideConfig = require("src/config/GuideConfig").Config

local moduleMap = {}

function getGuideModule(groupId)
	local module = moduleMap[groupId]
	if module == nil and GuideConfig[groupId] then
		module = GuideModule.new()
		module:setGroupId(groupId)
		moduleMap[groupId] = module
	end
	return module
end

function getAllModule()
	return moduleMap
end
