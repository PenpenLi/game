module("HerolvupUI", package.seeall)
setmetatable(_M, {__index = Control})
local Def = require("src/modules/hero/HeroDefine")
local BagData = require("src/modules/bag/BagData")
local BagLogic = require("src/modules/bag/BagLogic")
local ItemConfig = require("src/config/ItemConfig").Config
local Hero = require("src/modules/hero/Hero")

function new(name)
	local ctrl = Control.new(require("res/hero/HerolvupSkin"), {"res/hero/Herolvup.plist","res/common/an.plist"})
	ctrl.name = "HerolvupUI"
	setmetatable(ctrl,{__index = _M})
	ctrl:init(name)
	Instance = ctrl
	return ctrl
end
function uiEffect()
	return UIManager.THIRD_TEMP
end

function init(self,name)
	_M.touch = function(self, event)
		local ret = Common.outSideTouch(self, event)
		if ret == true then
			Stage.currentScene:dispatchEvent(Event.GuideRemove)
			GuideManager.dispatchEvent(GuideDefine.GUIDE_DO_STEP, {groupId = GuideDefine.GUIDE_EQUIP, step = 3})	
		end
	end
	local hero = Hero.getHero(name)
	self.hero = hero
	local function onMedicine(self,event,target)
		local itemId = target.itemId
		local med = target
		local function onHold(self,event,target)
			local itemNum = BagData.getItemNumByItemId(itemId)
			if BagData.getItemNumByItemId(itemId) <= 0 then
				local itemName = ItemConfig[itemId].name
				if itemName then
					Common.showMsg(itemName..'不足')
				end
				return
			end
			local nextExp = hero:getExpForNextLv()
			if hero.lv >= Master:getInstance().lv and hero.exp == nextExp then
				if not Stage.currentScene:getUI():getChild('TipsUI_Confirm_lvtip') then
					-- local tip = TipsUI.showTipsOnlyConfirm("英雄等级无法超过战队等级","提示",'lvtip')
					Common.showMsg('英雄等级无法超过战队等级')
					med:dispatchEvent(Event.TouchEvent,{etype=Event.Touch_out})
				else
					local a= 0
				end
			else
				local cnt = 1
				if event then
					local t = math.abs(event.maxTimes)
					if t < 3 then
						cnt = 1
					elseif t < 5 then
						cnt = math.min(5,itemNum)
					elseif t < 10 then
						cnt = math.min(10,itemNum)
					elseif t < 15 then
						cnt = math.min(13,itemNum)
					else
						cnt = math.min(15,itemNum)
					end
				end
				BagLogic.useItem(itemId,cnt,{name})
			end
		end
		if itemId and itemId > 0 then
			if event.etype == Event.Touch_began then
				if target.holdTimer then
					target:delTimer(target.holdTimer)
				end
				target.holdTimer = target:addTimer(onHold,0.3,-1,self)
				target:openTimer()
			elseif event.etype == Event.Touch_ended then
				onHold(self)
				if target.holdTimer then
					target:delTimer(target.holdTimer)
					target.holdTimer = nil
				end
			elseif event.etype == Event.Touch_out then
				if target.holdTimer then
					target:delTimer(target.holdTimer)
					target.holdTimer = nil
				end
			end
		end
	end
	for i=1,3 do 
		local itemId = Def.EXP_MEDICINE[i]
		self['exp'..i].itemId = itemId
		self['exp'..i]:addEventListener(Event.TouchEvent,onMedicine,self)
	end
	self.maxlv:setVisible(false)
	self.fullexp:setVisible(false)

	CommonGrid.bind(self.itembg)
	self.itembg:setHeroIcon2(name,'s',hero.quality)
	self:addArmatureFrame("res/common/effect/lvPb/lvPb.ExportJson")
	self:addArmatureFrame("res/common/effect/lvUpTxt/lvUpTxt.ExportJson")


	local px,py = self.itembg:getPosition()
	local size = self.itembg:getContentSize()
	-- self.herolvupEffect = ccs.Armature:create('heroup')
	-- self.attrgroup._ccnode:addChild(self.herolvupEffect)

	-- self.herolvupEffect:setPosition(px+size.width/2,py)

	self.lvupEffect = ccs.Armature:create('lvUpTxt')
	self._ccnode:addChild(self.lvupEffect,10)
	self.lvupEffect:setPosition(px+size.width/2,py+80)

	self.progEffect = ccs.Armature:create('lvPb')
	
	self.progEffect:setAnchorPoint(0.5,0.5)
	local x,y = self.explongprog:getContentSize().width/2,self.explongprog:getContentSize().height/2
	self.progEffect:setPosition(x,y)
	self.explongprog._ccnode:addChild(self.progEffect)

	Common.setLabelCenter(self.txtexp,'right')
	Common.setLabelCenter(self.txtname)
	-- self.txtname:setString(hero.cname)
	self.hero:showHeroNameLabel(self.txtname)
	
	self:refreshLvUp()
	Bag.getInstance():addEventListener(Event.BagRefresh,onBagRefresh,self)


	local function onTopExp(self,event,target)
		if event.etype == Event.Touch_began then
			self:refreshUseButton()
		elseif event.etype == Event.Touch_moved then
			self:refreshUseButton()
		elseif event.etype == Event.Touch_out then
			self:refreshUseButton()
		elseif event.etype == Event.Touch_ended then
			if self.hero.lv >= Master.getInstance().lv then
				self.use:setState(Button.UI_BUTTON_DISABLE)
			else
				self.use:setState(Button.UI_BUTTON_NORMAL)
				local cnt = 0 
				cnt = self:getMedicineCnt()
				if cnt <= 0 then
					Common.showMsg("英雄经验药水不足")
				else
					local tipUI = TipsUI.showTips("英雄经验药水不足 或者 英雄等级达到上限时 自动停止使用，确定一键使用药水吗？")
					tipUI:addEventListener(Event.Confirm,function(self,event)
						if event.etype == Event.Confirm_yes then
							Network.sendMsg(PacketID.CG_HERO_TOP_LVUP,name)
						end
					end,self)
				end
				GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_LV_UP, step = 4})				
			end
		end
	end
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.use, addFinishFun = function()
		if self.hero.lv >= Master.getInstance().lv then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_LV_UP, step = 4})				
			Stage.currentScene:getUI():runAction(cc.Sequence:create(
			cc.DelayTime:create(0.1),
			cc.CallFunc:create(function()
				GuideManager.dispatchEvent(GuideDefine.GUIDE_DO_STEP, {groupId = GuideDefine.GUIDE_HERO_LV_UP, step = 6})	
			end)
			))
		end
	end,step = 4, delayTime = 0.3, groupId = GuideDefine.GUIDE_HERO_LV_UP})
	self.use:addEventListener(Event.TouchEvent,onTopExp,self)
	self:refreshUseButton()
end

function refreshUseButton(self)
	if self.hero.lv >= Master.getInstance().lv then
		self.use:setState(Button.UI_BUTTON_DISABLE)
	else
		self.use:setState(Button.UI_BUTTON_NORMAL)
	end
end
function refreshLvUp(self)
	local hero = self.hero
	local percent = 100*hero.exp/hero:getExpForNextLv()
	self.txtexp:setString(hero.exp.."/"..hero:getExpForNextLv())
	self.explongprog:setPercent(percent)
	self.txtlv:setString('lv'..hero.lv)

	local nextExp = hero:getExpForNextLv()
	if hero.lv >= Def.MAX_LEVEL then
		self.fullexp:setVisible(false)
		self.maxlv:setVisible(true)
	elseif hero.lv >= Master:getInstance().lv and hero.exp >= nextExp then
		self.fullexp:setVisible(true)
		self.maxlv:setVisible(false)
	else
		self.fullexp:setVisible(false)
		self.maxlv:setVisible(false)
	end

	-- self.maxlv:setVisible(false)
	-- self.fullexp:setVisible(false)

	self:refreshItemCnt()
end

function getMedicineCnt(self)
	local cnt = 0
	for i=1,3 do
		local itemId = Def.EXP_MEDICINE[i]
		cnt = cnt + BagData.getItemNumByItemId(itemId)
	end
	return cnt
end
function refreshItemCnt(self)
	for i=1,3 do
		local itemId = Def.EXP_MEDICINE[i]
		local num = BagData.getItemNumByItemId(itemId)
		self['exp'..i].txtnum:setString(tostring(num))
	end
end
function onBagRefresh(self,event,target)
	self:refreshItemCnt()
end


function showLvUp(self,lvup)
	local hero = self.hero
	local percent = 100*self.hero.exp/self.hero:getExpForNextLv()
	self.txtexp:setString(self.hero.exp.."/"..self.hero:getExpForNextLv())
	self.explongprog:setPercent(percent)
	self.txtlv:setString('lv'..self.hero.lv)
	-- self.herolvupEffect:getAnimation():playWithNames({"成功进阶"},0,false)
	local nextExp = hero:getExpForNextLv()
	if hero.lv >= Def.MAX_LEVEL then
		self.fullexp:setVisible(false)
		self.maxlv:setVisible(true)
	elseif hero.lv >= Master:getInstance().lv and hero.exp >= nextExp then
		self.fullexp:setVisible(true)
		self.maxlv:setVisible(false)
	else
		self.fullexp:setVisible(false)
		self.maxlv:setVisible(false)
	end
	self.progEffect:getAnimation():play("p1",-1,0)
	UIManager.playMusic('expUp')
	if lvup then
		self.lvupEffect:getAnimation():play("头像升级啦",-1,0)
	end
end

function clear(self)
	Instance = nil
	Bag.getInstance():removeEventListener(Event.BagRefresh,onBagRefresh)
end


return HerolvupUI
