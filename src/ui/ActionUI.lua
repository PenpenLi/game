module( "ActionUI", package.seeall )
local grayLayer = nil

function show(ui,mtype)
	if _M[mtype] then
		addLayer(ui)
		_M[mtype](ui)
	else
		ui:setVisible(true)
	end
end

function hide(ui,mtype)
	if _M[mtype] then
		_M[mtype](ui)
	else
		removeLayer(ui)
		ui:setVisible(false)
	end
end

function removeLayer(ui)
	local preChild = UIManager.topChild()
	local curUI = UIManager.getCurrentUI()
	local effects = {}
	if preChild then
		effects = preChild["uiEffect"]() or{}
	elseif curUI then
		effects = curUI["uiEffect"]() or{}
	end
	if next(effects) then
		if effects[UIManager.UI_EFFECT.kFull] then
			if preChild then
				preChild:setTop()
			else
				curUI:setTop()
			end
		else
			UIManager.setUITop(true)
			UIManager.onFoldUp()
		end
		if effects[UIManager.UI_EFFECT.kLabel] then
			UIManager.onFoldLabel(true)
		end
	end
	local parent = ui:getParent()
	if parent:getChild("actionGray") then
		parent:removeChildByName("actionGray")
	end
end

function addLayer(ui)
	local curUI = UIManager.getCurrentUI()
	if curUI then curUI:setTop() end
	local parent = ui:getParent()
	if parent:getChild("actionGray") then
		parent:removeChildByName("actionGray")
	end
	local layer = UIManager.newGrayLayer("actionGray")
	layer.touch = function(self,event)
		if event.etype == Event.Touch_ended then
			scaleHide(ui)
		end
	end
	layer:setPositionY(-Stage.uiBottom)
	parent:addChild(layer)
end

function scale(ui)
	ui:setTop()
	ui:setVisible(true)
	local original = 1
	local parent = ui:getParent()
	ui:setPositionX(parent:getContentSize().width/2)
	ui:setPositionY(parent:getContentSize().height/2)
	ui:setAnchorPoint(0.5,0.5)
	ui:setScale(0.2)
	local scaleTo = cc.ScaleTo:create(0.15,original*1.1,original*1.1)
	local sineOut = cc.EaseSineOut:create(scaleTo)
	local scaleTo2 = cc.ScaleTo:create(0.2,original,original)
	local sineOut2 = cc.EaseSineOut:create(scaleTo2)
	--ui:setScale(1)
	local seq = cc.Sequence:create({sineOut,sineOut2})
	ui:runAction(seq)
end

function scaleHide(ui)
	local callBackFuc = function()
		removeLayer(ui)
		ui:setVisible(false)
	end
	local original = 1
	local callBack=cc.CallFunc:create(callBackFuc)
	local scaleTo = cc.ScaleTo:create(0.15,original*1.1,original*1.1)
	local sineOut = cc.EaseSineOut:create(scaleTo)
	local scaleTo2 = cc.ScaleTo:create(0.15,0,0)
	local sineOut2 = cc.EaseSineOut:create(scaleTo2)
	local seq = cc.Sequence:create({sineOut,sineOut2})
	ui:runAction(cc.Sequence:create({seq, callBack}))
end

--
function joint(group)
	local isCallBack = false
	local function callbackFunc()
		if not isCallBack and group["callback"] then
			group["callback"].func(unpack(group["callback"].params))
		end
		isCallBack = true
	end
	local function moveLeft(left)
		local callBackFucL = function()
			callbackFunc()
		end
		local callBackL =cc.CallFunc:create(callBackFucL)
		left:setPositionX(left:getPositionX()-left:getContentSize().width)
		local moveBy = cc.MoveBy:create(0.2,cc.p(left:getContentSize().width,0))
		local sineOut = cc.EaseSineOut:create(moveBy)
		left:runAction(cc.Sequence:create({sineOut,callBackL}))
	end
	local function moveRight(right)
		local callBackFucR = function()
			callbackFunc()
		end
		local callBackR =cc.CallFunc:create(callBackFucR)
		right:setPositionX(right:getPositionX()+right:getContentSize().width)
		local moveBy = cc.MoveBy:create(0.2,cc.p(-right:getContentSize().width,0))
		local sineOut = cc.EaseSineOut:create(moveBy)
		right:runAction(cc.Sequence:create({sineOut,callBackR}))
	end
	local function moveUp(up)
		local callBackFucU = function()
			callbackFunc()
		end
		local callBackU = cc.CallFunc:create(callBackFucU)
		up:setPositionY(up:getPositionY()+up:getContentSize().height)
		local moveBy = cc.MoveBy:create(0.2,cc.p(0,-up:getContentSize().height))
		local sineOut = cc.EaseSineOut:create(moveBy)
		up:runAction(cc.Sequence:create({sineOut,callBackU}))
	end
	if group["left"] then
		for k,v in pairs(group["left"]) do
			moveLeft(v)
		end
	end
	if group["right"] then
		for k,v in pairs(group["right"]) do
			moveRight(v)
		end
	end
	if group["up"] then
		for k,v in pairs(group["up"]) do
			moveUp(v)
		end
	end
end

function bounce(group)
	for k,v in pairs(group) do
		local scaleTo = cc.ScaleTo:create(0.7,1.1,1.1)
		local sineOut = cc.EaseSineOut:create(scaleTo)
		local scaleTo2 = cc.ScaleTo:create(0.7,1,1)
		local sineOut2 = cc.EaseSineOut:create(scaleTo2)
		local seq = cc.Sequence:create({sineOut,sineOut2})
		local repeate = cc.RepeatForever:create(seq)
		v:runAction(repeate)
	end
end

function stop(group)
	for k,v in pairs(group) do
		v:stopAllActions()
		v:setScale(1)
	end
end

return ActionUI
