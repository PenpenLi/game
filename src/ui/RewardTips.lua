module("RewardTips", package.seeall)
setmetatable(_M, {__index = Control})
local ItemConfig = require("src/config/ItemConfig").Config

function new(group)
	local ctrl = Control.new(require("res/common/RewardTipsSkin"), {"res/common/RewardTips.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(group)
	return ctrl
end

function uiEffect()
	THIRD_TEMP= {
		--[UIManager.UI_EFFECT.kBg] = true,
		[UIManager.UI_EFFECT.kGray] = true,
		--[UIManager.UI_EFFECT.kSlide] = true,
		[UIManager.UI_EFFECT.kScaleIn] = true,
		[UIManager.UI_EFFECT.kScaleOut] = true,
		[UIManager.UI_EFFECT.kFull] = true,
	}
	return THIRD_TEMP
end

function init(self,group)
	UIManager.playMusic("rewardTips")
	function onClose(self,event,target)
		if event.etype == Event.Touch_ended then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_ACHIEVE, step = 5})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_TASK, step = 3})
			--local pos = cc.p(self:getPositionX(), self:getPositionY())
			UIManager.removeUI(self)
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SIGN_IN, step = 3})
			--if group and next(group) then
			--	table.remove(group,1)
			--	show(group, pos)
			--end
		end
	end
	self.confirm:addEventListener(Event.TouchEvent,onClose,self)
	self.confirm:setVisible(false)
	self:openTimer()
	self:showUpTips(group)
end

function showUpTips(self,group)
	local item = group[1]
	self.wcmz:setAnchorPoint(0.5,0)
	self.fjfj:setAnchorPoint(0.5,0)
	self.fjfj:setString(item.title)
	self.wcmz:setString("获得物品")
	if #group <= 4 then
		self.gezi:setVisible(false)
		local num = 0
		for i = 1,4 do
			if group[i] then
				num = num + 1
				local item = group[i]
				self["dj"..i].sl:setAnchorPoint(1,0)
				self["dj"..i].sl:setString(item.num)
				CommonGrid.bind(self["dj"..i].herobg,"tips")
				self["dj"..i].herobg:setItemIcon(item.id)
			else
				self["dj"..i]:setVisible(false)
			end
		end
		for i = 1,num do
			local adjustX = 43 * (4 - num)
			self["dj"..i]:setPositionX(self["dj"..i]:getPositionX()+adjustX)
		end
	else
		self.gezi:setBgVisiable(false)
		for i = 1,4 do
			self["dj"..i]:setVisible(false)
		end
		self.gezi:setDirection(List.UI_LIST_HORIZONTAL)
		self.gezi:setItemNum(#group)
		for i = 1,#group do
			local item = group[i]
			local ctrl = self.gezi:getItemByNum(i)
			local grid = ctrl["gezi1"]
			CommonGrid.bind(grid.headBG,"tips")
			grid.headBG:setItemIcon(item.id)
			grid.sl:setAnchorPoint(1,0)
			grid.sl:setString(item.num)
		end
	end
	self:addTimer(showConfirm,0.35,1,self)
end

function showConfirm(self)
	self.confirm:setVisible(true)
	self.confirm:setAnchorPoint(0.5,0.5)
	self.confirm:setScale(0.2)
	self.confirm:setPositionX(self.confirm:getPositionX()+self.confirm:getContentSize().width/2)
	self.confirm:setPositionY(self.confirm:getPositionY()+self.confirm:getContentSize().height/2)
	local original = 1
	local scaleTo = cc.ScaleTo:create(0.15,original*1.1,original*1.1)
	local sineOut = cc.EaseSineOut:create(scaleTo)
	local scaleTo2 = cc.ScaleTo:create(0.2,original,original)
	local sineOut2 = cc.EaseSineOut:create(scaleTo2)
	local seq = cc.Sequence:create({sineOut,sineOut2})
	self.confirm:runAction(seq)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.confirm, clickFun = function()
		--UIManager.reset()
	end,step = 3, filterUI = 'RewardTips', delayTime = 0.3, groupId = GuideDefine.GUIDE_TASK})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.confirm, step = 3, filterUI = 'RewardTips', delayTime = 0.3, groupId = GuideDefine.GUIDE_SIGN_IN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.confirm, step = 5, filterUI = 'RewardTips', delayTime = 0.3, groupId = GuideDefine.GUIDE_ACHIEVE})
end

function show(group)
	local ui = nil
	if group and next(group) then
		if UIManager.getCurrentUI() then
			ui = UIManager.addChildUI("src/ui/RewardTips",group)
		else
			ui = UIManager.addUI("src/ui/RewardTips",group)
			--ui:setPositionY(ui:getPositionY()+Stage.uiBottom)
		end
	end
	return ui
end

function showTen(rewards)
	local ui = nil
	if UIManager.getCurrentUI() then
		ui = UIManager.addChildUI("src/modules/shop/ui/ShopTenUI",rewards,nil,"common")
	else
		ui = UIManager.addUI("src/modules/shop/ui/ShopTenUI",rewards,nil,"common")
		ui:setPositionY(ui:getPositionY()+Stage.uiBottom)
	end
	ui.jbbicon1:setVisible(false)
	ui.jbbicon2:setVisible(false)
	ui.oncemore:setVisible(false)
	ui.tenmore:setVisible(false)
	ui.onceCost:setVisible(false)
	ui.tenCost:setVisible(false)
end

--function hide()
--end

function clear(self)
	Control.clear(self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 3, groupId = GuideDefine.GUIDE_TASK})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 3, groupId = GuideDefine.GUIDE_SIGN_IN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 5, groupId = GuideDefine.GUIDE_ACHIEVE})
end

return RewardTips
