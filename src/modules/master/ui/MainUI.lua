module("MainUI", package.seeall)
setmetatable(MainUI, {__index = Control})
local Shop = require("src/modules/shop/Shop")
local ShopUI = require("src/modules/shop/ui/ShopUI")
local ShopDefine = require("src/modules/shop/ShopDefine")
local MasterDefine = require("src/modules/master/MasterDefine")
local WineLogic = require("src/modules/guild/wine/WineLogic")
local WineItemConfig = require("src/config/WineItemConfig").Config
local RechargeLogic = require("src/modules/recharge/RechargeLogic")
local NewOpenLogic = require("src/modules/newopen/NewOpenLogic")
local LvGiftLogic = require("src/modules/lvGift/LvGiftLogic")
local Activity = require('src/modules/activity/Activity')
local ActivityDefine = require("src/modules/activity/ActivityDefine")
local ThermaeData = require("src/modules/thermae/Data")
local ThermaeDefine = require("src/config/ThermaeDefineConfig").Defined
local ThermaeLogic = require("src/modules/thermae/ThermaeLogic")
local CrazyData = require("src/modules/crazy/Data")
local CrazyDefine = require("src/config/CrazyDefineConfig").Defined
local Logic = require("src/modules/task/TaskLogic")
local PeakLogic = require("src/modules/peak/PeakLogic")
local PublicDefine = require("src/modules/public/PublicDefine")
local PublicLogic = require("src/modules/public/PublicLogic")

--MainUI面板
local MainUIPanel = {
	["HeroList"]=1,
	["HeroInfo"]=1,
	["HeroLvUp"]=1,
	["PartnerChain"]=1,
	["PartnerCompose"]=1,
	["SkillHero"]=1,
	["SkillList"]=1,
	["Target"]=1,
	["Bag"]=1,
}

Instance = nil 

function new()
    local ctrl = Control.new(require("res/master/MainUISkin"),{"res/master/MainUI.plist"})
    setmetatable(ctrl,{__index = _M})
    ctrl:init()
    Instance = ctrl
    return ctrl
end

function addStage(self)
	self:setScale(Stage.uiScale)
	--[[
	if Master:getInstance().lv >= ThermaeDefine.level and not ThermaeLogic.getBathingHero() and ThermaeData.isOpen() then
		selectPanel(self, "src/modules/thermae/ui/ThermaeNotifyUI")
		--UIManager.addUI("src/modules/thermae/ui/ThermaeNotifyUI")
	end
	--]]
end

function init(self)
	--self:setContentSize(Stage.winSize)
	--self.up:marginCenter()
	self:addArmatureFrame("res/master/effect/MainVip.ExportJson")
	self:addArmatureFrame("res/lvGift/effect/LvGift.ExportJson")
	Common.setBtnAnimation(self.master.xips._ccnode,"MainVip","Animation1")
	self.mainBtn1.listbg:setVisible(false)
	self.forging:setVisible(false)
	--adjustMainPosY({self.up,self.master,self.right,self.folddown,self.activity,self.mystery,self.vipButton,self.flowerBtn,self.back,self.wine1,self.register,self.exercise,self.xshd,self.task})
	adjustMainPosY({self.up,self.master,self.right,self.folddown,self.back,self.wine1,self.mainBtn1,self.hongbao,self.crazy,self.hotwell,self.activity,self.lvGift,self.peak})
	self.uppos = {x=self.up:getPositionX(),y=self.up:getPositionY()}
	self.rightpos = {x=self.right:getPositionX(),y=self.right:getPositionY()}
	self.folddownpos = {x=self.folddown:getPositionX(),y=self.folddown:getPositionY()}
	self.foldScale = Stage.winSize.height/480/Stage.uiScale
	self:setBtnState()
	self.topCoin = {}
	self:start()
	self:openTimer()
	self:setWineTime()
	self:addEventListener(Event.Frame,onFrame,self)
end

function onFrame(self,event)
	self.hotwell:setVisible(ThermaeData.isOpen())
	self.hotwell.leftTime:setString(string.format("%02d:%02d",math.floor(ThermaeData.getLeftTime()/60),ThermaeData.getLeftTime()%60))
	if Master:getInstance().lv >= ThermaeDefine.level and not ThermaeLogic.getBathingHero() then
		self.thermaeEffect:setVisible(true)
	else
		self.thermaeEffect:setVisible(false)
	end

	self.crazy:setVisible(CrazyData.isOpen())
	local leftTime = CrazyDefine.lastTime - Common.getCronEventPassTime(CrazyDefine.startTimeId)
	self.crazy.leftTime:setString(string.format("%02d:%02d",math.floor(leftTime/60),leftTime%60))
	if Master:getInstance().lv >= CrazyDefine.level then
		self.crazyEffect:setVisible(true)
	else
		self.crazyEffect:setVisible(false)
	end

	local peakOpen = PeakLogic.isOpen()
	self.peak:setVisible(peakOpen)
	if peakOpen then
		local left = PeakLogic.getLeftTime()
		self.peak.leftTime:setString(string.format("%02d:%02d",math.floor(left/60),left%60))
		if Master:getInstance().lv >= PublicLogic.getOpenLv(PublicDefine.MODULE_PEAK) then
			self.peakEffect:setVisible(true)
		else
			self.peakEffect:setVisible(false)
		end
	end
end

function setBtnState(self,state)
	--local guildBtn = {self.back,self.hongbao}
	local guildBtn = {self.back}
	--local mainBtn = {self.master,self.activity,self.mystery,self.vipButton,self.flowerBtn,self.register,self.exercise,self.xshd,self.task}
	--lnl
	local mainBtn = {self.master,self.mainBtn1,self.crazy,self.hotwell,self.activity,self.lvGift}
	local flag = true
	if state == "guild" then
		flag = false
	end
	for k,v in pairs(mainBtn) do
		v:setVisible(flag)
	end
	for k,v in pairs(guildBtn) do
		v:setVisible(not flag)
	end
end

function adjustMainPosY(ctrls)
	for k,v in pairs(ctrls) do
		v:setPositionY(v:getPositionY() + Stage.uiBottom * 2 / Stage.uiScale)
	end
end

function onCheckHeroBtn(self,event,target)
	local heroIcon = Dot.check(self.right.rdown.yx,"checkHeroIcon")
	local partnerTeam = Dot.check(self.right.rdown.jb,"partnerTeam")
	local giftTeam = Dot.check(self.right.rdown.gift,"giftTeam")
	if heroIcon or partnerTeam or giftTeam then
		Dot.add(self.folddown)
	else
		Dot.remove(self.folddown)
	end
end

function onGoldPanel(self,event,target)
	if UIManager.getCurrentUI() then
		UIManager.addChildUI("src/modules/gold/ui/GoldUI")
	else
		local ui = UIManager.addUI("src/modules/gold/ui/GoldUI")
		ui:setPositionY(Stage.uiBottom)
	end
end

function start(self)
	self.wine1.timeLabel:setAnchorPoint(0.5,0)
	local d = 4
	self.wine1.timeLabel:enableShadow(d,-d)
	self.wine1.timeLabel:enableStroke(255,255,255,d)
	CommonGrid.bind(self.wine1,"tips")
	self.wine1:setVisible(false)
	--英雄
	self.right.rdown.yx:addEventListener(Event.Click, function (self,event,target)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_ACTIVE, step = 1})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_LV_UP, step = 1})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_POWER, step = 1})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_TRAIN, step = 1})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_EQUIP, step = 1})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_ACTIVE_SHOP, step = 1})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_GEM_QUICK, step = 1})
		selectPanel(self, "src/modules/hero/ui/HeroNormalListUI")
	end,self)
	Bag.getInstance():removeEventListener(Event.BagRefresh,onCheckHeroBtn)
	Bag.getInstance():addEventListener(Event.BagRefresh,onCheckHeroBtn,self)
	onCheckHeroBtn(self)
	--技能
	self.right.rdown.jn:addEventListener(Event.Click, function (self,event,target)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SKILL_STRENGTH, step = 1})

		selectPanel(self, "src/modules/skill/ui/SkillHeroUI")
	end,self)
	Dot.addNodeToCache(self.right.rdown.jn,DotDefine.DOT_C_SKILL)
	Dot.checkToCache(DotDefine.DOT_C_SKILL)
	--升级
	self.right.rdown.jb:addEventListener(Event.Click, function (self,event,target)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_PARTNER, step = 1})
		if PublicLogic.checkModuleOpen("partner") then
			selectPanel(self, "src/modules/partner/ui/PartnerHeroUI")
		end
	end,self)

	--背包
	self.right.rdown.bb:addEventListener(Event.Click, function(self,event)
		selectPanel(self, "src/modules/bag/ui/BagUI")
	end,self)

	-- 天赋
	self.right.rdown.gift:addEventListener(Event.Click,function(self,event)
		--selectPanel(self,"src/modules/gift/ui/GiftUI")
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_TALENT, step = 1})
		if Master:getInstance().lv < 16 then
			Common.showMsg("战队等级16级开放")
		else
			selectPanel(self, "src/modules/gift/ui/GiftHeroUI")
		end
	end,self)
	Dot.check(self.right.rdown.gift,"giftTeam")

	--任务
	self.mainBtn1.task:addEventListener(Event.Click, function(self,event) 
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_TASK, step = 1})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_ACHIEVE, step = 2})

		selectPanel(self, "src/modules/achieve/ui/TargetUI")
	end,self)
	if Logic:hasShowTimeTask() then 
		self.thermaeEffect = Common.setBtnAnimation(self.mainBtn1.task._ccnode,"LvGift","get",{x=0,y=12})
	else 
		self.mainBtn1.leftTime:setVisible(false)
		self.mainBtn1.shijianbg2:setVisible(false)
	end 
	Dot.addNodeToCache(self.mainBtn1.task, DotDefine.DOT_C_TARGET)
	Dot.checkToCache(DotDefine.DOT_C_TARGET)

	--离开
	self.back:addEventListener(Event.Click,function(self,evt)
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
		scene:addEventListener(Event.InitEnd, function()
			scene:setSceneRight()
		end)
	end,self)

	--主角
	self.master:addEventListener(Event.TouchEvent, function(self,event,target)
		if event.etype == Event.Touch_ended then
			selectPanel(self, "src/modules/master/ui/SettingUI")
		end
	end,self)
	self.master:adjustTouchBox(0,-36,-55,0)
	self.master:setTop()

	self.up:adjustTouchBox(10)
	self.up.vipBtn:addEventListener(Event.Click, function(self,event)
		local ui = UIManager.addUI("src/modules/vip/ui/VipUI")
		ui:showRecharge()
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_EIGHT, step = 6})
	end,self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.up.vipBtn, step = 6, groupId = GuideDefine.GUIDE_CHAPTER_EIGHT})
	self.up.addPhy:addEventListener(Event.Click, function(self,event)
		ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_PHY_ID)
	end,self)
	self.up.addMoney:addEventListener(Event.Click, onGoldPanel,self)
	self.up.addMoney:adjustTouchBox(20)
	self.up.vipBtn:adjustTouchBox(20)
	self.up.addPhy:adjustTouchBox(20)

	--活动
	self.activity:addEventListener(Event.Click,function(self,event)
		--selectPanel(self, "src/modules/activity/ui/ActivityUI")
		selectPanel(self, "src/modules/newopen/ui/NewOpenUI")
	end,self)
	self.activity:setVisible(false)
	self:addPhysicsTips()

	self.mainBtn1.exercise:addEventListener(Event.Click,function(self,event)
		selectPanel(self,"src/modules/activity/ui/Activity2UI")
	end,self)
	Dot.check(self.mainBtn1.exercise,"activityDot")

	--等级礼包
	self.lvGift:addEventListener(Event.Click,function(self,event)
		local nextRewardCfg = LvGiftLogic.getNextRewardCfg() 
		if nextRewardCfg then
			Activity.sendReward(ActivityDefine.LEVEL_ACT,nextRewardCfg.id)
		else
			local nextLvGiftCfg = LvGiftLogic.getNextLvGiftCfg(Master:getInstance().lv)
			if nextLvGiftCfg then
				selectPanel(self,"src/modules/lvGift/ui/LvGiftUI")
			end
		end
	end,self)
	LvGiftLogic.refreshStatus(self)

	--温泉
	self.hotwell:addEventListener(Event.Click,function(self,event)
		if ThermaeData.isOpen() then
			if Master:getInstance().lv < ThermaeDefine.level then
				Common.showMsg(ThermaeDefine.level .. "级开放")
			else
				selectPanel(self, "src/modules/thermae/ui/ThermaeUI")
			end
		end
	end,self)
	self.thermaeEffect = Common.setBtnAnimation(self.hotwell._ccnode,"LvGift","get",{x=0,y=12})
	--[[
	if Master:getInstance().lv >= ThermaeDefine.level and not ThermaeLogic.getBathingHero() then
	end
	--]]
	
	--疯狂之源
	self.crazy:addEventListener(Event.Click,function(self,event)
		if CrazyData.isOpen() then
			if Master:getInstance().lv < CrazyDefine.level then
				Common.showMsg(CrazyDefine.level .. "级开放")
			else
				selectPanel(self, "src/modules/crazy/ui/CrazyUI")
			end
		end
	end,self)
	self.crazyEffect = Common.setBtnAnimation(self.crazy._ccnode,"LvGift","get",{x=0,y=12})

	self.peak:addEventListener(Event.Click, function(self, event)
		if PeakLogic.isOpen() then
			if PublicLogic.checkModuleOpen(PublicDefine.MODULE_PEAK) then
				selectPanel(self, "src/modules/peak/ui/PeakUI")
			end
		end
	end,self)
	self.peakEffect = Common.setBtnAnimation(self.peak._ccnode,"LvGift","get",{x=0,y=12})
	

	--好友
	
	self.mainBtn2.friend:addEventListener(Event.Click,function(self,event)
		selectPanel(self, "src/modules/friends/ui/FriendsUI")
		--selectPanel(self, "src/modules/guild/boss/ui/GuildBossUI")
	end,self)
	Network.sendMsg(PacketID.CG_APPLY_LIST)
	--聊天
	self.mainBtn2.chat:addEventListener(Event.Click,function(self,event)
		local ChatUI = Stage.currentScene:getUI():getChild("Chat")
		ChatUI:doShow()
	end,self)

	--公会红包
	self.hongbao:addEventListener(Event.Click,function(self,event)
		selectPanel(self, "src/modules/guild/paper/ui/PaperUI")
	end,self)
	self.hongbao:setVisible(false)
	
	--self.mainBtn1.xshd:addEventListener(Event.Click,function(self,event)
	--	selectPanel(self,"src/modules/recharge/ui/RechargeUI")
	--end,self)
	--self.mainBtn1.xshd:setVisible(false)
	RechargeLogic.queryTime()
	NewOpenLogic.queryTime()

	--神秘商店
	--self.mystery:addEventListener(Event.Click,function(self,event)
	--	selectPanel(self,"src/modules/mystery/ui/MysteryShopUI")
	--end,self)
	--self.mystery:setVisible(false)

	--vip
	self.mainBtn1.vipButton:addEventListener(Event.Click, function(self,event)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_VIP_COPY, step = 2})
		selectPanel(self,"src/modules/vip/ui/VipUI")
	end,self)
	Dot.addNodeToCache(self.mainBtn1.vipButton, DotDefine.DOT_C_VIP)
	Dot.checkToCache(DotDefine.DOT_C_VIP)

	--签到
	self.mainBtn1.register:addEventListener(Event.Click, function(self,event)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SIGN_IN, step = 1})
		selectPanel(self,"src/modules/signIn/ui/SignInUI")
	end,self)
	Dot.check(self.mainBtn1.register,"signInRefresh")

	--鲜花
	self.mainBtn2.flowerBtn:addEventListener(Event.Click, function(self,event)
		local FlowerData = require("src/modules/flower/FlowerData")
		FlowerData.getInstance():setFlowerRefresh(false)
		Dot.checkToCache(DotDefine.DOT_C_FLOWER)
		selectPanel(self,"src/modules/flower/ui/FlowerPersonalUI")
	end,self)
	Dot.addNodeToCache(self.mainBtn2.flowerBtn, DotDefine.DOT_C_FLOWER)
	Dot.checkToCache(DotDefine.DOT_C_FLOWER)
	
	--聊天
	local chatUI = require("src/modules/chat/ui/ChatUI").new()
	chatUI:setPositionX(-chatUI:getContentSize().width + 200)
	self:addChild(chatUI)
	chatUI:setTop()
	self.chatUI = chatUI

	--头像vip
	self.vipLvTxt = cc.Label:createWithBMFont("res/common/SVipNum.fnt", "0")
	self.vipLvTxt:setAnchorPoint(cc.p(0, 0.5))
	self.vipLvTxt:setPosition(cc.p(self.master.xips.vipszi:getPositionX() + self.master.xips.vipszi:getContentSize().width - 3, self.master.xips.vipszi:getPositionY()))
	self.master.xips._ccnode:addChild(self.vipLvTxt)

	self.up.moneyLabel:setVisible(false)
	local moneyLabel = cc.LabelBMFont:create(tostring(0),  "res/master/charLv.fnt")
	moneyLabel:setPositionX(self.up.moneyLabel:getPositionX())
	moneyLabel:setPositionY(self.up.moneyLabel:getPositionY()+3)
	moneyLabel:setAnchorPoint(1,0.5)
	self.up._ccnode:addChild(moneyLabel)
	self.up.artMoney = moneyLabel

	self.up.rmbLabel:setVisible(false)
	local rmbLabel = cc.LabelBMFont:create(tostring(0),  "res/master/charLv.fnt")
	rmbLabel:setPositionX(self.up.rmbLabel:getPositionX())
	rmbLabel:setPositionY(self.up.rmbLabel:getPositionY()+3)
	rmbLabel:setAnchorPoint(1,0.5)
	self.up._ccnode:addChild(rmbLabel)
	self.up.artRmb = rmbLabel

	self.up.physicsLabel:setVisible(false)
	local phyLabel = cc.LabelBMFont:create(tostring(0),  "res/master/charLv.fnt")
	phyLabel:setPositionX(self.up.physicsLabel:getPositionX())
	phyLabel:setPositionY(self.up.physicsLabel:getPositionY()+3)
	phyLabel:setAnchorPoint(1,0.5)
	self.up._ccnode:addChild(phyLabel)
	self.up.artPhy = phyLabel
	--人物属性
	local master = Master.getInstance()
	master:removeEventListener(Event.MasterRefresh,setAttr)
	master:addEventListener(Event.MasterRefresh,setAttr,self)
	self:setAttr()
	
	--按钮适配
	self.btnList = {self.right.rdown.yx, self.right.rdown.jb, 
		self.right.rdown.jn, self.right.rdown.gift, self.right.rdown.bb}
	self.btnPosList1 = {}
	for _,btn in pairs(self.btnList) do
		local posX,posY = btn:getPosition()
		local pos = cc.p(posX, posY)
		table.insert(self.btnPosList1, pos)
	end
	--self.btnPosList = self.btnPosList1

	local offset = Stage.uiBottom*2
	for i=1,#self.btnList do
		local btn = self.btnList[i]
		btn:setPositionY(btn:getPositionY()-offset*(i-1)/5)
	end
	self.btnPosList2 = {}
	for _,btn in pairs(self.btnList) do
		local posX,posY = btn:getPosition()
		local pos = cc.p(posX, posY)
		table.insert(self.btnPosList2, pos)
	end
	self.btnPosList = self.btnPosList2

	self.right.yinying:setAnchorPoint(0, 1)
	self.right.yinying:setPositionY(self.right.yinying:getContentSize().height)
	self.right:adjustTouchBox(0,2*Stage.uiBottom,0,2*Stage.uiBottom)
	self.right.rdown:adjustTouchBox(0,2*Stage.uiBottom,0,2*Stage.uiBottom)

	--版本号
	self.verLabel:setString(Device.getFullVersion())

	self.right.foldup:addEventListener(Event.Click, onFoldMenuCb, self) 
	self.folddown:addEventListener(Event.Click, onFoldMenuCb, self) 
	self.right.foldup:adjustTouchBox(10) 
	self.folddown:adjustTouchBox(10)
	self.folddown:setVisible(true)
	self.right:setVisible(false)
end

function addPhysicsTips(self)
	self.up.physicsBg:adjustTouchBox(10)
	self.phyTips:changeParent(self.up)
	self.phyTips:setPosition(self.up.physicsBg:getPosition())
	self.phyTips:setAnchorPoint(1,1)
	self.phyTips:setVisible(false)
	local setTickLabel = function(tip,calFunc,p)
		tip:openTimer()
		tip:setString(Common.getDCTime(calFunc(p)))
		tip:addTimer(function(target) 
			target:setString(Common.getDCTime(calFunc(p)))
		end,1,-1)
	end
	setTickLabel(self.phyTips.tip2.rtime,Master.getLeftAddPhyTime,Master.getInstance())
	setTickLabel(self.phyTips.tip2.atime,Master.getResPhyTime,Master.getInstance())
	local tip = self.phyTips.tip2
	self.up.physicsBg:addEventListener(Event.TouchEvent,function(self,event)
		print("==========>",event.etype)
		if self.topCoin[3] and self.topCoin[3] ~= "phybig" then
			return
		end
		if event.etype == Event.Touch_began then
			self.phyTips:setVisible(true)
			local master = Master.getInstance()
			local buyCnt = Shop.getBuyCnt(ShopDefine.K_SHOP_VIRTUAL_PHY_ID)
			local phyCnt = string.format("%d/%d",buyCnt,buyCnt+Shop.getBuyCntLeft(ShopDefine.K_SHOP_VIRTUAL_PHY_ID))
			if master:isPhysicsFull() then
				self.phyTips.tip1:setVisible(true)
				self.phyTips.tip2:setVisible(false)
				self.phyTips.tip1.cnt:setString(phyCnt) 
			else
				self.phyTips.tip1:setVisible(false)
				self.phyTips.tip2:setVisible(true)
				local tip = self.phyTips.tip2
				tip.cnt:setString(phyCnt)
				tip.it:setString(string.format("%d分钟",MasterDefine.TIMER_ADD_PHYSICS/60))
			end
		elseif event.etype == Event.Touch_moved then
		else
			self.phyTips:setVisible(false)
		end
	end,self)
end

function loadSceneFinish(self)
	print("addMainUI ===================================================")
	local preFunction = function(keepLevelUI)
		if not keepLevelUI then
			UIManager.reset()
		end
		if self.right:isVisible() == false then
			self:onFoldMenu(true)	
		elseif self.isRolling then
			self.isRolling = nil
			self.right:setVisible(false)
			self:onFoldMenu(true)
			--Stage.currentScene:getUI():runAction(cc.Sequence:create(
			--	cc.DelayTime:create(0.2),
			--	cc.CallFunc:create(function()
			--		self:onFoldMenu(true)	
			--	end
			--)))
		end
	end
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.mainBtn1.vipButton, step = 2, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, filterLink = GuideDefine.FILTER_LINK, filterLink2 = GuideDefine.FILTER_CHAPTER_FIGHT_LINK, filterUI2 = GuideDefine.FILTER_CHAPTER_FIGHT_UI, filterUI = GuideDefine.FILTER_UI, checkFun = preFunction, addFinishFun = preFunction, groupId = GuideDefine.GUIDE_VIP_COPY})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.right.rdown.jn, step = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, filterLink = GuideDefine.FILTER_LINK, filterUI = GuideDefine.FILTER_UI, preFun = preFunction, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.right.rdown.yx, step = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, filterLink = GuideDefine.FILTER_LINK, filterUI = GuideDefine.FILTER_UI, preFun = preFunction, groupId = GuideDefine.GUIDE_POWER})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.right.rdown.yx, step = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, filterLink = GuideDefine.FILTER_LINK, filterLink2 = GuideDefine.FILTER_CHAPTER_FIGHT_LINK, filterUI = GuideDefine.FILTER_UI, filterUI = GuideDefine.FILTER_CHAPTER_FIGHT_UI, checkFun = preFunction, addFinishFun = preFunction, groupId = GuideDefine.GUIDE_GEM_QUICK})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.right.rdown.yx, step = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, filterLink = GuideDefine.FILTER_LINK, filterLink2 = GuideDefine.FILTER_CHAPTER_FIGHT_LINK, filterUI = GuideDefine.FILTER_UI, filterUI = GuideDefine.FILTER_CHAPTER_FIGHT_UI, checkFun = preFunction, addFinishFun = preFunction, groupId = GuideDefine.GUIDE_EQUIP})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.mainBtn1.task, step = 1, nextTime = 0.15, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, filterLink = GuideDefine.FILTER_LINK, filterUI = GuideDefine.FILTER_UI, preFun = function()
		UIManager.reset()
	end, groupId = GuideDefine.GUIDE_TASK})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.mainBtn1.task, step = 2, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, checkFun = function()
		UIManager.reset()
	end, groupId = GuideDefine.GUIDE_ACHIEVE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.mainBtn1.register, step = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, preFun = function()
		UIManager.reset()
	end, groupId = GuideDefine.GUIDE_SIGN_IN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.right.rdown.yx, step = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, filterLink = GuideDefine.FILTER_LINK, filterUI = GuideDefine.FILTER_UI, preFun = preFunction, groupId = GuideDefine.GUIDE_HERO_LV_UP})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.right.rdown.yx, step = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, filterLink = GuideDefine.FILTER_ARENA_LINK, filterUI = GuideDefine.FILTER_ARENA_UI, preFun = preFunction, groupId = GuideDefine.GUIDE_TRAIN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.right.rdown.yx, step = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, filterLink = GuideDefine.FILTER_ARENA_LINK, filterUI = GuideDefine.FILTER_ARENA_UI, preFun = preFunction, groupId = GuideDefine.GUIDE_HERO_ACTIVE_SHOP})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.right.rdown.gift, step = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, filterLink = GuideDefine.FILTER_LINK, filterUI = GuideDefine.FILTER_UI, delayTime = 0.3, preFun = function()
		preFunction()
		--local levelUI = require("src/modules/chapter/ui/LevelUI").Instance
		--if levelUI then
		--	levelUI:hideSettlementRewardUI()
		--	self:onFoldMenu(true)
		--end
		local panel = Stage.currentScene:getUI():getChild("Chapter")
		if panel then
			UIManager.removeUI(panel)
		end
	end, groupId = GuideDefine.GUIDE_TALENT})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.right.rdown.yx, step = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, filterLink = GuideDefine.FILTER_LINK, filterUI = GuideDefine.FILTER_UI, noDelayFun = function() 
		local Hero = require("src/modules/hero/Hero")
		if Hero.getHero('Chang') then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_JUMP, {groupId = GuideDefine.GUIDE_HERO_ACTIVE})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_START, {groupId = GuideDefine.GUIDE_HERO_ACTIVE_JUMP}) 
			GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, groupId = GuideDefine.GUIDE_HERO_ACTIVE_JUMP})
		end
	end, checkFun = preFunction, groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.right.rdown.jb, step = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, filterLink = GuideDefine.FILTER_LINK, filterUI = GuideDefine.FILTER_UI, noDelayFun = function() 
		--GuideManager.setGuide(true)
	end, preFun = preFunction, groupId = GuideDefine.GUIDE_PARTNER})
end

local icon2attr = {
	["moneybig"] = "money",
	["rmbbig"] = "rmb",
	["arenabig"] = "fame",
	["guildbig"] = "guildCoin",
	["tourbig"] = "tourCoin",
	["skillRage"] = "skillRage",
	["skillAssist"] = "skillAssist",
	["phybig"] = "physics",
	["exchangebig"] = "exchangeCoin",
	["peakbig"]	= "peakCoin",
}
local topCoinTb = {
	{"artMoney","addMoney", "moneybig"},
	{"artRmb","vipBtn","rmbbig"},
	{"artPhy","addPhy","phybig"},
}
function setAttr(self)
	local master = Master.getInstance()
	--头像
	local bodyBg = self.master.bodyBg
	CommonGrid.bind(bodyBg)
	bodyBg:setBodyIcon(master.bodyId)
	bodyBg._icon:setPosition(cc.p(50,55))
	bodyBg._icon:setScaleX(-1)

	self.master.lvLabel:setFontSize(20)
	self.master.lvLabel:setString(master.lv)

	self.master.nameLabel:setString(master.name)

	for index,v in ipairs(topCoinTb) do
		if not self.topCoin[index] then
			self.topCoin[index] = v[3]
		end
		self.up[v[2]]:setVisible(self.topCoin[index] == v[3])
		local name = icon2attr[self.topCoin[index]]
		if master[name] then
			self.up[v[1]]:setString(master[name])
		end
	end
	if self.topCoin[3] == "phybig" then
		self.up.artPhy:setString(string.format("%d/%d",master.physics,master:getMaxPhysics()))
	end

	self.vipLvTxt:setString(master.vipLv)	
end

function setCoin(self,mtype)
	--self.coinType = mtype
	self.topCoin[1] = mtype
	CommonGrid.setCoinIcon(self.up.jbicon,mtype or "moneybig")
	self:setAttr()
end

function setTopCoin(self,pos,coinName,val)
	self.topCoin[pos] = coinName
	self.isTopCoin = true
	pos = pos or 1
	local target,valLabel
	if pos == 1 then
		target = self.up.jbicon
		valLabel = self.up.artMoney
	elseif pos == 2 then
		target = self.up.zuanshiicon
		valLabel = self.up.artRmb
	elseif pos == 3 then
		target = self.up.tiliicon
		valLabel = self.up.artPhy
	end
	self.up[topCoinTb[pos][2]]:setVisible(self.topCoin[pos] == topCoinTb[pos][3])
	CommonGrid.setCoinIcon(target,coinName)
	valLabel:setString(val)
end

function resetTopCoin(self)
	self.topCoin = {}
	self:setCoin()
	CommonGrid.setCoinIcon(self.up.jbicon,"moneybig")
	CommonGrid.setCoinIcon(self.up.tiliicon,"phybig")
	CommonGrid.setCoinIcon(self.up.zuanshiicon,"rmbbig")
	self:setAttr()
end

function selectPanel(self, url,...)
	local ui = UIManager.getCurrentUI()
	UIManager.removeCurUIMask2("mask")
	if ui and MainUIPanel[ui.name] then
		UIManager.replaceUI(url,...)
	else
		UIManager.addUI(url,...)
	end
end

function setMainUITop(self,flag)
	local flag = flag or false
	if flag then
		self.up:setTop()
		self.folddown:setTop()
		self.right:setTop()
	else
		self.right:setVisible(flag)
	end
	self.up:setVisible(flag)
	self.uphide = not flag
	self.folddown:setVisible(flag)
	--UIManager.getCurrentUI().touchParent = false
end

function setMainUIPos(self,flag)
	local upPosY = self.uppos.y
	local rightPosY = self.rightpos.y
	local folddownY = self.folddownpos.y
	if flag then
		self.up:setPositionY(upPosY-Stage.uiBottom)
		self.right:setPositionY(rightPosY-Stage.uiBottom)
		self.folddown:setPositionY(folddownY-Stage.uiBottom)
		self.btnPosList = self.btnPosList1
	else
		self.up:setPositionY(upPosY)
		self.right:setPositionY(rightPosY)
		self.folddown:setPositionY(folddownY)
		self.btnPosList = self.btnPosList2
	end
end

function onFoldLabel(self)
	--ActionUI.joint({["up"] = {self.up}})
	--local moveTo
	--if self.uphide then
	--	moveTo = cc.MoveBy:create(0.2, cc.p(0,-50))
	--	self.uphide = false
	--else
	--	moveTo = cc.MoveBy:create(0.2, cc.p(0,50))
	--	self.uphide = true
	--end
	--local sineOut = cc.EaseSineOut:create(moveTo)
	--self.up:runAction(sineOut)
	if self.uphide then
		self.up:setVisible(true)
		self.uphide = false
	else
		self.up:setVisible(false)
		self.uphide = true
	end
end

function onFoldMenuCb(self,event,target)
	self:onFoldMenu()
end

function onFoldMenu(self,quick)
	local posX,posY = self.right.foldup:getPosition()
	local pos = cc.p(posX, posY)
	local decGap = 50
	local incGap = -10
	local allTime = 0.15
	local timeGap = 0.03
	if self.right:isVisible() then
		if self.isRolling == nil then
			self.isRolling = true
			--收缩
			UIManager.removeCurUIMask2("mask")
			if quick then
				self.isRolling = nil
				self.right:setVisible(false)
			else
				local co = nil
				co = coroutine.create(function()
					for i=#self.btnList,1,-1 do
						local btn = self.btnList[i]
						btn._ccnode:setCascadeOpacityEnabled(true)
						btn._ccnode:setOpacity(255)
						btn:setPosition(self.btnPosList[i].x, self.btnPosList[i].y)
						local targetPos = nil
						if i == 1 then
							targetPos = cc.p(pos.x, pos.y - decGap)
						else
							targetPos = self.btnPosList[i - 1]
						end
						btn:stopAllActions()
						btn:runAction(cc.Sequence:create({
							cc.Spawn:create(
							cc.MoveTo:create(timeGap, cc.p(targetPos.x, targetPos.y)), 
							cc.FadeOut:create(timeGap)
							),
							cc.CallFunc:create(function()
								btn:setVisible(false)
								if i > 1 then
									coroutine.resume(co)
								else
									self.isRolling = nil
								end
							end
							)
						}))
						coroutine.yield()
					end
				end
				)
				coroutine.resume(co)
				self.right.yinying:stopAllActions()
				self.right.yinying:runAction(cc.Sequence:create({
					cc.ScaleTo:create(allTime, 1, 0), 
					cc.CallFunc:create(function()
						self.right:setVisible(false)
					end
					)
				}))
			end
		end
	else
		if self.isRolling == nil then
			self.isRolling = true
			--伸展
			UIManager.addCurUIMask("mask")
			self.right:setVisible(true)
			if quick then
				self.isRolling = nil
				for i=#self.btnList,1,-1 do
					local btn = self.btnList[i]
					btn:stopAllActions()
					btn:setPosition(self.btnPosList[i].x, self.btnPosList[i].y)
					btn:setVisible(true)
					btn._ccnode:setCascadeOpacityEnabled(true)
					btn._ccnode:setOpacity(255)
				end
				self.right.yinying:stopAllActions()
				self.right.yinying:setScaleY(self.foldScale)
			else
				for i,btn in ipairs(self.btnList) do
					btn:setVisible(true)
					btn._ccnode:setCascadeOpacityEnabled(true)
					btn._ccnode:setOpacity(0)

					btn:stopAllActions()
					btn:setPosition(pos.x, pos.y - decGap)
					btn:runAction(cc.Sequence:create({
						cc.Spawn:create(
						cc.MoveTo:create(allTime, cc.p(self.btnPosList[i].x, self.btnPosList[i].y + incGap * i)),
						cc.FadeIn:create(allTime)
						),
						cc.MoveTo:create(0.1, self.btnPosList[i]),
						cc.CallFunc:create(function()
							self.isRolling = nil
						end),
					}))
				end

				self.right.yinying:setScaleY(0)
				self.right.yinying:stopAllActions()
				self.right.yinying:runAction(cc.Sequence:create({
					cc.ScaleTo:create(allTime, 1, self.foldScale)
				}))
			end
		end
	end
end

function setWineTime(self)
	local data = WineLogic.getData()
	if #data > 0 then
		local start = data[#data].time
		local id = data[#data].id
		local lastTime = WineItemConfig[id].last
		local leftTime = lastTime - (os.time() - start)
		if leftTime > 0 then
			self.wineTime = leftTime
			local function onCDTime(self,event)
				self.wineTime = self.wineTime - 1
				if self.wineTime > 0 then
					local leftShow = Common.getDCTime(self.wineTime)
					self.wine1.timeLabel:setString(leftShow)
				else
					if self.wineTimer then
						self:delTimer(self.wineTimer)
						self.wineTimer = nil
					end
				end
			end
			if self.wineTimer then
				self:delTimer(self.wineTimer)
			end
			self.wineTimer = self:addTimer(onCDTime, 1, leftTime, self)
			self.wine1:setVisible(true)
			self.wine1._id = id
			onCDTime(self)
		else
			self.wine1:setVisible(false)
		end
	else
		self.wine1:setVisible(false)
	end
end

function clear(self)
	Master.getInstance():removeEventListener(Event.MasterRefresh,setAttr)
	Bag.getInstance():removeEventListener(Event.BagRefresh,onCheckHeroBtn)
	Control.clear(self)
	Instance = nil
	Dot.clearNodeToCache(DotDefine.DOT_C_TARGET)
	Dot.clearNodeToCache(DotDefine.DOT_C_FLOWER)
	
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_ACHIEVE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 1, groupId = GuideDefine.GUIDE_GEM_QUICK})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 1, groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 1, groupId = GuideDefine.GUIDE_HERO_LV_UP})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 1, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 1, groupId = GuideDefine.GUIDE_POWER})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 1, groupId = GuideDefine.GUIDE_TASK})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 1, groupId = GuideDefine.GUIDE_PARTNER})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 1, groupId = GuideDefine.GUIDE_EQUIP})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 6, groupId = GuideDefine.GUIDE_CHAPTER_EIGHT})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_VIP_COPY})
end


return MainUI
