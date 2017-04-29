module(...,package.seeall) 

local Define = require("src/modules/flower/FlowerDefine")
local flowerData = require("src/modules/flower/FlowerData").getInstance()

function onGCFlowerGiveOpen(index, fromType, bodyId, name, flowerCount, hasGive, rewardLeftCount, tipShow, giveRecordList, costList)
	local flowerGiveUI = Stage.currentScene:getUI():getChild("FlowerGive")
	if flowerGiveUI == nil then
		flowerGiveUI = UIManager.addUI("src/modules/flower/ui/FlowerGiveUI") 
	end
	if flowerGiveUI then
		flowerGiveUI:refresh(index, fromType, rewardLeftCount, bodyId, name, flowerCount, hasGive, tipShow, giveRecordList, costList)
	end
end

function onGCFlowerGive(retCode, msg)
	if retCode == Define.ERR_CODE.GiveSuccess then
		Common.showMsg(msg)
		return
	end
	Common.showMsg(Define.ERR_TXT[retCode] or "操作失败")
end

function onGCFlowerPersonal(rewardLeftCount, giveRecordList, receiveRecordList)
	flowerData:setReceiveRecordList(receiveRecordList)
	flowerData:setSendRecordList(giveRecordList)
	local flowerPersonalUI = Stage.currentScene:getUI():getChild("FlowerPersonal") 
	if flowerPersonalUI then
		flowerPersonalUI:refresh(rewardLeftCount)
	end
end

function onGCFlowerGet()
	flowerData:setFlowerRefresh(true)
	Dot.checkToCache(DotDefine.DOT_C_FLOWER)
end
