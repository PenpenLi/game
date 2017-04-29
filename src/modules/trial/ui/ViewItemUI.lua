module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Config = require("src/config/TrialConfig").Config

function new(curType)
	local ctrl = Control.new(require("res/trial/ViewItemSkin"), {"res/trial/ViewItem.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl.type = curType
	ctrl:init()
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

_M.touch = function(self,event)
	Common.outSideTouch(self,event)
end

function randReward(r)
    local rewardList = {}
	for _,rr in pairs(r) do
		for n,_ in pairs(rr) do
			if type(n) == 'number' then
				rewardList[#rewardList+1] = n
			end
		end
	end
	return rewardList
end

function init(self)
	local list = {}
	for levelId,v in pairs(Config) do
		list[#list+1] = v
	end
	table.sort(list,function(a,b) return a.levelId < b.levelId end)
	self.sortList = list
	for _,v in ipairs(self.sortList) do
		if v.type == self.type then
			local item = self.itemList:getItemByNum(self.itemList:addItem())
			local itemList = randReward(v.reward)
			item.titleLabel:setString(v.title)
			local index = 1
			for i=1,#itemList do
				index = index + 1
				CommonGrid.bind(item['grid'..i],true)
				item["grid" .. i]:setItemIcon(itemList[i],"mIcon")
			end
			for i=index,8 do
				item["grid" .. i]:setVisible(false)
			end
		end
	end
end


