module(..., package.seeall)

local ItemConfig = require("src/config/ItemConfig").Config
local Hero = require("src/modules/hero/Hero")
local BaseMath = require("src/modules/public/BaseMath")

local Define = require("src/modules/trial/TrialDefine")
local Logic = require("src/modules/trial/TrialLogic")

local Config = require("src/config/TrialConfig").Config
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
	ctrl.result = result
	ctrl.levelId = levelId
    return ctrl
end

function getTitle(self,levelId)
	local conf = Config[levelId]
	return string.format("%s[%s]",Define.TYPE_NAME[conf.type],conf.title)
end

function win(self,levelId,entryTime,rewardList,isChief)
	SettlementWinUI.init(self)
	self:addConfirmBtn()

	self:setTitle(self:getTitle(levelId))

	local master = Master:getInstance()
	--local nextExp = BaseMath.getHumanLvUpExp(master.lv + 1)
	--local percent = master.exp/nextExp * 100
	if rewardList then
		local reward = {}
		for _,r in ipairs(rewardList) do 
			reward[r.rewardName] = reward[r.rewardName] or 0
			reward[r.rewardName] = reward[r.rewardName] + r.cnt
		end
		self:setMaster(master.lv,percent,reward.charExp,reward.money)

		self:setReward(reward)

		self:setHeroes(Logic.getFightListById(levelId),reward.heroExp)
	end
end

function lose(self,levelId)
	SettlementLoseUI.init(self)
	self:setTitle(self:getTitle(levelId))
	self:setHeroes(Logic.getFightListById(levelId))
end

function onClose(self,event,target)
	UIManager.removeUI(self)
	if Stage.currentScene.name ~= 'main' then
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
		scene:addEventListener(Event.InitEnd, function()
			UIManager.replaceUI("src/modules/trial/ui/TrialUI",self.levelId,self.result == Define.FIGHT_SUCCESS)
		end)
	end
end







