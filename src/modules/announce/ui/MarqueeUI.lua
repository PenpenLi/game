module(..., package.seeall)
setmetatable(_M, {__index = Control})

Instance = nil
function getInstance()
	if not Instance then
		Instance = new()
		Instance:setAnchorPoint(0.5,0.5)
		Instance:setPosition(Stage.winSize.width/2,Stage.winSize.height/1.33)
		Stage.currentScene:addChild(Instance,999)
	end
	Instance:setVisible(true)
	return Instance
end

function new()
	local skin = require("res/announce/MarqueeSkin")
	local ctrl = {
		name = "AnnounceMsg",
		_state = UI_LABEL_DEFAULT_STATE,
		uiType = UI_CONTROL_TYPE,
		_lastTouch = nil,
		_resCache = nil,
		_skin = skin, 
		_ccnode = nil,
		index = 1,
		tipsCount = 0
	}
	setmetatable(ctrl,{__index = _M})
	ctrl:addSpriteFrames("res/announce/Marquee.plist")
	ctrl:init()
	return ctrl
end

function addStage(self)
	self:setScale(Stage.uiScale)
end

function clear(self)
	Control.clear(self)
	Instance = nil
end

function init(self,content)
	self.touchEnabled = false
	local imgSkin = self._skin.children[1]
	local scissorNode = MX.ScissorNode:create()
	scissorNode:setContentSize(cc.size(imgSkin.width,imgSkin.height))
	scissorNode:setPosition(cc.p(imgSkin.x,imgSkin.y))
	scissorNode:setAnchorPoint(cc.p(0,0))
	self._ccnode = scissorNode

	--image
	local spr = cc.Sprite:createWithSpriteFrameName(imgSkin[1].img .. ".png")
    spr:setAnchorPoint(cc.p(0,0))
	spr:setContentSize(cc.size(imgSkin.width,imgSkin.height))
	spr:setPosition(0,0)
	scissorNode:addChild(spr)
end

function addAnnounce(self,content)
	self.tipsCount = self.tipsCount + 1
	self:setVisible(true)
	local lastTip = self.lastTip
	local textSkin = self._skin.children[2]
	local size = {width=textSkin.width,height=textSkin.height} 
	--local tip = Label.new(textSkin)
	local tip = RichText2.new()
	tip:setFontSize(20)
	tip.name = tip.name .. '_' .. self.index
	self.index = self.index + 1
	tip:setAnchorPoint(0,0)
	tip:setString(content)
	local offset = 0
	if lastTip and lastTip.alive then
		offset = math.max(lastTip:getPositionX() + lastTip:getContentSize().width,size.width) - size.width
	end
	tip:setPosition(size.width+offset,3)
	local distance = tip:getContentSize().width + size.width
	local speed = 70	
	local time = distance / speed 
	--action
	local move = cc.MoveBy:create(time,cc.p(-distance,0))
	local call = cc.CallFunc:create(function()
		tip:removeFromParent()
		self.tipsCount = self.tipsCount - 1
		if self.tipsCount == 0 then
			self:setVisible(false)
			--self:removeFromParent()
		end
	end)
	tip:runAction(cc.Sequence:create({move,call}))
	self:addChild(tip)
	self.lastTip = tip
end





