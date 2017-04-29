module(...,package.seeall)
setmetatable(_M, {__index = Control})

local PublicDefine = require("src/modules/public/PublicDefine")
local PublicLogic = require("src/modules/public/PublicLogic")
local CrontabConfig = require("src/config/CrontabConfig").Config
local Define = require("src/modules/peak/PeakDefine")

function new()
	local ctrl = Control.new(require("res/peak/ArenaListSkin"), {"res/peak/ArenaList.plist"})
	setmetatable(ctrl, {__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_LABEL
end

function init(self)
	self.back:addEventListener(Event.Click, onClose, self)
	self.areaCon:addEventListener(Event.TouchEvent, onTouchArena, self)
	self.peakCon:addEventListener(Event.TouchEvent, onTouchPeak, self)
	self.peakCon.txtkqsj:setString(Common.getCronEventHMStr(Define.CRONTAB_PEAK))

	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.peakCon, step = 3, groupId = GuideDefine.GUIDE_PEAK})
end

function onClose(self, evt)
	UIManager.removeUI(self)
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function onTouchArena(self, evt)
	if evt.etype == Event.Touch_ended then
		UIManager.addUI("src/modules/arena/ui/ArenaUI")
	end
end

function onTouchPeak(self, evt)
	if evt.etype == Event.Touch_ended then
		if PublicLogic.checkModuleOpen(PublicDefine.MODULE_PEAK) then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_PEAK, step = 3})
			UIManager.addUI("src/modules/peak/ui/PeakUI")
		end
	end
end
