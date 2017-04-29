module(..., package.seeall)
local LevelActConfig = require("src/config/LevelActivityConfig").Config
local Def = require("src/modules/activity/ActivityDefine")
local Activity = require('src/modules/activity/Activity')

function getNextLvGiftCfg(curLv)
	local cfg 
	for i = 1,#LevelActConfig do
		if curLv < LevelActConfig[i].lv then
			cfg = LevelActConfig[i]
			break
		end
	end
	return cfg
end

function getNextRewardCfg()
	for i =1 ,#LevelActConfig do
		if Activity.getActivityStatus(Def.LEVEL_ACT,i) == Def.STATUS_COMPLETED then
			return LevelActConfig[i]
		end
	end
end

function refreshStatus(ui)
	local mainui = ui or require("src/modules/master/ui/MainUI").Instance
	if mainui then
		local nextLvGiftCfg = getNextLvGiftCfg(Master:getInstance().lv)
		local nextRewardCfg = getNextRewardCfg() 
		if nextLvGiftCfg or nextRewardCfg then
			mainui.lvGift:setVisible(true)
			if nextRewardCfg then
				mainui.lvGift.get:setVisible(true)
				mainui.lvGift.txttishi:setString(string.format("%d级礼包",nextRewardCfg.lv))
				if not mainui.lvGiftAni then
					mainui.lvGiftAni = Common.setBtnAnimation(mainui.lvGift._ccnode,"LvGift","get")
				end
			else
				mainui.lvGift.get:setVisible(false)
				mainui.lvGift.txttishi:setString(string.format("%d级可领",nextLvGiftCfg.lv))
				if mainui.lvGiftAni then
					mainui.lvGiftAni:removeFromParent()
					mainui.lvGiftAni = nil
				end
			end
			if Master.getInstance().lv < 30 then
				if not mainui.lvGiftAni2 then
					mainui.lvGiftAni2 = Common.setBtnAnimation(mainui.lvGift._ccnode,"LvGift","play")
				end
			else
				if mainui.lvGiftAni2 then
					mainui.lvGiftAni2:removeFromParent()
					mainui.lvGiftAni2 = nil
				end
			end
		else
			mainui.lvGift:setVisible(false)
		end
	end
end
