module(..., package.seeall)

local Chapter = require("src/modules/chapter/Chapter")
local ChapterDefine = require("src/modules/chapter/ChapterDefine")
local ItemConfig = require("src/config/ItemConfig").Config
local Hero = require("src/modules/hero/Hero")
local BaseMath = require("src/modules/public/BaseMath")
local LevelConfig = require("src/config/LevelConfig").Config
local ChapterConfig = require("src/config/ChapterConfig").Config
local SettlementWinUI = require("src/ui/SettlementWinUI")
local SettlementLoseUI = require("src/ui/SettlementLoseUI")
local FixRewardConfig = require("src/config/FixRewardConfig").Config

function new(levelId,difficulty,result,rewardList,star,lastLevel)
	local ctrl
	local chapterId = Chapter.getChapterId(levelId)
	local difficultyName = ChapterDefine.DIFFICULTY_NAME[difficulty]
	local no = Chapter.getLevelNo(levelId)
	local title = '('..difficultyName..')'..Chapter.getChapterTitle(chapterId).." 第" ..no.."关 "..Chapter.getLevelTitle(levelId)
	if result == ChapterDefine.WIN then
    	ctrl = SettlementWinUI.new()
		setmetatable(_M, {__index = SettlementWinUI}) 
		setmetatable(ctrl,{__index = _M})
    	ctrl:win(levelId,difficulty,result,rewardList)
    	ctrl:setTitle(title)
    	ctrl:setStarNum(star)
	else
    	ctrl = SettlementLoseUI.new()
		setmetatable(_M, {__index = SettlementLoseUI}) 
		setmetatable(ctrl,{__index = _M})
		ctrl:lose(levelId,difficulty)
	end
	ctrl.lastLevel = lastLevel
	ctrl.chapterId = Chapter.getChapterId(levelId)
	ctrl.levelId = levelId
	ctrl.difficulty = difficulty
	if ChapterConfig[ctrl.chapterId+1] then
		ctrl.nextChapterOpened = Chapter.getTopOpenedLevel(ctrl.chapterId+1,1) > 0 
	end


    return ctrl
end

function win(self,levelId,difficulty,result,rewardList)
	SettlementWinUI.init(self)
	self:initChapter()
	local levelTitle = LevelConfig[levelId][difficulty].levelTitle
	self:setTitle(levelTitle,difficulty)

	local master = Master:getInstance()
	--local nextExp = BaseMath.getHumanLvUpExp(master.lv + 1)
	--local percent = master.exp/nextExp * 100
	local reward = {}
	for _,r in ipairs(rewardList) do 
		reward[r.rewardName] = r.cnt
	end
	-- local fixMoney = LevelConfig[levelId][difficulty].fixReward.money
	local lv = Master.getInstance().lv
	local fixMoney = FixRewardConfig[lv]['chapterReward'..difficulty].money
	local extraMoney
	if fixMoney and reward.money > fixMoney then
		extraMoney = reward.money - fixMoney
	else
		fixMoney = reward.money
	end
	self:setMaster(master.lv,percent,reward.charExp,fixMoney,extraMoney)

	self:setReward(reward)
	self:setHeroes(Chapter.fightHeroes,reward.heroExp)
	local chapterId = Chapter.getChapterId(levelId)
	local lastLevel = Chapter.getLastLevel(chapterId)
	if levelId ~= lastLevel and (chapterId ~= 1 or difficulty > 1)  then
		self.nextLevel = levelId + 1
		self:addNextBtn()
	else
		self.nextLevel = nil
	end
end

--下一关
-- function onNext(self)

-- end

function lose(self,levelId,difficulty)
	SettlementLoseUI.init(self)
	local levelTitle = LevelConfig[levelId][difficulty].levelTitle
	self:setTitle(levelTitle,difficulty)
	self:setHeroes(Chapter.fightHeroes)
end

function onClose(self,event,target)
	UIManager.removeUI(self)

	if Stage.currentScene.name ~= 'main' then
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
		scene:addEventListener(Event.InitEnd, function()
			local levelId = self.levelId
			if self.lastLevel then
				levelId = nil
			end
			UIManager.replaceUI("src/modules/chapter/ui/LevelUI",self.chapterId,self.difficulty,levelId,true)
		end)
		-- local firstLevelId = Chapter.getFirstLevel(self.chapterId+1 )
		-- local opened,passed,_ = Chapter.getLevelInfo(firstLevelId,1)
		-- if Chapter.isLastLevel(self.levelId) and self.difficulty==1 and not showChapterOpen[self.chapterId+1] and  opened and not passed then
		-- 	-- 开启新章节
		-- 	if ChapterConfig[self.chapterId+1] then
		-- 		showChapterOpen[self.chapterId+1] = true
		-- 		local ui = UIManager.replaceUI("src/modules/chapter/ui/LevelUI",self.chapterId,self.difficulty)
		-- 		if GuideManager.isShowGuide() == false then
		-- 			ui:showTip()	
		-- 		else
		-- 			GuideManager.setGuide(false)
		-- 		end
		-- 	else
		-- 		UIManager.replaceUI("src/modules/chapter/ui/LevelUI",self.chapterId,self.difficulty)
		-- 	end
		-- else
		-- 	UIManager.replaceUI("src/modules/chapter/ui/LevelUI",self.chapterId,self.difficulty)
		-- end
	end
end



function onNext(self)
	if Stage.currentScene.name ~= 'main' then
		--UIManager.addUI("src/modules/orochi/ui/FightUI",self.canFightLevel.levelId)
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
		scene:addEventListener(Event.InitEnd, function()
			UIManager.addUI("src/modules/chapter/ui/ChapterFightUI",self.nextLevel,self.difficulty)
		end)
	end
end



