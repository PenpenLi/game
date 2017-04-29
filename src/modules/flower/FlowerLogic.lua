module(..., package.seeall)

local BagDefine = require("src/modules/bag/BagDefine")

function getTimeStr(time)
	local min = math.floor((os.time() - time) / 60)
	if min < 1 then
		return '刚刚'
	elseif min < 60 then
		return min .. '分钟前'
	elseif min < 24 * 60 then
		local hour = math.floor(min / 60)
		return hour .. '小时前'
	end
	return '很久以前'
end

function getRewardStr(rewardList)
	for id,data in pairs(rewardList) do
		if id == BagDefine.ITEM_ID_PHY then
			return data[1]
		end
	end
end
