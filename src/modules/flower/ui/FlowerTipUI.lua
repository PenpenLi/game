module(..., package.seeall)
setmetatable(_M, {__index = Control})

function new()
	local ctrl = Control.new(require("res/flower/FlowerTipSkin"), {"res/flower/FlowerTip.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.THIRD_TEMP
end

function init(self)
	--_M.touch = Common.outSideTouch
	self.yes:addEventListener(Event.Click, onYes, self)
	self.no:addEventListener(Event.Click, onNo, self)
end

function showFirst(self, index, fromType, flowerType)
	self.firstCon:setVisible(true)
	self.leftCon:setVisible(false)
	self.index = index
	self.fromType = fromType
	self.flowerType = flowerType
end

function showLeft(self, index, fromType, flowerType)
	self.firstCon:setVisible(false)
	self.leftCon:setVisible(true)
	self.index = index
	self.fromType = fromType
	self.flowerType = flowerType
end

function onYes(self, evt)
	local val = 0
	if self.tipBtn:getSelected() == true then
		val = 1
	end
	Network.sendMsg(PacketID.CG_FLOWER_GIVE, self.index, self.fromType, self.flowerType, val)
	UIManager.removeUI(self)
end

function onNo(self, evt)
	UIManager.removeUI(self)
end
