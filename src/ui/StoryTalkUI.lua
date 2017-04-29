module(..., package.seeall)
setmetatable(_M, {__index = Control})

DIR_LEFT = 1
DIR_RIGHT = 2 

local FADE_TIME = 0.1

function new()
	local ctrl = Control.new(require("res/common/StoryTalkSkin"), {"res/common/StoryTalk.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function init(self)
	self.desTxt:setDimensions(400, 0)
	self.desTxt._ccnode:setLocalZOrder(10)
	self.desTxt:setFontSize(20)
	self.desTxt:setString('')

	self.desRichTxt = RichText2.new()
	self.desRichTxt:setTextWidth(400)
	self.desRichTxt._ccnode:setLocalZOrder(10)
	self:addChild(self.desRichTxt)

	self.leftIcon = cc.Sprite:create()
	self.leftIcon:setFlippedX(true)
	self.leftIcon:setAnchorPoint(cc.p(0, 0))
	self._ccnode:addChild(self.leftIcon)

	self.rightIcon = cc.Sprite:create()
	self.rightIcon:setAnchorPoint(cc.p(1, 0))
	self._ccnode:addChild(self.rightIcon)

	self.bgSize = self.talkBg:getContentSize()
end

function addStage(self)
	self:openTimer()
end

function setStoryTalk(self, desc, iconName, dir, scaleVal)
	local oldDir = self.curDir
	local oldName = self.curHero

	self.isTalking = true
	self.curDir = dir
	self.curHero = iconName
	self.desc = desc
	self.scaleVal = scaleVal or 0.6
	self.htmlTxt = self.desc

	if oldDir == nil then
		self:fadeInTalk()
	else
		if dir == oldDir then
			if iconName ~= oldName then
				self:fadeOutTalk()
			else
				self:setTalk()			
			end
		else
			self:bothAction()
		end
	end
end

function bothAction(self)
	local icon = nil
	local hideIcon = nil
	self.leftIcon:setVisible(true)
	self.rightIcon:setVisible(true)
	if self.curDir == DIR_LEFT then
		icon = self.leftIcon
		hideIcon = self.rightIcon
	else
		icon = self.rightIcon
		hideIcon = self.leftIcon
	end
	icon:setColor(cc.c3b(255, 255, 255))
	icon:setTexture(self:getIconPath(self.curHero))

	local callFun = function()
		hideIcon:setColor(cc.c3b(128, 128, 128))
		self:setTalk()
	end
	self:tweenToShow(icon, callFun)


	local scaleAction = cc.ScaleTo:create(FADE_TIME, self.scaleVal * 0.8)
	hideIcon:stopAllActions()
	hideIcon:runAction(
		cc.Sequence:create(
			scaleAction
		)
	)
end

function fadeOutTalk(self)
	local icon = nil
	if self.curDir == DIR_LEFT then
		icon = self.leftIcon
	else
		icon = self.rightIcon
	end

	local size = icon:getContentSize()
	local endPos = cc.p(0, 0)
	if self.curDir == DIR_LEFT then
		endPos.x = -size.width / Stage.uiScale
	else
		endPos.x = Stage.width / Stage.uiScale + size.width
	end

	local endFadeOut = function()
		self:fadeInTalk(true)
	end

	local fadeOut = cc.FadeOut:create(FADE_TIME)
	local action = cc.MoveTo:create(FADE_TIME, endPos)
	icon:stopAllActions()
	icon:runAction(
		cc.Sequence:create(
			cc.Spawn:create(action, fadeOut),
			cc.CallFunc:create(endFadeOut)
		)
	)

	--action = cc.MoveTo:create(FADE_TIME, cc.p(self.talkBg:getPositionX(), -self.bgSize.height / 2))
	--self.talkBg:runAction(
	--	cc.Sequence:create(
	--		cc.Spawn:create(action, fadeOut),
	--	)
	--)
end

function fadeInTalk(self, isIgnoreBgMove)
	local startTalkFun = function()
		self:setTalk()
	end
	local icon = nil
	if self.curDir == DIR_LEFT then
		icon = self.leftIcon
		self.leftIcon:setVisible(true)
		self.rightIcon:setVisible(false)
	else
		icon = self.rightIcon
		self.rightIcon:setVisible(true)
		self.leftIcon:setVisible(false)
	end
	icon:setColor(cc.c3b(255, 255, 255))
	icon:setTexture(self:getIconPath(self.curHero))
	self:tweenToShow(icon, startTalkFun)	
	
	if not isIgnoreBgMove then
		local action = cc.MoveTo:create(FADE_TIME, cc.p(self.talkBg:getPositionX(), 0))
		local fadeIn = cc.FadeIn:create(FADE_TIME)
		self.talkBg:setPosition(self.talkBg:getPositionX(), -self.bgSize.height)
		self.talkBg:stopAllActions()
		self.talkBg:runAction(
			cc.Sequence:create(
				cc.Spawn:create(action, fadeIn)
			)
		)
	end
end

function tweenToShow(self, icon, callFun)
	local size = icon:getContentSize()
	local startPos = cc.p(0, 0)
	local endPos = cc.p(0, 0)
	if self.curDir == DIR_LEFT then
		startPos.x = -size.width / Stage.uiScale
	else
		startPos.x = Stage.width / Stage.uiScale + size.width 
		endPos.x = Stage.width / Stage.uiScale
	end

	icon:setOpacity(0)
	icon:setScale(self.scaleVal)
	local fadeIn = cc.FadeIn:create(FADE_TIME)
	local action = cc.MoveTo:create(FADE_TIME, endPos)
	icon:setPosition(startPos)
	icon:stopAllActions()
	icon:runAction(
		cc.Sequence:create(
			cc.Spawn:create(action, fadeIn),
			cc.CallFunc:create(callFun)
		)
	)
end

function setTalk(self)
	self:setIconEndPos()
	local tb = Html.parsestr(self.htmlTxt)
	self.curTxt = ''
	self.txt = self:getTxt(tb) 

	self:removeTimer()
	self.talkTimer = self:addTimer(onRefreshTalk, 0.07, -1, self)
	self.tb = Common.utf2tb(self.txt)
	self.tbLen = #self.tb
	self.tbIndex = 1
	--self:setString(self.htmlTxt)
	if self.curDir == DIR_LEFT then
		self.posX = self.leftIcon:getContentSize().width * self.scaleVal + 200
	else
		self.posX = self.rightIcon:getPositionX() - self.rightIcon:getContentSize().width * self.scaleVal - 150
	end

	self.desTxt:setString(self.desc)
	if self.curDir == DIR_LEFT then
		self.desTxt:setPositionX(self.leftIcon:getContentSize().width * self.scaleVal + 2)
	else
		self.desTxt:setPositionX(self.rightIcon:getPositionX() - self.rightIcon:getContentSize().width * self.scaleVal - self.desTxt:getContentSize().width + 50)
	end
	self.desTxt:setString('')

	self:onRefreshTalk()
end

function getTxt(self, tb)
	local txt = ''
	for k,v in pairs(tb) do
		if type(v) == "table" then
			txt = txt .. self:getTxt(v)	
		elseif type(k) == "number" then
			txt = txt .. v
		end
	end
	return txt
end

function onRefreshTalk(self)
	if self.tbIndex < self.tbLen then
		self.curTxt = self.curTxt .. self.tb[self.tbIndex]
		self:setString(self.curTxt)
		self.tbIndex = self.tbIndex + 1
	else
		self:setFullString(self.htmlTxt)
		self.isTalking = false
		self:removeTimer()
	end
end

function hasTalking(self)
	return self.isTalking
end

function showTalkDirect(self)
	self:setIconEndPos()
	self:setFullString(self.htmlTxt)
	self:removeTimer()
	self.isTalking = false
end

function setIconEndPos(self)
	local size = self.leftIcon:getContentSize()
	local endPos = cc.p(0, 0)
	self.leftIcon:setPosition(endPos)

	size = self.rightIcon:getContentSize()
	endPos = cc.p(Stage.width / Stage.uiScale, 0)
	self.rightIcon:setPosition(endPos)
end

function setString(self, txt)
	self.desTxt:setVisible(true)
	self.desRichTxt:setVisible(false)
	self.desTxt:setString(txt)
	self.desTxt:setPositionY(self.bgSize.height - self.desTxt:getContentSize().height - 23)
end

function setFullString(self, txt)
	self.desTxt:setVisible(false)
	self.desRichTxt:setVisible(true)
	self.desRichTxt:setString(txt)
	self.desRichTxt:setPositionX(self.desTxt:getPositionX())
	self.desRichTxt:setPositionY(self.bgSize.height - 23)
end

function removeTimer(self)
	if self.talkTimer then
		self:delTimer(self.talkTimer)
		self.talkTimer = nil
	end
end

function getIconPath(self, iconName)
	local res = "res/hero/bicon/" .. iconName .. ".png" 
	return res
end
