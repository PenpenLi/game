module(..., package.seeall)
setmetatable(_M, {__index = Control})
local Data = require("src/modules/crazy/Data")

Instance = nil 
function new()
	local ctrl = Control.new(require("res/crazy/CrazyNotifySkin"),{"res/crazy/CrazyNotify.plist","res/common/an.plist"})
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
	self.looklook:addEventListener(Event.TouchEvent,onLook,self)
	self.touch=Common.outSideTouch
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end


function onLook(self,event)
	if event.etype == Event.Touch_ended then
		UIManager.removeUI(self)
		if Data.isOpen() then
			if MainUI.Instance then
				UIManager.addUI("src/modules/crazy/ui/CrazyUI")
			end
		else
			Common.showMsg("疯狂之源已经结束啦~！")
		end
		--self:removeFromParent()
	end
end
