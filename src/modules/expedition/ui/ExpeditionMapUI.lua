module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Define = require("src/modules/expedition/ExpeditionDefine")
local expeditionData = require("src/modules/expedition/ExpeditionData").getInstance()
local Config = require("src/config/ExpeditionConfig").Config
local Logic = require("src/modules/expedition/ExpeditionLogic")

function new()
	local ctrl = Control.new(require("res/expedition/ExpeditionMapSkin"), {"res/expedition/ExpeditionMap.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function init(self)
	self.copyBtnList = {}
	self.treasureBtnList = {}
	self.lastSel = nil
	for i=1,Define.COPY_NUM do
		local con = self:getChild("con" .. i)
		con:getChild("yz"):setVisible(false)

		local btn = con:getChild("yz1")
		btn.param = i
		btn:addEventListener(Event.Click, onEnterCopy, self)
		table.insert(self.copyBtnList, btn)	
  
		btn = self:getChild("baoxiang" .. i)
		btn.param = i
		btn:addEventListener(Event.Click, onGetTreasure, self)
		table.insert(self.treasureBtnList, btn)	
		
		local arrow = cc.Sprite:create('res/expedition/ExpeditionArrow.png')
		arrow:setAnchorPoint(cc.p(0.5, 0.5))
		arrow:setVisible(false)
		arrow:setPosition(cc.p(con:getChild("yz"):getContentSize().width/2, con:getChild("yz"):getContentSize().height/2 + 20))
		con.arrow = arrow
		con._ccnode:addChild(arrow)
	end

	for i=1,4 do
		local con = self:getChild("yd" .. i)
		con.touchEnabled = false
	end

	--宝藏提示
	self.wjs:setVisible(false)
	self.wjs._ccnode:setLocalZOrder(1)

	--self.bgMapLeft = cc.Sprite:create('res/expedition/ExpeditionMap_map1.jpg')
	--self.bgMapLeft:setLocalZOrder(-1)
	--self.bgMapLeft:setAnchorPoint(cc.p(0, 0))
	--self._ccnode:addChild(self.bgMapLeft)

	--self.bgMapRight = cc.Sprite:create('res/expedition/ExpeditionMap_map2.jpg')
	--self.bgMapRight:setLocalZOrder(-1)
	--self.bgMapRight:setAnchorPoint(cc.p(0, 0))
	--self.bgMapRight:setPosition(cc.p(self.bgMapLeft:getContentSize().width, 0))

	self:addBg()
end

function addBg(self)
	local index = 1
	local fun = function(tex)
		print('index ######################################### ' .. index)
		if index == 1 then
			self.bgMapLeft = cc.Sprite:createWithTexture(tex)
			self.bgMapLeft:setLocalZOrder(-1)
			self.bgMapLeft:setAnchorPoint(cc.p(0, 0))
			self._ccnode:addChild(self.bgMapLeft)
		else
			self.bgMapRight = cc.Sprite:createWithTexture(tex)
			self.bgMapRight:setLocalZOrder(-1)
			self.bgMapRight:setAnchorPoint(cc.p(0, 0))
			self.bgMapRight:setPosition(cc.p(self.bgMapLeft:getContentSize().width, 0))
			self._ccnode:addChild(self.bgMapRight)
		end
		index = index + 1
	end

	cc.Director:getInstance():getTextureCache():addImageAsync("res/expedition/ExpeditionMap_map1.jpg", fun)
	cc.Director:getInstance():getTextureCache():addImageAsync("res/expedition/ExpeditionMap_map2.jpg", fun)
end

function onEnterCopy(self, evt, target)
	if target.param == expeditionData:getCurId() then
		Network.sendMsg(PacketID.CG_EXPEDITION_CHALLANGE, Define.NEXT_NO)
	end
end

function onGetTreasure(self, evt, target)
	if target.param < expeditionData:getCurId() then
		Network.sendMsg(PacketID.CG_EXPEDITION_GET_TREASURE, target.param)
	else
		local config = Logic.getTreasureConfig(target.param) 
		local money = config.rewardList.money and config.rewardList.money[1] or 0
		local gemCount = config.rewardList.tourCoin and config.rewardList.tourCoin[1] or 0
		self.wjs.moneyTxt:setString(money)
		self.wjs.gemCountTxt:setString(gemCount)

		local posX = target:getPositionX() + 70
		local posY = target:getPositionY() - self.wjs:getContentSize().height / 2
		if posX + self.wjs:getContentSize().width > self:getContentSize().width then
			posX = target:getPositionX() - self.wjs:getContentSize().width  - 20
		end
		self.wjs:setPosition(posX, posY)

		local isShowGem = (gemCount > 0)
		self.wjs.gemCountTxt:setVisible(isShowGem)
		self.wjs.jfbicon:setVisible(isShowGem)

		self:showTip()
	end
end

function onTouch(self, evt)
	self:hideTip()

	self.touchEnabled = true
	self:touch(evt)	
	self.touchEnabled = false
end

function showTip(self)
	self:hideTip()
	self.wjs:setVisible(true)

	local function stopTipShow()
		self:hideTip()
	end
	self.wjs:runAction(cc.Sequence:create(cc.DelayTime:create(5.0),cc.CallFunc:create(stopTipShow)))
end

function hideTip(self)
	self.wjs:setVisible(false)
	self.wjs:stopAllActions()
end

function refresh(self)
	self:showSel()
	self:disablePass()
	self:showTreasureStatue()
	self:showMask()
end

function showSel(self)
	local curId = expeditionData:getCurId()
	if self.lastSel ~= nil then
		self.lastSel:setVisible(false)
		local arrow = self.lastCon.arrow
		arrow:setVisible(false)
		arrow:stopAllActions()
	end
	if self:getChild("con" .. curId) ~= nil then
		self.lastSel = self:getChild("con" .. curId):getChild("yz")
		self.lastSel:setVisible(true)
		self.lastCon = self:getChild("con" .. curId)

		local con = self:getChild("con" .. curId)
		local arrow = con.arrow
		arrow:setVisible(true)
		arrow:setPosition(cc.p(con:getChild("yz"):getContentSize().width/2, con:getChild("yz"):getContentSize().height/2 + 20))
		local moveAction = cc.MoveBy:create(0.6, cc.p(0, 30))
		arrow:runAction(cc.RepeatForever:create(cc.Sequence:create({
			moveAction,
			moveAction:reverse()
		})))
	end
end

function disablePass(self)
	local curId = expeditionData:getCurId()
	if curId >= 1 then
		for i=1,Define.COPY_NUM do
			local con = self:getChild("con" .. i)
			local btn = con.yz1
			if i <= curId - 1 then
				btn:setEnabled(false)
				btn:setState(Button.UI_BUTTON_DISABLE)
			else
				btn:setEnabled(true)
				btn:setState(Button.UI_BUTTON_NORMAL)
			end
		end
	end
end

function showTreasureStatue(self)
	self:addArmatureFrame("res/chapter/effect/boxblink.ExportJson")
	local data = expeditionData:getTreasureList()
	local curId = expeditionData:getCurId()
	for index,btn in ipairs(self.treasureBtnList) do
		if data[index] then
			if btn.eff then
				btn.eff:setVisible(false)
			end
			btn:setState(Button.UI_BUTTON_DISABLE)
		else
			if index < curId then
				if btn.eff == nil then
					local boxEffect = ccs.Armature:create('boxblink')
					btn.eff = boxEffect
					btn._ccnode:addChild(boxEffect)
					local size = btn:getContentSize()
					boxEffect:setPosition(size.width/2,size.height/2)
					boxEffect:setScale(0.7)
					boxEffect:getAnimation():playWithNames({'Animation1'},0,true)
					boxEffect:setLocalZOrder(-1)
				else
					btn.eff:setVisible(true)
				end
			end
			btn:setState(Button.UI_BUTTON_NORMAL)
		end
	end
end

function showMask(self)
	local block = math.floor((expeditionData:getCurId() - 1) / 3)
	for i=1,4 do
		if i <= block then
			self:getChild("yd" .. i):setVisible(false)
		else
			self:getChild("yd" .. i):setVisible(true)
		end
	end
end

function getMapWidth(self)
	return 2048--self.bgMapLeft:getContentSize().width + self.bgMapRight:getContentSize().width
end

function addStage(self)
	self:setScale(1 / Stage.uiScale)
end
