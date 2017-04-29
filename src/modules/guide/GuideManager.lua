module("GuideManager", package.seeall)

local GuideModule = require("src/modules/guide/GuideModule")
local GuideModuleFactory = require("src/modules/guide/GuideModuleFactory")
local GuideConfig = require("src/config/GuideConfig").Config
local GuideMask = require("src/modules/guide/GuideMask")
local Chapter = require("src/modules/chapter/Chapter")
local Guide = require("src/modules/guide/Guide")
local FightDefine = require("src/modules/fight/Define")
local Hero = require("src/modules/hero/Hero")

guideDispatcher = {}
setmetatable(guideDispatcher, {__index = EventDispatcher})

local curGuideGroupId = nil
local finishList = {}
local finishStr = ""
local sortConfigList = {}
local isGuide = false
local isFirst = true

function init()
	initSortIdList()
	addListener()
end

function initSortIdList()
	for id,config in pairs(GuideConfig) do
		table.insert(sortConfigList, config)
	end
	table.sort(sortConfigList, function(a,b) 
		return a.sortId < b.sortId
	end)
end

function addListener()
	Master.getInstance():addEventListener(Event.ChapterEnd, onRefreshChapter)
	Master.getInstance():addEventListener(Event.MasterRefresh, onRefreshLv)

	guideDispatcher:addEventListener(GuideDefine.GUIDE_START, onStart)
	guideDispatcher:addEventListener(GuideDefine.GUIDE_NEXT_STEP, onNextStep)
	guideDispatcher:addEventListener(GuideDefine.GUIDE_STACK_UPDATE, onStackUpdate)
	guideDispatcher:addEventListener(GuideDefine.GUIDE_REGISTER_COMPONENT, onRegisterComponent)
	guideDispatcher:addEventListener(GuideDefine.GUIDE_UNREGISTER_COMPONENT, onUnRegisterComponent)
	guideDispatcher:addEventListener(GuideDefine.GUIDE_REGISTER_SUB_COMPONENT, onRegisterSubComponent)
	guideDispatcher:addEventListener(GuideDefine.GUIDE_UNREGISTER_SUB_COMPONENT, onUnRegisterSubComponent)
	guideDispatcher:addEventListener(GuideDefine.GUIDE_REMOVE_MASK, onRemoveMask)
	guideDispatcher:addEventListener(GuideDefine.GUIDE_JUMP, onJump)
	guideDispatcher:addEventListener(GuideDefine.GUIDE_COMBO, onCombo)
	guideDispatcher:addEventListener(GuideDefine.GUIDE_DO_STEP, onDoStep)

	guideDispatcher:addEventListener(GuideDefine.GUIDE_REGISTER_MAIN_COMPONENT, onRegisterMainComponent)
	guideDispatcher:addEventListener(GuideDefine.GUIDE_UNREGISTER_MAIN_COMPONENT, onUnRegisterMainComponent)

	guideDispatcher:addEventListener(GuideDefine.GUIDE_TRIGGER_TALK, onTriggerTalk)
	guideDispatcher:addEventListener(GuideDefine.GUIDE_REFRESH_LV, onRefreshLv)
	guideDispatcher:addEventListener(GuideDefine.GUIDE_REFRESH_HERO_LV, onRefreshHeroLv)
end

function addFightSceneListener()
	Stage.currentScene:addEventListener(Event.FightReport, onEndReport) 
	Stage.currentScene:addEventListener(Event.FightDie, onTargetDie)
	Stage.currentScene:addEventListener(Event.FightStart, onFightStart)
	Stage.currentScene:addEventListener(Event.FightPower, onFightPower)
	Stage.currentScene:addEventListener(Event.FightHit, onFightHit)
	Stage.currentScene:addEventListener(Event.FightCombo, onFightCombo) 
end

function addChapterFightSceneListener(levelId)
	if levelId == 102 then
		local config = GuideConfig[GuideDefine.GUIDE_CHAPTER_THIRD]
		startGuide(config)
	elseif levelId == 103 then
		local config = GuideConfig[GuideDefine.GUIDE_CHAPTER_FOUR]
		startGuide(config)
	elseif levelId == 110 then
		--local config = GuideConfig[GuideDefine.GUIDE_CHAPTER_TEN]
		--startGuide(config)
	end

	Stage.currentScene:addEventListener(Event.FightStart, onChapterFightStart)
	Stage.currentScene:addEventListener(Event.FightReport, onChapterEndReport) 

	if curGuideGroupId == GuideDefine.GUIDE_CHAPTER_FIRST or
		curGuideGroupId == GuideDefine.GUIDE_CHAPTER_THIRD or 
		curGuideGroupId == GuideDefine.GUIDE_CHAPTER_FOUR then
		dealWithFightUI()
	end
	
	addInitStep()
end

function dealWithFightUI()
	Stage.currentScene:getUI().suspend.touchEnabled = false
	Stage.currentScene.fightType = FightDefine.FightType.guide
	Stage.currentScene:getUI().zizhu:setVisible(false)
	Stage.currentScene:getUI().quxiao:setVisible(false)
end

function initFinishList(guideStr)
	finishList = {}
	finishStr = guideStr
	print("finishStr ========================" .. finishStr)
	if finishStr ~= "" then
		local tab = Common.split(finishStr, GuideDefine.GUIDE_USER_SPLIT_SIGN)
		for _,groupId in ipairs(tab) do
			print("groupdId =======================" .. groupId)
			finishList[tostring(groupId)] = groupId	
		end
	end
end

function addInitStep()
	doByStep(GuideDefine.GUIDE_CHAPTER_FIRST, 9)
	doByStep(GuideDefine.GUIDE_CHAPTER_SECOND, 2)
	doByStep(GuideDefine.GUIDE_CHAPTER_THIRD, 2)
	doByStep(GuideDefine.GUIDE_CHAPTER_FOUR, 2)
end

function onRefreshLv()
	if isFirst == false then
		local lv = Master.getInstance().lv
		for _,config in ipairs(sortConfigList) do
			--print("onRefreshLv =====================================" .. config.id)
			if config.triggerType == GuideDefine.GUIDE_TRIGGER_TYPE_LV and Stage.currentScene.name ~= 'fight' then
				startGuide(config)
			end
		end
	end
	isFirst = false
end

function onRefreshHeroLv(listener)
	for _,config in ipairs(sortConfigList) do
		if config.triggerType == GuideDefine.GUIDE_TRIGGER_TYPE_HERO_LV then
			print('refreshHeroLv config.id = ' .. config.id)
			startGuide(config)
		end
	end
end

function onRefreshChapter(listener, event)
	local levelId = event.levelId
	local difficulty = event.difficulty
	--print("onRefreshChapter =======================levelId = " .. levelId .. " difficulty = " .. difficulty)
	for _,config in ipairs(sortConfigList) do
		if config.triggerType == GuideDefine.GUIDE_TRIGGER_TYPE_CHAPTER then
			startGuide(config)
		end
	end
	--doByStep(GuideDefine.GUIDE_CHAPTER_FIRST, 23)
end

function onTriggerTalk(listener, event)
	local groupId = event.groupId
	local stepType = event.step 
	--print("onTriggerTalk =================== groupId = " .. groupId)
	local guideModule = GuideModuleFactory.getGuideModule(groupId)
	if guideModule and hasFinishGuide(groupId) == false then
		--print("onTriggerTalk =================== stepType = " .. stepType)
		guideModule:registerComponent(event)
		if curGuideGroupId == groupId then
			guideModule:triggerTalk(stepType)
		end
	end
end

function onEndReport(listener, event)
	print("end report%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
	--doByStep(GuideDefine.GUIDE_FIGHT_SCENE, 6)
end

function onTargetDie(listener, event)
	print("target die ====================================")
	doByStep(GuideDefine.GUIDE_FIGHT_SCENE, 6)
end

function onFightStart(listener, event)
	print("fight start =======================================")
	doByStep(GuideDefine.GUIDE_FIGHT_SCENE, 2)

	Stage.currentScene:setHeroANoAddPower(false)
	Stage.currentScene:addHeroAPower(50)
	Stage.currentScene:setHeroANoAddPower(true)
	Stage.currentScene:addHeroAAssist(50)

	Stage.currentScene:getUI().touchEnabled = false
end

function onChapterFightStart(listener, event)
	print('onChapterFightStart ==================================')
	doByStep(GuideDefine.GUIDE_CHAPTER_FIRST, 10)
	doByStep(GuideDefine.GUIDE_CHAPTER_SECOND, 3)
	doByStep(GuideDefine.GUIDE_CHAPTER_THIRD, 3)
	doByStep(GuideDefine.GUIDE_CHAPTER_FOUR, 3)
	doByStep(GuideDefine.GUIDE_CHAPTER_TEN, 2)
end

function onChapterEndReport(listener, event)
	doByStep(GuideDefine.GUIDE_CHAPTER_FIRST, 15)
	doByStep(GuideDefine.GUIDE_CHAPTER_FIRST, 18)
end

function onFightPower(listener, event)
end

function doByStep(guideId, stepType)
	local config = GuideConfig[guideId]
	if config and (curGuideGroupId == guideId or config.isSpecial == 1) then
		local guideModule = GuideModuleFactory.getGuideModule(guideId)
		if guideModule ~= nil and hasFinishGuide(guideId) == false then
			guideModule:doByStep(stepType)
		end
	end
end

function onFightHit(listener, event)
	--local atk = (Stage.currentScene.heroA == event.hero and 1 or 2)
	--local name = event.hero.heroName
	--local comboIndex = event.comboIndex
	--local hitConfigList = Guide.getTypeConfigList(GuideDefine.GUIDE_MASK_TYPE_TARGET_SKILL)
	--local len = #hitConfigList
	--print("atk =====" .. atk .. " name = " .. name .. " comboIndex = " .. comboIndex)
	--for i=1,len do
	--	local config = hitConfigList[i]
	--	local param = config.param
	--	local atkParam = param[1]
	--	local nameParam = param[2]
	--	local comboIndexParam = param[3]
	--	if atk == atkParam and name == nameParam and comboIndex == comboIndexParam then
	--		print(" stepType = " .. config.stepType)
	--		doByStep(GuideDefine.GUIDE_FIGHT_SCENE, config.stepType)
	--		break
	--	end
	--end
end

function onFightCombo(listener, event)
	print('onFightCombo ====================================')
	--doByStep(GuideDefine.GUIDE_FIGHT_SCENE, 24)
end

function onStart(listener, event)
	local config = nil
	if event.param == nil then
		config = GuideConfig[event.groupId]
	else
		--for _,conf in pairs(GuideConfig) do
		--	if conf.triggerType == event.triggerType and conf.triggerParam == event.triggerParam then
		--		config = conf
		--		break
		--	end
		--end
	end
	if config then
		print("onStart =======================" .. config.id)
		startGuide(config)
	end
end

function triggerGuide()
	for _,config in ipairs(sortConfigList) do
		if config.triggerType ~= GuideDefine.GUIDE_TRIGGER_TYPE_OTHER then
			startGuide(config)
		end
	end
end

function startGuide(config)
	--if curGuideGroupId == nil then
	--	print("startGuide 1==========================")
	--end
	--if hasFinishPreGuide(config.id) == true then
	--	print("startGuide 2=============================")
	--end
	--if hasFinishGuide(config.id) == false then
	--	print("startGuide 3===========================")
	--end
	--print('triggerType ===================' .. config.triggerType)
	--if config.triggerType == GuideDefine.GUIDE_TRIGGER_TYPE_NONE or config.triggerType == GuideDefine.GUIDE_TRIGGER_TYPE_OTHER then
	--	print("startGuide 4==========================")
	--end
	--if hasEnoughLv(config) == true then
	--	print("startGuide 5==========================")
	--end
	--if hasPassChapter(config) == true then
	--	print("startGuide 6==========================")
	--end
	if config then
		local guideModule = GuideModuleFactory.getGuideModule(config.id)
		--if guideModule ~= nil then
		--	print('startGuide 7==========================')
		--end
		if guideModule ~= nil and 
			(curGuideGroupId == nil or config.isSpecial == 1) and 
			hasFinishPreGuide(config.id) == true and 
			hasFinishGuide(config.id) == false and 
			(config.triggerType == GuideDefine.GUIDE_TRIGGER_TYPE_NONE or
			config.triggerType == GuideDefine.GUIDE_TRIGGER_TYPE_OTHER or
			hasEnoughHeroLv(config) == true or
			hasEnoughLv(config) == true or
			hasPassChapter(config) == true) then

			if config.jump == 1 then
				Network.sendMsg(PacketID.CG_GUIDE, config.id)
			end
			if config.isSpecial == 0 then
				curGuideGroupId = config.id
			else
				dealWithFightUI()
			end
			if Config.isGuideNil == nil then
				guideModule:doStart()
			end
		end
	end
end

function hasPassChapter(config)
	if config.triggerType == GuideDefine.GUIDE_TRIGGER_TYPE_CHAPTER and Chapter.isLevelPassed(config.triggerParam[1], config.triggerParam[2]) then
		return true
	end
	return false
end

function hasEnoughLv(config)
	if config.triggerType == GuideDefine.GUIDE_TRIGGER_TYPE_LV and Master.getInstance().lv >= config.triggerParam[1] then
		return true
	end
	return false
end

function hasEnoughHeroLv(config)
	if config.triggerType == GuideDefine.GUIDE_TRIGGER_TYPE_HERO_LV then
		if Hero.getHeroCountMoreThanLv(config.triggerParam[1]) >= 1 then
			return true
		end
	end
	return false
end

function hasFinishPreGuide(groupId)
	for _,config in pairs(GuideConfig) do
		if config.nextId == groupId and hasFinishGuide(config.id) == false then
			return false	
		end
	end
	return true
end

function onNextStep(listener, event)
	local groupId = event.groupId
	local guideModule = GuideModuleFactory.getGuideModule(groupId)
	if guideModule ~= nil and hasFinishGuide(groupId) == false then
		guideModule:doNext(event.active)
	end
end

function onStackUpdate(listener, event)

end

function onRegisterComponent(listener, event)
	local module = GuideModuleFactory.getGuideModule(event.groupId)
	if module ~= nil and hasFinishGuide(event.groupId) == false then
		module:registerComponent(event)
	end
end

function onUnRegisterComponent(listener, event)
	local stepType = event.step
	local groupId = event.groupId
	local module = GuideModuleFactory.getGuideModule(groupId)
	if module ~= nil then
		module:unregisterComponent(stepType)
	end
end

function onRemoveMask(listener, event)
	local groupId = event.groupId
	local config = GuideConfig[groupId]
	local module = GuideModuleFactory.getGuideModule(groupId)
	print('groupId ============' .. groupId .. ' step = ' .. event.step)
	if module ~= nil and (curGuideGroupId ~= nil and curGuideGroupId == groupId) or  (config and config.isSpecial == 1) then
		if hasFinishGuide(groupId) == false then
			module:touchComponent(groupId, event.step)
		end
	end
end

function onJump(listener, event)
	local groupId = event.groupId
	local module = GuideModuleFactory.getGuideModule(groupId)
	if groupId == curGuideGroupId and module then
		module:removeMask(groupId)
		print('onJump =======' .. groupId)
		finishGuide(groupId, true)
	end
end

function onCombo(listener, event)
	--doByStep(GuideDefine.GUIDE_FIGHT_SCENE, 23)
end

function onDoStep(listener, event)
	local groupId = event.groupId
	local step = event.step
	doByStep(groupId, step)
end

function onRegisterMainComponent(listener, event)
	local allModule = GuideModuleFactory.getAllModule()
	for _,module in pairs(allModule) do
		if module.groupId ~= 0 and hasFinishGuide(module.groupId) == false then
			module:registerMainComponent()
		end
	end
end

function onUnRegisterMainComponent(listener, event)
	local allModule = GuideModuleFactory.getAllModule()
	for _,module in pairs(allModule) do
		module:unregisterMainComponent(event.url)
	end
end

function onRegisterSubComponent(listener, event)
	local allModule = GuideModuleFactory.getAllModule()
	for _,module in pairs(allModule) do
		if module.groupId ~= 0 and hasFinishGuide(module.groupId) == false then
			module:registerSubComponent()
		end
	end
end

function onUnRegisterSubComponent(listener, event)
	local allModule = GuideModuleFactory.getAllModule()
	for _,module in pairs(allModule) do
		module:unregisterSubComponent()
	end
end

function clearAllModuleComponent()
	local allModule = GuideModuleFactory.getAllModule()
	for _,module in pairs(allModule) do
		module:clearAllComponent()
	end
end

function hasFinishGuide(groupId)
	--print('hasFinishGuide = ' .. groupId)
	return (finishList[tostring(groupId)] ~= nil)
end

function finishGuide(groupId, isJump)
	if finishList[tostring(groupId)] == nil then
		finishList[tostring(groupId)] = groupId
		print('finish ===============' .. groupId)
		finishStr = finishStr .. groupId .. ","
		Network.sendMsg(PacketID.CG_GUIDE, groupId)

		local config = GuideConfig[groupId]
		if config then
			if config.isSpecial == 0 then
				curGuideGroupId = nil
			end
			--触发下一引导
			if isJump == nil then
				if config.nextId ~= 0 then
					local nextConfig = GuideConfig[config.nextId]
					if nextConfig.autoDo == 0 then
						print("config.nextId ==============================================" .. config.nextId)
						startGuide(GuideConfig[config.nextId])
					end
				else
					triggerGuide()
				end
			end
		end
	end
end

function addEventListener(etype, func, listener)
	guideDispatcher:addEventListener(etype, func, listener)
end

function dispatchEvent(etype, event)
	guideDispatcher:dispatchEvent(etype, event)
end

function isShowGuide()
	return isGuide
end

function setGuide(val)
	isGuide = val
end

init()
