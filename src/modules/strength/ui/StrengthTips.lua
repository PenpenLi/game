module("StrengthTips",package.seeall)
setmetatable(_M,{__index = Control})

function new()
	local ctrl = Control.new(require("res/strength/StrengthTipsSkin"),{"res/strength/StrengthTips.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function addStage(self)
end

function init(self)
	self:addArmatureFrame("res/strength/effect/active/StrengthActive.ExportJson")
	function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.known:addEventListener(Event.Click,onClose,self)	
end

function refreshLabel(self,labels)
	for i = 1,3 do
		local label = labels[i]
		if label then
			self["txt"..i]:setString(label)
		else
			self["txt"..i]:setString("")
		end
	end
	self.jhcgzi:setVisible(false)
	Common.setBtnAnimation(self._ccnode,"StrengthActive","active",{y=100})
end

return StrengthTips
