module(...,package.seeall)

local Define = require("src/modules/dot/DotDefine")
local AchieveData = require("src/modules/achieve/AchieveData")
local VipData = require("src/modules/vip/VipData")


function onGCDot(type)
	if type == Define.DOT_ACHIEVE then
		AchieveData.getInstance():setAchieveRefresh(true)	
		Dot.checkToCache(DotDefine.DOT_C_TARGET)
	elseif type == Define.DOT_VIP_DAILY then
		VipData.getInstance():setHasDaily(true)
		Dot.checkToCache(DotDefine.DOT_C_VIP)
	end
end



