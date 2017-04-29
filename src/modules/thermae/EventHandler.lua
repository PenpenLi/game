module(..., package.seeall)
local Data = require("src/modules/thermae/Data")
local Define = require("src/modules/thermae/Define")
local ThermaeLogic = require("src/modules/thermae/ThermaeLogic")
local ThermaeDefine = require("src/config/ThermaeDefineConfig").Defined

function onGCThermaeQuery(isOpen,leftTime,bathing,money,rmb,item)
	Data.setData(isOpen,leftTime,bathing,money,rmb,item)
	if isOpen then
		Data.startTimer()
	else
		Data.stopTimer()
	end
	local ThermaeUI = require("src/modules/thermae/ui/ThermaeUI").Instance
	if ThermaeUI then
		ThermaeUI:updateBathing()
	end
end

function onGCThermaeNotify(op)
	if op == Define.ThermaeNodity.open then
		if MainUI.Instance and Master:getInstance().lv >= ThermaeDefine.level then
			MainUI.Instance:selectPanel("src/modules/thermae/ui/ThermaeNotifyUI")
		end
		Data.setOpen(true)
		Data.clearReward()
		Data.setLeftTime(ThermaeDefine.lastTime)
		Data.startTimer()
	elseif op == Define.ThermaeNodity.close then
		local ThermaeUI = require("src/modules/thermae/ui/ThermaeUI").Instance
		if ThermaeUI then
			--UIManager.removeUI(ThermaeUI)
			ThermaeUI:showReward()
		end
		Data.setOpen(false)
		Data.clearReward()
		Data.stopTimer()
	end
end

function onGCThermaeBath()
	local ThermaeUI = require("src/modules/thermae/ui/ThermaeUI").Instance
	if ThermaeUI then
		ThermaeUI:updateBathing()
	end
end

function onGCThermaeEndBath()
	--Data.clearReward()
	local ThermaeUI = require("src/modules/thermae/ui/ThermaeUI").Instance
	if ThermaeUI then
		--ThermaeUI:updateBathing()
		UIManager.removeUI(ThermaeUI)
	end
end
