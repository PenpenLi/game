module(...,package.seeall)

local ItemHandbookConfig = require("src/config/ItemHandbookConfig").Config
local HeroHandbookConfig = require("src/config/HeroHandbookConfig").Config
local Def = require("src/modules/handbook/HandbookDefine")


HandbookList = {hero={},item={}}
for i,conf in ipairs(HeroHandbookConfig) do 
	HandbookList.hero[i] = Def.STATUS_NOTCOMPLETE
end

for i,conf in ipairs(ItemHandbookConfig) do 
	HandbookList.item[i] = Def.STATUS_NOTCOMPLETE
end

itemlib = {}

function addHandbookInfo(hbinfo)
	for i,info in pairs(hbinfo) do 
		HandbookList[info.name] = {}
		for _,status in ipairs(info.status) do
			table.insert(HandbookList[info.name],status)
		end
	end
end

function getRewardList(name)
	return HandbookList[name]
end

function setItemlib(lib)
	for _,itemId in ipairs(lib) do 
		itemlib[itemId] = true
	end
end

function isItemInLib(itemId)
	return itemlib[itemId]
end