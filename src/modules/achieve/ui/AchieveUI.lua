module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Define = require("src/modules/achieve/AchieveDefine")
local Config = require("src/config/AchieveConfig").Config
local achieveData = require("src/modules/achieve/AchieveData").getInstance()
local Logic = require("src/modules/achieve/AchieveLogic")
local Common = require("src/core/utils/Common")
local TargetUI = require("src/ui/TargetUI")

function new(skin)
	local ctrl = Control.new(skin)
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function init(self)
	self:sendReqMsg()
end

function refresh(self)
	self.achieveList:removeAllItem()

	local sortList = function(dataList, isCommit)
		local tab = {}
		for _,data in pairs(dataList) do
			data.isCommit = isCommit
			table.insert(tab, data)
		end
		table.sort(tab, function(a, b)
				return a.id < b.id
			end
		)
		return tab
	end
	
	local dataList = achieveData:getCommitList()
	local commitList = sortList(dataList, true)

	dataList = achieveData:getUnfinishList()
	local unfinishList = sortList(dataList, false)

	self.achieveDataList = {}
	for i=1,#commitList do
		table.insert(self.achieveDataList, commitList[i])
	end
	for i=1,#unfinishList do
		table.insert(self.achieveDataList, unfinishList[i])
	end
	self.dataLen = #self.achieveDataList
	self.curIndex = 1
end


function refreshList(self)
	if self.dataLen and self.curIndex <= self.dataLen then
		local data = self.achieveDataList[self.curIndex]
		local config = Config[data.id]
		if config then
			local index = self.achieveList:addItem()
			local item = self.achieveList:getItemByNum(index)
			self:refreshItem(item, data)
			self.curIndex = self.curIndex + 1
		end
	end
end

function refreshItem(self, item, data)
	if data.isCommit and data.id == 9901 then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, step = 4, delayTime = 0, groupId = GuideDefine.GUIDE_ACHIEVE, noDelayFun = function()
				self.achieveList:showTopItem(item.num)
			end
		})
	end
	local function onGet(id, evt)
		if evt.etype == Event.Touch_ended then
			Network.sendMsg(PacketID.CG_ACHIEVE_GET, id)
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_ACHIEVE, step = 4})
		end
	end

	local config = Config[data.id]
	local grid = CommonGrid.new()
	grid:setAnchorPoint(0.5, 0.5)
	grid:setIcon('item/120/' .. config.icon)
	grid:setScale(0.8)
	grid:setPosition(item.gridCon.grid1:getContentSize().width / 2,
	item.gridCon.grid1:getContentSize().height / 2)
	item.gridCon:addChild(grid)
	item:addEventListener(Event.TouchEvent, onGet, data.id)

	--Common.setLabelCenter(item.titleTxt)
	item.contentTxt:setString(config.title)
	item.titleTxt:setString(config.content)
	item.countTxt:setDimensions(item.countTxt:getContentSize().width, 0)
	item.countTxt:setHorizontalAlignment(Label.Alignment.Right)

	if data.isCommit then
		item.get:setVisible(true)
		item.countTxt:setString("")
		item.doingTxt:setVisible(false)
	else
		item.doingTxt:setVisible(true)
		item.get:setVisible(false)
		local hasFinish,progressStr = Logic.hasAchieveFinish(data.id)
		if hasFinish == false then
			if progressStr == "" then
				item.countTxt:setString("")
			else
				item.countTxt:setString(progressStr)  
			end
		end
	end
	TargetUI.setItemReward(self, item, config.reward)
end

function sendReqMsg(self)
	Network.sendMsg(PacketID.CG_ACHIEVE_LIST)
end

function clear(self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 4, groupId = GuideDefine.GUIDE_ACHIEVE})
	Control.clear(self)
end
