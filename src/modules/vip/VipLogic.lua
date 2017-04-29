module(..., package.seeall)

local VipConfig = require("src/config/VipConfig").Config
local VipData = require("src/modules/vip/VipData")
local Define = require("src/modules/vip/VipDefine")

function getVipAddCount(type)
	local vipLv = Master.getInstance().vipLv
	local config = VipConfig[vipLv]
	return config[type]
end

function checkDot()
	local hasDaily = false
	local dailyInfo = VipData.getInstance():getDailyInfo()
	for _,v in pairs(dailyInfo) do
		if v == Define.VIP_DAILY_NO_GET then
			hasDaily = true
			break
		end
	end
	if not hasDaily then
		VipData.getInstance():setHasDaily(false)
		Dot.checkToCache(DotDefine.DOT_C_VIP)
	end
end
