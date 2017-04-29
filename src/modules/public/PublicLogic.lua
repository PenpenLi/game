module(...,package.seeall)

local OpenLvConfig = require("src/config/OpenLvConfig").Config

OpenLvData = {}


function loadOpenLvConfig()
	for id,conf in ipairs(OpenLvConfig) do
		OpenLvData[conf.moduleName] = conf.charLv
	end
end

loadOpenLvConfig()

function isModuleOpened(moduleName)
	local lv = OpenLvData[moduleName]
	if lv then
		if Master.getInstance().lv >= lv then
			return true
		else
			return false
		end
	else
		return true
	end
end

function getOpenLv(moduleName)
	return OpenLvData[moduleName] or 0
end

function checkModuleOpen(moduleName)
	if not isModuleOpened(moduleName) then
		local lv = OpenLvData[moduleName]
		--TipsUI.showTipsOnlyConfirm(tostring(lv) .. "级开启")	
		Common.showMsg(tostring(lv) .. "级开启")
		return false
	end
	return true
end 







