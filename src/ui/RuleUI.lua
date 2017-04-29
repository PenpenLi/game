module("RuleUI", package.seeall)
setmetatable(_M, {__index = Control})

Trial = 1
Expedition = 2
Orochi = 3
Arena = 4
Flower = 5
Texas = 6
GuildKick = 7
GuildWine = 8
Peak = 11

local Config = require("src/config/RuleConfig").Config

function new()
	local ctrl = Control.new(require("res/common/RuleSkin"), {"res/common/Rule.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect()
	return UIManager.SECOND_TEMP
end

function addStage(self)
	--self:setScale(Stage.uiScale)
	--self:setPositionY(Stage.uiBottom)
end


function init(self)
	self.titleLabel:setAnchorPoint(0.5,0)
	self.close1:addEventListener(Event.Click, onClose, self)

	local posX,posY = self.contentLabel:getPosition()
	local contentSize = cc.size(500,self.contentLabel:getContentSize().height)
	local rich = RichText.new(RichText.UI_RICH_TEXT_DEFAULT_SKIN)
	rich:setPosition(posX+contentSize.width/2,posY+contentSize.height)
	rich:setContentSize(cc.size(contentSize.width,0))
	rich:setColor(38,11,11)
	self.rich = rich
	self:addChild(rich)
	self.rich:setVisible(false)

	self.contentLabel:setAnchorPoint(0,1)
	self.contentLabel:setPositionY(self.contentLabel:getPositionY() + self.contentLabel:getContentSize().height)
	self.contentLabel:setDimensions(537, 0)
	self.contentLabel:setVisible(false)
	self.descView:setVisible(false)

	self.isGrayLayer = true
end

function setId(self,id)
	local conf = Config[id]
	assert(conf,"lost conf==>" .. id)
	self:setTitle(conf.title)
	self:setContent(conf.txt,true)
end

function setTitle(self,title)
	self.titleLabel:setString(title)
end

function setContent(self,content,isHtml)
	self.rich:setVisible(isHtml)
	self.contentLabel:setVisible(not isHtml)
	if isHtml then
		self.rich:setString(content)
	else
		self.contentLabel:setString(content)
	end
end

function onClose(self, evt)
	UIManager.removeUI(self)
end

return RuleUI

