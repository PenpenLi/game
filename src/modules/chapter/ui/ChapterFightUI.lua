module(..., package.seeall)
local HeroFightListUI = require("src/ui/HeroFightListUI")
setmetatable(_M, {__index = HeroFightListUI})
local HeroDefine = require("src/modules/hero/HeroDefine")
local FightDefine = require("src/modules/fight/Define")
local Hero = require("src/modules/hero/Hero")
local FightControl = require("src/modules/fight/FightControl")
local LevelConfig = require("src/config/LevelConfig").Config
local DialogConfig = require("src/config/DialogConfig").Config
local Monster = require("src/modules/hero/Monster")
local ChapterDefine = require("src/modules/chapter/ChapterDefine")
local Common = require("src/core/utils/Common")
local Chapter = require("src/modules/chapter/Chapter")

function new(levelId,difficulty)
	local monster = Monster.getMonsterObjectByLevelId(levelId,difficulty)
	local ctrl = HeroFightListUI.new(monster)
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "ChapterFightUI"
	ctrl:init(levelId,difficulty)
	return ctrl
end

function sendFBEnd(winer,star,levelId,difficulty,fightHeroes)
	local ui = WaittingUI.create(PacketID.GC_CHAPTER_FB_END)
	ui:addEventListener(WaittingUI.Event.Timeout,function()
		local tipsUI = TipsUI.showTopTips("网络不太好哦,请重试")
		tipsUI:setBtnName("重试","退出")
		tipsUI:addEventListener(Event.Confirm,function(self,event) 
			if event.etype == Event.Confirm_yes then
				sendFBEnd(winer,star,levelId,difficulty,fightHeroes)
			elseif event.etype == Event.Confirm_no then
				ui:removeFromParent()
				local scene = require("src/scene/MainScene").new()
				Stage.replaceScene(scene)
			end
		end)
	end,self)
	if winer == 'A' then
		Network.sendMsg(PacketID.CG_CHAPTER_FB_END,levelId,difficulty,ChapterDefine.WIN,fightHeroes,star)
	else
		Network.sendMsg(PacketID.CG_CHAPTER_FB_END,levelId,difficulty,ChapterDefine.DEFEATED,fightHeroes,star)
	end
end
function onFightEnd(self,event)
	local fightHeroes = {}
	for i=1,4 do
		if self.heroFightList[i] then
			fightHeroes[i] = self.heroFightList[i]
		else
			fightHeroes[i] = ''
		end
	end
	local winer = event.winer
	-- 计算星星数
	local star = 1
	if winer == 'A' then
		local remain = 4 - event.infoA.index
		local h = Hero.getHero(fightHeroes[event.infoA.index])
		local dead = 3 - remain
		if dead <= 1 then
			star = 3
		elseif dead == 2 then
			local hp = event.infoA.hp
			if hp/h.dyAttr.maxHp >= 0.5 then
				star = 2
			else
				star = 1
			end
		end

		-- local conf = LevelConfig[self.levelId][self.difficulty]
		-- for i=3,1,-1 do
		-- 	if dead <= conf.starCondition[i] then
		-- 		star = i
		-- 		break
		-- 	end
		-- end
		sendFBEnd(winer,star,self.levelId,self.difficulty,fightHeroes)
	elseif winer == 'B' then
		sendFBEnd(winer,star,self.levelId,self.difficulty,fightHeroes)
	else
		-- 主动退出
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
		scene:addEventListener(Event.InitEnd, function()
			local chapterId = Chapter.getChapterId(self.levelId)
			UIManager.replaceUI('src/modules/chapter/ui/LevelUI',chapterId,self.difficulty,self.levelId)
		end)
	end
end


local clickTime = 0
function onFight(self,event,target)
	if (os.time() - clickTime) < 1 then
		return
	else
		clickTime = os.time()
	end
	local conf = LevelConfig[self.levelId][self.difficulty]
	if conf.energy > Master.getInstance().physics then
		Common.showMsg("体力不足，无法挑战")
		return
	end
	if self:canFight() then
		self:setFightEnabled(false)
		-- self:doFight()
		sendFBStart(self.levelId,self.difficulty)
	end
	StatisSDK.startLevel(self.levelId.."_"..self.difficulty)
end


function init(self,levelId,difficulty)
	self.levelId = levelId
	self.difficulty = difficulty
	HeroFightListUI.init(self)
	self:resetHeroFightList(Chapter.fightHeroes)

	local fun = function()
		self.isGuide = true
	end
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.fight, step = 8, groupId = GuideDefine.GUIDE_CHAPTER_FIRST, nextTime=0})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.fight, step = 6, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC, nextTime=0})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.fight, step = 6, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD, nextTime=0})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.fight, step = 13, groupId = GuideDefine.GUIDE_HERO_ACTIVE, nextTime=0})
end


function toFightScene(self)
	local opened,passed,times,buyTimes,star = Chapter.getLevelInfo(self.levelId,self.difficulty)
	local fightScene = HeroFightListUI.toFightScene(self,FightDefine.FightType.chapter,{star=star})
	local function onDialog(self,event)
		if event.round == 1 then
			local dialogId = LevelConfig[self.levelId][self.difficulty].dialog
			if dialogId > 0 then
				local dialog = DialogConfig[dialogId]
				if #dialog > 0 then
					local mask = require("src/ui/Mask").new()
					mask._ccnode:setLocalZOrder(1000)
					fightScene:addChild(mask)
					mask:setStoryTalkList(dialog)
				end
			end
		end
	end
	fightScene:addEventListener(Event.FightStart, onDialog,self)
end



function doFight(self)
	HeroFightListUI.doFight(self)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIRST, step = 8})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC, step = 6})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD, step = 6})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_ACTIVE, step = 13})
end

function sendFBStart(levelId,difficulty)
	local ui = WaittingUI.create(PacketID.GC_CHAPTER_FB_START)
	ui:addEventListener(WaittingUI.Event.Timeout,function()
		local tipsUI = TipsUI.showTopTips("网络不太好哦,请重试")
		tipsUI:addEventListener(Event.Confirm,function(self,event) 
			if event.etype == Event.Confirm_yes then
				sendFBStart(levelId,difficulty)
			elseif event.etype == Event.Confirm_no then
				ui:removeFromParent()
			end
		end)
	end,self)
	Network.sendMsg(PacketID.CG_CHAPTER_FB_START,levelId,difficulty)
end

function onFightInit(self, event)
	HeroFightListUI.onFightEnd(self, event)
	GuideManager.addChapterFightSceneListener(self.levelId)
end

function refreshListItem(self, item, hero)
	local name = hero.name 
	if name == "Shingo" then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, step = 6, delayTime = 0.3, noDelayFun = function()
				self.isGuide = true
				Chapter.fightHeroes = {}
				self:resetHeroFightList(Chapter.fightHeroes)
				self.herolist:showTopItem(item.num)
			end
		,groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, step = 9, delayTime = 0.3, noDelayFun = function()
				self.isGuide = true
				Chapter.fightHeroes = {}
				self:resetHeroFightList(Chapter.fightHeroes)
				self.herolist:showTopItem(item.num)
			end	
		,groupId = GuideDefine.GUIDE_HERO_ACTIVE})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, step = 4, delayTime = 0.3, noDelayFun = function()
				self.isGuide = true
				Chapter.fightHeroes = {}
				self:resetHeroFightList(Chapter.fightHeroes)
				self.herolist:showTopItem(item.num)
			end	
		,groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, step = 4, delayTime = 0.3, noDelayFun = function()
				self.isGuide = true
				Chapter.fightHeroes = {}
				self:resetHeroFightList(Chapter.fightHeroes)
				self.herolist:showTopItem(item.num)
			end	
		,groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD})
	elseif name == "Athena" then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, step = 7, delayTime = 0.3, noDelayFun = function()
				self.herolist:showTopItem(item.num)
			end	
		,groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, step = 5, delayTime = 0.3, noDelayFun = function()
				self.herolist:showTopItem(item.num)
			end	
		,groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, step = 5, delayTime = 0.3, noDelayFun = function()
				self.herolist:showTopItem(item.num)
			end	
		,groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, step = 11, delayTime = 0.3, noDelayFun = function()
				self.herolist:showTopItem(item.num)
			end	
		,groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	elseif name == 'Chang' then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, step = 10, delayTime = 0.3, noDelayFun = function()
				self.herolist:showTopItem(item.num)
			end	
		,groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	elseif name == 'Mai' then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, step = 12, delayTime = 0.3, noDelayFun = function()
				self.herolist:showTopItem(item.num)
			end	
		,groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	end
end

function addStage(self)
	HeroFightListUI.addStage(self)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 5, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_DO_STEP, {step = 8, groupId = GuideDefine.GUIDE_SIGN_IN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_DO_STEP, {step = 8, groupId = GuideDefine.GUIDE_CHAPTER_SECOND})
end

function addWarnEff(self)
	self:addArmatureFrame("res/armature/effect/Finger.ExportJson")
	local fingerEff = ccs.Armature:create("Finger")
	fingerEff:getAnimation():play('特效', -1, 1)
	fingerEff:setPosition(cc.p(self.fight:getContentSize().width / 2, self.fight:getContentSize().height/2))
	self.fight._ccnode:addChild(fingerEff)
end

-- 	-- local scene = require("src/scene/FightScene").new()
-- 	-- Stage.replaceScene(scene)
-- end

function clear(self)
	HeroFightListUI.clear(self)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 6, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 7, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 8, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 4, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 5, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 6, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC})

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 4, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 5, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 6, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD})

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 9, groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 10, groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 11, groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 12, groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 13, groupId = GuideDefine.GUIDE_HERO_ACTIVE})
end

function onClose(self,event,target)
	if event.etype == Event.Touch_ended then
		local chapterId = Chapter.getChapterId(self.levelId)
		self:closeUI()
		UIManager.addUI("src/modules/chapter/ui/LevelUI",chapterId)
	end
end
