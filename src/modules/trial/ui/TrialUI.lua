module(..., package.seeall)
setmetatable(_M, {__index = Control}) 

local Hero = require("src/modules/hero/Hero")
local HeroDefine = require("src/modules/hero/HeroDefine")
local BaseMath = require("src/modules/public/BaseMath")

local Config = require("src/config/TrialConfig").Config
local Logic = require("src/modules/trial/TrialLogic")
local Define = require("src/modules/trial/TrialDefine")

function new(levelId,isWin)
    local ctrl = Control.new(require("res/trial/TrialSkin"),{"res/trial/Trial.plist"})
    setmetatable(ctrl,{__index = _M})
	ctrl.levelId = levelId
	ctrl.isWin = isWin
    ctrl:init()
    return ctrl
end

function init(self)
	local list = {}
	for levelId,v in pairs(Config) do
		list[#list+1] = v
	end
	table.sort(list,function(a,b) return a.levelId < b.levelId end)
	self.sortList = list
	--Logic.resetByDay()
	--effect
	--self:addArmatureFrame("res/common/effect/BtnShine.ExportJson")
	--self:addArmatureFrame("res/common/effect/BtnShine2.ExportJson")
	Network.sendMsg(PacketID.CG_TRIAL_CHECK)
	self.master = Master.getInstance()
	self.back:addEventListener(Event.Click,onBack,self)
	self.rank:addEventListener(Event.Click,function() 
		UIManager.addUI("src/modules/trial/ui/RankUI")
	end,self)
	self.rank:setVisible(false)

	--self.gate.view:addEventListener(Event.Click,onViewItem,self)
	--self.gate:setVisible(false)
	--self.gate.level:setBgVisiable(false)
	--self.gate.level:setDirection(List.UI_LIST_HORIZONTAL)
	--self.levelMap = {}
	self:createLevel()
	self:openTimer()
	self:addTimer(function() 
		if self.levelId then
			local type = Config[self.levelId].type
			UIManager.addChildUI("src/modules/trial/ui/LevelGateUI",type)
		end
	end,0.2,1)
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function uiEffect(self)
	return UIManager.FIRST_TEMP
end

function showRule(self)
	local ui = UIManager.addChildUI("src/ui/RuleUI")
	ui:setId(RuleUI.Trial)
end

function showRank(self)
	UIManager.addChildUI("src/modules/trial/ui/RankUI")
end

function createLevel(self)
	for i=1,3 do
		local grid = self["lvGroup" .. i]
		grid.type = i
		if self:isOpen(i) then
			grid:addEventListener(Event.TouchEvent,onClickGroup,self)
		else
			grid:shader(Shader.SHADER_TYPE_GRAY)
			grid:addEventListener(Event.TouchEvent,function(self,event) 
				if event.etype == Event.Touch_ended then
					local msg = string.format("%d级开启",self:getOpenLvByType(i))
					Common.showMsg(msg)
				end
			end,self)
		end
		if i == 1 then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=grid, step = 3, groupId = GuideDefine.GUIDE_TRIAL})
		end
		for j=1,3 do
			local g = grid["daoju" .. j] 
			if g then
				CommonGrid.bind(g,"tips")
				g.touchParent = false
				g:setItemIcon(Define.TYPE_REWARD[i][j],"mIcon")
			end
		end
	end
end

function isOpen(self,type)
	for _,v in ipairs(self.sortList) do
		if v.type == type then
			if self.master.lv >= v.openLv then
				return true
			end
		end
	end
	return false
end

function getOpenLvByType(self,type)
	for _,v in ipairs(self.sortList) do
		if v.type == type then
			return v.openLv
		end
	end
end

function onClickGroup(self,event,target)
	if event.etype == Event.Touch_ended then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_TRIAL, step = 3})
		self.curType = target.type
		self:showLevel(target.type)
		--local counter = Define.MAX_LEVEL_COUNTER-Logic.getCounterByType(self.curType)
		--if counter == 0 then
		--	Common.showMsg("今日可挑战次数0，请改日再战")
		--else
		--	self:showLevel(target.type)
		--end
	end
end

function showLevel(self,type) 
	if type == Define.TYPE_A then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_START, {groupId = GuideDefine.GUIDE_TRIAL_ENTER}) 
		GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, groupId = GuideDefine.GUIDE_TRIAL_ENTER})
	end
	if type == Define.TYPE_B then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_START, {groupId = GuideDefine.GUIDE_TRIAL_SECOND_ENTER}) 
		GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, groupId = GuideDefine.GUIDE_TRIAL_SECOND_ENTER})
	end
	if type == Define.TYPE_C then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_START, {groupId = GuideDefine.GUIDE_TRIAL_THIRD_ENTER}) 
		GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, groupId = GuideDefine.GUIDE_TRIAL_THIRD_ENTER})
	end
	UIManager.addChildUI("src/modules/trial/ui/LevelGateUI",type)
	--[[
	ActionUI.show(self.gate,"scale")
	self:getChild("actionGray"):addEventListener(Event.TouchEvent,function() 
		ActionUI.hide(self.gate,"scaleHide")
	end,self)
	local levelList = self.gate.level
	levelList:removeAllItem()
	for _,v in pairs(self.sortList) do
		if v.type == type then
			local item = levelList:getItemByNum(levelList:addItem())
			item:addEventListener(Event.TouchEvent,onFight,self)
			item.levelId = v.levelId
			item.title:setString(v.title)
			self.levelMap[v.levelId] = item 
		end
	end
	self.levelType = type
	self:setLevelData(self)
	--]]
end

function setLevelData(self)
end

function onViewItem(self,event,target)
	UIManager.addChildUI("src/modules/trial/ui/ViewItemUI",self.curType)
end

function onFight(self,event,target)
	if event.etype == Event.Touch_ended then
		local levelId = target.levelId
		local level = Logic.getLevelByLevelId(levelId)
		if level.status == Define.STATUS.HAD_PASS then
			TipsUI.showTipsOnlyConfirm("已通关")
		elseif level.status == Define.STATUS.CAN_FIGHT then
			--UIManager.addUI("src/modules/trial/ui/LevelUI",levelId)
			UIManager.addUI("src/modules/trial/ui/FightUI",levelId)
		else
			local msg = string.format("%d级开启",Config[levelId].openLv)
			Common.showMsg(msg)
		end
	end
end

function onReset(self)
	if Logic.getCounter() == Define.MAX_RESET_TIMES then
		Common.showMsg("今天不能重置了哦")
	else
		Network.sendMsg(PacketID.CG_TRIAL_RESET)
	end
end


--
function onBack(self,event)
	UIManager.removeUI(self)
end





