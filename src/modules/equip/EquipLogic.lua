module(...,package.seeall)
local EquipDefine = require("src/modules/equip/EquipDefine")
local Hero = require("src/modules/hero/Hero")

local EquipDefine = require("src/modules/equip/EquipDefine")
local EquipConfig = require("src/config/EquipConfig").Config
local EquipItemConfig = require("src/config/EquipItemConfig").Config
local EquipLvUpCostConfig = require("src/config/EquipLvUpCostConfig").Config
local EquipColorUpCostConfig = require("src/config/EquipColorUpCostConfig").Config
local EquipOpenLvConfig = require("src/config/EquipOpenLvConfig").Config

local heroEquip = {}
function new()
	local equip = {
		{lv=1,c=1},
		{lv=1,c=1},
		{lv=1,c=1},
		{lv=1,c=1},
	}
	return equip
end

function initEquipData(list)
	--Common.printR(list)
	for _, v in ipairs(list) do
		heroEquip[v.heroName] = v.list
	end
end

function setEquipList(heroName, list)
	heroEquip[heroName] = list
end

function getEquipList(heroName)
	local list = heroEquip[heroName]
	if not list then
		list = new()
		heroEquip[heroName] = list 
	end
	return list
end

function getEquip(heroName, pos)
	local list = getEquipList(heroName)
	local equip = list[pos]
	if not equip then
		equip = {lv=1,c=1}
		list[pos] = equip
	end
	return equip
end

function onHeroLvUp(heroName, oldLv, newLv)
	if oldLv ~= newLv then
		local hero = Hero.getHero(heroName)
		for i = 1, 4 do
			local lv = EquipOpenLvConfig[i].openlv 
			if newLv >= lv and oldLv < lv then
				Common.showMsg(hero.cname .. "开启了新的装备!")
				--TipsUI.showTipsOnlyConfirm(hero.cname.."开启了新装备, 快去看看吧!")
				return
			end
		end
	end
end
