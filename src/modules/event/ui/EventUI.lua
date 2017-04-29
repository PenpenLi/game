module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Config = require("src/config/EventConfig").Config

function new(eventId)
    local ctrl = Control.new(require("res/event/EventSkin"),{"res/event/Event.plist","res/common/an.plist"})
    setmetatable(ctrl,{__index = _M})
    ctrl:init(eventId)
    return ctrl
end

function init(self,eventId)
	Common.setLabelCenter(self.titleLabel)
	self.close:addEventListener(Event.Click,onClose,self)

	local conf = Config[1]
	if conf then
		self.titleLabel:setString(conf.title)
		self.contentLabel:setVisible(false)
		local contentSize = cc.size(430,0) 
		local posX,posY = self.contentLabel:getPosition()
		local rich = RichText.new(RichText.UI_RICH_TEXT_DEFAULT_SKIN)
		local html = conf.content
		rich:setPosition(posX+contentSize.width/2,posY + 20)
		rich:setContentSize(contentSize)
		rich:setString(html)
		self:addChild(rich)
	end
	local call = cc.CallFunc:create(function()
		UIManager.removeUI(self)
	end)
	self:runAction(cc.Sequence:create({cc.DelayTime:create(3), call}))
end

function addStage(self)
	self:setWinCenter()
end


function onClose(self,event)
	UIManager.removeUI(self)
end



