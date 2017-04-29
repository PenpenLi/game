module(..., package.seeall)

local HeroFightListUI = require("src/ui/HeroFightListUI")
setmetatable(_M, {__index = HeroFightListUI})

local Data = require("src/modules/peak/PeakData")
local Monster = require("src/modules/hero/Monster")
local PeakConfig = require("src/config/PeakConfig").Config[1]
local Define = require("src/modules/peak/PeakDefine")
local FightControl = require("src/modules/fight/FightControl")
local FightDefine = require("src/modules/fight/Define")
local Hero = require("src/modules/hero/Hero")

function new()
	local ctrl = HeroFightListUI.new({})
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "PeakFightUI"
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_RAW
end

function init(self)
	HeroFightListUI.init(self)
	self.timeDesTxt:setVisible(true)
	self.timeTxt:setVisible(true)
	self:initSelectTimer()
end

function initSelectTimer(self)
	self:openTimer()
	self.startTime = os.time()
	self.timer = self:addTimer(onRefresh, 1, -1, self)
end

function onRefresh(self, evt)
	if not self.isTimeOut then
		local leftTime = PeakConfig.fightTime - (os.time() - self.startTime)
		if leftTime > 0 then
			self.timeTxt:setString(leftTime .. '秒')
		else
			self.timeTxt:setString('0秒')
			self.isTimeOut = true
			self:setFightEnabled(false)
			self:randomFightHeroList()
		end
	end
end

function randomFightHeroList(self)
	local tb = {}
	local copyList = {}
	local heroInfoList = Data.getInstance():getSelectHeroList()
	for name,_ in pairs(heroInfoList) do
		table.insert(copyList, name)
	end

	for i=1,Define.TEAM_HERO_COUNT do
		local len = #copyList
		local index = math.random(1, len)
		local name = table.remove(copyList, index)
		table.insert(tb, name)
	end
	self:resetHeroFightList(tb)
	self:sendEnterMsg()
end

function getHeroList(self)
	return Data.getInstance():getPrepareHeroList()
end

function doFight(self)
	local openNum = self:getOpenNum()
	if Common.GetTbNum(self.heroFightList) < openNum then
		local tip = TipsUI.showTips(string.format("你的出战阵容不足%d人，是否继续？",openNum))
		tip:addEventListener(Event.Confirm,function(self,event) 
			self:setFightEnabled(true)
			if event.etype == Event.Confirm_yes then
				self:sendEnterMsg()
			end
		end,self)
	else
		self:sendEnterMsg()
	end
end

function sendEnterMsg(self)
	local tab = {}
	for i=1,4 do
		local name = self.heroFightList[i]
		table.insert(tab, name)
	end
	Network.sendMsg(PacketID.CG_PEAK_READY_GO, tab)
end

function refreshToFightScene(self, dir)
	self.dir = dir
	self.isTimeOut = true
	self:setFightEnabled(false)
	self:setEnemyFightList(Data.getInstance():getEnemyHeroList())
	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(Define.SELECT_DEALY_TIME),
		cc.CallFunc:create(function()
			self:doTeamFight()
		end)
	))
end

function toFightScene(self)
	self:prepareHeroes()
	local fightControl = nil
	if self.dir == Define.DIR_LEFT then
		fightControl = FightControl.new(self.AHeroes,self.BHeroes)
	else
		fightControl = FightControl.new(self.BHeroes,self.AHeroes)
	end
	if Stage.currentScene.name == "fight" then
		return Stage.currentScene
	end
	local scene = require("src/scene/FightScene").new(fightControl,FightDefine.FightModel.autoA_autoB,FightDefine.FightType.arena)
	scene:addEventListener(Event.InitEnd,function()
		scene.ui.suspend.touchEnabled = false
		self:onFightInit()
	end,self)
	scene:addEventListener(Event.FightEnd,self.onFightEnd,self)
	scene:addEventListener(Event.FightDie,self.onFightDie,self)
	Stage.replaceScene(scene)
	return scene
end

function closeUI(self)
	local tip = TipsUI.showTips(string.format("当前选择退出战斗会判断此次战斗逃跑，无法获得积分哦，是否选择退出？"))
	tip:addEventListener(Event.Confirm,function(self,event) 
		if event.etype == Event.Confirm_yes then
			Network.sendMsg(PacketID.CG_PEAK_FAIL)
			HeroFightListUI.closeUI(self)
		end
	end,self)
end

function onFightEnd(self,event)
	local result = Define.END_SUCCESS 
	if self.dir == Define.DIR_LEFT then
		if event.winer == 'B' then
			result = Define.END_FAIL
		end
	else
		if event.winer == 'A' then
			result = Define.END_FAIL
		end
	end
	Network.sendMsg(PacketID.CG_PEAK_END, result)

	local scene = self:returnToMainScene()
	scene:addEventListener(Event.InitEnd, function()
		UIManager.replaceUI("src/modules/peak/ui/PeakUI")
		if result == Define.END_SUCCESS then
			TipsUI.showTipsOnlyConfirm("你赢了，获得" .. PeakConfig.successScore .. "积分!")
		else
			TipsUI.showTipsOnlyConfirm("你输了，获得" .. PeakConfig.failScore .. "积分!")
		end
	end)
	--重置英雄血量
	Hero.resetAllHeroFightAttr()
end
