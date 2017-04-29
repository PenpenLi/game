module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Config = require("src/config/FlowerConfig").Config
local Define = require("src/modules/flower/FlowerDefine")
local Logic = require("src/modules/flower/FlowerLogic")
local RuleUI = require("src/ui/RuleUI")

function new()
	local ctrl = Control.new(require("res/flower/FlowerGiveSkin"), {"res/flower/FlowerGive.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_RAW
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function init(self)
	self:initComponent()
	self:addListener()
	self:addBg()
end

function initComponent(self)
	self.bodyGrid = CommonGrid.bind(self.infoCon.bodyGrid)
	self.recordList.jlBG1:setVisible(false)
end

function addBg(self)
	local spr = cc.Sprite:create('res/flower/flowerBg.png')
	spr:setPosition(cc.p(self._skin.width/2, self._skin.height/2 - 20))
	spr:setLocalZOrder(-1)
	self._ccnode:addChild(spr)
end

function addListener(self)
	self.back:addEventListener(Event.Click, onClose, self)
	self.ruleBtn:addEventListener(Event.Click, onShowRule, self)
end

function onClose(self, evt)
	UIManager.removeUI(self)
end

function onShowRule(self, evt)
	local ruleUI = UIManager.addChildUI("src/ui/RuleUI")
	ruleUI:setId(RuleUI.Flower)
end

function refresh(self, index, fromType, sendCount, bodyId, name, flowerCount, hasGive, tipShow, recordList, costList)
	self.index = index
	self.fromType = fromType
	self.hasGive = hasGive
	self.sendCount = sendCount
	self.tipShow = tipShow

	self:refreshRecordList(name, recordList)	
	self:refreshPersonalInfo()
	self:refreshReceiverInfo(bodyId, name, flowerCount)
	self:refreshSendCon(costList)
end

function refreshRecordList(self, name, recordList)
	self.recordList:removeAllItem()

	local len = #recordList
	self.recordList:setItemNum(len)
	for i=1,len do
		local record = recordList[len - i + 1]
		local item = self.recordList:getItemByNum(i)
		local config = Config[record.flowerType]
		item.senderTxt:setString(record.name)
		
		item.receiverTxt:setPositionX(item.senderTxt:getPositionX() + item.senderTxt:getContentSize().width + 5)
		item.receiverTxt:setString('向' .. name .. '赠送了')

		item.flowerCountTxt:setPositionX(item.receiverTxt:getPositionX() + item.receiverTxt:getContentSize().width + 5)
		item.flowerCountTxt:setString(config.flowerCount .. '朵鲜花')
		
		item.timeTxt:setString(Logic.getTimeStr(record.giveTime))
	end
end

function refreshPersonalInfo(self)
	self.sendCountTxt:setString(self.sendCount)
end

function refreshReceiverInfo(self, bodyId, name, flowerCount)
	--目标信息
	self.bodyGrid:setBodyIcon(bodyId)
	self.infoCon.nameLabel:setString(name)
	self.flowerCon.flowerCountTxt:setString(flowerCount)
end

function refreshSendCon(self, costList)
	for i=1,3 do
		local config = Config[i]
		self.sendflower['send'..i].sendflower:setVisible(false)
		self.sendflower['send'..i].vipTipTxt:setVisible(false)
		self.sendflower['send'..i].closeTxt:setVisible(false)
		self.sendflower['send'..i].rewardTxt:setString('可获得体力*' .. Logic.getRewardStr(config.senderReward))
		self.sendflower['send'..i].moneyTxt:setString(costList[i].cost)
		if costList[i].costType == Define.FLOWER_COST_TYPE_MONEY then
			CommonGrid.setCoinIcon(self.sendflower['send'..i].jbbicon, 'money')
		else
			CommonGrid.setCoinIcon(self.sendflower['send'..i].jbbicon, 'rmb')
		end
	end
	if self.hasGive == 1 then
		self.sendflower.send1.closeTxt:setVisible(true)
		self.sendflower.send2.closeTxt:setVisible(true)

		local config = Config[Define.FLOWER_TYPE_NINE_N]
		if Master.getInstance().vipLv >= config.openNeed then
			self:showGiveBtn(Define.FLOWER_TYPE_NINE_N)
		else
			self.sendflower.send3.vipTipTxt:setVisible(true)
			self.sendflower.send3.vipTipTxt:setString('VIP' .. config.openNeed .. '可开放')
		end
	else
		for i=1,3 do
			local config = Config[i]
			if Master.getInstance().vipLv >= config.openNeed then
				self:showGiveBtn(i)
			else
				self.sendflower['send'..i].vipTipTxt:setVisible(true)
				self.sendflower['send'..i].vipTipTxt:setString('VIP' .. config.openNeed .. '可开放')
			end
		end
	end
end

function showGiveBtn(self, i)
	self.sendflower['send'..i].sendflower:setVisible(true)
	self.sendflower['send'..i].sendflower.sendFlowerBtn.flowerType = i
	if self.sendflower['send'..i].sendflower.sendFlowerBtn:hasEventListener(Event.Click, onGive) == false then
		self.sendflower['send'..i].sendflower.sendFlowerBtn:addEventListener(Event.Click, onGive, self)
	end
end

function onGive(self, evt, target)
	if self.tipShow == 0 then
		if self.sendCount <= 0 then
			local ui = UIManager.addChildUI('src/modules/flower/ui/FlowerTipUI')
			ui:showFirst(self.index, self.fromType, target.flowerType)
			return
		end
		if self.hasGive == 1 then
			local ui = UIManager.addChildUI('src/modules/flower/ui/FlowerTipUI')
			ui:showFirst(self.index, self.fromType, target.flowerType)
			return
		end
	end
	Network.sendMsg(PacketID.CG_FLOWER_GIVE, self.index, self.fromType, target.flowerType, self.tipShow)
end

