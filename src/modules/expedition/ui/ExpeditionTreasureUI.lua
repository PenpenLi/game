module(..., package.seeall)
setmetatable(_M, {__index = Control})

local ItemConfig = require("src/config/ItemConfig").Config
local BagDefine = require("src/modules/bag/BagDefine")

function new()
	local ctrl = Control.new(require("res/expedition/ExpeditionTreasureSkin"), {"res/expedition/ExpeditionTreasure.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function init(self)	
	self.grid1 = CommonGrid.bind(self.tips.daoju.gezi1, true)
	self.grid1.shuziBG._ccnode:setLocalZOrder(1)
	self.grid1.txtshuzi._ccnode:setLocalZOrder(2)
	self.grid1._icon:setScale(0.8)
	self.grid1:setIconCenter()

	self.grid2 = CommonGrid.bind(self.tips.daoju.gezi2, true)
	self.grid2.shuziBG._ccnode:setLocalZOrder(1)
	self.grid2.txtshuzi._ccnode:setLocalZOrder(2)
	self.grid2._icon:setScale(0.8)
	self.grid2:setIconCenter()

	self.grid3 = CommonGrid.bind(self.tips.daoju.gezi3, true)
	self.grid3.shuziBG._ccnode:setLocalZOrder(1)
	self.grid3.txtshuzi._ccnode:setLocalZOrder(2)
	self.grid3._icon:setScale(0.8)
	self.grid3:setIconCenter()

	self.tips.qd:addEventListener(Event.TouchEvent, onClose, self)
	self.tips.close:addEventListener(Event.TouchEvent, onClose, self)
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_LABEL
end

function onClose(self, evt)
	if evt.etype == Event.Touch_ended then
		UIManager.removeUI(self)
	end
end

function showTreasureUI(self, id, money, gemCount, item)
	self.tips.daoju.gezi1.txtshuzi:setString('')
	self.tips.daoju.gezi2.txtshuzi:setString('')
	self.tips.daoju.gezi3.txtshuzi:setString('')

	self.grid1:setItemIcon(item.itemId)
	self.tips.daoju.gezi1.txtshuzi:setString(item.count)

	local grid = nil
	local numTxt = nil
	if money > 0 then
		self.grid2:setItemIcon(BagDefine.ITEM_ID_MONEY)
		self.tips.daoju.gezi2.txtshuzi:setString(money)

		grid = self.grid3
		numTxt = self.tips.daoju.gezi3.txtshuzi
	else
		grid = self.grid2
		numTxt = self.tips.daoju.gezi2.txtshuzi
	end

	if gemCount > 0 then
		grid:setItemIcon(BagDefine.ITEM_ID_EXPEDITION)
		numTxt:setString(gemCount)
	end
end
