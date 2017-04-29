module(...,package.seeall)

local Define = require("src/modules/weapon/WeaponDefine")
local WeaponQualityConfig = require("src/config/WeaponQualityConfig").Config
local WeaponConfig = require("src/config/WeaponConfig").Config
local WeaponLvConfig = require("src/config/WeaponLvConfig").Config
local WeaponNeedConfig = require("src/config/WeaponNeedConfig").Config
local BagData = require("src/modules/bag/BagData")

-- {wepId, lv, exp, quality}
weps = {} 
weaponRefresh = false
isInit = false

function setWepData(ls)
	isInit = true
	Common.printR(ls)
	weps = ls
	refreshDot()
end

function getWep(wid)
	for k, v in pairs(weps) do
		if v.wepId == wid then
			return v
		end
	end
end

function getSumLv()
	local sumLv = 0
	for k, v in pairs(weps) do
		sumLv = sumLv + v.lv
	end
	return sumLv
end

function getWeaponConfig(wepId, quailty, lv)
	return WeaponConfig[wepId * 10000 + quailty * 1000 + lv]
end

function getLvConfig(lv)
	return WeaponLvConfig[lv]
end

function getQualityConfig(quality)
	for _,config in pairs(WeaponQualityConfig) do
		if config.quality == quality then
			return config
		end
	end
end

function getNeedConfig(wepId)
	return WeaponNeedConfig[wepId]
end


function refreshDot()
	if hasActiveInAll() == true and isInit == true then
		weaponRefresh = true	
		Dot.checkToCache(DotDefine.DOT_C_WEAPON)
	end
end

function hasActiveInAll()
	for k,v in ipairs(Define.WEP_LIST) do
		local active = canActive(v)
		if active == true then
			return true
		end
	end
	return false
end

function canActive(wepId)
	local wep = getWep(wepId)
	if wep == nil then
		local num = BagData.getItemNumByItemId(WeaponNeedConfig[wepId].fragItem)
		local qualityConfig = getQualityConfig(0)
		if num >= qualityConfig.fragNeed then
			return true
		end
	end
	return false
end
