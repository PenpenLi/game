--[[
-- 通用提示框
--]]
module("TipsUI", package.seeall)
setmetatable(_M, {__index = Control})

function new()
	local ctrl = Control.new(require("res/common/TipsSkin"),{"res/common/Tips.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	ctrl:adjustTouchBox(0,Stage.uiBottom,0,2*Stage.uiBottom)
	return ctrl
end

function init(self)
	self.confirm:addEventListener(Event.TouchEvent,onConfirm,self)
	self.yes:addEventListener(Event.TouchEvent,onYes,self)	
	self.no:addEventListener(Event.TouchEvent,onNo,self)	
	self.close:addEventListener(Event.TouchEvent,onClose,self)
	self.close:setVisible(false)
	Common.setLabelCenter(self.yes.skillzi)
	Common.setLabelCenter(self.no.skillzi)
	self:setBtnName("是","否")
	local skin = self.txtneirong:getSkin()
	self.txtneirong:setAnchorPoint(0,1)
	self.txtneirong:setPosition(skin.x,skin.y + skin.height)
	self.txtneirong:setDimensions(skin.width,0)
	self.txtneirong:setHorizontalAlignment(Label.Alignment.Center)
	if GuideManager then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.yes, step = 5, groupId = GuideDefine.GUIDE_HERO_LV_UP})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.yes, step = 3, groupId = GuideDefine.GUIDE_UP_STAR})
	end
end

function onConfirm(self,event)
	if event.etype == Event.Touch_ended then
		self:dispatchEvent(Event.Confirm,{etype = Event.Confirm_known})
		if self._parent then
			self._parent:removeChild(self)
		end
	end
end

function onYes(self,event)
	if event.etype == Event.Touch_ended then
		self:dispatchEvent(Event.Confirm,{etype = Event.Confirm_yes})
		if GuideManager then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_LV_UP, step = 5})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_UP_STAR, step = 3})
		end
		if self._parent then
			self._parent:removeChild(self)
		end
	end
end

function onNo(self,event)
	if event.etype == Event.Touch_ended then
		self:dispatchEvent(Event.Confirm,{etype = Event.Confirm_no})
		if self._parent then
			self._parent:removeChild(self)
		end
	end
end

function onClose(self,event)
	if event.etype == Event.Touch_ended then
		self:dispatchEvent(Event.Confirm,{etype = Event.Confirm_close})
		if self._parent then
			self._parent:removeChild(self)
		end
	end
end

function showTips(content,title,name)
	content = content or "what a funy games~"
	title = title or "提示"
	local tipsPanel = new()
	if name then
		tipsPanel.name = "TipsUI_"..name
	end
	--tipsPanel.txtbiaoti:setString(title)
	tipsPanel.txtneirong:setString(content)
	tipsPanel.confirm:setVisible(false)
	tipsPanel:setPositionY(Stage.uiBottom)
	if Stage.currentScene:getUI():getChild(tipsPanel.name) then
		Stage.currentScene:getUI():removeChildByName(tipsPanel.name)
	end
	Stage.currentScene:getUI():addChild(tipsPanel)
	return tipsPanel
end

function showTipsOnlyConfirm(content,title,name)
	content = content or "what a funy games~"
	title = title or "提示"
	local tipsPanel = new()
	if name then
		tipsPanel.name = "TipsUI_Confirm_"..name
	end
	--tipsPanel.txtbiaoti:setString(title)
	tipsPanel.txtneirong:setString(content)
	tipsPanel.no:setVisible(false)
	tipsPanel.yes:setVisible(false)
	tipsPanel:setPositionY(Stage.uiBottom)
	if Stage.currentScene:getUI():getChild(tipsPanel.name) then
		Stage.currentScene:getUI():removeChildByName(tipsPanel.name)
	end
	Stage.currentScene:getUI():addChild(tipsPanel)
	return tipsPanel
end

function setBtnName(self,btn1,btn2)
	self.yes.skillzi:setString(btn1)
	self.no.skillzi:setString(btn2)
end

function showTopTipsOnlyConfirm(content,title,name)
	content = content or "what a funy games~"
	title = title or "提示"
	local tipsPanel = new()
	tipsPanel.name = "TopTips"
	--tipsPanel.txtbiaoti:setString(title)
	tipsPanel.txtneirong:setString(content)
	tipsPanel.no:setVisible(false)
	tipsPanel.yes:setVisible(false)
	tipsPanel:setAnchorPoint(0.5,0.5)
	tipsPanel:setPosition(Stage.winSize.width/2,Stage.winSize.height/2)
	if Stage.currentScene:getChild(tipsPanel.name) then
		Stage.currentScene:removeChildByName(tipsPanel.name)
	end
	tipsPanel._ccnode:setLocalZOrder(1001)
	if Stage.currentScene:getUI() ~= Stage.currentScene then
		Stage.currentScene:addChild(tipsPanel)
	end
	return tipsPanel
end

function showTopTips(content,title)
	content = content or "what a funy games~"
	title = title or "提示"
	local tipsPanel = new()
	tipsPanel.name = "TopTips"
	--tipsPanel.txtbiaoti:setString(title)
	tipsPanel.txtneirong:setString(content)
	tipsPanel.confirm:setVisible(false)
	tipsPanel:setAnchorPoint(0.5,0.5)
	tipsPanel:setPosition(Stage.winSize.width/2,Stage.winSize.height/2)
	if Stage.currentScene:getChild(tipsPanel.name) then
		Stage.currentScene:removeChildByName(tipsPanel.name)
	end
	tipsPanel._ccnode:setLocalZOrder(1001)
	Stage.currentScene:addChild(tipsPanel)
	return tipsPanel
end

function clear(self)
	Control.clear(self)
	if GuideManager then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 5, groupId = GuideDefine.GUIDE_HERO_LV_UP})
	end
end

return TipsUI

