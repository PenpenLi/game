module(..., package.seeall)

local ItemConfig = require("src/config/ItemConfig").Config
local Hero = require("src/modules/hero/Hero")
local BaseMath = require("src/modules/public/BaseMath")

local OrochiConfig = require("src/config/OrochiConfig").Config
local Define = require("src/modules/orochi/OrochiDefine")
local Logic = require("src/modules/orochi/OrochiLogic")

local SettlementWinUI = require("src/ui/SettlementWinUI")
local SettlementLoseUI = require("src/ui/SettlementLoseUI")

function new(result,levelId,entryTime,reward,isChief)
	local ctrl
	if result == Define.FIGHT_SUCCESS then
    	ctrl = SettlementWinUI.new()
		setmetatable(_M, {__index = SettlementWinUI}) 
		setmetatable(ctrl,{__index = _M})
    	ctrl:win(levelId,entryTime,reward,isChief)
	else
    	ctrl = SettlementLoseUI.new()
		setmetatable(_M, {__index = SettlementLoseUI}) 
		setmetatable(ctrl,{__index = _M})
    	ctrl:lose(levelId)
	end
    return ctrl
end

function getTitle(self,levelId)
	local boss = Logic.getLevelBoss(levelId)
	return Common.getMonsterName(boss.monsterId)
end

function win(self,levelId,entryTime,rewardList,isChief)
	SettlementWinUI.init(self)
	--self:initOrochi()

	--self:setOrochiChief(isChief,entryTime)
	self:addConfirmBtn()

	self:setTitle(self:getTitle(levelId))

	local master = Master:getInstance()
	--local nextExp = BaseMath.getHumanLvUpExp(master.lv + 1)
	--local percent = master.exp/nextExp * 100
	if rewardList then
		local reward = {}
		for _,r in ipairs(rewardList) do 
			reward[r.rewardName] = r.cnt
		end
		self:setMaster(master.lv,percent,reward.charExp,reward.money)

		--Common.printR(reward)
		self:setReward(reward)

		self:setHeroes(Logic.Expedition,reward.heroExp)
		--自动下阵 
		Logic.Expedition[1] = ""
	end

	--下一个关卡
	self.canFightLevel = Logic.getCanFightLevel()
	if self.canFightLevel then
		self:addNextBtn()
	end
end

function onView(self)
	UIManager.removeUI(self)
	if Stage.currentScene.name ~= 'main' then
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
		scene:addEventListener(Event.InitEnd, function()
			UIManager.replaceUI("src/modules/orochi/ui/OrochiRankUI")
		end)
	end
end

function lose(self,levelId)
	self:setTitle(self:getTitle(levelId))
	self:setHeroes(Hero.expedition)
	SettlementLoseUI.init(self)
end

function onClose(self,event,target)
	UIManager.removeUI(self)
	if Stage.currentScene.name ~= 'main' then
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
		scene:addEventListener(Event.InitEnd, function()
			UIManager.replaceUI("src/modules/orochi/ui/OrochiUI")
		end)
	end
end

function onNext(self)
	if Stage.currentScene.name ~= 'main' then
		--UIManager.addUI("src/modules/orochi/ui/FightUI",self.canFightLevel.levelId)
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
		scene:addEventListener(Event.InitEnd, function()
			UIManager.addUI("src/modules/orochi/ui/FightUI",self.canFightLevel.levelId)
		end)
	end
end






