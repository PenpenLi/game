module(...,package.seeall)
local NewOpenData = require("src/modules/newopen/NewOpenData")
local NewOpenDefine = require("src/modules/newopen/NewOpenDefine")

function onGCNewOpenQuery(day,rewards)
	NewOpenData.setData(day,rewards)
	local NewOpenUI = Stage.currentScene:getUI():getChild("NewOpen")
	if NewOpenUI then
		NewOpenUI:refreshInfo()
	end
	if Stage.currentScene.name == 'main' then
		local mainui = Stage.currentScene:getUI()
		Dot.check(mainui.activity,"checkNewOpen")
	end
end

function onGCNewOpenTime(beginTime,endTime,getEndTime,isOpen)
	NewOpenData.setTimeData(beginTime,endTime,getEndTime)
	local mainui = Stage.currentScene:getUI()
	if Stage.currentScene.name == "main" and Stage.currentScene.bg1:getChild("MainBg") then
		--if os.time() < getEndTime and os.time() >= beginTime then
		if isOpen == 1 then
			mainui.activity:setVisible(true)
		else
			mainui.activity:setVisible(false)
		end
	end
end

function onGCNewLoginGet(ret)
	if ret == NewOpenDefine.LOGIN_GET_RET.kOk then
	else
		local content = NewOpenDefine.LOGIN_GET_RET_TIPS[ret]
		Common.showMsg(string.format(content))
	end
end

function onGCNewRechargeGet(ret)
	if ret == NewOpenDefine.RECHARGE_GET_RET.kOk then
	else
		local content = NewOpenDefine.RECHARGE_GET_RET_TIPS[ret]
		Common.showMsg(string.format(content))
	end
end

function onGCNewDiscountBuy(ret)
	if ret == NewOpenDefine.DISCOUNT_BUY_RET.kOk then
	elseif ret == NewOpenDefine.DISCOUNT_BUY_RET.kNoRmb then
		local tipsUI = TipsUI.showTips("钻石不足，确定去充值？")
		tipsUI.yes.skillzi:setString("充值")
		tipsUI.no.skillzi:setString("取消")
		tipsUI:addEventListener(Event.Confirm,function(self, event)
			if event.etype == Event.Confirm_yes then
				UIManager.addUI("src/modules/vip/ui/VipUI")
			end
		end,self)
	else
		local content = NewOpenDefine.DISCOUNT_BUY_RET_TIPS[ret]
		Common.showMsg(string.format(content))
	end
end
