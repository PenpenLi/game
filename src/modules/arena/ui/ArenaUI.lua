module(..., package.seeall)
setmetatable(_M, {__index = Control})
local ArenaData = require("src/modules/arena/ArenaData")
local ArenaDefine = require("src/modules/arena/ArenaDefine")
local Hero = require("src/modules/hero/Hero")
local ArenaConstConfig = require("src/config/ArenaConstConfig").Config
local ShopDefine = require("src/modules/shop/ShopDefine")
local ShopUI = require("src/modules/shop/ui/ShopUI")
local FlowerDefine = require("src/modules/flower/FlowerDefine")
local HeroGridS = require("src/ui/HeroGridS")

function new()
	local ctrl = Control.new(require("res/arena/ArenaSkin"),{"res/arena/Arena.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:addSpriteFrames("res/master/Body.plist")
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_LABEL
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 3, groupId = GuideDefine.GUIDE_ARENA})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 5, groupId = GuideDefine.GUIDE_ARENA})
end

function onClose(self,event,target)
	UIManager.removeUI(self)
end

function init(self)
	self.back:addEventListener(Event.Click,onClose,self)
	function onFightRecord(self,event,target)
		UIManager.addChildUI("src/modules/arena/ui/FightRecordUI")
		Network.sendMsg(PacketID.CG_ARENA_FIGHT_RECORD)
	end
	self.tiaozhan.down.dzj:addEventListener(Event.Click,onFightRecord,self)

	function onRule(self,event,target)
		local ui = UIManager.addChildUI("src/ui/RuleScrollUI")
		ui:setId(RuleScrollUI.Arena)
	end
	self.tiaozhan.down.gzsm:addEventListener(Event.Click,onRule,self)
	function onChangeTeam(self,event,target)
		--local ChangeTeamUI = require("src/modules/arena/ui/ChangeTeamUI").new()
		--self:addChild(ChangeTeamUI)	
		UIManager.addChildUI("src/modules/arena/ui/ChangeTeamUI")
	end
	function onChangeEnemy(self,event,target)
		Network.sendMsg(PacketID.CG_ARENA_CHANGE_ENEMY)
	end
	function onArenaShop(self,event,target)
		UIManager.addChildUI("src/modules/arena/ui/ArenaShopUI")
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_ARENA, step = 4})
	end
	function onResetCD(self,event,target)
		Network.sendMsg(PacketID.CG_ARENA_RESET_CD)
	end
	function onAddCnt(self,event,target)
		ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_ARENA_ID)
	end
	self.zhenrong.tzzr:addEventListener(Event.Click,onChangeTeam,self)
	self.tiaozhan.hyp:addEventListener(Event.Click,onChangeEnemy,self)
	self.tiaozhan.reset:addEventListener(Event.Click,onResetCD,self)
	self.tiaozhan.down.addCnt:addEventListener(Event.Click,onAddCnt,self)
	self.tiaozhan.down.addCnt:setVisible(false)
	self.tiaozhan.hyp:setVisible(false)
	self.tiaozhan.reset:setVisible(false)
	CommonGrid.setCoinIcon(self.tiaozhan.jf.jfbicon,"rmb")
	self.tiaozhan.jf:setVisible(false)
	self.tiaozhan.down.dhjl:addEventListener(Event.Click,onArenaShop,self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.tiaozhan.down.dhjl, step = 4, groupId = GuideDefine.GUIDE_ARENA})
	function onRank(self,event,target)
		UIManager.addUI("src/modules/rank/ui/RankUI")
	end
	self.tiaozhan.down.phb:addEventListener(Event.Click,onRank,self)

	function onRec(self,event,target)
		local conf = ArenaConstConfig[1]
		local ui = UIManager.addChildUI("src/ui/HeroRec2UI")
		ui:setRec(conf.recType,conf.recDesc,conf.recHero)
	end
	self.tiaozhan.rec:addEventListener(Event.Click,onRec,self)
	self:addArmatureFrame("res/common/effect/heroRec/HeroRec.ExportJson")
	Common.setBtnAnimation(self.tiaozhan.rec._ccnode,"HeroRec","1",{x=-52,y=7})

	function onEnemyInfo(self,event,target)
		if event.etype == Event.Touch_ended then
			local arenaData = ArenaData.getArenaData()
			local enemy = arenaData.enemyList[target.tiaozhan.id]
			local ui = UIManager.addChildUI("src/ui/TeamTipsUI")
			ui:refreshInfo(enemy, FlowerDefine.FLOWER_FROM_TYPE_ARENA)
		end
	end
	function onChallenge(self,event,target)
		Network.sendMsg(PacketID.CG_ARENA_FIGHT_BEGIN,target.id)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_ARENA, step = 2})
	end
	local herolist = self.zhenrong.chuzhanlist
	for i = 1,4 do
		herolist["yx"..i].heroGrid = HeroGridS.new(herolist["yx"..i].headBG,i)
		herolist["yx"..i].heroGrid:setVisible(false)
		herolist["yx"..i].txtshuzi:setVisible(false)
		herolist["yx"..i].lvbg:setVisible(false)
	end
	local list = self.tiaozhan.tiaozhanlist
	for i = 1,3 do
		list["tzlist"..i].tiaozhan.id = i
		list["tzlist"..i]:addEventListener(Event.TouchEvent,onEnemyInfo,self)
		list["tzlist"..i].tiaozhan.touchParent = false
		list["tzlist"..i].tiaozhan:addEventListener(Event.Click,onChallenge,self)
		list["tzlist"..i]:setVisible(false)
		CommonGrid.bind(list["tzlist"..i].lheadBG)
		if i == 3 then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=list["tzlist"..i].tiaozhan, step = 2, delayTime = 0.3, groupId = GuideDefine.GUIDE_ARENA})
		end
	end

	self.tiaozhan.txtsj:setVisible(false)
	self.tiaozhan.txtsjj:setVisible(false)
	self.tiaozhan.down.lv2:setVisible(false)
	--self.tiaozhan.down.rank = cc.LabelBMFont:create("",  "res/arena/arenanum.fnt")
	--self.tiaozhan.down.rank:setAnchorPoint(0,0)
	--self.tiaozhan.down._ccnode:addChild(self.tiaozhan.down.rank)
	--self.tiaozhan.down.rank:setPosition(self.tiaozhan.down.lv2:getPosition())
	--self.tiaozhan.down.rank:setString('0')
	self.tiaozhan.down.rank = cc.LabelAtlas:_create("0123456789", "res/arena/ranknum.png", 22, 27, string.byte('0'))
	self.tiaozhan.down.rank:setAnchorPoint(0,0)
	self.tiaozhan.down._ccnode:addChild(self.tiaozhan.down.rank)
	self.tiaozhan.down.rank:setPosition(self.tiaozhan.down.lv2:getPosition())
	self.tiaozhan.down.rank:setString('0')

	self:openTimer()

	Shop.cntQuery({ShopDefine.K_SHOP_VIRTUAL_ARENA_ID})
	Network.sendMsg(PacketID.CG_ARENA_QUERY)
	WaittingUI.create(PacketID.GC_ARENA_QUERY)
end

function refreshArena(self)
	self:refreshHeroList()
	self:refreshEnemyList()
	local arenaData = ArenaData.getArenaData()
	self.tiaozhan.txtsj:setVisible(true)
	self.tiaozhan.txtsj:setString(arenaData.leftTimes .. "/" .. arenaData.maxTimes)
	if arenaData.leftTimes <= 0 then
		self.tiaozhan.down.addCnt:setVisible(true)
	else
		self.tiaozhan.down.addCnt:setVisible(false)
	end
	self.tiaozhan.txtsjj:setVisible(true)
	if self.cdTimer then
		self:delTimer(self.cdTimer)
		self.cdTimer = nil
	end
	if arenaData.nextTime > 0 then
		self.leftTime = arenaData.nextTime
		function onCDTime(self,event)
			self.leftTime = self.leftTime - 1
			if self.leftTime <= 0 then
				self.tiaozhan.hyp:setVisible(true)
				self.tiaozhan.reset:setVisible(false)
				self.tiaozhan.jf:setVisible(false)
			end
			setCDTime(self,self.leftTime)
		end
		self.tiaozhan.hyp:setVisible(false)
		self.tiaozhan.reset:setVisible(true)
		self.tiaozhan.jf:setVisible(true)
		self:setCDTime(arenaData.nextTime)
		if not self.cdTimer then
			self.cdTimer = self:addTimer(onCDTime, 1, arenaData.nextTime, self)
		end
	else
		self.tiaozhan.hyp:setVisible(true)
		self.tiaozhan.reset:setVisible(false)
		self.tiaozhan.jf:setVisible(false)
		self:setCDTime(arenaData.nextTime)
	end
	self.tiaozhan.down.rank:setString(tostring(arenaData.rank))
	local cost = ArenaConstConfig[1].cost
	self.tiaozhan.jf.txtjf:setString(cost)
end

function setCDTime(self,time)
	local timeShow = Common.getDCTime(time)
	self.tiaozhan.txtsjj:setString(timeShow)
end
	
function clear(self)
	Control.clear(self)
	if self.cdTimer then
		self:delTimer(self.cdTimer)
		self.cdTimer = nil
	end
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_ARENA})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 4, groupId = GuideDefine.GUIDE_ARENA})
end

function refreshHeroList(self)
	local list = self.zhenrong.chuzhanlist
	local arenaData = ArenaData.getArenaData()
	for i = 1,4 do
		local heroName = arenaData.fightList[i].name
		local hero = Hero.heroes[heroName]
		if hero then
			list["yx"..i].heroGrid:setVisible(true)
			list["yx"..i].heroGrid:setHero(hero)
		else
			list["yx"..i].heroGrid:setVisible(false)
		end
		--local grid = list["yx"..i].headBG
		--local heroName = arenaData.fightList[i].name
		--grid:setHeroIcon(heroName)
		--local hero = Hero.heroes[heroName]
		--if hero then
		--	list["yx"..i].txtshuzi:setString(hero.lv)
		--end
	end
	local fightval = self:getAllFight()
	self.zhenrong.txtzdlsz:setString(fightval)
end

function getAllFight(self)
	local power = 0
	local fightList = ArenaData.getArenaData().fightList
	--不算援助战力
	for i = 1,#fightList do
		if fightList[i].pos ~= 4 then
			local heroName = fightList[i].name
			local hero = Hero.heroes[heroName]
			if hero then
				power = power + hero:getFight()
			end
		end
	end
	return power
end

function refreshEnemyList(self)
	local list = self.tiaozhan.tiaozhanlist
	local arenaData = ArenaData.getArenaData()
	local enemyList = arenaData.enemyList
	for i = 1,#enemyList do
		local enemy = enemyList[i]
		list["tzlist"..i]:setVisible(true)
		list["tzlist"..i].txtsz:setString(enemy.rank)
		list["tzlist"..i].txtszz:setString(enemy.fightVal)
		list["tzlist"..i].txtmz:setString(enemy.name)
		list["tzlist"..i].lheadBG:setBodyIcon(enemy.icon)
	end
end
