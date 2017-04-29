module(...,package.seeall)
local BagData = require("src/modules/bag/BagData")
local BagDefine = require("src/modules/bag/BagDefine")


function useItem(itemId,cnt,argList)
	if cnt < 1 or cnt > BagDefine.kMaxUseCnt then
		assert(false)
		return false,"参数cnt不对"
	end
	local pos = BagData.getPosByItemIdAtLeast(itemId,cnt)
	--暂时只能针对一格子使用
	if pos == 0 then
		return false,"背包没有对应的道具"
	end
	Network.sendMsg(PacketID.CG_ITEM_USE,pos,cnt,argList)
	return true
end

function isFragItem(id)
	if BagData.getItemType(id) == BagDefine.ITEM_TYPE.kStrengthFrag or
		BagData.getItemType(id) == BagDefine.ITEM_TYPE.kWeaponFrag or
		BagData.getItemType(id) == BagDefine.ITEM_TYPE.kHeroFrag or 
		BagData.getItemType(id) == BagDefine.ITEM_TYPE.kPartnerFrag then
		--BagData.getItemType(id) == BagDefine.ITEM_TYPE.kPartnerLvupFrag then
		return true
	else
		return false
	end
end
