module(...,package.seeall)
local Weapon = require("src/modules/weapon/Weapon")
local Define = require("src/modules/weapon/WeaponDefine")
local ItemConfig = require("src/config/ItemConfig").Config
local NeedConfig = require("src/config/WeaponNeedConfig").Config

function onGCWeaponQuery(list)
	Weapon.setWepData(list)
	local panel = Stage.currentScene:getUI():getChild("Weapon")
	if panel then
		panel:refresh()
	end
end

function onGCWeaponOpen(id, ret)
	local panel = Stage.currentScene:getUI():getChild("Weapon")
	if ret == Define.ERR_CODE.OpenNeedFrag then
		local name = ItemConfig[id].name
		Common.showMsgWithParam(Define.ERR_TXT[ret], name)
	elseif ret == Define.ERR_CODE.Success then
		if panel then
			panel:showActiveEff()
		end
		--local name = Define.WEP_NAME[id]
		--Common.showMsgWithParam(Define.ERR_TXT[ret], name)
	else
		Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
	end
end

function onGCWeaponUpLv(id, ret, hasLvUp, wepId, lv)
	local panel = Stage.currentScene:getUI():getChild("Weapon")
	if ret == Define.ERR_CODE.UpLvSuccess then
		local exp = ItemConfig[id].attr.wepExp
		if hasLvUp == 0 then
			Common.showMsgWithParam(Define.ERR_TXT[ret], exp)
		else
			if panel then
				--panel:showLvUpEff()
			end
			--local name = Define.WEP_NAME[wepId]
			--Common.showMsgWithParam(Define.ERR_TXT[Define.ERR_CODE.UpLvUpLv], exp, name, lv)
		end
	else
		Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
	end
end

function onGCWeaponUpQuality(id, ret)
	local panel = Stage.currentScene:getUI():getChild("Weapon")
	if ret == Define.ERR_CODE.UpQualitySuccess then
		if panel then
			panel:showUpEff()
			panel:showFlyEff()
		end
		local wepId = math.modf(id / 10000)
		local lv = math.modf((id - wepId * 10000) / 1000)
		local name = Define.WEP_NAME[wepId]
		local color = Define.WEP_UPQUALITY_COLOR[lv]
		Common.showMsgWithParam(Define.ERR_TXT[ret], name, color)
	elseif ret == Define.ERR_CODE.UpQualityNeedFrag then
		local config = NeedConfig[id]
		local name = ItemConfig[config.fragItem].name 
		Common.showMsgWithParam(Define.ERR_TXT[ret], name)
	else
		Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
	end
end
