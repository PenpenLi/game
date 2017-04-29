module(..., package.seeall)

local Mask = require("src/ui/Mask")
setmetatable(_M, {__index = Mask})

function new(stencilType)  
	local instance = Mask.new()
	setmetatable(instance, {__index = _M})
	instance:init(stencilType)
	return instance
end

function init(self, stencilType)
	self.name = "GuideMask"

	self.stencilType = stencilType
	if stencilType == GuideDefine.GUIDE_STENCIL_TYPE_LAYER then
		self._ccnode = cc.LayerColor:create(cc.c4b(0, 0, 0, 122))
	else
		self._ccnode = cc.Sprite:create()
		self._ccnode:setAnchorPoint(0, 0)
		self:setContentSize(cc.size(Stage.width, Stage.height))
	end

	self.touchParent = false
	self.touchChildren = false
end

function setStencilInfo(self, stencilInfo, desc)
	print("setStencilInfo =================================== name = " .. stencilInfo.component.name)
	--预回调
	if stencilInfo.preFun ~= nil then
		stencilInfo.preFun()
	end

	self.maskType = GuideDefine.GUIDE_MASK_TYPE_ARROW

	local stencil = stencilInfo.component
	local pos = stencil._ccnode:convertToWorldSpace(cc.p(0, 0))
	local orginPosX,orginPosY = stencil:getPosition()
	local size = stencil:getContentSize()
	local anchorPoint = stencil._ccnode:getAnchorPoint()
	local fingerScale = Stage.uiScale
	if stencilInfo.fingerScale then
		fingerScale = stencilInfo.fingerScale
	end

	self.clickFun = stencilInfo.clickFun
	self.nextTime = stencilInfo.nextTime
	self.touchFun = stencilInfo.touchFun
	self.touchTarget = stencil
	self.touchComponent = stencilInfo.touchComponent
	self.noCallTouchFun = stencilInfo.noCallTouchFun
	self.mustJump = stencilInfo.mustJump
	--点击区域
	self.touchRect = cc.rect(pos.x, pos.y, size.width, size.height)

	--手指
	self:addArmatureFrame("res/armature/effect/Finger.ExportJson")
	self.finger = cc.Sprite:create()
	self.finger:setPosition(pos.x + size.width/2 * fingerScale, pos.y + size.height/2 * fingerScale)
	self._ccnode:addChild(self.finger, 100)

	if stencilInfo.noFinger == nil then
		local fingerEff = ccs.Armature:create("Finger")
		fingerEff:getAnimation():play('特效', -1, 1)
		self.finger:addChild(fingerEff)

		fingerEff = ccs.Armature:create("Finger")
		fingerEff:getAnimation():play('手指', -1, 1)
		self.finger:addChild(fingerEff)
	else
		if stencilInfo.hasEff then
			local fingerEff = ccs.Armature:create("Finger")
			fingerEff:getAnimation():play('特效', -1, 1)
			self.finger:addChild(fingerEff)
		end
		self.maskType = GuideDefine.GUIDE_MASK_TYPE_TALK
	end

	if self.stencilType == GuideDefine.GUIDE_STENCIL_TYPE_LAYER then
		stencil:setPosition(pos.x, pos.y)

		self.stencil = cc.RenderTexture:create(Stage.width, Stage.height)
		--self.stencil:setKeepMatrix(true)
		--self.stencil:setVirtualViewport(cc.p(0, 0), cc.size(Stage.width, Stage.height), cc.rect(0, 0, Stage.width, Stage.height))
		local val = stencil._ccnode:getScale()
		if stencilInfo.scaleVal then
			stencil._ccnode:setScale(val * stencilInfo.scaleVal)
		end
		self.stencil.touchEnabled = false
		self.stencil:setPosition(cc.p(Stage.width/2, Stage.height/2))
		self.stencil:begin()
		stencil._ccnode:visit()
		self.stencil:endToLua()
		self.stencil:getSprite():getTexture():setAntiAliasTexParameters()
		self._ccnode:addChild(self.stencil)
		if stencilInfo.scaleVal then
			stencil._ccnode:setScale(val)
		end

		stencil:setPosition(orginPosX, orginPosY)
	else
		self.clipNode = cc.ClippingNode:create()
		self.clipNode:setContentSize(cc.size(Stage.width, Stage.height))
		self.clipNode:setInverted(true)
		self._ccnode:addChild(self.clipNode)
		--self._ccnode:setAlphaThreshold(0)

		local bg = cc.LayerColor:create(cc.c4b(0, 0, 0, 122))	
		self.clipNode:addChild(bg)

		--设置模板
		self.stencil = cc.DrawNode:create()
		self.stencil:setPosition(pos)
		self.stencil:setAnchorPoint(anchorPoint)
		local pointList = {
			cc.p(0, 0),
			cc.p(0, size.height * Stage.uiScale),
			cc.p(size.width * Stage.uiScale, size.height * Stage.uiScale),
			cc.p(size.width * Stage.uiScale, 0)
		}
		self.stencil:drawPolygon(pointList, table.getn(pointList), cc.c4f(1, 1, 1, 1), 0, cc.c4f(0, 0, 0, 1))
		self.clipNode:setStencil(self.stencil)
	end

	--说明(分四个区域,根据手指位置来确定)
	if #desc > 0 then
		local guideUI = require("src/modules/guide/ui/GuideUI").new()
		local uiSize = guideUI:getContentSize()
		guideUI:setDesc(desc[1])
		self:addChild(guideUI)
		local centerX = Stage.width / 2
		local centerY = Stage.height / 2
		if pos.x <= centerX and pos.y <= centerY then
			guideUI:setPosition(self.finger:getPositionX() + 80, self.finger:getPositionY())	
		elseif pos.x <= centerX and pos.y > centerY then
			guideUI:setPosition(self.finger:getPositionX() + 80, self.finger:getPositionY())
		elseif pos.x > centerX and pos.y > centerY then
			guideUI:setPosition(self.finger:getPositionX() - 80 - uiSize.width, self.finger:getPositionY())
		elseif pos.x > centerX and pos.y <= centerY then
			guideUI:setPosition(self.finger:getPositionX() - 80 - uiSize.width, self.finger:getPositionY())
		end

		if (guideUI:getPositionX() + uiSize.width) >= Stage.width then
			guideUI:setPositionX(Stage.width - uiSize.width - 10)	
		end

		if (guideUI:getPositionY() + uiSize.height) >= Stage.height then
			guideUI:setPositionY(Stage.height - uiSize.height - 10)
		end
	end
end

function setTouchTarget(self, target)
	self.touchTarget = target
end

function setTalk(self, desc, talkUIPos)
	self.maskType = GuideDefine.GUIDE_MASK_TYPE_TALK

	local guideUI = require("src/modules/guide/ui/GuideUI").new()
	guideUI:setDesc(desc[1])
	self:addChild(guideUI)
	if talkUIPos == nil then
		guideUI:setPosition((Stage.width - guideUI:getContentSize().width) / 2, 0)
	else
		guideUI:setPosition((Stage.width - guideUI:getContentSize().width) / 2 + talkUIPos.x, talkUIPos.y)
	end
end

function setFocusIcon(self, componentInfo, desc, res, posGap, talkUIPos)
	self.maskType = GuideDefine.GUIDE_MASK_TYPE_TALK

	--预回调
	if componentInfo.preFun ~= nil then
		componentInfo.preFun()
	end

	if #desc > 0 then
		self:setTalk(desc, talkUIPos)
	end
	

	local pos = cc.p(0, 0)
	if componentInfo.component ~= nil then
		pos = componentInfo.component._ccnode:convertToWorldSpace(cc.p(0, 0))
	end
	local spr = cc.Sprite:create(res)
	spr:setAnchorPoint(cc.p(0, 0.5))
	spr:setScale(Stage.uiScale)
	self._ccnode:addChild(spr)
	spr:setPosition(cc.p(pos.x + posGap.x, pos.y + posGap.y))
end

function setStoryTalkList(self, desc)
	self.maskType = GuideDefine.GUIDE_MASK_TYPE_TALK
	
	self.touch = Mask.touch
	Mask.setStoryTalkList(self, desc, true)
end

function endTalk(self)
	print('endTalk touchStencil ======================')
	self:touchStencil()
end

function setNone(self)
	self._ccnode:setOpacity(0)
	self.touch = function()
		return true
	end
end

function setNoTarget(self, desc)
	local guideUI = require("src/modules/guide/ui/GuideUI").new()
	local uiSize = guideUI:getContentSize()
	guideUI:setDesc(desc[1])
	guideUI:setPosition(100, Stage.height/2)
	self:addChild(guideUI)

	self:addArmatureFrame("res/armature/effect/Finger.ExportJson")
	self.finger = cc.Sprite:create()
	self.finger:setPosition(cc.p(Stage.width/2, Stage.height/2))
	self._ccnode:addChild(self.finger, 100)

	local fingerEff = ccs.Armature:create("Finger")
	fingerEff:getAnimation():play('特效', -1, 1)
	self.finger:addChild(fingerEff)

	fingerEff = ccs.Armature:create("Finger")
	fingerEff:getAnimation():play('手指', -1, 1)
	self.finger:addChild(fingerEff)
end

function touch(self, event)
	local ret = false
	--外部处理判断点击事件
	if self.touchFun == nil then
		if self.maskType == GuideDefine.GUIDE_MASK_TYPE_ARROW then
			local hasTouch = false
			local p = self.touchTarget:getParent()
			local child = self.touchTarget:getParent():getTouchedChild(event.p)
			if child == self.touchTarget then
				print('child ========== self.touchTarget =========================')
				--坑爹，还需要判断是否在UI层
				if self:isInUI(self.touchTarget) == true then
					print('child ========== equal self.touchTarget =========================')
					hasTouch = true
				else
					if getTouchedChild(Stage.currentScene:getUI(), event) == nil then
						hasTouch = true	
					end
				end
			end
			if hasTouch == true and event.etype ~= Event.Touch_moved then
				if self.touchComponent == nil then
					if event.etype == Event.Touch_ended then
						--self:touchStencil()
					end
					ret = true
				else
					local hasTouch = self.touchComponent:touch(event)
					if hasTouch == true then
						if event.etype == Event.Touch_ended then
							print('touch touchStencil 111111111111111')
							self:touchStencil()
						end
						--点中了，不需要再派发点击
						ret = false
					end
				end
			end
			
			if self.noCallTouchFun == nil then
				if Stage.currentScene:getUI().name == "Fight" and ret == true then
					Stage.currentScene:getUI():touch(event)
				end
				if ret == true and self.mustJump then
					self:triggerTouchComponent()
				end
			elseif ret == true then
				ret = false
				self:touchStencil()
			end
		elseif self.maskType == GuideDefine.GUIDE_MASK_TYPE_TALK then
			if event.etype == Event.Touch_ended then
				print('touch touchStencil 22222222222222222222')
				self:touchStencil()
				ret = true
			end

			if ret == true and self.clickFun ~= nil then
				self.clickFun()
			end
			ret = false
		end
	else
		ret = self.touchFun(event)
		if ret == true then
			print('touch touchStencil 333333333333333333333333')
			self:touchStencil()
		end
	end
	if ret == true then
		print("ret is true =======================")
	end

	return ret
end

function triggerTouchComponent(self)
	print("triggerTouchComponent ===========================")
	if self.clickFun ~= nil then
		self.clickFun()
	end
	self:touchStencil()
end

function setModule(self, guideModule)
	self.guideModule = guideModule
end

function touchStencil(self)
	self:removeFromParent()
	if self.nextTime ~= nil and self.nextTime > 0 then
		Stage.currentScene:getUI().touchEnabled = false
		Stage.currentScene:getUI():runAction(cc.Sequence:create(
			cc.DelayTime:create(self.nextTime),
			cc.CallFunc:create(function()
				if self.guideModule then
					print('touchStecil finishCurStep delay time ')
					Stage.currentScene:getUI().touchEnabled = true
					self.guideModule:finishCurStep()
					self.guideModule = nil
				end
			end)
		))
	else	
		if self.guideModule then
			print('touchStecil finishCurStep ')
			self.guideModule:finishCurStep()
			self.guideModule = nil
		end
	end
end

function isInUI(self, target)
	local parent = nil
	if target["getParent"] then
		parent = target:getParent()
	end
	if parent == nil then
		return false
	end
	if parent.name and (parent.name  == "MainUI" or parent.name == "Fight") then
		return true
	else
		return self:isInUI(parent)
	end
end
