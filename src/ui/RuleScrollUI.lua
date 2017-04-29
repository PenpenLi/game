module("RuleScrollUI", package.seeall)
setmetatable(_M, {__index = Control})

Trial = 1
Expedition = 2
Orochi = 3
Arena = 4
Flower = 5
Texas = 6
GuildKick = 7
GuildWine = 8
SignIn = 9
Crazy = 10
Treasure = 12
WorldBoss = 13
GuildBoss = 14

local Config = require("src/config/RuleConfig").Config

function new()
	local ctrl = Control.new(require("res/common/RuleSkin"), {"res/common/Rule.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

--_M.touch = function(self,event)
--	Common.outSideTouch(self,event)
--end

function addStage(self)
	--self:setScale(Stage.uiScale)
	--self:setPositionY(Stage.uiBottom)
end


function init(self)
	self.titleLabel:setAnchorPoint(0.5,0)
	self.close1:addEventListener(Event.Click, onClose, self)

	local posX,posY = self.contentLabel:getPosition()
	local contentSize = cc.size(537,self.contentLabel:getContentSize().height)

	self.contentLabel:setAnchorPoint(0,1)
	self.contentLabel:setPositionY(self.contentLabel:getPositionY() + self.contentLabel:getContentSize().height)
	self.contentLabel:setDimensions(537, 0)
	self.contentLabel:setVisible(false)

	self.isGrayLayer = true

	--self.content:setBgVisiable(false)
	--self.labelSkin = self.content:getItemSkin().children[1]
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
	self.contentLabel:setVisible(not isHtml)
	if isHtml then
		--self.desRichTxt = RichText.new(RichText.UI_RICH_TEXT_DEFAULT_SKIN)
		--rich:setPosition(self.labelSkin.x+self.labelSkin.width/2,self.labelSkin.y+self.labelSkin.height)
		--rich:setContentSize(cc.size(self.labelSkin.width,0))
		--rich:setColor(255,255,255)
		--self.desRichTxt:setString(content)
		--rich.color = r .. "," .. g .. ","  .. b
		--self.content:removeAllItem()
		--self.content:addItem(rich)

		--self.desRichTxt = RichText2.new()
		--self.desRichTxt:setString(content)
		self.desRichTxt = RichText2.new()
		self.desRichTxt:setVerticalSpace(5)
		self.desRichTxt:setTextWidth(500)
		self.desRichTxt:setShadow(false)
		self.desRichTxt:setFontSize(17)
		self.descView:setDirection(ScrollView.UI_VERTICAL)
		self.descView:setTopSpace(8)
		self.descView:setMoveNode(self.desRichTxt)
		self.desRichTxt:setString(content)
		if self.descView:getContentSize().height < self.desRichTxt:getContentSize().height then
			self.descView.minY = self.descView.startY
			self.descView.maxY = self.desRichTxt:getContentSize().height
		else
			self.descView.minY = self.descView.startY
			self.descView.maxY = self.descView.startY
		end
		self.descView.tqsmbg:setVisible(false)
	else
		self.contentLabel:setString(content)
	end
end

function onClose(self, evt)
	UIManager.removeUI(self)
end

return RuleScrollUI

