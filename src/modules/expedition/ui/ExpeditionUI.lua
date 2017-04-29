module(..., package.seeall)
setmetatable(_M, {__index = Control})

local MapUI = require("src/modules/expedition/ui/ExpeditionMapUI")
local ShopUI = require("src/modules/expedition/ui/ExpeditionShopUI")
local HeroSelUI = require("src/modules/expedition/ui/ExpeditionHeroSelUI")

local expeditionData = require("src/modules/expedition/ExpeditionData").getInstance()
local ItemConfig = require("src/config/ItemConfig").Config
local Define = require("src/modules/expedition/ExpeditionDefine")
local Common = require("src/core/utils/Common")
local ResetConfig = require("src/config/ExpeditionResetConfig").Config[1]

local Hero = require("src/modules/hero/Hero")
local VipDefine = require("src/modules/vip/VipDefine")
local VipLogic = require("src/modules/vip/VipLogic")


function new()
	local ctrl = Control.new(require("res/expedition/ExpeditionSkin"), {"res/expedition/Expedition.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP_LABEL
end

function init(self)
	local size = self:getContentSize()
	self.contentWidth = size.width
	self.colorBg = cc.LayerColor:create(cc.c4b(13, 19, 51, 255), Stage.winSize.width, Stage.winSize.height)
	self.colorBg:setPosition(cc.p(-(Stage.winSize.width - size.width) / 2, 0))
	self.colorBg:setLocalZOrder(-10)
	self._ccnode:addChild(self.colorBg)

	-- self.clip = cc.ClippingNode:create()
	-- self.clip:setStencil(self.zhezhao._ccnode)
	-- self.clip:setAlphaThreshold(0)
	-- self.clip:addChild(self.mapUI._ccnode)
	--self.clip:setLocalZOrder(-1)
	self.mapUI = MapUI.new()
	self.mapUI:setPosition(0, -Stage.uiBottom)
	self.mapUI.touchEnabled = false
	self.mapUI._ccnode:setLocalZOrder(-1)
	self:addChild(self.mapUI)
	self.mapUI:setPositionX(expeditionData:getLastDragX())

	self.maxPosX = 0
	self.minPosX = self.maxPosX - (self.mapUI:getMapWidth() - Stage.winSize.width) / Stage.uiScale

	self.down:setPositionY(self.down:getPositionY() - Stage.uiBottom)
	self.down.touchParent = false
	--剩余次数
	self.down.txtcis:setString("0")

	--重新开始
	self.down.cxks:addEventListener(Event.Click, onRestart, self)
	--增加次数
	self.down.jiahao:addEventListener(Event.Click, onAdd, self)
	--兑换奖励
	self.down.dhjl:addEventListener(Event.Click, onShop, self)
	--规则
	self.down.guize:addEventListener(Event.Click, onShowRule, self)
	--扫荡
	self.down.yjsd:addEventListener(Event.Click, onClearCopy, self)

	--关闭
	self.back.touchParent = false
	self.back:addEventListener(Event.Click, onClose, self)

	self.lastClickX = 0
	self:setContentSize(cc.size(Stage.winSize.width, Stage.winSize.height))
	self:addEventListener(Event.TouchEvent, onTouch, self)

	self:refresh()
end

function onTouch(self, evt)
	if evt.etype == Event.Touch_began then
		self.lastClickX = evt.x
	elseif evt.etype == Event.Touch_moved then
		local curX = evt.x - self.lastClickX + self.mapUI:getPositionX()
		if curX >= self.minPosX and curX <= self.maxPosX then
			self.mapUI:setPositionX(curX)
			expeditionData:setLastDragX(curX)
		end
		self.lastClickX = evt.x
	end
	self.mapUI:onTouch(evt)
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)

	local parent = self._parent
	local pSize = parent:getContentSize()
	--self.back:setPositionX((pSize.width - self.contentWidth) / 2)
	--self.down:setPositionX((pSize.width - self.contentWidth) / 2)

	Network.sendMsg(PacketID.CG_EXPEDITION_QUERY)

	if Master.getInstance():hasEventListener(Event.MasterRefresh, onRefreshMoney) == false then
		Master.getInstance():addEventListener(Event.MasterRefresh, onRefreshMoney, self)
	end

	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 3, groupId = GuideDefine.GUIDE_EXPEDITION})
end

function onRefreshMoney(self, evt, target)
	self:refresh()
end

function clear(self)
	Master.getInstance():removeEventListener(Event.MasterRefresh, onRefreshMoney)

	Control.clear(self)
end

function onRestart(self, evt)
	if expeditionData:getResetCount() > 0 then
		local tipsUI = TipsUI.showTips("是否结束本次巡回赛，并重新开始？")
		tipsUI:addEventListener(Event.Confirm,function(self, event)
			if event.etype == Event.Confirm_yes then
				Network.sendMsg(PacketID.CG_EXPEDITION_RESET)
			end
		end,self)
	else
		Common.showMsg("剩余次数为0，无法重置")
	end
end

function onAdd(self, evt)
	local maxCount = VipLogic.getVipAddCount(VipDefine.VIP_EXPEDITION_RESET)
	if expeditionData:getBuyResetCount() < maxCount then
		local cost = ResetConfig.resetList[1]
		local tipsUI = TipsUI.showTips("是否花费" .. cost .. "钻石，购买1次巡回赛次数?")
		tipsUI:addEventListener(Event.Confirm, function(self,event) 
			if event.etype == Event.Confirm_yes then
				Network.sendMsg(PacketID.CG_EXPEDITION_BUY_COUNT)
			end
		end, self)
	else
		Common.showMsg("已达最大购买次数")
	end
end

function onShop(self, evt)
	UIManager.addChildUI("src/modules/expedition/ui/ExpeditionShopUI")
end

function onShowRule(self, evt)
	local ui = UIManager.addChildUI("src/ui/RuleUI")
	ui.touchParent = false
	ui:setId(RuleUI.Expedition)
end

function onClearCopy(self, evt)
	Network.sendMsg(PacketID.CG_EXPEDITION_CLEAR)
end

function onClose(self, evt)
	UIManager.removeUI(self)
end

function refresh(self)
	if expeditionData:getHasResetCount() == 1 or expeditionData:getPassId() <= expeditionData:getCurId() then
		self.down.yjsd:setEnabled(false)
		self.down.yjsd:setState(Button.UI_BUTTON_DISABLE)
	else
		self.down.yjsd:setEnabled(true)
		self.down.yjsd:setState(Button.UI_BUTTON_NORMAL)
	end

	self.down.txtcis:setString(expeditionData:getResetCount())
	self.mapUI:refresh()
end

function showTreasureUI(self, id, money, gemCount, item)
	local ui = UIManager.addChildUI("src/modules/expedition/ui/ExpeditionTreasureUI")
	ui:showTreasureUI(id, money, gemCount, item)
end

function showChallangeUI(self, name, lv, icon, guildName)
	local ui = UIManager.addChildUI("src/modules/expedition/ui/ExpeditionEnemyUI")
	ui:showChallangeUI(name, lv, icon, guildName)
end

function refreshHeroSelUI(self)
	local ui = UIManager.addChildUI("src/modules/expedition/ui/ExpeditionHeroSelUI")
	ui:refresh()
end

function refreshShopData(self, data)
	local ui = self:getChild("ExpeditionShop")
	if ui ~= nil then
		ui:refreshShopData(data)
	end
end

function setItemBuy(self, shopId, state)
	local ui = self:getChild("ExpeditionShop")
	if ui ~= nil then
		ui:setShopItemBuyState(shopId, state)
	end
end
