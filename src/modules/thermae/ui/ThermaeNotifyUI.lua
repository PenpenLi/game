module(..., package.seeall)
setmetatable(_M, {__index = Control})
local Hero = require("src/modules/hero/Hero")
local ThermaeLogic = require("src/modules/thermae/ThermaeLogic")
local ThermaeDefine = require("src/config/ThermaeDefineConfig").Defined
local Data = require("src/modules/thermae/Data")
local HeroDefineConfig = require("src/config/HeroDefineConfig").Config
local ThermaeSpeak = require("src/config/ThermaeSpeakConfig").Config
local ThermaeConfig = require("src/config/ThermaeConfig").Config

Instance = nil 
function new()
	local ctrl = Control.new(require("res/thermae/ThermaeNotifySkin"),{"res/thermae/ThermaeNotify.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	Instance = ctrl
	return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP_FULL
end

function clear(self)
	Instance = nil
	Control.clear(self)
end

function init(self)
	self.look:addEventListener(Event.TouchEvent,onLook,self)
	self.touch=Common.outSideTouch
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end


function onLook(self,event)
	if event.etype == Event.Touch_ended then
		UIManager.removeUI(self)
		if Data.isOpen() and Master:getInstance().lv >= ThermaeDefine.level then
			if MainUI.Instance then
				UIManager.addUI("src/modules/thermae/ui/ThermaeUI")
			end
		else
			Common.showMsg("温泉活动已经结束啦~！")
		end
		--self:removeFromParent()
	end
end
