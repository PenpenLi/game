module(..., package.seeall)
setmetatable(_M, {__index = Control}) 

local Hero = require("src/modules/hero/Hero")
local HeroDefine = require("src/modules/hero/HeroDefine")
local BaseMath = require("src/modules/public/BaseMath")
local FightDefine = require("src/modules/fight/Define")
local MonsterConfig = require("src/config/MonsterConfig").Config

local OrochiConfig = require("src/config/OrochiConfig").Config
local Logic = require("src/modules/orochi/OrochiLogic")
local Define = require("src/modules/orochi/OrochiDefine")

local VipLogic = require("src/modules/vip/VipLogic")
local VipDefine = require("src/modules/vip/VipDefine")

DIRECTION_RIGHT = 1
DIRECTION_LEFT = -1
local statusMap =
{
	[Define.STATUS.CAN_FIGHT] = "canFight",
	[Define.STATUS.CLOSED] = "close",
	[Define.STATUS.HAD_PASS] = "hadPass",
}

function new()
    local ctrl = Control.new(require("res/orochi/OrochiSkin"),{"res/orochi/Orochi.plist"})
    setmetatable(ctrl,{__index = _M})
    ctrl:init()
    return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP_FULL
end

function addStage(self)
end

function init(self)
	Network.sendMsg(PacketID.CG_OROCHI_CHECK)
	self.master = Master.getInstance()
	local bg = Common.addBg(self,"res/orochi/OrochiBg.jpg")
	bg:setPositionY(-Stage.uiBottom)
	self:setPositionY(Stage.uiBottom)
	self.back:addEventListener(Event.Click,onBack,self)
	self.chief:setVisible(false)

	self:initDetail()
	self:refresh()
	--self:addEventListener(Event.TouchEvent,onTouchUI,self)
end

function initDetail(self)
	self.detail.touchParent = false
	self.chief.touchParent = false
	self.detail:addEventListener(Event.TouchEvent,onFight,self)   
	Common.setLabelCenter(self.detail.nameLabel)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.detail, step = 4, groupId = GuideDefine.GUIDE_OROCHI})
	--旋转圈
	self:addArmatureFrame("res/orochi/Step.ExportJson")
	local stepAnimation = ccs.Armature:create('Step')
	stepAnimation:setPosition(360,67)
	stepAnimation:setAnchorPoint(0.5,0.5)
	stepAnimation:getAnimation():play("step",-1,-1)
	self.heros._ccnode:addChild(stepAnimation,-99)
	self.detail.stepAnimation = stepAnimation
	self.heros.hero1.step1:setVisible(false)
	--粒子
	local focus = cc.ParticleSystemQuad:create("res/orochi/focus.plist")
	focus:setAnchorPoint(0.5,0.5)
	local dsize = self.detail:getContentSize()
	focus:setPosition(dsize.width/2,dsize.height/2)
	self.detail._ccnode:addChild(focus)
	self.detail.focus = focus
	--战力
	local fightLabel = self.detail.canFight.fightVal
	fightLabel:setVisible(false)
	local label = cc.Label:createWithBMFont("res/common/zdl.fnt", "0")
	label:setAnchorPoint(0,0.5)
	label:setPosition(fightLabel:getPositionX(),fightLabel:getPositionY()+5)
	self.detail.canFight._ccnode:addChild(label)
	self.detail.canFight.fightLabel = label
end

function refresh(self)
	self.levelList = Logic.getLevelList(true)
	--Common.printR(levelList)
	--能挑战的优先
	self.startPos = 1
	for k,v in ipairs(self.levelList) do
		if v.status == Define.STATUS.CAN_FIGHT then
			self.startPos = k
			break
		end
	end
	self.circleSeq = {}
	self.circleConf = {}
	self:setLevelData()

	self.frameN = 1
	self:addEventListener(Event.Frame, function() 
		if self.frameN > 8 then 
			self.seqNum = 0 
			self:closeTimer() 
			--self:setLevelData()
			local heroCtrl = self.circleSeq[1]
			if heroCtrl and heroCtrl.body.canPlay then
				heroCtrl.body:getAnimation():playWithNames({"待机"},0,true)
			end
		else
			self:createCircle()
		end
	end, self)
	self:openTimer()
end

function createCircle(self)
	local levelList = self.levelList
	--self.circleSeq = {}
	--local circleConf = {}
	local circleConf = self.circleConf
	for i=self.frameN,8 do
		local hero = self.heros["hero" .. i]
		hero.realIndex = i
		hero.body = hero["body".. i]
		--hero.levelData = levelList[startPos]
		local levelId = levelList[self.startPos].levelId
		hero.levelId = levelId
		self.startPos = self.startPos + 1
		if self.startPos > #levelList then self.startPos = 1 end
		hero.step = hero["step" .. i]
		local elem = {}
		elem.pos = cc.p(hero:getPosition())
		elem.size = hero.step:getContentSize()
		circleConf[i] = elem
		self.circleSeq[i] = hero
		--armature
		--local heroName = MonsterConfig[monster.monsterId].name 
		local conf = OrochiConfig[levelId]
		local heroName = conf.showBoss

		--local resUrl = FightDefine.sresUrl[heroName]
		--assert(resUrl,"lost hero armature=====>"..heroName)
		local heroBody
		if conf.isOpen == 1 then
			local resUrl = string.format("res/armature/%s/small/%s.ExportJson",string.lower(heroName),heroName)
			self:addArmatureFrame(resUrl)
			heroBody = ccs.Armature:create(heroName)
			heroBody.canPlay = true
			hero._ccnode:addChild(heroBody)
		else
			heroBody = Sprite.new("shadowBody",string.format("res/hero/shadow/%s.png",heroName))
			--heroBody:setContentSize(cc.size(150,258))
			Common.printR(heroBody:getContentSize())
			hero:addChild(heroBody)
		end
		local heroBoneWidth = heroBody:getBone("影子"):getDisplayManager():getBoundingBox().width
		--heroBody:setAnchorPoint(0.5,0.5)
		heroBody:setScale(hero.body:getContentSize().width/heroBoneWidth)
		heroBody:setPosition(hero.body:getPositionX()+hero.body:getContentSize().width/2,hero.body:getPositionY())
		hero.body:removeFromParent()
		hero.body = heroBody
		--local dd = Common.getDrawBoxNode(heroBody:getBoundingBox())
		--hero._ccnode:addChild(dd)
		hero:addEventListener(Event.TouchEvent, onTouchHero , self)
		hero.touchParent = false

		self.frameN = self.frameN + 1
		break
	end 
	--self.circleConf = circleConf
	--self.seqNum = 0 
end

function onTouchHero(self,evt,target)
	local hero = target
	if evt.etype == Event.Touch_began then
		self.touchHero = true
	elseif evt.etype == Event.Touch_ended then
		if self.touchHero then
			local realIndex = hero.realIndex
			if realIndex < 5 then
				self:rotate(DIRECTION_LEFT, realIndex - 1)
			else
				self:rotate(DIRECTION_RIGHT, 8 - realIndex + 1)
			end
		end
		self.touchHero = nil
	end
end

function setLevelData(self)
	local heroCtrl = self.circleSeq[1]
	local levelId = heroCtrl and heroCtrl.levelId
	if not levelId then
		local level = Logic.getCanFightLevel() 
		if not level then 
			level = self.levelList[1] 
		end
		levelId = level.levelId 
	end
	local data = Logic.getLevelByLevelId(levelId) 
	local monster = Logic.getLevelBoss(data.levelId) 
	local conf = OrochiConfig[data.levelId]
	local heroName = conf.showBoss
	local cname = conf.showName
	if data.status == Define.STATUS.CAN_FIGHT then
		self.detail.openLv:setVisible(false)
		self.detail.canFight.fightLabel:setString(conf.fightVal)
	else
		self.detail.openLv:setVisible(true)
		if cname then
			self.detail.openLv.lv:setString("Lv" .. conf.openLv)
		else
			self.detail.oppo:setVisible(false)
			self.detail.oppoNameLabel:setVisible(false)
			self.detail.order:setVisible(false)
			self.detail.openLv:setVisible(false)
		end
	end
	for _,n in pairs(statusMap) do
		if self.detail[n] then self.detail[n]:setVisible(false) end
	end
	self.detail[statusMap[data.status]]:setVisible(true)
	self.detail.nameLabel:setString(cname or "暂未开放")
	self.detail.oppoNameLabel:setString(HeroDefine.CAREER_NAMES[monster.career])
	self.detail.oppo:setState(tostring(monster.career))
	--setLvNum(monster.lv,self.detail.lvLabel)
	--armature
	if heroCtrl and heroCtrl.body.canPlay then
		heroCtrl.body:getAnimation():playWithNames({"待机"},0,true)
		heroCtrl.step:setVisible(false)
		self.detail.stepAnimation:setVisible(true)
	end
	self:setBar(data.levelId)
	--章节
	local label = cc.LabelAtlas:_create("0123456789", "res/common/FightVal.png", 23, 28 , string.byte('0'))
	label:setPosition(cc.p(self.chapterNum:getPositionX()+self.chapterNum:getContentSize().width/2,self.chapterNum:getPositionY()))
	label:setAnchorPoint(0.5,0)
	label:setString(tostring(Logic.getCurChapterId()))
	self._ccnode:addChild(label)
	self.chapterNum:setVisible(false)
end

function rotate(self,direction,step,timeGap)
	direction = direction or DIRECTION_RIGHT
	step = step or 1
	timeGap = timeGap or 0.3
	if self.seqNum ~= 0 then return end
	self.seqNum = #self.circleSeq
	function doRotate()
		local newSeq = {}
		local startPos = 1
		local endPos = 1
		if direction == DIRECTION_LEFT then 
			startPos = #self.circleSeq
		else
			endPos = #self.circleSeq
		end
		local index = 1
		for i=startPos,endPos,direction do
			spr = self.circleSeq[i]
			if spr.body.canPlay then
				spr.body:getAnimation():stop()
			end
			index = index + 1
			local pos = i + direction
			if direction == DIRECTION_RIGHT and pos > 8 then
				pos = 1
			elseif direction == DIRECTION_LEFT and pos == 0 then
				pos = 8
			end
			self.detail.focus:setVisible(false)
			self.detail.stepAnimation:setVisible(false)
			spr.step:setVisible(true)
			local nextPlace = self.circleConf[pos]
			local scale = nextPlace.size.width / spr.step:getContentSize().width
			local moveTo = cc.MoveTo:create(timeGap,nextPlace.pos)
			local scaleTo = cc.ScaleTo:create(timeGap,scale,scale)
			local call = cc.CallFunc:create(function()
				self.seqNum = self.seqNum - 1
				if self.seqNum == 0  then
					self.detail.focus:setVisible(true)
					self:setLevelData()
					if step > 0 then
						--circle end
						doRotate()
						self.seqNum = #self.circleSeq
						step = step - 1
					end
				end
			end)
			spr:stopAllActions()
			spr:runAction(cc.Sequence:create({cc.Spawn:create({moveTo,scaleTo}),call}))
			newSeq[pos] = spr
			spr.realIndex = pos
		end
		self.circleSeq = newSeq
	end
	step = step - 1
	doRotate()
end

function setBar(self,levelId)
	--local level = Logic.getCanFightLevel()
	local conf = OrochiConfig[levelId]
	local heroName = conf.showBoss
	--self.bar.bossNameLabel:setString(conf.showName)
	--self.bar.bossNameLabel:setVisible(false)
	self.rule:removeEventListener(Event.Click,showRule)
	self.rule:addEventListener(Event.Click,showRule,self)
	self.bar.counterLabel:setString(string.format("%s",Define.MAX_RESET_COUNTER - Logic.getResetCounter()))
	self.bar.reset:removeEventListener(Event.Click,onReset)
	self.bar.reset:addEventListener(Event.Click,onReset,self)
	if not self.bar.wipe:hasEventListener(Event.Click,onWipe) then
		self.bar.wipe:addEventListener(Event.Click,onWipe,self)
	end
	if not Logic.canWipe() then
		self.bar.wipe:setEnabled(false)
		self.bar.wipe:shader(Shader.SHADER_TYPE_GRAY)
	end
	--道具格子
	local itemList = Logic.getLevelItem(levelId)
	local i = 1
	for _,itemId in pairs(itemList) do
		local grid = self.bar.item["grid" .. i]
		if not grid then break end
		CommonGrid.bind(grid,"tips")
		grid:setItemIcon(itemId,'',64)
		i = i + 1
	end
	for j=i,4 do
		self.bar.item["grid" .. j]:setVisible(false)
	end
end

--重置
function onReset(self)
	if Define.MAX_RESET_COUNTER <= Logic.getResetCounter() then
		Common.showMsg("今天不能重置了哦")
		return
	end
	local tipUI = TipsUI.showTips("是否重新开始所有挑战？")
	self.resetTipUI = tipUI
	tipUI:addEventListener(Event.Confirm,function(self,event) 
		if event.etype == Event.Confirm_yes then
			Network.sendMsg(PacketID.CG_OROCHI_RESET)
		end
	end,self)
end

function showRule(self)
	local ui = UIManager.addChildUI("src/ui/RuleUI")
	ui:setId(RuleUI.Orochi)
end

function showRank(self)
	UIManager.addChildUI("src/modules/orochi/ui/OrochiRankUI")
end


function onFight(self,event,target)
	if event.etype == Event.Touch_ended then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_OROCHI, step = 4})
		if not self.circleSeq[1] then
			return
		end
		local levelId = self.circleSeq[1].levelId
		local level = Logic.getLevelByLevelId(levelId)
		local conf = OrochiConfig[levelId]
		if level.status == Define.STATUS.CAN_FIGHT then
			UIManager.addUI("src/modules/orochi/ui/FightUI",levelId)
		elseif level.status == Define.STATUS.HAD_PASS then
			Common.showMsg("已通关")
		elseif conf.openLv > self.master.lv then
			Common.showMsg("等级不够")
		else
			Common.showMsg("暂未开放")
		end
	end
end


function onBack(self,event)
	if self.resetTipUI then
		self.resetTipUI:removeFromParent()
	end
	UIManager.removeUI(self)
end

function setLvNum(lv,target)
	local lv = cc.LabelBMFont:create(tostring(lv),  "res/common/LvNum.fnt")
	lv:setTag(0)
	lv:setAnchorPoint(cc.p(0,0))
	lv:setPosition(target:getPosition())
	target:setVisible(false)
	target._parent._ccnode:removeChildByTag(0)
	target._parent._ccnode:addChild(lv)
end

function onTouchUI(self,event)
	if event.etype == Event.Touch_began then
		self.lastPos = event.p.x
	elseif event.etype == Event.Touch_moved then
		if self.lastPos and self.alive then
			if event.p.x > self.lastPos then
				self:rotate(DIRECTION_RIGHT)
			elseif event.p.x < self.lastPos then
				self:rotate(DIRECTION_LEFT)
			end
		end
		self.lastPos = nil
	end
end

function onWipe(self)
	Network.sendMsg(PacketID.CG_OROCHI_WIPE)
end






