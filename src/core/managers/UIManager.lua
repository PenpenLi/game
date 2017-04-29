module("UIManager",package.seeall)

------------------------------------
local _uiStack = _uiStack or {}
local _childStack = _childStack or {}
local _currentUI = _currentUI or nil
local _uiBg = _uiBg or nil
local _uiGray = _uiGray or nil

UI_EFFECT = {
	kBg     = 1, --添加底图
	kGray   = 2, --半透明蒙层
	kSlideIn  = 3, --滑进
	kSlideOut  = 4, --滑出
	kScaleIn  = 5, --放大
	kScaleOut  = 6, --缩小
	kFull   = 7, --全屏
	kLabel = 8,  --钻石Label
}
--[[一级面板通用模板]]
FIRST_TEMP = {
	[UIManager.UI_EFFECT.kBg] = true,
	[UIManager.UI_EFFECT.kGray] = true,
	--[UIManager.UI_EFFECT.kSlideIn] = true,
	--[UIManager.UI_EFFECT.kSlideOut] = true,
	--[UIManager.UI_EFFECT.kScale] = true,
	--[UIManager.UI_EFFECT.kFull] = true,
} 
FIRST_TEMP_FULL = {
	[UIManager.UI_EFFECT.kBg] = true,
	[UIManager.UI_EFFECT.kGray] = true,
	--[UIManager.UI_EFFECT.kSlideIn] = true,
	--[UIManager.UI_EFFECT.kSlideOut] = true,
	[UIManager.UI_EFFECT.kFull] = true,
}
FIRST_TEMP_LABEL = {
	[UIManager.UI_EFFECT.kBg] = true,
	[UIManager.UI_EFFECT.kGray] = true,
	--[UIManager.UI_EFFECT.kSlideIn] = true,
	--[UIManager.UI_EFFECT.kSlideOut] = true,
	[UIManager.UI_EFFECT.kLabel] = true,
}
FIRST_TEMP_RAW = {
	[UIManager.UI_EFFECT.kGray] = true,
	[UIManager.UI_EFFECT.kFull] = true,
	[UIManager.UI_EFFECT.kLabel] = true,
}

--[[二级面板通用模板]]
SECOND_TEMP= {
	--[UIManager.UI_EFFECT.kBg] = true,
	[UIManager.UI_EFFECT.kGray] = true,
	--[UIManager.UI_EFFECT.kSlide] = true,
	--[UIManager.UI_EFFECT.kScaleIn] = true,
	--[UIManager.UI_EFFECT.kSlideOut] = true,
	[UIManager.UI_EFFECT.kFull] = true,
}
SECOND_TEMP_FULL = {
	[UIManager.UI_EFFECT.kGray] = true,
	[UIManager.UI_EFFECT.kFull] = true,
}

--[[三级面板通用模板]]
THIRD_TEMP= {
	--[UIManager.UI_EFFECT.kBg] = true,
	[UIManager.UI_EFFECT.kGray] = true,
	--[UIManager.UI_EFFECT.kSlide] = true,
	[UIManager.UI_EFFECT.kScaleIn] = true,
	[UIManager.UI_EFFECT.kScaleOut] = true,
	[UIManager.UI_EFFECT.kFull] = true,
}

THIRD_TEMP_NOGRAY = {
	--[UIManager.UI_EFFECT.kBg] = true,
	--[UIManager.UI_EFFECT.kGray] = true,
	--[UIManager.UI_EFFECT.kSlide] = true,
	[UIManager.UI_EFFECT.kScaleIn] = true,
	[UIManager.UI_EFFECT.kScaleOut] = true,
	[UIManager.UI_EFFECT.kFull] = true,
}


local function push(data)
	_uiStack[#_uiStack+1] = data
end

local function top()
	return _uiStack[#_uiStack]
end

local function pop()
	local data = top()
	_uiStack[#_uiStack] = nil
	if #_uiStack == 0 and GuideManager then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_MAIN_COMPONENT)
	end
	return data
end

function getTopParams()
	local data = top()
	if data then
		return data.params
	end
end

function setTopParams(...)
	local data = top()
	if data then
		data.params = {...}
		return true
	end
	return false
end

function pushChild(ui)
	_childStack[#_childStack+1] = ui
end

function topChild()
	return _childStack[#_childStack]
end

function popChild()
	local ui = topChild()
	_childStack[#_childStack] = nil
	return ui
end

function hasChildUI(self)
	return (#_uiStack > 0)
end

function reset()
	_uiStack = {}
	_childStack = {}
	if _currentUI and _currentUI.alive then
		_currentUI:removeFromParent()
	end
	_currentUI = nil
	if _uiBg then
		_uiBg:removeFromParent()
		_uiBg = nil
	end
	if _uiGray then
		_uiGray:removeFromParent()
		_uiGray = nil
	end
end

function setUIStatus(status)
	local preData = top()
	preData.status = status
end

function getUI(name)
	return Stage.currentScene:getUI():getChild(name)
end

function setBackBtn(ui)
	ui:adjustTouchBox(0,Stage.uiBottom,0,2*Stage.uiBottom)
	if ui.back then
		ui.back:setPositionX(10)
		ui.back:setPositionY(ui.back:getPositionY() + Stage.uiBottom*2 / Stage.uiScale - Stage.uiBottom) --减去ui多加的(Stage.uiBottom - Stage.uiBottom/Stage.uiScale)
	end
	--if ui.close then
	--	ui.close:setPositionX(0)
	--	ui.close:setPositionY(ui.close:getPositionY() + Stage.uiBottom*2 / Stage.uiScale - Stage.uiBottom)
	--end
end

function addChildUI(url,...)
	if _currentUI and _currentUI.alive then
		local child = require(url).new(...)
		local curChild = _currentUI:getChild(child.name)
		if curChild then
			return curChild
		else
			addChildUIReal(child)
			return child
		end
	else
		addUI(url,...)
	end
end

function addChildUIReal(ui)
	setBackBtn(ui)
	local effects = {}
	if ui["uiEffect"] then
		effects = ui["uiEffect"]() or {}
	end
	if effects[UI_EFFECT.kGray] then
		local grayName = "gray_layer"
		local preChild = topChild()
		local ui = _currentUI
		if preChild and preChild.alive then
			ui = preChild
		end
		if not ui:getChild(grayName) then
			local layer = newGrayLayer(grayName)
			layer:setPositionX(ui:getContentSize().width/2)
			layer:setPositionY(ui:getContentSize().height/2)
			layer._ccnode:ignoreAnchorPointForPosition(false)
			layer:setAnchorPoint(0.5,0.5)
			ui:addChild(layer)
		end
	end
	pushChild(ui)
	_currentUI:addChild(ui)
	if effects[UI_EFFECT.kFull] then
		_currentUI:setTop()
	else
		setUITop(true)
		onFoldUp()
	end
	if effects[UI_EFFECT.kSlideIn] then
		slideAction(ui)
	elseif effects[UI_EFFECT.kScaleIn] then
		scaleAction(ui)
	elseif effects[UI_EFFECT.kLabel] then
		onFoldLabel(true)
	end
end

function addUI(url,...)
	local preData = top()
	if preData and preData.url == url then
		return _currentUI
	end
	if _currentUI and _currentUI.alive then
		_currentUI:removeFromParent()
	end
	_currentUI = require(url).new(...)
	local data = {url = url,params = {...}}
	push(data)
	addUIReal(_currentUI)
	_childStack = {}
	if GuideManager then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_MAIN_COMPONENT, data)
	end
	return _currentUI
end

function addUIReal(ui)
	setBackBtn(ui)
	local effects = {}
	if ui["uiEffect"] then
		effects = ui["uiEffect"]() or {}
	end
	setUIBg(effects[UI_EFFECT.kBg])
	setUIGray(effects[UI_EFFECT.kGray])
	Stage.currentScene:getUI():addChild(ui)
	if effects[UI_EFFECT.kFull] then
		if _uiGray then
			_uiGray:setTop()
		end
		_currentUI:setTop()
	else
		--setMainUIPos(true)
		setUITop(true)
		onFoldUp()
	end
	if effects[UI_EFFECT.kSlideIn] then
		slideAction(ui)
	elseif effects[UI_EFFECT.kScaleIn] then
		scaleAction(ui)
	elseif effects[UI_EFFECT.kLabel] then
		onFoldLabel(true)
	end
	setChatUI(false)
end

function setChatUI(flag)
	local chatUI = Stage.currentScene:getUI().chatUI
	if Stage.currentScene.name ~= 'main' or not chatUI then
		return
	end
	if flag then
		chatUI:setVisible(true)
		chatUI:setTop()
	else
		chatUI:setVisible(flag)
	end
end

function onFoldUp()
	onFoldRight(true,true)
	onFoldLabel(false)
end

function onFoldDown()
	onFoldRight(false,true)
	onFoldLabel(true)
end

function onFoldLabel(flag)
	if Stage.currentScene.name ~= 'main' then
		return
	end
	local ui = Stage.currentScene:getUI()
	ui.uphide = ui.uphide or false
	if flag == ui.uphide then
		ui:onFoldLabel()
	end
	--ui:onFoldLabel()
end

function onFoldRight(flag,quick)
	if Stage.currentScene.name ~= 'main' then
		return
	end
	local ui = Stage.currentScene:getUI()
	if flag == ui.right:isVisible() then
		ui:onFoldMenu(quick)
	end
end

function setUITop(flag)
	if Stage.currentScene.name ~= 'main' then
		return
	end
	Stage.currentScene:getUI():setMainUITop(flag)
end

function setMainUIPos(flag)
	if Stage.currentScene.name ~= 'main' then
		return
	end
	Stage.currentScene:getUI():setMainUIPos(flag)
end

function setUIBg(flag,grayflag)
	if Stage.currentScene.name ~= 'main' then
		return
	end
	if _uiBg == nil then
		_uiBg = Sprite.new('uiBg','res/map/bg016.jpg')
		Stage.currentScene:getUI():addChild(_uiBg)
	end
	_uiBg:setVisible(flag)
end

function setUIGray(flag)
	if Stage.currentScene.name ~= 'main' then
		return
	end
	if _uiGray == nil then
		_uiGray = newGrayLayer()
		Stage.currentScene:getUI():addChild(_uiGray)
	end
	_uiGray:setVisible(flag)
end

function removeUI(ui)
	if ui["uiEffect"] and ui.alive then
		local effects = ui["uiEffect"]() or {}
		if effects[UI_EFFECT.kSlideOut] then
			slideActionReverse(ui)
		elseif effects[UI_EFFECT.kScaleOut] then
			scaleActionReverse(ui)
		else
			removeUICb(ui)
		end
	else
		removeUICb(ui)
	end
end

function removeUICb(ui)
	ui:removeFromParent()
	--removeCurUIMask()
	if _currentUI == ui then
		_currentUI = nil
		_childStack = {}
		pop()
		local preData = top()
		if preData then
			_currentUI = require(preData.url).new(unpack(preData.params))
			if _currentUI["setUIStatus"] and preData.status then
				_currentUI["setUIStatus"](_currentUI,unpack(preData.status))
				setUIStatus()
			end
			addUIReal(_currentUI)
		else
			setUITop(true)
			setUIBg(false)
			setUIGray(false)
			--setMainUIPos(false)
			onFoldDown()
			setChatUI(true)
		end
	else
		popChild()
		local preChild = topChild()
		local effects = {}
		if preChild then
			if preChild["uiEffect"] then
				effects = preChild["uiEffect"]() or {}
			end
			--if not effects[UI_EFFECT.kGray] then
			--	removeCurUIMask()
			--end
			local name = "gray_layer"
			if preChild.alive and preChild:getChild(name) then
				preChild:removeChildByName(name)
			end
			if effects[UI_EFFECT.kFull] then
				_currentUI:setTop()
				preChild:setTop()
			else
				setUITop(true)
				onFoldUp()
			end
		elseif _currentUI then
			if _currentUI["uiEffect"] then
				effects = _currentUI["uiEffect"]() or {}
			end
			removeCurUIMask()
			if effects[UI_EFFECT.kFull] then
				_uiGray:setTop()
				_currentUI:setTop()
			else
				setUITop(true)
				onFoldUp()
			end
		end
		if effects[UI_EFFECT.kLabel] then
			onFoldLabel(true)
		end
	end
end

function replaceUI(url,...)
	local preData = top()
	if preData and preData.url == url 
		and unpack(preData.params) == ... then
		return _currentUI
	end
	_uiStack = {}
	return addUI(url,...)
end

-- 延迟替换，切场景时改善长时间无响应的用户体验
function replaceUI2(url,...)
	local vararg = {...}
	Stage.addTimer(function()
		replaceUI(url,unpack(vararg))
	end,0.5,1)
end

function getCurrentUI()
	return _currentUI
end

function slideActionReverse(ui)
	Stage.currentScene.touchEnabled = false
	local callBackFuc = function()
		Stage.currentScene.touchEnabled = true
		removeUICb(ui)
	end
	local callBack=cc.CallFunc:create(callBackFuc)
	local moveBy = cc.MoveBy:create(0.2,cc.p(-Stage.winSize.width,0))
	local sineOut = cc.EaseSineOut:create(moveBy)
	ui:runAction(cc.Sequence:create({sineOut, callBack}))
end

function slideAction(ui)
	local callBackFuc = function()
		addUICb(ui)
	end
	local callBack=cc.CallFunc:create(callBackFuc)
	ui:setPositionX(Stage.winSize.width)
	local moveBy = cc.MoveBy:create(0.2,cc.p(-Stage.winSize.width,0))
	local sineOut = cc.EaseSineOut:create(moveBy)
	ui:runAction(cc.Sequence:create({sineOut,callBack}))
end

function scaleActionReverse(ui)
	Stage.currentScene.touchEnabled = false
	local callBackFuc = function()
		Stage.currentScene.touchEnabled = true
		removeUICb(ui)
	end
	local original = ui:getScale()
	local callBack=cc.CallFunc:create(callBackFuc)
	local scaleTo = cc.ScaleTo:create(0.15,original*1.1,original*1.1)
	local sineOut = cc.EaseSineOut:create(scaleTo)
	local scaleTo2 = cc.ScaleTo:create(0.15,0,0)
	local sineOut2 = cc.EaseSineOut:create(scaleTo2)
	local seq = cc.Sequence:create({sineOut,sineOut2})
	ui:runAction(cc.Sequence:create({seq, callBack}))
end	

function addUICb(ui)
	if ui["uiEffect"] then
		local effects = ui["uiEffect"]() or {}
		if effects[UI_EFFECT.kLabel] then
			onFoldLabel(true)
		end
	end
end

function scaleAction(ui)
	local original = ui:getScale()
	local parent = ui:getParent()
	ui:setPositionX(parent:getContentSize().width/2)
	if parent.name == "MainUI" then
		ui:setPositionY(parent:getContentSize().height/2 + Stage.uiBottom)
	else
		ui:setPositionY(parent:getContentSize().height/2)
	end
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

function newGrayLayer(name)
	local width = Stage.winSize.width + 1
	local height = Stage.winSize.height + 2*Stage.uiBottom
	local layer = LayerColor.new(name or "gray_layer",0,0,0,180,width,height)
	return layer
end

function removeCurUIMask(name)
	local name = name or "gray_layer"
	if _currentUI and _currentUI:getChild(name) then
		_currentUI:removeChildByName(name)
	end
end

function removeCurUIMask2(name)
	local name = name or "gray_layer"
	local mainui = Stage.currentScene:getUI()
	if mainui.up:isVisible() then
		mainui.up:removeChildByName(name)
		mainui.up:adjustTouchBox(0)
	else
		removeCurUIMask(name)
	end
end

function addCurUIMask(name)
	local name = name or "gray_layer"
	local function onClick(self,event,target)
		if event.etype == Event.Touch_ended then
			local ui = Stage.currentScene:getUI()
			ui:onFoldMenu()
			removeCurUIMask2(name)
		end
	end
	if _currentUI and _currentUI.alive then
		local mainui = Stage.currentScene:getUI()
		local layer = newGrayLayer(name)
		layer:addEventListener(Event.TouchEvent,onClick,self)
		if mainui.up:isVisible() then
			layer._ccnode:ignoreAnchorPointForPosition(false)
			layer:setAnchorPoint(0,1)
			layer:setPositionX(-mainui.up:getPositionX())
			local width = Stage.winSize.width
			local height = Stage.winSize.height
			local posX = mainui.up:getPositionX()
			local posY = mainui.up:getPositionY()
			layer:setPositionY(height - mainui.up:getPositionY())
			--_currentUI:addChild(layer)
			if not mainui.up:getChild(name) then
				mainui.up:addChild(layer)
				mainui.up:adjustTouchBox(posX,posY,width,height)
			end
		else
			--layer:setAnchorPoint(0.5,0.5)
			--layer:setPositionX(_currentUI:getContentSize().width/2)
			layer:setPositionY(-Stage.uiBottom)
			_currentUI:addChild(layer)
		end
	end
end

--UI音效
function playMusic(filename)
	AudioEngine.playEffect(string.format("res/sound/ui/%s.mp3",filename),false)
end


return UIManager
