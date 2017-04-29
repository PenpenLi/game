module(...,package.seeall)
local EquipDefine = require("src/modules/equip/EquipDefine")
local EquipLogic = require("src/modules/equip/EquipLogic")
local Hero = require("src/modules/hero/Hero")

function onGCEquipList(heroName, list)
	EquipLogic.setEquipList(heroName, list)
	local EquipUI = Stage.currentScene:getUI():getChild("Upgradingequipment")
	if EquipUI then
		EquipUI:refreshEquip()
		EquipUI:refreshItem()
	end
end

function onGCEquipListAll(list)
	EquipLogic.initEquipData(list)
end

function onGCEquipLvUp(err)
	Common.showMsg("升级" .. EquipDefine.ERR_TXT[err])
	if err == EquipDefine.ERR_CODE.Success then
		local EquipUI = Stage.currentScene:getUI():getChild("Upgradingequipment")
		if EquipUI then
			EquipUI:equipFx("lv")
		end
	end
end

function onGCEquipColorUp(err)
	Common.showMsg("升阶" .. EquipDefine.ERR_TXT[err])
	if err == EquipDefine.ERR_CODE.Success then
		local EquipUI = Stage.currentScene:getUI():getChild("Upgradingequipment")
		if EquipUI then
			EquipUI:equipFx("c")
		end
	end
end



