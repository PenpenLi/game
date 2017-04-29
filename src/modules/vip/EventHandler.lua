module(..., package.seeall)

local Define = require("src/modules/vip/VipDefine")
local VipData = require("src/modules/vip/VipData")
local VipLogic = require("src/modules/vip/VipLogic")
local VipConfig = require("src/config/VipConfig").Config
local VipLevelUI = require("src/modules/vip/ui/VipLevelUI")
local VipLevelLogic = require("src/modules/vip/VipLevelLogic")

function onGCVipRecharge(retCode)
	if retCode == Define.ERR_CODE.RECHARGE_SUCCESS then
		Network.sendMsg(PacketID.CG_VIP_CHECK)
	end
	Common.showMsg(Define.ERR_TXT[retCode] or "操作失败")	
end

function onGCVipBuyGift(retCode, lv)
	if retCode == Define.ERR_CODE.BUY_NO_MONEY then
		Common.showRechargeTips()
	elseif retCode == Define.ERR_CODE.BUY_SUCCESS then
		VipData.getInstance():setBuy(lv)
		local panel = Stage.currentScene:getUI():getChild("Vip")
		if panel ~= nil then
			panel:refreshPrivilege()
		end
	else
		Common.showMsg(Define.ERR_TXT[retCode] or "操作失败")
	end
end

function onGCVipCheck(recharge, rechargeList, giftBuyList, dailyInfo)
	VipData.getInstance():setBuyList(giftBuyList)
	VipData.getInstance():setDailyInfo(dailyInfo)
	local panel = Stage.currentScene:getUI():getChild("Vip")
	if panel ~= nil then
		if panel.isPaper then
			panel:refreshRechargeRmb(recharge / 100)
			panel:refreshPrivilege()
		else
			panel:refreshRechargeRmb(recharge / 100)
			panel:refreshRecharge(rechargeList)
			panel:refreshPrivilege()
		end
	end
end

function onGCVipGetDaily(retCode, vipLv)
	local panel = Stage.currentScene:getUI():getChild("Vip")
	if retCode == Define.ERR_CODE.DAILY_SUCCESS then
		VipData.getInstance():getDailyInfo()[vipLv] = Define.VIP_DAILY_GET
		VipLogic.checkDot()

		if panel then
			panel:refreshListItem(vipLv)

			local tb = {}
			local item = {title='日常礼包', id=VipConfig[vipLv].dailyGift, num=1}
			table.insert(tb, item)

			local ui = RewardTips.show(tb)
			if ui then
				ui:setAnchorPoint(0.5, 0.5)
				ui:setPosition(ui:getContentSize().width/2,ui:getContentSize().height/2)
				ui.touchParent = false
			end
		end
	else
		Common.showMsg(Define.ERR_TXT[retCode] or "操作失败")
	end
end

function onGCVipLevelStart(retCode,levelId)
	if retCode == Define.ERR_CODE.OK then
		UIManager.addChildUI("src/modules/vip/ui/VipLevelFightUI",levelId)


	elseif retCode == Define.ERR_CODE.LIMIT then
		Common.showMsg("挑战次数不足")
	end
end

function onGCVipLevelEnd(retCode,levelId,result,reward,heroes)
	if retCode == Define.ERR_CODE.OK then
		UIManager.addUI("src/modules/vip/ui/SettlementUI",levelId,result,reward,heroes)
	end

end

function onGCVipLevelInfo(retCode,times)
	VipLevelLogic.fightTimes = times
	local ui = UIManager.getUI("VipLevel")
	if ui then
		ui:refreshTimes()
	end
end
