module(...,package.seeall)
setmetatable(_M, {__index = Control})

local Data = require("src/modules/peak/PeakData")
local Define = require("src/modules/peak/PeakDefine")
local Hero = require("src/modules/hero/Hero")
local PeakConfig = require("src/config/PeakConfig").Config[1]

function new()
	local ctrl = Control.new(require("res/peak/PeakSkin"), {"res/peak/Peak.plist"})
	setmetatable(ctrl, {__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_LABEL
end

function init(self)
	self:initCon()
	self:initBtn()
	self:initHeroGrid()
	self:initScoreNum()
	self:sendMsg()
	self:addListener()
	self:initTimer()
end

function addStage(self)
	Control.addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function initCon(self)
	self.peakCon1:setVisible(true)
	self.peakCon2:setVisible(false)

	self.peakCon1.coolTimeTxt:setVisible(false)
	self.peakCon1.coolTimeTitleTxt:setVisible(false)
	self.peakCon1.resetBtn:setVisible(false)

	--GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 4, groupId = GuideDefine.GUIDE_PEAK})
end

function initBtn(self)
	self.peakCon1.resetBtn:setVisible(false)
	self.peakCon1.cancelBtn:setVisible(false)
	self.peakCon1.findBtn:setVisible(false)
end

function initHeroGrid(self)
	self.heroGridList = {}
	local con = self.peakCon1.gridCon
	for i=1,Define.HERO_COUNT do
		local heroGrid = HeroGridS.new(con["grid"..i].herobg2, i)
		heroGrid:setScale(0.8)
		heroGrid:setVisible(false)
		table.insert(self.heroGridList, heroGrid)	
	end

	self.myGridList = {}
	local con2 = self.peakCon2.myGridCon
	for i=1,Define.HERO_COUNT do
		local heroGrid = HeroGridS.new(con2["grid"..i].herobg2, i)
		heroGrid.guanbi = con2["grid"..i].guanbi
		heroGrid:setScale(0.8)
		heroGrid:setVisible(false)
		heroGrid.guanbi._ccnode:setLocalZOrder(10)
		table.insert(self.myGridList, heroGrid)	
	end

	self.enemyGridList = {}
	local con3 = self.peakCon2.enemyGridCon
	for i=1,Define.HERO_COUNT do
		local heroGrid = HeroGridS.new(con3["grid"..i].herobg2, i)
		heroGrid.guanbi = con3["grid"..i].guanbi
		heroGrid.gridNum = i
		heroGrid:setScale(0.8)
		heroGrid:setVisible(false)
		heroGrid.guanbi._ccnode:setLocalZOrder(10)
		heroGrid.guanbi:setVisible(false)
		heroGrid:addEventListener(Event.TouchEvent, onDelHero, self)
		table.insert(self.enemyGridList, heroGrid)	
	end
end

function initScoreNum(self)
	self.scoreLabel = cc.LabelAtlas:_create("0123456789", "res/arena/ranknum.png", 22, 27, string.byte('0'))
	self.scoreLabel:setAnchorPoint(0,0)
	self.peakCon1.down._ccnode:addChild(self.scoreLabel)
	self.scoreLabel:setPosition(cc.p(self.peakCon1.down.txtpm:getPositionX() + 100, self.peakCon1.down.txtpm:getPositionY()))
	self.scoreLabel:setString('0')
end

function sendMsg(self)
	Network.sendMsg(PacketID.CG_PEAK_TEAM_CHECK)
end

function addListener(self)
	self.back:addEventListener(Event.Click, onClose, self)
	self.peakCon1.down.ruleBtn:addEventListener(Event.Click, onRule, self)
	self.peakCon1.down.rankBtn:addEventListener(Event.Click, onRank, self)
	self.peakCon1.down.recordBtn:addEventListener(Event.Click, onRecord, self)
	self.peakCon1.down.exchangeBtn:addEventListener(Event.Click, onExchange, self)
	self.peakCon1.teamBtn:addEventListener(Event.Click, onTeam, self)
	self.peakCon1.cancelBtn:addEventListener(Event.Click, onCancel, self)
	self.peakCon1.resetBtn:addEventListener(Event.Click, onReset, self)
	self.peakCon1.findBtn:addEventListener(Event.Click, onFind, self)

	self.peakCon2.readyBtn:addEventListener(Event.Click, onReady, self)
	self.peakCon2.cancelBtn:addEventListener(Event.Click, onCancelDel, self)
end

function onClose(self, evt)
	if self.peakCon1:isVisible() == true then
		Network.sendMsg(PacketID.CG_PEAK_CANCEL)
		UIManager.removeUI(self)
		return
	end
	if self.peakCon2:isVisible() == true then
		local tip = TipsUI.showTips("当前选择退出战斗会判断此次战斗逃跑，无法获得积分哦，是否选择退出？")
		tip:addEventListener(Event.Confirm,function(self,event) 
			if event.etype == Event.Confirm_yes then
				self.isFail = true
				self.isFinding = nil
				self.peakCon2.readyBtn:setVisible(true)
				self.peakCon2.cancelBtn:setVisible(false)

				Network.sendMsg(PacketID.CG_PEAK_FAIL)
				self:sendMsg()
			end
		end,self)
	end
end

function initTimer(self)
	self:openTimer()
	self.openLeftTime = Common.getCronEventLeftTime(Define.CRONTAB_PEAK)
	if self.openLeftTime > (24*3600-PeakConfig.continueTime) then
		--活动时间内
		self.peakCon1.countDownTxt:setVisible(false)
		self.peakCon1.countDownTitleTxt:setVisible(false)
	end
	self.startTime = os.time()
	self.timer = self:addTimer(onRefreshTime, 1, -1, self)
	self:refreshTimeAbout()
end

function onRule(self, evt)
	if self.isFinding then
		Common.showMsg('正在搜索敌人!')
		return
	end
	local ui = UIManager.addChildUI("src/ui/RuleUI")
	ui:setId(RuleUI.Peak)
end

function onRank(self, evt)
	if self.isFinding then
		Common.showMsg('正在搜索敌人!')
		return
	end
	UIManager.addUI("src/modules/rank/ui/RankUI")
end

function onRecord(self, evt)
	if self.isFinding then
		Common.showMsg('正在搜索敌人!')
		return
	end
	UIManager.addChildUI("src/modules/peak/ui/PeakRecordUI")
	Network.sendMsg(PacketID.CG_PEAK_FIGHT_RECORD)
end

function onExchange(self, evt)
	if self.isFinding then
		Common.showMsg('正在搜索敌人!')
		return
	end
	UIManager.addChildUI("src/modules/peak/ui/PeakShopUI")
end

function onTeam(self, evt)
	if self.isFinding then
		Common.showMsg('正在搜索敌人!')
		return
	end
	if not self.isFinding then
		UIManager.addUI("src/modules/peak/ui/PeakHeroListUI")
	end
end

function onCancel(self, evt)
	self.isFinding = false
	self.peakCon1.findBtn:setVisible(true)
	self.peakCon1.cancelBtn:setVisible(false)
	Network.sendMsg(PacketID.CG_PEAK_CANCEL)
end

function onReset(self, evt)
	local tip = TipsUI.showTips(string.format("需要花费" .. Data.getInstance():getResetCost() .. "钻石，是否重置？"))
	tip:addEventListener(Event.Confirm,function(self,event) 
		if event.etype == Event.Confirm_yes then
			Network.sendMsg(PacketID.CG_PEAK_RESET_SEARCH)
		end
	end)
end

function onFind(self, evt)
	local list = Data.getInstance():getHeroNameList()
	if #list < Define.HERO_COUNT then
		Common.showMsg('上阵英雄最少为' ..  Define.HERO_COUNT .. '个')
		return
	end
	self.isFinding = true
	self.peakCon1.findBtn:setVisible(false)
	self.peakCon1.cancelBtn:setVisible(true)
	Network.sendMsg(PacketID.CG_PEAK_SEARCH)
end

function onRefreshTime(self, evt)
	self:refreshTimeAbout()
end

function refreshTimeAbout(self)
	self:refreshOpenTime()
	self:refreshCoolTime()
	self:refreshBtn()
	self:refreshSelect()
end

function refreshOpenTime(self)
	if Data.getInstance():getStart() == false then
		local leftTime = self.openLeftTime - (os.time() - self.startTime)
		if leftTime > 0 then
			Data.getInstance():setStart(false)
			self.peakCon1.countDownTxt:setString(Common.getDCTime(leftTime))
			self.peakCon1.countDownTxt:setVisible(true)
			self.peakCon1.countDownTitleTxt:setVisible(true)
		else
			Data.getInstance():setStart(true)
			self.peakCon1.countDownTxt:setVisible(false)
			self.peakCon1.countDownTitleTxt:setVisible(false)
		end	
	end
end

function refreshCoolTime(self)
	if Data.getInstance():getStart() == true then
		local coolTime = Data.getInstance():getCoolTime() - (os.time() - self.startTime)
		if coolTime > 0 then
			self.isCoolTime = true
			self.peakCon1.coolTimeTxt:setVisible(true)
			self.peakCon1.coolTimeTxt:setString(Common.getDCTime(coolTime))
			self.peakCon1.coolTimeTitleTxt:setVisible(true)
			self.peakCon1.resetBtn:setVisible(true)
		else
			self.isCoolTime = false
			self.peakCon1.coolTimeTxt:setVisible(false)
			self.peakCon1.coolTimeTitleTxt:setVisible(false)
			self.peakCon1.resetBtn:setVisible(false)
		end
	end
end

function refreshBtn(self)
	if Data.getInstance():getStart() then
		if self.isCoolTime then
			self.peakCon1.resetBtn:setVisible(true)
			self.peakCon1.findBtn:setVisible(false)
			self.peakCon1.cancelBtn:setVisible(false)
		else
			if self.isFinding then
				self.peakCon1.findBtn:setVisible(false)
				self.peakCon1.resetBtn:setVisible(false)
				self.peakCon1.cancelBtn:setVisible(true)
			else
				self.peakCon1.findBtn:setVisible(true)
				self.peakCon1.resetBtn:setVisible(false)
				self.peakCon1.cancelBtn:setVisible(false)
			end
		end
	else
		self.peakCon1.resetBtn:setVisible(false)
		self.peakCon1.cancelBtn:setVisible(false)
		self.peakCon1.findBtn:setVisible(false)
	end
end

function refreshTeamCon(self)
	if Data.getInstance():getStart() == true then
		self.peakCon1.countDownTxt:setVisible(false)
		self.peakCon1.countDownTitleTxt:setVisible(false)
	end
	UIManager.setUITop(false)
	self.isSelecting = false
	self.peakCon1:setVisible(true)
	self.peakCon2:setVisible(false)
	self:refreshScore()
	self:refreshTeamGrid()
end

function refreshScore(self)
	self.scoreLabel:setString(Data.getInstance():getScore())	
end

function onReady(self, evt)
	if self.isSelecting then
		local left = self:getLeftEnemyList()
		if #left ~= Define.TEAM_HERO_SELECT then
			Common.showMsg('请去除' .. Define.HERO_DEL_COUNT .. '个英雄')
			return
		end
		self.isReady = true
		self.peakCon2.readyBtn:setVisible(false)
		self.peakCon2.cancelBtn:setVisible(true)
		Network.sendMsg(PacketID.CG_PEAK_CTRL_ENEMY_CONFIRM, left)
	end
end

function onCancelDel(self, evt)
	if self.isSelecting then
		self.isReady = false
		self:resetEnemyGrid()

		self.peakCon2.readyBtn:setVisible(true)
		self.peakCon2.cancelBtn:setVisible(false)

		local left = self:getLeftEnemyList()
		Network.sendMsg(PacketID.CG_PEAK_CTRL_ENEMY_CONFIRM, left)
	end
end

function onDelHero(self, evt, target)
	if evt.etype == Event.Touch_ended then
		if self.isSelecting and not self.isReady then
			if target.guanbi:isVisible() == false then
				local left = self:getLeftEnemyList()
				if #left <= Define.TEAM_HERO_SELECT then
					Common.showMsg('最多去除' .. Define.HERO_DEL_COUNT .. '个英雄')
					return
				end
				target.guanbi:setVisible(true)
			else
				target.guanbi:setVisible(false)
			end
		end
	end
end

function getLeftEnemyList(self)
	local tab = {}
	for _,grid in ipairs(self.enemyGridList) do
		if grid.guanbi:isVisible() == false then
			table.insert(tab, grid.heroName)
		end
	end
	return tab
end

function resetEnemyGrid(self)
	for _,grid in ipairs(self.enemyGridList) do
		grid.guanbi:setVisible(false)
	end
end

function refreshTeamGrid(self)
	local heroNameList = Data.getInstance():getHeroNameList()
	for i=1,Define.HERO_COUNT do
		local grid = self.heroGridList[i]
		local heroName = heroNameList[i] 
		if heroName then
			local hero = Hero.heroes[heroName]
			if hero then
				grid:setVisible(true)
				grid:setHero(hero)
			else
				grid:setVisible(false)
			end
		end
	end
end

function startSelect(self)
	self.selectStartTime = os.time()
	self.isSelecting = true
	self:refreshEnemyCon()
end

function refreshEnemyCon(self)
	UIManager.setUITop(false)
	self.peakCon1:setVisible(false)
	self.peakCon2:setVisible(true)
	self.isReady = nil
	self:resetEnemyGrid()
	self:refreshMyGridList()
	self:refreshEnemyGridList()
	self:refreshNameTxt()
end

function refreshMyGridList(self)
	local heroNameList = Data.getInstance():getHeroNameList()
	Common.printR(Data.getInstance():getSelectHeroList())
	for i=1,Define.HERO_COUNT do
		local grid = self.myGridList[i]
		local heroName = heroNameList[i] 
		if heroName then
			local hero = Hero.heroes[heroName]
			if hero then
				if Data.getInstance():getSelectHero(heroName) then
					grid.guanbi:setVisible(false)
				else
					grid.guanbi:setVisible(true)
				end
				grid:setVisible(true)
				grid:setHero(hero)
			else
				grid:setVisible(false)
			end
		else
			grid:setVisible(false)
		end
	end
end

function refreshEnemyGridList(self)
	local heroInfoList = Data.getInstance():getEnemyHeroInfo()
	local selLen = Common.GetTbNum(Data.getInstance():getSelectEnemyList())
	for i=1,Define.HERO_COUNT do
		local grid = self.enemyGridList[i]
		local info = heroInfoList[i]
		if info then
			if selLen <= Define.TEAM_HERO_SELECT then
				if Data.getInstance():getSelectEnemy(info.name) then
					grid.guanbi:setVisible(false)
				else
					grid.guanbi:setVisible(true)
				end
			end
			grid.heroName = info.name
			grid:setVisible(true)
			grid:setHero(info)
		else
			grid:setVisible(false)
		end
	end
end

function refreshNameTxt(self)
	local name = Data.getInstance():getEnemyName()
	self.peakCon2.enemyNameTxt:setString(name)

	self.peakCon2.myNameTxt:setString(Master.getInstance().name)
end

function refreshSelect(self)
	if self.isSelecting then
		local leftTime = PeakConfig.selectTime - (os.time() - self.selectStartTime)
		if leftTime > 0 then
			self.peakCon2.leftTimeTxt:setString(leftTime .. '秒')
		else
			self.isSelecting = false
			local left = self:getRandomNameList()
			Network.sendMsg(PacketID.CG_PEAK_CTRL_ENEMY_CONFIRM, left)
		end
	end
end

function getRandomNameList(self)
	local left = {}
	local heroInfoList = Data.getInstance():getEnemyHeroInfo()
	local copyList = Common.deepCopy(heroInfoList)
	for i=1,Define.TEAM_HERO_SELECT do
		local len = #copyList
		local index = math.random(1, len)
		local info = table.remove(copyList, index)
		table.insert(left, info.name)
	end
	return left
end

function refreshToNextUI(self)
	self.isSelecting = false
	self.peakCon2.readyBtn:setVisible(false)
	self.peakCon2.cancelBtn:setVisible(false)

	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(Define.SELECT_DEALY_TIME),
		cc.CallFunc:create(function()
			if not self.isFail then
				UIManager.addUI('src/modules/peak/ui/PeakFightUI')
			end
			self.isFail = nil
		end)
	))
end
