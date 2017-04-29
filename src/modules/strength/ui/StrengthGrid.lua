module("StrengthGrid",package.seeall)
setmetatable(_M,{__index = Control})
local ItemConfig = require("src/config/ItemConfig").Config
local StrengthDefine = require("src/modules/strength/StrengthDefine")

function new()
	local ctrl = Control.new(require("res/strength/StrengthGridSkin"),{"res/strength/StrengthGrid.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function init(self)
end

function setIcon(self,id,name)
	local res = "res/common/icon/item/" .. ItemConfig[id][name or "icon"] .. ".png"
	self.icon._ccnode:setTexture(res)
	local width = self.icon._ccnode:getContentSize().width
	local scale = name == "descIcon" and 92 or 65 --目前格子大小 
	self.icon._ccnode:setScale(scale/width)
end

function setActiveState(self,state)
	self.state = state
	self.noActive:setVisible(false)
	self.notActive:setVisible(false)
	self.canCompose:setVisible(false)
	self.canActive:setVisible(false)
	self.crossy:setVisible(false)
	self.crossg:setVisible(false)
	Shader.setShader(self.icon._ccnode,"Gray")
	if state == StrengthDefine.GRID_STATE.active then
		Shader.setShader(self.icon._ccnode)
	elseif state == StrengthDefine.GRID_STATE.noActive then
		self.noActive:setVisible(true)
	elseif state == StrengthDefine.GRID_STATE.notActive then
		self.notActive:setVisible(true)
		self.crossy:setVisible(true)
	elseif state == StrengthDefine.GRID_STATE.canCompose then
		self.canCompose:setVisible(true)
		self.crossg:setVisible(true)
	elseif state == StrengthDefine.GRID_STATE.canActive then
		self.canActive:setVisible(true)
		self.crossg:setVisible(true)
	end
	if state == StrengthDefine.GRID_STATE.canActive then
		ActionUI.bounce({self})
	else
		ActionUI.stop({self})
	end
end

function getActiveState(self)
	return self.state
end

return StrengthGrid

