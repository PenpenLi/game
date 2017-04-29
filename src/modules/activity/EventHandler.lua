module(...,package.seeall)

local Activity = require("src/modules/activity/Activity")
local Def = require("src/modules/activity/ActivityDefine")
local LvGiftLogic = require("src/modules/lvGift/LvGiftLogic")


function onGCActivityInfo(result,activityId,info)
	if result == Def.RET_OK then
		Activity.setActivityInfo(activityId,info)
		local ui2 = UIManager.getUI("Activity")
		if ui2 then
			ui2:showActivity(activityId)
		end
	end
	-- ui refresh
end

function onGCActivityReward(result,activityId,id,timestamp)
	if result == Def.RET_OK then
		Activity.setActivityItem(activityId,id,Def.STATUS_REWARDED)
		local ui2 = UIManager.getUI("Activity")
		if ui2 then
			ui2:refreshActivity(activityId)
		end
		LvGiftLogic.refreshStatus()
		local mainUI = Stage.currentScene:getUI()
		if mainUI then
			Dot.check(mainUI.mainBtn1.exercise,"activityDot")
		end
	elseif result == Def.RET_REWARDED then
		Common.showMsg("本奖励已经领取了，无法重复领取")
	elseif result == Def.RET_NOINTIME then
		Common.showMsg("未到领取体力时段")
	else
		Common.showMsg("领取失败")
	end
end

function onGCActivityTip(activityId,id)
	if Activity.ActivityList[activityId] == nil then
		Activity.ActivityList[activityId] = {}
	end
	Activity.ActivityList[activityId][id] = {status = Def.STATUS_COMPLETED}


	-- ui refresh
	if activityId == Def.FIRSTCHARGE_ACT then
		local mainUI = require("src/modules/master/ui/MainUI").Instance
		if mainUI then
			Dot.check(mainUI.mainBtn1.exercise,"activity2Dot")
		end
	end
end

function onGCActivityMonthcardbuy(result)


end

function onGCActivityMonthcardInfo(monthCardInfo,newBuy)
	Activity.monthCardInfo = monthCardInfo
	local ui = UIManager.getUI("Activity")
	if ui then
		-- ui:showMonthCardActivity()
		ui:refreshActivity(Def.MONTHCARD_ACT)
	end
	if newBuy == 1 then
		Common.showMsg("购买月卡成功！")
	end
end

function onGCActivityFoundationBuy(result,result2)
	local ui2 = UIManager.getUI("Activity")
	if result == Def.RET_OK then
		Activity.foundationBuy = result2
		if ui2 then
			if Activity.foundationBuy == 0 then
				Common.showMsg("购买开服基金成功")
			end
			ui2:showActivity(Def.FOUNDATION_ACT)
		end
	elseif result == Def.RET_RMB then
		if ui2 then
			Common.showMsg("钻石不足")
		end
	elseif result == Def.RET_REPEAT then
		if ui2 then
			Common.showMsg("不可以重复购买")
		end
	elseif result == Def.RET_LEVEL then
		if ui2 then
			Common.showRechargeTips("VIP等级不够 是否升级VIP等级")
		end
	end
end

function onGCActivityVipBuy(id,result)
	local ui2 = UIManager.getUI("Activity")
	if result == Def.RET_OK then
		if ui2 then
			Common.showMsg("购买VIP礼包成功")
			ui2:showActivity(Def.VIP_ACT)
		end
	elseif result == Def.RET_RMB then
		if ui2 then
			Common.showMsg("钻石不足")
		end
	elseif result == Def.RET_REPEAT then
		if ui2 then
			Common.showMsg("不可重复购买")
		end
	end

end

function onGCActivityVip(id,status)
	Activity.vipGift[id] = status
	local ui2 = UIManager.getUI("Activity")
	if ui2 then
		ui2:showActivity(Def.VIP_ACT)
	end
end

function onGCWheelRet(ret)
	local ui2 = UIManager.getUI("Activity")
	if ui2 then
		if ret == -1 then
			Common.showMsg("活动已经结束")
		elseif ret == 0 then
			Common.showMsg("钻石不足")
		elseif ret >= 1 and ret <= 8 then
			ui2:showWheelRun(ret)
		end
	end
end

function onGCWheelInfo(list)
	local ui2 = UIManager.getUI("Activity")
	if ui2 then
		ui2:showWheelInfo(list)
	end
end

function onGCActivityMonthcardReceive(result,monthCardId)
	local ui2 = UIManager.getUI("Activity")
	if result == Def.RET_OK then
		if ui2 then
			-- ui2:showMonthCardActivity()
		end
	elseif result == Def.RET_REPEAT then
		if ui2 then
			Common.showMsg("不可重复领取")
		end
	else
		if ui2 then
			Common.showMsg("领取失败")
		end
	end
end

function onGCActivityDb(actId,actDb)
	Activity.ActivityDb[actId] = actDb
end
