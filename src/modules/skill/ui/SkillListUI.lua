module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Hero = require("src/modules/hero/Hero")
local FightHeroDefine = require("src/modules/fight/Define")
local HeroDefine = require("src/modules/hero/HeroDefine")
local BagData = require("src/modules/bag/BagData")

local SkillLogic = require("src/modules/skill/SkillLogic")
local SkillConfig = require("src/config/SkillConfig").Config
local SkillGroupConfig = require("src/config/SkillGroupConfig").Config
local SkillExpConfig = require("src/config/SkillExpConfig").Config
local Define = require("src/modules/skill/SkillDefine")
local SkillFighter = require("src/modules/skill/ui/SkillFighter")
local SkillUpConfig = require("src/config/SkillUpConfig").Config

Instance = nil


TabId2Type={"normal","rage","assist"}
function new(heroName,tabType)
	local ctrl = Control.new(require("res/skill/SkillListSkin"),{"res/skill/SkillList.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl.heroName = heroName
	if type(tabType) == 'number' then tabType = TabId2Type[tabType] end
	ctrl.tabType = tabType or "normal"
	ctrl:init(heroName)
	Instance = ctrl
	return ctrl
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 3, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 7, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 13, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
end

function uiEffect()
	return UIManager.FIRST_TEMP
end

function init(self)
	self.master = Master.getInstance()
	self.channel:addEventListener(Event.Change, function(self,event,target) self:selectChannel(event.target.name) end, self)
	self.back:addEventListener(Event.Click,onBack,self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.back, step = 14, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
	--强化大师
	self.upgrade:addEventListener(Event.Click,function() 
		UIManager.addChildUI("src/modules/skill/ui/SkillMaster",self.heroName) 
	end,self)
	--更换技能
	self.change:addEventListener(Event.Click,function() 
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SKILL_STRENGTH, step = 8})
		UIManager.addChildUI("src/modules/skill/ui/SkillEquipUI",self.heroName,self.tabType,self) 
	end,self)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.change, step = 8, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})

	self:addAnimation()
	self:addHyperLink()
	self:initShowLayer()
	self:initTopCoin()
	--self:initNormal()
	--self:initRage()
	--self:initAssist()
	self:refresh(self.heroName)
	self:selectChannel()

	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.normal.skill1.upgrade, step = 4, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.normal.skill2.upgrade, step = 5, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.normal.skill3.upgrade, step = 6, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})

	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.normal.skill3.upgrade, step = 12, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
end

function addAnimation(self)
	self:addArmatureFrame("res/skill/upgrade/Upgrade.ExportJson")
	local upAnimation = ccs.Armature:create('Upgrade')
	upAnimation:getAnimation():play("Animation1",-1,-1)
	upAnimation:setAnchorPoint(0,0)
	upAnimation:setPosition(0,0)
	self.upgrade.setState = function() end
	self.upgrade._ccnode:addChild(upAnimation)
	self:addArmatureFrame("res/skill/change/Change.ExportJson")
	local changeAnimation = ccs.Armature:create('Change')
	changeAnimation:setAnchorPoint(0,0)
	changeAnimation:setPosition(0,-23)
	self.changeAnimation = changeAnimation
	self.change.setState = function() end
	self.change._ccnode:addChild(changeAnimation,99)
end

--技能展示
function initShowLayer(self)
	local back = LayerColor.new("showbackgroud",0,0,0,200,Stage.width,Stage.height)
	back:setPositionY(-Stage.uiBottom)
	self:addChild(back)
	self.showLayer = back
	self:addEventListener(Event.TouchEvent,function(self,event,target) 
		if target.alive and event.etype == Event.Touch_ended then
			--UIManager.setUITop(true)
			self.showLayer:setVisible(false)
			if self.fighter then
				self.fighter:setVisible(false)
			end
		end
	end,self)
	self.showLayer:setVisible(false)
end

function onBack(self,event)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SKILL_STRENGTH, step = 14})
	UIManager.removeUI(self)
end

function refresh(self,heroName)
	self.heroName = heroName
	self.hero = Hero.getHero(heroName)
	self.groupBoxList = {}
	if self.fighter then
		self.fighter:remove()
		self.fighter = nil
	end
	--self["select" .. self.tabType:upper()]()
	self.wanfa:setString(HeroDefine.HERO_WANFA[HeroDefine.DefineConfig[self.heroName].wanfa])
	self:selectChannel()
	self:selectNomal()
	self:selectRage()
	self:selectAssist()
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	--dot
	Dot.check(self.channel.normal,"skill",self.hero,Define.CTYPE_NORMAL)
	Dot.check(self.channel.rage,"skill",self.hero,Define.CTYPE_RAGE)
	Dot.check(self.channel.assist,"skill",self.hero,Define.CTYPE_ASSIST)
end

function selectChannel(self,cname)
	self.tabType = cname or self.tabType
	cname = self.tabType
	for _,v in pairs(TabId2Type) do
		self[v]:setVisible(false)
	end
	self[cname]:setVisible(true)
	self.channel[cname]:setSelected(true)
	--
	self.upgrade:setVisible(false)
	--self.change:setVisible(false)
	local coinList = {
		{name = "moneybig",val=self.master.money,canAdd=true},
		{name = "rmbbig",val=self.master.rmb,canAdd=true},
		{name = "skillItem" .. tostring(self.hero.career),val=BagData.getItemNumByItemId(Define.Career2Item[self.hero.career])},
		{name = "skillItem6",val=BagData.getItemNumByItemId(Define.Career2Item[6])},
	}
	if self.tabType == "normal" then
		self.ctype = Define.CTYPE_NORMAL
		self.upgrade:setVisible(true)
		--self.change:setVisible(true)
		self.changeAnimation:getAnimation():play("更换招数",-1,-1)
	elseif self.tabType == "rage" then
		self.ctype = Define.CTYPE_RAGE
		--self.change:setVisible(true)
		self.changeAnimation:getAnimation():play("更换怒技",-1,-1)
		coinList[2] = {name = "skillRage",val=self.master.skillRage}
	elseif self.tabType == "assist" then
		self.ctype = Define.CTYPE_ASSIST
		self.changeAnimation:getAnimation():play("更换援助",-1,-1)
		coinList[2] = {name = "skillAssist",val=self.master.skillAssist}
	end
	if SkillLogic.checkCanOpenSkill(self.hero,self.ctype) then
		self.changeAnimation:getAnimation():resume()
	else
		self.changeAnimation:getAnimation():pause()
	end
	--dot
	Dot.check(self.change,"skill",self.hero,self.ctype)
	--
	self:setTopCoin(coinList)
end

function setSkillBox(self,box,groupId)
	box.skillBg.groupId = groupId
	if not box.skillBg:hasEventListener(Event.TouchEvent,preview) then
		box.skillBg:addEventListener(Event.TouchEvent,preview,self)
		box.skillBg.touchParent = false
	end
	box.preview.groupId = groupId
	if not box.preview:hasEventListener(Event.TouchEvent,preview) then
		box.preview:addEventListener(Event.TouchEvent,preview,self)
		box.preview.touchParent = false
	end
	box.upgrade.groupId = groupId
	if not box.skillBg._icon then
		CommonGrid.bind(box.skillBg)
	end
	box.skillBg:setSkillGroupIcon(groupId,65)
end

--招数
function selectNomal(self)
	local block = self.normal
	block.heroName:setString(string.format("%s Lv.%d",self.hero.cname,self.hero.lv))
	local groupList = SkillLogic.getGroupListByCtype(self.hero,Define.CTYPE_NORMAL,true)
	for i=1,3 do
		local box = block["skill" .. i]
		local group = groupList[i]
		if not group then break end
		local conf = SkillGroupConfig[group.groupId]
		self.groupBoxList[group.groupId] = box
		if not box.upgrade:hasEventListener(Event.TouchEvent,onUpgrade) then
			box.upgrade.tip = 'skill' .. i
			box.upgrade:addEventListener(Event.TouchEvent,onUpgrade,self)
			local rich = Common.createRichText(box.effectLabel,15,{150,53,0})
			box.effectLabel = rich
		end
		self:setSkillBox(box,group.groupId)
		box.oppo:setState(tostring(conf.career))	--克制属性图标
		local labelTb = {
			skillNameLabel = {group.name},
			lvLabel = {"Lv" .. group.lv},	--等级
			hurt = {group:getAtk()},	--伤害
			oppoNameLabel = {HeroDefine.CAREER_NAMES[conf.career]},	--克制属性
			effectLabel = {group:getEffectDesc()},	--效果
			--oppoLabel = {group:getOppo()},	--克制提升
			moneyLabel = {group:getUpgradeCost()},	--金币消耗
		}
		for k,v in pairs(labelTb) do
			box[k]:setString(string.format("%s",v[1]))
		end
		self:setSkillStar(box,conf.star)
		--消耗道具
		self:setSkillUpCost(box,group)
		--克制效果
		local tb = {"order","oppoNameLabel","oppo","attack","effectLabel"}
		if group:getIsOpenOppo() then
			for _,v in pairs(tb) do box[v]:setVisible(true) end
			box.lockDesc:setVisible(false)
		else
			for _,v in pairs(tb) do box[v]:setVisible(false) end
			box.lockDesc:setVisible(true)
		end
	end
end

--怒气
local RageCTypeMap = {[Define.TYPE_FINAL]="final",[Define.TYPE_COMBO]="combo",[Define.TYPE_BROKE]="broke"}
function selectRage(self)
	local block = self.rage
	block.heroName:setString(string.format("%s Lv.%d",self.hero.cname,self.hero.lv))
	local groupList = SkillLogic.getGroupListByCtype(self.hero,Define.CTYPE_RAGE,true)
	for i=1,3 do
		local group = groupList[i]
		if not group then
			break
		end
		local box = block[RageCTypeMap[group.type]]
		local conf = SkillGroupConfig[group.groupId]
		self.groupBoxList[group.groupId] = box
		if not box.upgrade:hasEventListener(Event.TouchEvent,onUpgrade) then
			box.upgrade:addEventListener(Event.TouchEvent,onUpgrade,self)
		end
		local labelTb = {
			skillNameLabel = {group.name},
			lvLabel = {"Lv" .. group.lv},	--等级
			hitLabel = {group:getAtk()},	--伤害
			hitLabel2 = {group:getAtk()},	--伤害
			rageLabel = {group:getUpgradeCost()},	--金币消耗
		}
		for k,v in pairs(labelTb) do
			box[k]:setString(string.format("%s",v[1]))
		end
		self:setSkillBox(box,group.groupId)
		self:setSkillStar(box,conf.star)
		--消耗道具
		self:setSkillUpCost(box,group)
	end
end

--援助
local AssistCTypeMap = {[Define.TYPE_FINAL]="final",[Define.TYPE_COMBO]="combo",[Define.TYPE_BROKE]="broke"}
function selectAssist(self)
	local block = self.assist
	block.heroName:setString(string.format("%s Lv.%d",self.hero.cname,self.hero.lv))
	--技能
	local doRender = function(box,group)
		local conf = SkillGroupConfig[group.groupId]
		self.groupBoxList[group.groupId] = box
		if not box.upgrade:hasEventListener(Event.TouchEvent,onUpgrade) then
			box.upgrade:addEventListener(Event.TouchEvent,onUpgrade,self)
			local rich = Common.createRichText(box.effectLabel,15,{150,53,0})
			box.effectLabel = rich
			--Common.setLabelCenter(box.effectLabel,"left")
			if box.lockDesc then Common.setLabelCenter(box.lockDesc) end
		end
		box.upgrade.groupId = group.groupId
		local labelTb = {
			skillNameLabel = {group.name},
			lvLabel = {"Lv" .. group.lv},	--等级
			--assistValLabel = {group:getAssistVal()},	--提升
			effectLabel = {group:getEffectDesc()},	--效果
			moneyLabel = {group:getUpgradeCost()},	--援助点消耗
		}
		for k,v in pairs(labelTb) do
			box[k]:setString(string.format("%s",v[1]))
		end
		self:setSkillStar(box,conf.star)
		--box.effectLabel:setPositionY(box.effectLabel._skin.y-box.effectLabel:getContentSize().height+16)
		--if conf.needStar > self.hero.quality then
		if not group:getIsOpen() then
			--星级限定
			if box.lockDesc then 
				box.lockDesc:setVisible(true)
				box.lockDesc:setString(string.format("需要英雄%d星激活",conf.needStar)) 
			end
			if box.jbbicon then box.jbbicon:setVisible(false) end
			box.moneyLabel:setVisible(false)
			box.upgrade:setVisible(false)
			box.txtxiaoguo:setVisible(false)
			box.effectLabel:setVisible(false)
		else
			if box.lockDesc then box.lockDesc:setVisible(false) end
			if box.jbbicon then box.jbbicon:setVisible(true) end
			box.moneyLabel:setVisible(true)
			box.upgrade:setVisible(true)
			box.txtxiaoguo:setVisible(true)
			box.effectLabel:setVisible(true)
		end
		return box
	end
	--主动技
	local attackGroup = SkillLogic.getSkillGroup(self.hero,Define.TYPE_ASSIST)
	if attackGroup then
		local box = doRender(self.assist.zhudong,attackGroup)
		self:setSkillBox(box,attackGroup.groupId)
		--消耗道具
		self:setSkillUpCost(box,attackGroup)
	end
	--被动技
	local groupList = SkillLogic.getGroupListByType(self.hero,Define.TYPE_ASSISTR)
	local block = self.assist.beidong
	for i=1,3 do
		local group = groupList[i]
		if not group then
			break
		end
		local box = block["skill" .. i]
		doRender(box,group)
	end
end

function setSkillStar(self,box,num)
	for i=1,5 do
		if i > num then
			box.star["star" .. i]:setVisible(false)
		else
			box.star["star" .. i]:setVisible(true)
		end
	end
end

--消耗道具
function setSkillUpCost(self,box,group)
	local pos = {{80,110},{107,132}}
	local p = pos[1]
	for itemId,itemType in pairs(group:getConf().upItem) do
		local num = SkillUpConfig[group.lv]["upItem" .. itemType] or 0
		if num > 0 then
			p = pos[2]
		end
		box.item1.itemIcon:setVisible(num>0)
		box.item1.itemNumLabel:setVisible(num>0)
		box.item1.itemIcon:setState(tostring(Define.Item2Career[itemId]))
		box.item1.itemNumLabel:setString(num)
	end
	local targetLabel = box.moneyLabel or box.rageLabel
	local targetCoin = box.coinMoney or box.coinRage or box.coinAssist
	targetCoin:setPositionX(p[1])
	targetLabel:setPositionX(p[2])
end


--快捷切换
function addHyperLink(self)
	local myIndex = 1
	local heroList = SkillLogic.getHeroList()
	for k,h in ipairs(heroList) do
		if h.name == self.heroName then
			myIndex = k 
			break
		end
	end
	local doShow = function()
		local leftHero = heroList[myIndex-1]
		local rightHero = heroList[myIndex+1]
		self.left:setVisible(false) 
		self.right:setVisible(false)
		if leftHero then self.left:setVisible(true) end
		if rightHero then self.right:setVisible(true) end
	end
	local linkHero = function(direction)
		myIndex = myIndex + direction
		local nextHero = heroList[myIndex]
		self:refresh(nextHero.name) 
		doShow()
	end
	self.left:addEventListener(Event.Click,function() linkHero(-1) end,self)
	self.right:addEventListener(Event.Click,function() linkHero(1) end,self)
	self.left:adjustTouchBox(15)
	self.right:adjustTouchBox(15)
	doShow()
end

function onUpgrade(self,event,target)
	if event.etype == Event.Touch_ended then
		local groupId = target.groupId 
		local group = SkillLogic.getSkillGroupById(self.hero,groupId)
		if groupId then
			if group:getIsOpen() then
				local isOnce = target.isOnce and 1 or 0
				Network.sendMsg(PacketID.CG_SKILL_UPGRADE,self.heroName,groupId,isOnce)
			else
				local conf = SkillGroupConfig[groupId]
				Common.showMsg("英雄达到%d级开启",conf.openLv)
			end
		end
		if target.tip == 'skill1' then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SKILL_STRENGTH, step = 4})
		end
		if target.tip == 'skill2' then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SKILL_STRENGTH, step = 5})
		end
		if target.tip == 'skill3' then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SKILL_STRENGTH, step = 12})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SKILL_STRENGTH, step = 6})
		end
	end
end

function onUpgradeSucceed(self,groupId)
	local box = self.groupBoxList[groupId]
	local grid = box.skillBg
	if not grid then
		self:refresh(self.heroName)
		local group = SkillLogic.getSkillGroupById(self.hero,groupId)
		Common.showMsg(string.format("%s成功强化至Lv%s",group.name,group:getLv()))
		UIManager.playMusic("lvUp")
		return
	end
	local parent = box.upgrade._ccnode
	local btnSize = parent:getContentSize() 
	local fly = cc.ParticleSystemQuad:create("res/skill/upgrade/b.plist")
	fly:setAnchorPoint(0.5,0.5)
	fly:setPosition(btnSize.width/2,btnSize.height/2)
	parent:addChild(fly)
	local btn = cc.ParticleSystemQuad:create("res/skill/upgrade/a.plist")
	btn:setAutoRemoveOnFinish(true)
	btn:setAnchorPoint(0.5,0.5)
	btn:setPosition(btnSize.width/2,btnSize.height/2)
	parent:addChild(btn)
	--让你飞
	local gSize = grid:getContentSize()
	local worldPoint = grid._parent._ccnode:convertToWorldSpace(cc.p(grid:getPosition())) 
	worldPoint = {x=worldPoint.x+50,y=worldPoint.y+50}
	local move = cc.MoveTo:create(0.3,cc.p(parent:convertToNodeSpace(worldPoint)))
	local call = cc.CallFunc:create(function()
		--闪光
		local shine = cc.ParticleSystemQuad:create("res/skill/upgrade/c.plist")
		shine:setAutoRemoveOnFinish(true)
		shine:setAnchorPoint(0.5,0.5)
		shine:setPosition(gSize.width/2,gSize.height/2)
		grid._ccnode:addChild(shine)
		fly:removeFromParent()
		--real set
		self:refresh(self.heroName)
		local group = SkillLogic.getSkillGroupById(self.hero,groupId)
		if group then
			Common.showMsg(string.format("%s成功强化至Lv%s",group.name,group:getLv()))
		end
		UIManager.playMusic("lvUp")
	end)
	fly:runAction(cc.Sequence:create({cc.DelayTime:create(0.1),move,call}))
end

function loadSkillFighter(self,groupId,callback)
	if self.fighter then
		self.fighter:setVisible(true)
		callback()
	else
		SkillFighter.new(self.heroName,self,function(fighter) 
			self._ccnode:addChild(fighter.heroBody,1)
			self.fighter = fighter
			self.fighter:setVisible(true)
			callback()
		end)
	end
end

function preview(self,event,target)
	if event.etype == Event.Touch_ended then 
		local groupId = target.groupId
		local waitUI = WaittingUI.create(-1,5)	
		self:loadSkillFighter(groupId,function() 
			waitUI:removeFromParent()
			--UIManager.setUITop(false)
			self.showLayer:setVisible(true)
			local x = 100+self.fighter:getContentSize().width
			self.fighter:setScaleX(-1)
			self.fighter:setScaleY(1)
			self.fighter:setPosition(x,self.showLayer:getPositionY()+20)
			self.fighter:show(groupId)
		end)
	end
end


function clear(self)
	Instance = nil
	Control.clear(self)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 4, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 5, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 6, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 8, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
end

function initTopCoin(self)
	for i=1,4 do
		local coinBox = self.up["coin" .. i]
		local artLabel = cc.LabelBMFont:create(tostring(0),  "res/master/charLv.fnt")
		artLabel:setPositionX(coinBox.valLabel:getPositionX())
		artLabel:setPositionY(coinBox.valLabel:getPositionY()+3)
		artLabel:setAnchorPoint(1,0.5)
		coinBox._ccnode:addChild(artLabel)
		coinBox.valLabel:setVisible(false)
		coinBox.valLabel = artLabel
		coinBox.add.pos = i
		coinBox:setPositionY(Stage.uiBottom)
		self.up["coin" .. i .. "Bg"]:setPositionY(Stage.uiBottom)
	end
	self.up.coin1.add:addEventListener(Event.Click,function() 
		if UIManager.getCurrentUI() then
			UIManager.addChildUI("src/modules/gold/ui/GoldUI")
		else
			local ui = UIManager.addUI("src/modules/gold/ui/GoldUI")
			ui:setPositionY(Stage.uiBottom)
		end
	end,self)
	self.up.coin2.add:addEventListener(Event.Click,function() 
		UIManager.addUI("src/modules/vip/ui/VipUI")
	end,self)
end

function onAddCoin(self,event,target)
	local pos = target.i
end

function setTopCoin(self,coinList)
	if coinList then
		self.coinList = coinList
	end
	for k,v in ipairs(self.coinList) do
		local coinBox = self.up["coin" .. k]
		coinBox.valLabel:setString(v.val)
		CommonGrid.setCoinIcon(coinBox.coin,v.name)
		coinBox.add:setVisible(v.canAdd)
	end
end










