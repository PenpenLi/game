module("StrengthCompose",package.seeall)
setmetatable(_M,{__index = Control})
local ItemConfig = require("src/config/ItemConfig").Config
local BagData = require("src/modules/bag/BagData")
local StrengthLogic = require("src/modules/strength/StrengthLogic")

function new(id)
	local ctrl = Control.new(require("res/strength/StrengthComposeSkin"),{"res/strength/StrengthCompose.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(id)
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function init(self,id)
	self.id = id
	_M.touch = Common.outSideTouch
	--local function onClose(self,event,target)
	--	UIManager.removeUI(self)
	--end
	--self.close:addEventListener(Event.Click,onClose,self)
	local function onCompose(self,event,target)
		local fragCfg = StrengthLogic.getFragConfig()[id]
		if fragCfg then
			local destId = fragCfg.destId
			Network.sendMsg(PacketID.CG_STRENGTH_FRAG_COMPOSE,destId)
		end
	end
	self.compose:addEventListener(Event.Click,onCompose,self)
	Bag.getInstance():addEventListener(Event.BagRefresh,onBagRefresh,self)
	self:setTxtFontSize()
	self.gridDst.txtname:setAnchorPoint(0.5,0)
	self.gridSrc.txtnum:setAnchorPoint(0.5,0)
	CommonGrid.bind(self.gridSrc.bg)
	CommonGrid.bind(self.gridDst.bg)
	self:refreshInfo()
end

function onBagRefresh(self,event,target)
	self:refreshInfo()
end

function clear(self)
	Control.clear(self)
	Bag.getInstance():removeEventListener(Event.BagRefresh,onBagRefresh)
end

function setTxtFontSize(self)
	--self.txtReason:setFontSize(22)
	--self.gridDst.txtname:setFontSize(22)
	--self.gridSrc.txtnum:setFontSize(22)
	--self.txthf:setFontSize(22)
	--self.cost:setFontSize(22)
end

function refreshInfo(self)
	local id = self.id
	self.gridSrc.bg:setItemIcon(id)
	local cfg = StrengthLogic.getFragConfig()[id]
	if cfg  then
		self.cost:setString(cfg.cost)
		self.gridDst.bg:setItemIcon(cfg.destId)
		local itemCfg = ItemConfig[cfg.destId]
		self.txtbt:setString("合成"..itemCfg.name)
		self.gridDst.txtname:setString(itemCfg.name)
		local num = BagData.getItemNumByItemId(id)
		self.gridSrc.txtnum:setString(num .. "/" ..cfg.num)
		if num >= cfg.num then
			self.gridSrc.txtnum:setColor(243,208,117)
			self.txtReason:setVisible(false)
		else
			self.gridSrc.txtnum:setColor(233,0,0)
		end
	end
end

return StrengthCompose
