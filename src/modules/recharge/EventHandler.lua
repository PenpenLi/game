module(...,package.seeall)
local RechargeDefine = require("src/modules/recharge/RechargeDefine")
local RechargeLogic = require("src/modules/recharge/RechargeLogic")

function onGCRechargeQuery(num,status)
	--local RechargeUI = Stage.currentScene:getUI():getChild("Recharge")
	--if RechargeUI then
	--	RechargeUI:refreshInfo(num,status)
	--end
	local RechargeUI = Stage.currentScene:getUI():getChild("Activity")
	if RechargeUI then
		RechargeUI:refreshAccuActInfo(num,status)
	end
end

function onGCRechargeGet(retCode)
	Common.showMsg(RechargeDefine.RECHARGE_GET_RET_TIPS[retCode])
end

function onGCRechargeTime(beginTime,endTime,getEndTime,isOpen)
	RechargeLogic.setData(beginTime,endTime,getEndTime)
	local mainui = Stage.currentScene:getUI()
	if Stage.currentScene.name == "main" and Stage.currentScene.bg1:getChild("MainBg") then
		--if os.time() < getEndTime and os.time() >= beginTime then
		--if isOpen == 1 then
		--	mainui.mainBtn1.xshd:setVisible(true)
		--else
		--	mainui.mainBtn1.xshd:setVisible(false)
		--end
	end
end
