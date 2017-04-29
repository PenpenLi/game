module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Define = require("src/modules/flower/FlowerDefine")
local FlowerData = require("src/modules/flower/FlowerData")
local Config = require("src/config/FlowerConfig").Config
local Logic = require("src/modules/flower/FlowerLogic")
local RuleUI = require("src/ui/RuleUI")
local PublicLogic = require("src/modules/public/PublicLogic")

function new()
	local ctrl = Control.new(require("res/flower/FlowerPersonalSkin"), {"res/flower/FlowerPersonal.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_RAW
end

function init(self)
	self:initSelect()
	self:addBg()
	self.recordList.jlBG1:setVisible(false)
	self:sendRegMsg()
	self:addListener()
	GuideManager.dispatchEvent(GuideDefine.GUIDE_START, {groupId = GuideDefine.GUIDE_FLOWER_ENTER}) 
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, groupId = GuideDefine.GUIDE_FLOWER_ENTER})
end

function initSelect(self)
	self.btnType = Define.FLOWER_BTN_ONE_NINE
	self.flowerRbg.receive:setSelected(true)
	--self:refreshRecordList()
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function addBg(self)
	local spr = cc.Sprite:create('res/flower/flowerBg.png')
	spr:setPosition(cc.p(self._skin.width/2, self._skin.height/2 - 20))
	spr:setLocalZOrder(-1)
	self._ccnode:addChild(spr)
end

function sendRegMsg(self)
	Network.sendMsg(PacketID.CG_FLOWER_PERSONAL)
end

function addListener(self)
	self.back:addEventListener(Event.Click, onClose, self)
	self.flowerRankBtn:addEventListener(Event.Click, onShowRank, self)
	self.sendBtn:addEventListener(Event.Click, onShowSend, self)
	self.rule:addEventListener(Event.Click, onShowRule, self)
	self.flowerRbg:addEventListener(Event.Change, onChangeType, self)
end

function onClose(self, evt)
	UIManager.removeUI(self)
end

function onShowRank(self, evt)
	if PublicLogic.checkModuleOpen("rank") then
		local rankDefine = require("src/modules/rank/RankDefine")
		local ui = UIManager.addUI("src/modules/rank/ui/RankUI")
		ui:selectType(rankDefine.RANK_TYPE_FLOWER)
	end
end

function onShowSend(self, evt)
	UIManager.addChildUI('src/modules/flower/ui/FlowerLinkUI')
end

function onShowRule(self, evt)
	local ruleUI = UIManager.addChildUI("src/ui/RuleUI")
	ruleUI:setId(RuleUI.Flower)
end

function onChangeType(self, evt)
	if evt.target.name == "send" then
		self.btnType = Define.FLOWER_BTN_SEND
	elseif evt.target.name == "receive" then
		self.btnType = Define.FLOWER_BTN_RECEIVE
	end
	self:refreshRecordList()
end

function refresh(self, leftCount)
	self.flowerCon.flowerCountTxt:setString(Master.getInstance().flowerCount)
	self.sendCountTxt:setString(leftCount)

	self:refreshRecordList()
end

function refreshRecordList(self)
	self.recordList:removeAllItem()
	
	local recordList = FlowerData.getInstance():getReceiveRecordListByType(self.btnType)
	local len = #recordList
	self.recordList:setItemNum(len)
	for i=1,len do
		local record = recordList[len - i + 1]
		local item = self.recordList:getItemByNum(i)
		local config = Config[record.flowerType]
		if self.btnType ~= Define.FLOWER_BTN_SEND then
			item.senderTxt:setString(record.name)
			item.receiverTxt:setPositionX(item.senderTxt:getPositionX() + item.senderTxt:getContentSize().width + 5)
			item.receiverTxt:setString('向您赠送了')
		else
			item.senderTxt:setString('')
			item.receiverTxt:setPositionX(item.senderTxt:getPositionX() + item.senderTxt:getContentSize().width + 5)
			item.receiverTxt:setString('向' .. record.name .. '赠送了')
		end
	
		item.flowerCountTxt:setPositionX(item.receiverTxt:getPositionX() + item.receiverTxt:getContentSize().width + 5)
		item.flowerCountTxt:setString(config.flowerCount .. '朵鲜花')

		--item.timeTxt:setContentSize(100, 20)
		item.timeTxt:setString(Logic.getTimeStr(record.giveTime))
	end
end
