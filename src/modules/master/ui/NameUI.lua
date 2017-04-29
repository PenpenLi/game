module(..., package.seeall)
setmetatable(_M, {__index = Control}) 

local MasterDefine = require("src/modules/master/MasterDefine")
local SensitiveFilter = require("src/modules/public/SensitiveFilter")
local Announce = require("src/modules/announce/Announce")

function new()
    local ctrl = Control.new(require("res/master/NameSkin"),{"res/master/Name.plist"})
    setmetatable(ctrl,{__index = _M})
    ctrl:init()
    return ctrl
end

function uiEffect()
	local effect = {
		[UIManager.UI_EFFECT.kBg] = true,
		[UIManager.UI_EFFECT.kFull] = true,
	}
	return effect
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function clear(self)
	Control.clear(self)
	Announce.showLoginAnnounce()
end

function init(self)
	self.tipLabel:setDimensions(self.tipLabel:getContentSize().width,0)
	self.tipLabel:setHorizontalAlignment(Label.Alignment.Center)
	self.tipLabel:setVisible(false)
	self.editBox = Common.createEditBox(self.nameLabel)
	self.editBox:setMaxLength(MasterDefine.MAX_NAME)
	self._ccnode:addChild(self.editBox)
	local name = Common.randomRoleName()
	local try = 2
	while try > 0 and SensitiveFilter.hasSensitiveWord(name) do
		name = Common.randomRoleName()
		try = try - 1
	end
	self.editBox:setText(name)

	self.confirm:addEventListener(Event.Click,onConfirm,self)
	self.dice:addEventListener(Event.Click,onDice,self)
end

function onConfirm(self)
	local name = self.editBox:getText()
	if name:len() < 1 then
		self:showTip("名字不能为空")
		return 
	end
	if #Common.utf2tb(name) > MasterDefine.MAX_NAME then
		self:showTip(string.format("最多可输入%d个字符",MasterDefine.MAX_NAME))
		return 
	end
	local isSensitive = SensitiveFilter.hasSensitiveWord(name)
	if isSensitive then
		self:showTip("名字不合法")
	else
		Network.sendMsg(PacketID.CG_RENAME,name)
	end
end

function onDice(self)
	local name = Common.randomRoleName()
	self.editBox:setText(name)
end

function showTip(self,tip)
	self.tipLabel:setVisible(true)
	self.tipLabel:setString(tip)
end



