module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Define = require("src/modules/achieve/AchieveDefine")
local Logic = require("src/modules/task/TaskLogic")

function new()
	local ctrl = Control.new(require("res/achieve/TargetSkin"), {"res/achieve/Target.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.SECOND_TEMP
end

function init(self)
	self:initCon()
	self:initSel()
	self:initTimer()
	self:addListener()	
end

function initCon(self)
	local AchieveUI = require("src/modules/achieve/ui/AchieveUI")
	local TaskUI = require("src/modules/task/ui/TaskUI")
	local TimeTaskUI = require("src/modules/task/ui/TimeTaskUI")

	self.achieveUI = AchieveUI.new(self.achieveCon._skin)
	self.taskUI = TaskUI.new(self.taskCon._skin)
	self.timeTaskUI = TimeTaskUI.new(self.timelimitCon._skin)

	--self.back._ccnode:setLocalZOrder(100)
	self.achieveCon:removeFromParent()
	self.taskCon:removeFromParent()
	self.timelimitCon:removeFromParent()

	self:addChild(self.achieveUI)
	self:addChild(self.taskUI)
	self:addChild(self.timeTaskUI)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.targetRbg.achievement, step = 3, groupId = GuideDefine.GUIDE_ACHIEVE})
	self.targetRbg.timelimit:setVisible(Logic:hasShowTimeTask())

end

function initSel(self)
	self.typeVal = Define.TARGET_TASK
	self:refresh()
	self.targetRbg.task:setSelected(true)
	Dot.check(self.targetRbg.achievement, DotDefine.DOT_C_ACHIEVE)
end

function initTimer(self)
	self:openTimer()
	self:addEventListener(Event.Frame, onRefreshList, self)
end

function addListener(self)
	self.back:addEventListener(Event.Click, onClose, self)
	self.targetRbg:addEventListener(Event.Change, onChangeTarget, self)
	Dot.check(self.targetRbg.task,"taskRefresh")
	Dot.check(self.targetRbg.timelimit,"timeTaskRefresh")
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function onClose(self)
	UIManager.removeUI(self)
end

function onRefreshList(self)
	self.achieveUI:refreshList()
	self.taskUI:refreshList()
	self.timeTaskUI:refreshList()
end

function onChangeTarget(self, evt)
	if evt.target.name == "achievement" then
		self.typeVal = Define.TARGET_ACHIEVE
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_ACHIEVE, step = 3})
	elseif evt.target.name == "timelimit" then 
		self.typeVal = Define.TARGET_TIMETASK
	else
		self.typeVal = Define.TARGET_TASK
	end
	self:refresh()
end

function refresh(self)
	if self.typeVal == Define.TARGET_ACHIEVE then
		self.achieveUI:setVisible(true)
		self.taskUI:setVisible(false)
		self.timeTaskUI:setVisible(false)
	elseif self.typeVal == Define.TARGET_TIMETASK then
		self.achieveUI:setVisible(false)
		self.taskUI:setVisible(false)
		self.timeTaskUI:setVisible(true)
		self.timeTaskUI:refreshTime()
	else
		self.achieveUI:setVisible(false)
		self.taskUI:setVisible(true)
		self.timeTaskUI:setVisible(false)
	end
end

function refreshAchieveList(self)
	self.achieveUI:refresh()
	Dot.check(self.targetRbg.achievement, DotDefine.DOT_C_ACHIEVE)
	Dot.checkToCache(DotDefine.DOT_C_TARGET)
end

function refreshTaskList(self)
	self.taskUI:refresh()
	Dot.check(self.targetRbg.task,"taskRefresh")
end

function refreshTimeTaskList(self)
	print("refreshTimeTaskList================")
	self.timeTaskUI:refreshTime()
	Dot.check(self.targetRbg.timelimit,"timeTaskRefresh")

end

function clear(self)
	Control.clear(self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 3, groupId = GuideDefine.GUIDE_ACHIEVE})
end
