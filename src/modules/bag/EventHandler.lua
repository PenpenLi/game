module(...,package.seeall)
local BagData = require("src/modules/bag/BagData")
local BagDefine = require("src/modules/bag/BagDefine")
local ItemConfig = require("src/config/ItemConfig").Config
local WineItemConfig = require("src/config/WineItemConfig").Config
local USE_ITEM_TIPS = BagDefine.USE_ITEM_TIPS
local USE_ITEM = BagDefine.USE_ITEM


function onGCBagList(op,bagData)
	--Common.printR(bagData)
	BagData.setBagData(op,bagData)
	local bagPanel = Stage.currentScene:getUI():getChild("Bag")
	if bagPanel then
		bagPanel:refreshBag()
	end
end

function onGCBagExpand(cap)
	--BagData.setBagCap(cap)
	local bagPanel = Stage.currentScene:getUI():getChild("Bag")
	if bagPanel then
		bagPanel:refreshBag()
		--bagPanel:refreshCap()
	end
	--不需要操作码，有返回必定成功，失败情况前端已经过滤
	Common.showMsg(string.format("扩充成功！"))
end

function onGCItemSell(money)
	UIManager.playMusic("dropItem")
	local bagPanel = Stage.currentScene:getUI():getChild("Bag")
	if bagPanel then
		local bagOperate = bagPanel:getChild("BagOperate")
		bagOperate:onClose({etype = Event.Touch_ended})
	end
	--Common.showMsg(string.format("出售道具成功,获得银币%d",money))
	--require("src/ui/TipsUI").showTips(string.format("出售道具成功,获得银币%d",money))
	--[[
	local bagPanel = Stage.currentScene:getChild("Bag")
	if bagPanel then
		bagPanel:refreshBag()
		--bagPanel:refreshCap()
	end
	--]]
end

function onGCItemUse(ret,itemId)
	local bagPanel = Stage.currentScene:getUI():getChild("Bag")
	if not bagPanel then
		return
	end
	local content 
	if USE_ITEM.kItemUseOk == ret then
		--local cfg = ItemConfig[itemId]
		--content = string.format(USE_ITEM_TIPS[ret],cfg and cfg.name or "")
		local cfg = WineItemConfig[itemId]
		if cfg then
			Common.showMsg(cfg.desc)
		end
	else
		content = USE_ITEM_TIPS[ret] or "道具使用失败"
		Common.showMsg(content)
	end
	--require("src/ui/TipsUI").showTips(string.format("成功使用道具%d,返回码%d",itemId,ret))
end

function onGCRewardTips(rewards)
	--if #rewards > 4 then
	--	local rewards2 = {}
	--	for i = 1,#rewards do
	--		if i > 10 then
	--			break
	--		end
	--		table.insert(rewards2,rewards[i])
	--	end
	--	RewardTips.showTen(rewards2)
	--else
	--	for k,v in pairs(rewards) do
	--		v.title = BagDefine.REWARD_TIPS[v.titleId]
	--	end
	--	RewardTips.show(rewards)
	--end
	for k,v in pairs(rewards) do
		v.title = BagDefine.REWARD_TIPS[v.titleId]
	end
	RewardTips.show(rewards)
end

