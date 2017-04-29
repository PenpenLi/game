module(..., package.seeall)

local GuideStepConfig = require("src/config/GuideStepConfig").Config
local GuideConfig = require("src/config/GuideConfig").Config
local GuideMask = require("src/modules/guide/GuideMask")
local SkillLogic = require("src/modules/skill/SkillLogic")
local Monster = require("src/modules/hero/Monster")
local FightDefine = require("src/modules/fight/Define")
local Guide = require("src/modules/guide/Guide")

function new()
	local instance = {}
	setmetatable(instance, {__index = _M})
	instance:init()
	return instance
end

function init(self)
	self.groupId = 0	
	self.componentList = {}
	self.isComplete = false
	self.curStep = nil
	self.isExcute = false
	self.mask = nil
end

function setGroupId(self, id)
	self.groupId = id
	self.guideConfig = GuideConfig[id]
	--print('setGroupId =====================' .. self.groupId)
end

function registerComponent(self, componentInfo, isActive)
	local component = componentInfo.component
	local stepType = componentInfo.step
	local config = Guide.getConfig(self.groupId, stepType)
	local step = Common.split(config.id, "_")[GuideDefine.GUIDE_VAL_STEP]
	local stepNum = tonumber(step)
	self.componentList[stepNum] = componentInfo
	if componentInfo.delayTime == nil then
		componentInfo.delayTime = GuideDefine.GUIDE_DELAY_SHOW_TIME_DEFAULT
	end
	if componentInfo.nextTime == nil then
		componentInfo.nextTime = 0
	end
	if componentInfo.stencilType == nil then
		componentInfo.stencilType = GuideDefine.GUIDE_STENCIL_TYPE_LAYER
	end
	if componentInfo.componentType == nil then
		componentInfo.componentType = GuideDefine.GUIDE_COMPONENT_NORMAL
	end

	print('registerComponent groupId == ' .. self.groupId .. ' stepType = ' .. stepType .. ' step = ' .. step)
	--if self.isComplete == false then
	--	print("registerComponent 1=================================")
	--end
	--if self.curStep ~= nil then
	--	print("registerComponent 2================================= step = " .. step .. " curStep.step == " .. self.curStep.step)
	--	if stepNum == self.curStep.step then
	--		print("registerComponent 3==============================")
	--	end
	--end
	if self.isComplete == false and	self.curStep ~= nil then
		print("registerComponent ==============================")
		if stepNum == self.curStep.step and self.curStep.finish == false then
			print("registerComponent1 ==============================")
			if self.isExcute == false and self:hasSubUI() == false and self.mask == nil then
				print("registerComponent2 ==============================")
				self:guideCurStep()
			else
				print("registerComponent3 ==============================")
				--防止组件被删除,需重设置
				if self.mask ~= nil then
					self.mask:setTouchTarget(component)
				end
			end
		elseif stepNum == self.curStep.step + 1 and self.curStep.finish == true then
			print("registerComponent4 ==============================")
			if isActive then
				self:doNext()
			else
				self:doNext(0)
			end
		else
			if self.curStep.step < stepNum then
				local stepInfo = GuideStepConfig[self.groupId .. "_" .. step]
				if stepInfo.mustExe == 1 and self.curStep.step < stepNum - 1 then
					print("registerComponent5 ==============================")
					self:jumpToStep(stepNum)
				end
			end
		end
	end
end

function jumpToStep(self, step)
	local lastStep = step - 1
	self.curStep = GuideStepConfig[self.groupId .. "_" .. lastStep]
	self.curStep.step = lastStep
	self.curStep.finish = true
	self:doNext()
end

function unregisterComponent(self, stepType)
	local config = Guide.getConfig(self.groupId, stepType)
	local step = Common.split(config.id, "_")[GuideDefine.GUIDE_VAL_STEP]
	--print("unregisterComponent groupId = " .. self.groupId .. " steyp = " .. stepType)
	self.componentList[tonumber(step)] = nil
end

function registerMainComponent(self)
	print("registerMainComponent ================================")
	local list = {}
	for step,componentInfo in pairs(self.componentList) do
		if componentInfo.componentType == GuideDefine.GUIDE_COMPONENT_MAIN and self.isComplete == false then
			table.insert(list, componentInfo)
		end
	end

	for _,componentInfo in ipairs(list) do
		self.componentList[componentInfo.step] = nil
		self:registerComponent(componentInfo)
	end
end

function registerSubComponent(self)
	--print("registerSubComponent ================================" .. self.groupId)
	if self.isComplete == false then
		local list = {}
		for step,componentInfo in pairs(self.componentList) do
			table.insert(list, componentInfo)
		end

		print('list ===========================' .. #list)
		if self.curStep then
			print('self.curStep is  = ' .. self.curStep.step)
			if self.curStep.finish == false then
				print('isFinsih ==============')
			end
		end
		if self.guideConfig.jump == 1 then
			print('jump ===============================1')
		end
		if #list > 0 then
			for _,componentInfo in ipairs(list) do
				self.componentList[componentInfo.step] = nil
				self:registerComponent(componentInfo, true)
			end
		elseif self.curStep and self.guideConfig.jump == 1 then
			if self.curStep.finish == false and self.isExcute == false then
				self:guideCurStep()
			end
		end
	end
end

function unregisterMainComponent(self, url)
	--print("unregisterMainComponent =================================== groupId = " .. self.groupId)
	for step,componentInfo in pairs(self.componentList) do
		--print('url ===================' .. url .. ' step = ' .. step)
		if componentInfo.componentType == GuideDefine.GUIDE_COMPONENT_MAIN then
			if self.curStep and step == self.curStep.step and url ~= componentInfo.filterLink and url ~= componentInfo.filterLink2 then
				if self.mask then
					self.mask:removeFromParent()
					print("remove mask ==========================")
				end
				self.curStep.finish = false
				self.mask = nil
				self.isExcute = false
			end
		end
	end
end

function unregisterSubComponent(self)
	--print("unregisterSubComponent =================================== groupId = " .. self.groupId)
	if self.curStep and self.curStep.finish == false then
		if self.mask then
			self.mask:removeFromParent()
		end
		self.mask = nil
		self.curStep.finish = false
		self.isExcute = false
	end
end

function clearAllComponent(self)
	--print('clearAllComponent ======================')
	self.componentList = {}
end

function triggerTalk(self, step)
	if self.curStep and (self.curStep.step == step or self.curStep.step + 1 == step) then
		print('triggerTalk 1================== step = ' .. step)
		if self.curStep.step + 1 == step then
			print('triggetTalk2 =======================')
			if self.curStep.finish == true and self:hasSubUI() == false then
				self:doNext()
			end
		elseif self.isExcute == false and self:hasSubUI() == false then
			print('triggerTalk 3==================')
			self:guideCurStep()
		end
	end
end

function doStart(self)
	print("doStart ==============================" .. self.groupId)
	if self.isExcute == false then
		self.curStep = GuideStepConfig[self.groupId .. "_" .. GuideDefine.GUIDE_FIRST_STEP]
		self.curStep.step = GuideDefine.GUIDE_FIRST_STEP
		self.curStep.finish = false
		print("doStart 2==========================")
		if self:isGuideMainWithChildUI(self.curStep.step) == false and self.curStep.active == 0 then
			print("doStart 3==========================")
			self:guideCurStep()
		end
	end
end

function doNext(self, active)
	print("doNext ===========================" .. self.groupId)
	if self.curStep ~= nil then
		local tab = Common.split(self.curStep.id, "_")
		local stepNum = tonumber(tab[GuideDefine.GUIDE_VAL_STEP]) + 1
		print("self.curStep ===========================" .. stepNum)
		local step = GuideStepConfig[self.groupId .. "_" .. stepNum]
		if step ~= nil then
			print("self.curStep2 ===========================" .. stepNum)
			if active == nil or step.active == 0 then
				print("self.curStep3 ===========================" .. stepNum)
				if self:isGuideMainWithChildUI(stepNum) == false then				
					self.curStep = step
					self.curStep.finish = false
					self.curStep.step = stepNum
					print("enter doNext active=============================")
					self:guideCurStep()
				end
			end
		elseif self.curStep.finish == true then
			self:complete()
		end
	end
end

function touchComponent(self, groudId, step)
	if self.groudId == groupId and 
		self.curStep and 
		self.curStep.step == step and
		self.curStep.finish == false and
		self.mask ~= nil then
		self.mask:triggerTouchComponent()
	end
end

function removeMask(self, groupId)
	if self.groupId == groupId then
		self.mask:removeFromParent()
		self.mask = nil
	end
end

--当前还有子界面,不能引导主界面相关UI
function isGuideMainWithChildUI(self, stepNum)
	self:doCheckFun(stepNum)

	local step = GuideStepConfig[self.groupId .. "_" .. stepNum]
	local HeroInfoUI = require("src/modules/hero/ui/HeroInfoUI")
	if UIManager.hasChildUI() == false then
		print('UIManager.hasChildUI =============')
	end
	if self.componentList[stepNum] == nil then
		print('self.componentList[stepNum] == nil ==============')
	elseif self.componentList[stepNum].componentType == GuideDefine.GUIDE_COMPONENT_NORMAL then
		print('isNormal ===================')
	elseif UIManager.getUI(self.componentList[stepNum].filterUI) ~= nil then
		print('not nil ====================')
	end
	if self:hasSubUI() == false then
		print('hasSubUI ============= false')
	end
	if UIManager.hasChildUI() == false or 
		self.componentList[stepNum] == nil or
		self.componentList[stepNum].componentType == GuideDefine.GUIDE_COMPONENT_NORMAL or
		(UIManager.getUI(self.componentList[stepNum].filterUI) ~= nil or UIManager.getUI(self.componentList[stepNum].filterUI2) ~= nil) or 
		(self.componentList[stepNum].filterUI == GuideDefine.FILTER_HERO_INFO_UI and HeroInfoUI.Instance ~= nil) and
		self:hasSubUI() == false then
		return false
	end
	return true
end

function doCheckFun(self, step)
	if self.componentList[step] and self.componentList[step].checkFun then
		self.componentList[step].checkFun()
	end
end

function hasSubUI(self)
	if Stage.currentScene:getChild('TopMasterLvUp') ~= nil or
		Stage.currentScene:getUI():getChild('HeroBTUI') ~= nil or
		Stage.currentScene:getUI():getChild('RewardTips') ~= nil or
		((UIManager.getCurrentUI() and UIManager.getCurrentUI():getChild('RewardTips') ~= nil) and 
		(self:getCurComponentInfo() == nil or self:getCurComponentInfo().filterUI ~= 'RewardTips')) or
		Stage.currentScene:getUI():getChild('ChainActiveUI') ~= nil then
		return true
	end
	return false
end

function doByStep(self, stepType)
	print("doByStep ===========================" .. stepType)
	if self.curStep ~= nil then
		local config = Guide.getConfig(self.groupId, stepType)
		local step = tonumber(Common.split(config.id, "_")[GuideDefine.GUIDE_VAL_STEP])
		if self.curStep.step < stepType and self:hasJump(stepType) == true then
			self.curStep = Guide.getConfig(self.groupId, stepType - 1)
			self.curStep.step = stepType - 1
		end
		if self.curStep.step == step - 1 or self.curStep.step == step then
			self:doNext()
		end
	end
end

function hasJump(self, stepType)
	if self.curStep ~= nil then
		local stepNum = self.curStep.step
		for i=stepNum,stepType-1 do
			local config = Guide.getConfig(self.groupId, i)
			if config and config.jump == 0 then
				return false
			end
		end
		return true
	end
	return false
end

function guideCurStep(self)
	if self.curStep ~= nil then
		print("guideCurStep1 ===================================")
		if self.componentList[self.curStep.step] == nil then
			print('groupId ==================' .. self.groupId)
			print('fuck why componentList[' .. self.curStep.step .. '] = nil')
		end
		if self.componentList[self.curStep.step] ~= nil or
			(self.curStep.type ~= GuideDefine.GUIDE_MASK_TYPE_ARROW and 
			self.curStep.type ~= GuideDefine.GUIDE_MASK_TYPE_NO_LIMIT and 
			self.curStep.type ~= GuideDefine.GUIDE_MASK_TYPE_SKILL_HERO and
			self.curStep.type ~= GuideDefine.GUIDE_MASK_TYPE_SKILL_ATTR) then
			print("guideCurStep2 ===================================")
			self:excute()
		end
	else
		print("guideCurStep3 ===================================")
		self:complete()
	end
end

function excute(self)
	print("excute ======================")
	self.isExcute = true
	self.isComplete = false
	self:showGuide()
end

function showGuide(self)
	print("showGuide===========================")
	if self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_ARROW then
		print("showGuide ===============================" .. Stage.currentScene.name)
		local componentInfo = self:getCurComponentInfo()
		self.mask = GuideMask.new(componentInfo.stencilType)
		self.mask:setModule(self)
		self.mask._ccnode:setLocalZOrder(1000)
		Stage.currentScene:addChild(self.mask)
		local step = self.curStep.step
		if componentInfo.noDelayFun then
			componentInfo.noDelayFun()
		end
		if componentInfo.delayTime > 0 then
			print("showGuide arrow delay =========================== " .. componentInfo.delayTime)
			Stage.currentScene:getUI().touchEnabled = false
			Stage.currentScene:getUI():runAction(cc.Sequence:create(
				cc.DelayTime:create(componentInfo.delayTime),
				cc.CallFunc:create(function()
					Stage.currentScene:getUI().touchEnabled = true
					if self.mask ~= nil then
						self.mask:setStencilInfo(componentInfo, self.curStep.desc)
					end
					if componentInfo.addFinishFun then
						componentInfo.addFinishFun()
					end
				end)
			))
		else
			print("showGuide arrow  no delay =========================== ")
			self.mask:setStencilInfo(componentInfo, self.curStep.desc)
		end
	elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_TALK then
		print('Guide talk ================')
		self.mask = GuideMask.new(GuideDefine.GUIDE_STENCIL_TYPE_LAYER)
		self.mask:setModule(self)
		self.mask:setTalk(self.curStep.desc)
		self.mask._ccnode:setLocalZOrder(1000)
		Stage.currentScene:addChild(self.mask)
	elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_NO_LIMIT then
		print('Guide no limit =========================')
		local componentInfo = self:getCurComponentInfo()
		local component = componentInfo.component
		local size = component:getContentSize()
		component:addArmatureFrame("res/armature/effect/Finger.ExportJson")
		local finger = cc.Sprite:create()
		finger:setPosition(component:getPositionX() + size.width/2, component:getPositionY() + size.height/2)
		component._ccnode:addChild(finger, 100)

		local fingerEff = ccs.Armature:create("Finger")
		fingerEff:getAnimation():play('特效', -1, 1)
		finger:addChild(fingerEff)

		fingerEff = ccs.Armature:create("Finger")
		fingerEff:getAnimation():play('手指', -1, 1)
		finger:addChild(fingerEff)
		print("componentName @@@@@@@@@@@@@@@@@=====================" .. component.name)
		local fun = nil
		fun = function(listener, event)
			print("remove ========================================")
			if finger then
				finger:removeFromParent()
				self:finishCurStep()
				component:removeEventListener(Event.Click, fun) 
			end
			finger = nil
		end
		component:addEventListener(Event.Click, fun, component)

		--自动移除
		if componentInfo.removeTime then
			print("removeTime ===================================" .. componentInfo.removeTime)
			Stage.currentScene:getUI():runAction(cc.Sequence:create(
				cc.DelayTime:create(componentInfo.removeTime),
				cc.CallFunc:create(function()
					fun()
				end)
			))
		end
	elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_STORY_TALK then
		print('Guide story talk ============= step = ' .. self.curStep.id)
		local componentInfo = self:getCurComponentInfo()
		if componentInfo and componentInfo.noDelayFun then
			componentInfo.noDelayFun()
		end
		self.mask = GuideMask.new(GuideDefine.GUIDE_STENCIL_TYPE_LAYER)
		self.mask:setModule(self)
		self.mask:setStoryTalkList(self.curStep.desc)
		self.mask._ccnode:setLocalZOrder(1000)
		Stage.currentScene:addChild(self.mask)
	elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_SKILL_HERO then
		print('Guide rage bar ======================')
		self.mask = GuideMask.new(GuideDefine.GUIDE_STENCIL_TYPE_LAYER)
		local spr = cc.Sprite:create()

		local heroSpr = cc.Sprite:create("res/hero/nicon/Mai.jpg")
		spr:addChild(heroSpr)
		local bgSpr = cc.Sprite:create("res/hero/nicon/qualitybg1.png")
		spr:addChild(bgSpr)
		local attrSpr = cc.Sprite:create("res/hero/career/1.png")
		attrSpr:setAnchorPoint(cc.p(0, 1))
		attrSpr:setPosition(cc.p(-bgSpr:getContentSize().width/2, bgSpr:getContentSize().height/2))
		spr:addChild(attrSpr)

		spr:setScale(Stage.uiScale)
		spr:setPosition(cc.p(Stage.width/2, Stage.height/2))

		local pos = attrSpr:convertToWorldSpace(cc.p(-20, 20))

		self.mask._ccnode:addChild(spr)
		self.mask:setFocusIcon(self:getCurComponentInfo(), self.curStep.desc, "res/guide/Guide_circle.png", pos, cc.p(-300, Stage.height/2))
		self.mask:setModule(self)
		self.mask._ccnode:setLocalZOrder(1000)
		Stage.currentScene:addChild(self.mask)
	elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_SKILL_ATTR then
		print('Guide speed cir ================================')
		self.mask = GuideMask.new(GuideDefine.GUIDE_STENCIL_TYPE_LAYER)
		self.mask:setFocusIcon(self:getCurComponentInfo(), self.curStep.desc, "res/guide/Guide_circle.png", cc.p(-20, 2), cc.p(0, Stage.height/2))
		self.mask:setModule(self)
		self.mask._ccnode:setLocalZOrder(1000)
		Stage.currentScene:addChild(self.mask)
	elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_HERO_GET then
		print('Guide hero get ====================================')
		Stage.currentScene:getUI().touchEnabled = true
		local ui = UIManager.addUI("src/modules/hero/ui/HeroRecruitEffect", "Shingo")
		ui:playEffect()
		local fun = nil
		fun = function(listener, event)
			Stage.currentScene:removeEventListener(Event.HeroRecruitRemove, fun)
			print('GuideHero get 2==================================')
			self:finishCurStep()
		end
		Stage.currentScene:addEventListener(Event.HeroRecruitRemove, fun)
	elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_NONE then
		print("none ===================================|")
		self.mask = GuideMask.new(GuideDefine.GUIDE_STENCIL_TYPE_LAYER)
		self.mask:setNone()
		self.mask._ccnode:setLocalZOrder(1000)
		Stage.currentScene:addChild(self.mask)

		local fun = nil
		fun = function(listener, event)
			print("none ===================================3222")
			Stage.currentScene:removeEventListener(Event.HeroRecruitRemove, fun)
			self.mask:removeFromParent()
			self.mask = nil
			self:finishCurStep()
		end
		Stage.currentScene:addEventListener(Event.HeroRecruitRemove, fun)
	elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_TOUCH_EVT then
		self.mask = GuideMask.new(GuideDefine.GUIDE_STENCIL_TYPE_LAYER)
		self.mask:setNone()
		self.mask._ccnode:setLocalZOrder(1000)
		Stage.currentScene:addChild(self.mask)

		local fun = nil
		fun = function(listener, event)
			print("none ===================================3222")
			Stage.currentScene:removeEventListener(Event.GuideRemove, fun)
			self.mask:removeFromParent()
			self.mask = nil
			self:finishCurStep()
		end
		Stage.currentScene:addEventListener(Event.GuideRemove, fun)
	elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_TOUCH_NONE then
		self.mask = GuideMask.new(GuideDefine.GUIDE_STENCIL_TYPE_LAYER)
		self.mask:setNoTarget(self.curStep.desc)
		self.mask._ccnode:setLocalZOrder(1000)
		self.mask.touch = function()
			self.mask:removeFromParent()
			self.mask = nil
			local signUI = UIManager.getUI('SignIn')
			if signUI then
				UIManager.removeUI(signUI)
			end

			self:finishCurStep()
			return false
		end
		Stage.currentScene:addChild(self.mask)
	else
		print('enter showGuide2===========================')
		if self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_FIGHT_SCENE then
			print("enter fight scene==========================================")
			local param = self.curStep.param
			local aMonsterList = {}
			local bMonsterList = {}
			for i=1,#param do
				local id = param[i]
				local monster = Monster.new(id)
				if i < #param then
					table.insert(aMonsterList, monster)
				else
					table.insert(bMonsterList, monster)
				end
			end
			local fightTipMgr = require("src/modules/fightTip/FightTipManager")
			fightTipMgr.setIsShowTip(false)
			local fightControl = require("src/modules/fight/FightControl").new(aMonsterList, bMonsterList)
			local scene = require("src/scene/FightScene").new(fightControl, FightDefine.FightModel.handA_handB, FightDefine.FightType.guide)
			scene:addEventListener(Event.FightEnd, function()
				local s = require("src/scene/MainScene").new()
				Stage.replaceScene(s)
			end,self)
			scene:addEventListener(Event.InitEnd, function() 
				scene.ui.suspend.touchEnabled = false
				scene.ui.po:setVisible(false)
				scene.ui.jie:setVisible(false)
				scene.ui.assist:setVisible(false)
				scene.ui.pow:setVisible(false)
			end,self)
			Stage.replaceScene(scene)
			fightTipMgr.setIsShowTip(true)

			GuideManager.addFightSceneListener()
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_REPORT then
			print("enter report=======================================")
			local param = self.curStep.param
			local fightControl = Stage.currentScene:getFightControl()
			local report = {}
			for _,obj in ipairs(param) do
				local isAHit = (obj[1] == 1)
				local groupId = obj[2]
				local hero = nil
				if isAHit then
					hero = fightControl:getHeroA()
				else
					hero = fightControl:getHeroB()
				end
				print("groupId ==================================" .. groupId)
				local skill = SkillLogic.getSkillGroupById(hero, groupId)
				skill:setLv(obj[3])
				table.insert(report, fightControl:createRound(isAHit, skill:getSkillObjList()))
			end
			Stage.currentScene:setReport(report)
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_ASSIST_LV then
			local param = self.curStep.param
			local fightControl = Stage.currentScene:getFightControl()
			for _,obj in ipairs(param) do
				local isAAssist = (obj[1] == 1)
				local groupId = obj[2]
				local hero = nil
				if isAAssist then
					hero = fightControl:getAssistA()
				else
					hero = fightControl:getAssistB()
				end
				print("assist groupId ==================================" .. groupId)
				local skill = SkillLogic.getSkillGroupById(hero, groupId)
				skill:setLv(obj[3])
			end
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_SKILL_LV then
			local param = self.curStep.param
			local fightControl = Stage.currentScene:getFightControl()
			for _,obj in ipairs(param) do
				local isAHit = (obj[1] == 1)
				local groupId = obj[2]
				local hero = nil
				if isAHit then
					hero = fightControl:getHeroA()
				else
					hero = fightControl:getHeroB()
				end
				local skill = SkillLogic.getSkillGroupById(hero, groupId)
				skill:setLv(obj[3])
			end
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_STOP_NEXT then
			print("stop next =======================================")
			Stage.currentScene:pause()
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_START_NEXT then
			print("start next ======================================")
			Stage.currentScene:resume()
			Stage.currentScene:nextHero()
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_PAUSE then
			print("pause ===========================================")
			local panel = Stage.currentScene:getUI()
			if panel then
				panel:stopFight()
			end
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_RESUME then
			print("resume =-========================================")
			local panel = Stage.currentScene:getUI()
			if panel then
				panel:continueFight()
			end
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_SPERATE then
			print("setPosx =============================================")
			Stage.currentScene:sperateHero()
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_FIGHT_START_STOP then
			print("fight start stop ================================")
			if self.groupId == GuideDefine.GUIDE_FIGHT_SCENE then
				Stage.currentScene:setHeroANoAddPower(true)
			end
			local Ai = require("src/modules/fight/Ai")
			Stage.currentScene.ui:stopCD()
			Stage.currentScene:changeAiState(Ai.AI_STATE_NONE)
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_FIGHT_START_NEXT then
			print("fight start next =================================")
			local Ai = require("src/modules/fight/Ai")
			Stage.currentScene.ui:startCD()
			Stage.currentScene:changeAiState(Ai.AI_STATE_HIT)
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_RAGE_FULL then
			print('Guide rage full ========================')
			local param = self.curStep.param
			local rage = 100
			if #param > 0 then
				rage = param[1]
			end
			Stage.currentScene:setHeroANoAddPower(false)
			Stage.currentScene.heroA:getInfo():addPower(rage)
			Stage.currentScene:setHeroANoAddPower(true)
			if param[2] == nil then
				Stage.currentScene:setHeroANoAddPower(false)
			end
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_TARGET_SKILL then
			print('Target skill============================')
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_ASSIST_FULL then
			print('Guide assit ==========================')
			Stage.currentScene:addHeroAAssist(100)
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_CRITICAL then
			print('Guide critical ==========================')
			if self.curStep.param == GuideDefine.GUIDE_HERO_LEFT then
				Stage.currentScene.heroA.hero.dyAttr.crthit = 10000
			else
				Stage.currentScene.heroB.hero.dyAttr.crthit = 10000
			end
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_RESET_CRITICAL then
			print('Guide reset critical ---------------------')
			if self.curStep.param == GuideDefine.GUIDE_HERO_LEFT then
				Stage.currentScene.heroA.hero.dyAttr.crthit = 0
			else
				Stage.currentScene.heroB.hero.dyAttr.crthit = 0
			end
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_CATCH then
			print("setComboStop &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
			Stage.currentScene:setComboStop(true)
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_RESET_CATCH then
			print("setComboStop2 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
			Stage.currentScene:setComboStop(false)
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_HIDE_BTN then
			print("setBTNHide &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
			for _,v in ipairs(self.curStep.param) do
				if v == 1 then
					Stage.currentScene.ui.po:setVisible(false)
				elseif v == 2 then
					Stage.currentScene.ui.assist:setVisible(false)
				elseif v == 3 then
					Stage.currentScene.ui.pow:setVisible(false)
				else
					Stage.currentScene.ui.jie:setVisible(false)
				end
			end
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_SHOW_BTN then
			for _,v in ipairs(self.curStep.param) do
				if v == 1 then
					Stage.currentScene.ui.po:setVisible(true)
				elseif v == 2 then
					Stage.currentScene.ui.assist:setVisible(true)
				elseif v == 3 then
					Stage.currentScene.ui.pow:setVisible(true)
				else
					Stage.currentScene.ui.jie:setVisible(true)
				end
			end
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_TIME_OUT then
			Stage.currentScene.ui:timeOver()	
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_ASSIST then
			Stage.currentScene.fightLogic:assist()
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_COMBO then
			Stage.currentScene.fightLogic:combo()
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_SKILL then
			Stage.currentScene.fightLogic:power()
			print('power skill =======================')
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_SHOW_CHAP_JUMP then
			local levelui = require("src/modules/chapter/ui/LevelUI").Instance
			if levelui then
				levelui:showTip()
			end
		elseif self.curStep.type == GuideDefine.GUIDE_MASK_TYPE_FIGHT_EFF then
			local fightUI = UIManager.getUI('ChapterFightUI')
			if fightUI then
				fightUI:addWarnEff()
			end
		end
		print('finishcurstep111111111')
		self:finishCurStep()
	end
	print("curStep =======================================" .. self.curStep.id)
	print("curType ========================================" .. self.curStep.type)
end

function finishCurStep(self)
	print('enter finishCurStep ==================================')
	if self.curStep then
		self.curStep.finish = true
		self.mask = nil
		if self.curStep.finishStep == 1 then	
			Network.sendMsg(PacketID.CG_GUIDE, self.groupId)
		end
	end
	self.isExcute = false
	GuideManager.dispatchEvent(GuideDefine.GUIDE_NEXT_STEP, {groupId = self.groupId, active = 0})
end

function complete(self)
	self.isComplete = true
	GuideManager.finishGuide(self.groupId)
end

function hasComplete(self)
	return self.isComplete
end

function getCurComponentInfo(self)
	return self.componentList[self.curStep.step]
end
