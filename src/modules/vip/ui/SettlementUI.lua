module(..., package.seeall)

local Define = require("src/modules/vip/VipDefine")
local ItemConfig = require("src/config/ItemConfig").Config
local Hero = require("src/modules/hero/Hero")
local BaseMath = require("src/modules/public/BaseMath")
local SettlementWinUI = require("src/ui/SettlementWinUI")
local SettlementLoseUI = require("src/ui/SettlementLoseUI")

function new(levelId,result,rewardList,heroes)
	local ctrl
	if result == Define.WIN then
    	ctrl = SettlementWinUI.new()
		setmetatable(_M, {__index = SettlementWinUI}) 
		setmetatable(ctrl,{__index = _M})
    	ctrl:win(levelId,result,rewardList,heroes)
	else
    	ctrl = SettlementLoseUI.new()
		setmetatable(_M, {__index = SettlementLoseUI}) 
		setmetatable(ctrl,{__index = _M})
		ctrl:lose(levelId,heroes)
	end
    return ctrl
end

function win(self,levelId,result,rewardList,heroes)
	SettlementWinUI.init(self)
	local master = Master:getInstance()
	--local nextExp = BaseMath.getHumanLvUpExp(master.lv + 1)
	--local percent = master.exp/nextExp * 100
	local reward = {}
	for _,r in ipairs(rewardList) do 
		reward[r.rewardName] = r.cnt
	end
	self:setTitle("")
	self:addConfirmBtn()
	-- local lv = Master.getInstance().lv
	-- local fixMoney = FixRewardConfig[lv]['chapterReward'..difficulty].money
	-- local extraMoney
	-- if fixMoney and reward.money > fixMoney then
	-- 	extraMoney = reward.money - fixMoney
	-- else
	-- 	fixMoney = reward.money
	-- end
	-- self:setMaster(master.lv,percent,reward.charExp,fixMoney,extraMoney)
	self:setMaster(master.lv,percent,reward.charExp,reward.money)
	self:setReward(reward)
	self:setHeroes(heroes)
end

--下一关
-- function onNext(self)

-- end

function lose(self,levelId,heroes)
	SettlementLoseUI.init(self)
	self:setHeroes(heroes)
end

function onClose(self,event,target)
	UIManager.removeUI(self)

	if Stage.currentScene.name ~= 'main' then
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
		scene:addEventListener(Event.InitEnd, function()
			UIManager.replaceUI("src/modules/vip/ui/VipLevelUI")
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







