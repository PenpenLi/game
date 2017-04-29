module(..., package.seeall)
setmetatable(_M, {__index = Control}) 

--local FightLogic = require("src/modules/fight/FightLogic")
local Define = require("src/modules/fight/Define")
local Helper = require("src/modules/fight/KofHelper")
--local Hero = require("src/modules/fight/Hero")
local Ai = require("src/modules/fight/Ai")
local HeroDefine = require("src/modules/hero/HeroDefine")
local OrochiDescConfig = require("src/config/OrochiDescConfig").Config


local btnOpacity = 130

function new()
    local ctrl = Control.new(require("res/fight/FightSkin"),{"res/fight/Fight.plist","res/fight/FightEffect.plist"})
    setmetatable(ctrl,{__index = _M})
    ctrl:init()
	ctrl:setScale(Stage.uiScale)
    return ctrl
end

function init(self)
	local args = Stage.currentScene.args
	self.effectList = {}
	self.hpA = 1
	self.hpB = 1
	self:setContentSize(Stage.winSize)

	Common.setLabelCenter(self.left.buf1.time,"center")
	Common.setLabelCenter(self.left.buf2.time,"center")

	Common.setLabelCenter(self.right.buf1.time,"center")
	Common.setLabelCenter(self.right.buf2.time,"center")
	Common.setLabelCenter(self.right.txtmingzi,"right")
	self.right.txtmingzi:setString("")
	self.left.txtmingzi:setString("")

	self.right.txthp:setString("")
	self.left.txthp:setString("")

	self:clearBuf()
	self.powRight.txtpow:setString("")
	self.powLeft.txtpow:setString("")
	Common.setLabelCenter(self.right.jnmz.txtjnmz,"center")
	Common.setLabelCenter(self.left.jnmz.txtjnmz,"center")
	self.right.jnmz:setVisible(false)
	self.left.jnmz:setVisible(false)

	local posy = {self.cd, self.suspend, self.career, self.left, self.right,self.zdzd}
	for k, v in ipairs(posy) do
		v:setPositionY(v:getPositionY() + Stage.uiBottom * 2 / Stage.uiScale)
	end

	self.career:setVisible(false)

	--self.cdpanel.touchEnabled = true
	--[[
	self.cdpanel:addEventListener(Event.TouchEvent, function()
		local H = require("src/modules/hero/Hero")
		H.resetAllHeroHp()
		Stage.replaceScene(require("src/scene/MainScene").new())
	end,self)
	--]]

	self.left.hpLeft1:setPercent(100)
	self.left.hpLeft2:setPercent(100)

	self.right.hpRight1:setPercent(100)
	self.right.hpRight2:setPercent(100)
	self.right.hpRight1:setMidpoint(cc.p(1,0))
	self.right.hpRight2:setMidpoint(cc.p(1,0))

    --self.right.powRight.zanqiR1:setMidpoint(cc.p(1,0))
    --self.right.powRight.zanqiR2:setMidpoint(cc.p(1,0))
    --self.right.powRight.zanqiR3:setMidpoint(cc.p(1,0))
	self.powRight.pow:setMidpoint(cc.p(1,0))
	self.powRight.pow2:setMidpoint(cc.p(1,0))

	--self.assist.assistmask:setReverseDirection(true)
	--self.assist.assistmask.touchEnabled = false 
	--self.pow.powmask:setReverseDirection(true)
	--self.pow.powmask.touchEnabled = false
	--self.po.pomask:setReverseDirection(true)
	--self.po.pomask.touchEnabled = false


	self:addArmatureFrame("res/armature/effect/fightBtnEffect/FightBtnEffect.ExportJson")
	self:addArmatureFrame("res/armature/effect/AssistBtnEffect.ExportJson")
	self:addArmatureFrame("res/armature/effect/comboTips/ComboTips.ExportJson")

	--self:addArmatureFrame("res/armature/effect/assist/addTime/AssistAddTime.ExportJson")
	--self:addArmatureFrame("res/armature/effect/AddHpEffect.ExportJson")
	--self:addArmatureFrame("res/armature/effect/AddPowerEffect.ExportJson")
	self:addArmatureFrame("res/armature/effect/addHpPowEffect/AddHpPowEffect.ExportJson")
	self:addArmatureFrame("res/armature/effect/skillNameEffect/SkillNameEffect.ExportJson")
	self:addArmatureFrame("res/armature/effect/Finger.ExportJson")
	--self:addArmatureFrame("res/armature/effect/assist/uiEffect/AssistUiEffect.ExportJson")
	self:initUiEffect()



	--self:startCD()
	self:setCD()
	
	local size = self:getContentSize()
	local laycolor = LayerColor.new2("pauseLaycolor",cc.c4b(0,0,0,127),size.width,size.height)
	laycolor:setAnchorPoint(0,0)
	laycolor:setPosition(0,0)
	self:addChild(laycolor)
	self.pauseLaycolor = laycolor
	self.pause:setTop()
	self.suspend:addEventListener(Event.TouchEvent,onPause,self)
	self.pause:setVisible(false)
	laycolor:setVisible(false)

	self.pause.quit:addEventListener(Event.TouchEvent,onQuit,self)
	self.pause.goon:addEventListener(Event.TouchEvent,onContinue,self)
	self.pause.musicopen:addEventListener(Event.TouchEvent,onMusicOpen,self)
	self.pause.musicclose:addEventListener(Event.TouchEvent,onMusicClose,self)

	--[[
	if Stage.currentScene.fightType == Define.FightType.arena or Stage.currentScene.fightType == Define.FightType.guild then
		self.pause.quit:setEnabled(false)
		self.pause.quit:shader(Shader.SHADER_TYPE_GRAY)
	end
	--]]

	
	local eff = ccs.Armature:create("FightBtnEffect")
	--eff:getAnimation():play("开启提示",-1,1)
	self.pow.eff = eff
	self.pow._ccnode:addChild(eff)
    --self.pow.eff:setVisible(false)
    self.pow.pow1:setVisible(false)
	eff:setAnchorPoint(0.5,0.5)

	local x, y = self.pow.pow1:getPosition()
	local size = self.pow.pow1:getContentSize()
	eff:setPosition(x + size.width / 2, y + size.height / 2)
	--self.pow.pow1:setTop()
	self.pow.powmask:setOpacity(btnOpacity)
	--self.pow.shuzibg:setTop()
	--self.pow.cnt:setTop()
    --self.pow.cnt:setVisible(false)
	self.pow.pow1:addEventListener(Event.TouchEvent,onPower,self)
	if args.noPow then
		self.pow.pow1:setEnabled(false)
		self.pow.lock:setVisible(true)
	else
		self.pow.lock:setVisible(false)
	end


	---[[
	local eff = ccs.Armature:create("FightBtnEffect")
	--eff:getAnimation():play("开启提示",-1,1)
	self.assist.eff = eff
	self.assist._ccnode:addChild(eff)
	eff:setAnchorPoint(0.5,0.5)
	local x, y = self.assist.yz:getPosition()
	local size = self.assist.yz:getContentSize()
	eff:setPosition(x + size.width / 2, y + size.height / 2)

	local eff = ccs.Armature:create("AssistBtnEffect")
	--eff:setScale(0.8)
	eff:getAnimation():play("援助按钮",-1,1)
	self.assist.effLoop = eff
	self.assist._ccnode:addChild(eff)
    self.assist.effLoop:setVisible(false)
	eff:setAnchorPoint(0.5,0.5)
	--]]
	local x, y = self.assist.yz:getPosition()
	local size = self.assist.yz:getContentSize()
	eff:setPosition(x + size.width / 2, y + size.height / 2)

	self.assist.yz:addEventListener(Event.TouchEvent,onAssist,self)
	if args.noAssist then
		self.assist.yz:setEnabled(false)
		self.assist.lock:setVisible(true)
	else
		self.assist.lock:setVisible(false)
	end
    self.assist.cnt:setVisible(false)
	self.assist.shuzibg:setVisible(false)
	--self.assist.yz:setTop()
    --self.assist.assistmask:setTop()
	--self.assist.assistmask:shader(Shader.SHADER_TYPE_GRAY)
	self.assist.assistmask:setOpacity(btnOpacity)
    self.assist.shuzibg:setTop()
    self.assist.cnt:setTop()
	self.assist.yz:setVisible(false)



	local eff = ccs.Armature:create("FightBtnEffect")
	--eff:getAnimation():play("开启提示",-1,1)
	self.po.eff = eff
	self.po._ccnode:addChild(eff)
    --self.po.eff:setVisible(false)
    self.po.po1:setVisible(false)
	eff:setAnchorPoint(0.5,0.5)
	local x, y = self.po.po1:getPosition()
	local size = self.po.po1:getContentSize()
	eff:setPosition(x + size.width / 2, y + size.height / 2)
	--self.po.po1:setTop()
	self.po.pomask:setOpacity(btnOpacity)
	--self.po.shuzibg:setTop()
	--self.po.cnt:setTop()

	self.po.po1:addEventListener(Event.TouchEvent,onBreakPower,self)
	--self.po.cnt:setVisible(false)
	if args.noBreak then
		self.po.po1:setEnabled(false)
		self.po.lock:setVisible(true)
	else
		self.po.lock:setVisible(false)
	end

	local x, y = self.jie.jie1:getPosition()
	local size = self.jie.jie1:getContentSize()

	local eff = ccs.Armature:create("ComboTips")
	eff:getAnimation():play("ComboTips",-1,0)
	self.jie.preEff = eff
	self.jie._ccnode:addChild(eff)
	self.jie.preEff:setVisible(false)
	eff:setAnchorPoint(0.5,0.5)
	eff:setPosition(x + size.width / 2, y + size.height / 2)

	local eff = ccs.Armature:create("FightBtnEffect")
	--eff:getAnimation():play("开启提示",-1,1)
	self.jie.eff = eff
	self.jie._ccnode:addChild(eff)
    --self.jie.eff:setVisible(false)
    self.jie.jie1:setVisible(false)
	eff:setAnchorPoint(0.5,0.5)
	eff:setPosition(x + size.width / 2, y + size.height / 2)
	--self.jie.jie1:setTop()
	--self.jie.shuzibg:setTop()
	--self.jie.cnt:setTop()

	self.jie.jie1:addEventListener(Event.TouchEvent,onCombo,self)
	if args.noCombo then
		self.jie.jie1:setEnabled(false)
		self.jie.lock:setVisible(true)
	else
		self.jie.lock:setVisible(false)
	end
	--self.jie.jiemask:shader(Shader.SHADER_TYPE_GRAY)
	self.jie.jiemask:setOpacity(btnOpacity)
	--self.jie.cnt:setVisible(false)

	--if Device.platform == "windows" then
	if true and Device.platform == "windows" then
		self.winA:marginRight(10)
		self.winB:marginRight(10)
		self.winA:addEventListener(Event.TouchEvent, onAWin, self)
		self.winB:addEventListener(Event.TouchEvent, onBWin, self)
		-- self.winA:setVisible(false)
		-- self.winB:setVisible(false)
	else
		self.winA:setVisible(false)
		self.winB:setVisible(false)
	end	

	self:updateFightModel()
	--竞技场
	if Master:getInstance().lv < 3 or  Stage.currentScene.fightType == Define.FightType.arena or Stage.currentScene.fightType == Define.FightType.trial then
		self.quxiao:setVisible(false)
		self.zizhu:setVisible(false)
	end

	if Stage.currentScene.fightType == Define.FightType.chapter then
		--[[
		if Stage.currentScene.args.star and Stage.currentScene.args.star < 3 then
			self.quxiao:setVisible(false)
			self.zizhu:setVisible(false)
		end
		--]]
	end
	self.quxiao:addEventListener(Event.TouchEvent,onCancleAuto,self)
	self.zizhu:addEventListener(Event.TouchEvent,onAuto,self)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.assist, step = 16, delayTime = 0, preFun = function()
		self:stopFight()
	end, clickFun = function()
		self:continueFight()
	end,groupId = GuideDefine.GUIDE_CHAPTER_FIRST})

	local preFunction = function()
		self.touchEnabled = true
		self.po.po1:setVisible(true)
		self.pow.pow1:setVisible(true)
		self.assist.yz:setVisible(true)
		self.jie.jie1:setVisible(true)
	end
	local clickFunction = function()
		self.po.po1:setVisible(false)
		self.pow.pow1:setVisible(false)
		self.assist.yz:setVisible(false)
		self.jie.jie1:setVisible(false)
	end
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.po.po1, step = 4, scaleVal = Stage.uiScale, preFun = preFunction, clickFun = clickFunction, noCallTouchFun = true, noFinger = true, groupId = GuideDefine.GUIDE_CHAPTER_TEN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.pow.pow1, step = 5, scaleVal = Stage.uiScale, preFun = preFunction, clickFun = clickFunction, noCallTouchFun = true, noFinger = true, groupId = GuideDefine.GUIDE_CHAPTER_TEN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.assist.yz, step = 6, scaleVal = Stage.uiScale, preFun = preFunction, clickFun = clickFunction, noCallTouchFun = true, noFinger = true, groupId = GuideDefine.GUIDE_CHAPTER_TEN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.jie.jie1, step = 7, scaleVal = Stage.uiScale, preFun = preFunction, clickFun = clickFunction, noCallTouchFun = true, noFinger = true, groupId = GuideDefine.GUIDE_CHAPTER_TEN})

	--[[
	self.left.buf1:addEventListener(Event.TouchEvent,onBuf,self)
	self.left.buf2:addEventListener(Event.TouchEvent,onBuf,self)

	self.right.buf1:addEventListener(Event.TouchEvent,onBuf,self)
	self.right.buf2:addEventListener(Event.TouchEvent,onBuf,self)
	--]]
	local seq = cc.Sequence:create(
		cc.EaseIn:create(cc.FadeOut:create(1), 2.5),
		cc.EaseOut:create(cc.FadeIn:create(1), 2.5)
	)
	local rep = cc.RepeatForever:create(seq)
	self.left.buf1.icon:runAction(rep)
	self.left.buf2.icon:runAction(rep:clone())

	self.right.buf1.icon:runAction(rep:clone())
	self.right.buf2.icon:runAction(rep:clone())
	self:openTimer()
	--self:addTimer(initLazy,5,1)
end


function setCareerVisiable(self,flag)
	self.isCareerVisiable = flag
end

function initHeroCareer(self)
	local heroA = Stage.currentScene.heroA.hero
	local heroB = Stage.currentScene.heroB.hero

	self.career.txtcareerB:setString(heroB.careerName)
	self.career.txtcareerB._ccnode:setColor(HeroDefine.CAREER_COLOR[heroB.career])
	self.career.txtcareerB2:setString(heroB.careerName)
	self.career.txtcareerB2._ccnode:setColor(HeroDefine.CAREER_COLOR[heroB.career])
	self.career.txtcareerA:setString(heroA.careerName)
	self.career.txtcareerA._ccnode:setColor(HeroDefine.CAREER_COLOR[heroA.career])

	self.career.txtdesc:setString(OrochiDescConfig[heroB.career].desc)

	self.career.iconA._ccnode:setTexture("res/hero/career/" .. heroA.career .. ".png")
	self.career.iconA._ccnode:setScale(0.5)
	self.career.iconA._ccnode:setAnchorPoint(cc.p(0,0))
	self.career.iconB._ccnode:setTexture("res/hero/career/" .. heroB.career .. ".png")
	self.career.iconB._ccnode:setScale(0.5)
	self.career.iconB._ccnode:setAnchorPoint(cc.p(0,0))
	self.career.iconB2._ccnode:setTexture("res/hero/career/" .. heroB.career .. ".png")
	self.career.iconB2._ccnode:setScale(0.5)
	self.career.iconB2._ccnode:setAnchorPoint(cc.p(0,0))

	if self.isCareerVisiable then
		self.career:setVisible(true)
	end
	
end

function setVipCopyEffect(self,visible,value)
	if self.vipCopyEffect then
		self._ccnode:removeChild(self.vipCopyEffect,true)
		self.vipCopyEffect = nil
	end
	--local ret,value = true,100
	if visible then
		self.vipCopyEffect = Helper.createVipCopyEffect(nil,value)
		self._ccnode:addChild(self.vipCopyEffect)
		self.vipCopyEffect:setPosition(20,355)
	end
end

function initHeroName(self)
	local nameA = Stage.currentScene.heroA.hero.cname
	local nameB = Stage.currentScene.heroB.hero.cname
	self.left.txtmingzi:setString(nameA)
	self.right.txtmingzi:setString(nameB)
end

function initAtkSpeed(self)
	local atkSpeedA = Stage.currentScene.heroA.hero.dyAttr.atkSpeed
	local atkSpeedB = Stage.currentScene.heroB.hero.dyAttr.atkSpeed
	--print('==================fuck,atkSpeedA,atkSpeedB:',atkSpeedA,atkSpeedB)

	if self.left.lvTxt then
		--self.left.gsbg._ccnode:removeChild(self.left.lvTxt,true)
		self.left.lvTxt:setString(tostring(atkSpeedA))
	--end
	else
		local lvTxt = cc.LabelAtlas:_create("0123456789", "res/common/atkSpeedNum.png", 15, 19, string.byte('0'))
		self.left.lvTxt = lvTxt
		lvTxt:setAnchorPoint(0.5, 0.5)
		self.left.gsbg._ccnode:addChild(lvTxt)
		--lvTxt:setPositionX(24)
		--lvTxt:setPositionY(23)
		lvTxt:setPosition(75,48)
		lvTxt:setString(tostring(atkSpeedA))
	end

	if self.right.lvTxt then
		--self.right.gsbg._ccnode:removeChild(self.right.lvTxt,true)
		self.right.lvTxt:setString(tostring(atkSpeedB))
	--end
	else
		local lvTxt = cc.LabelAtlas:_create("0123456789", "res/common/atkSpeedNum.png", 15, 19, string.byte('0'))
		self.right.lvTxt = lvTxt
		lvTxt:setAnchorPoint(0.5, 0.5)
		self.right.gsbg2._ccnode:addChild(lvTxt)
		--lvTxt:setPositionX(24)
		--lvTxt:setPositionY(23)
		lvTxt:setPosition(85,48)
		lvTxt:setString(tostring(atkSpeedB))
	end
end

function initHpNum(self)
	local heroA = Stage.currentScene.heroA
	local heroB = Stage.currentScene.heroB
end

function initPowNum(self)
end

function initLazy(self) 
	self:addEventListener(Event.Frame, onFrameEvent)
    --self.pow.cnt:setVisible(true)
    --self.assist.cnt:setVisible(true)
	--self.assist.shuzibg:setVisible(true)
	--self.po.cnt:setVisible(true)
	--self.jie.cnt:setVisible(true)
	self:initRound()
end

function initRound(self)
	self:initAtkSpeed()
	self:initHeroName()
	self:initHeroCareer()
	self:setHeroIcon()
	--self:setVipCopyEffect(true,"1000%")
	self:clearBuf()
	Stage.currentScene:dispatchEvent(Event.FightRound)
end

function initUiEffect(self)
	--[[
	local eff = ccs.Armature:create("AssistAddTime")
	self.addTimeEffect = eff
	eff:setAnchorPoint(0.5,0.5)
	local x,y = self.cdpanel:getPosition()
	local size = self.cdpanel:getContentSize()
	eff:setPosition(x + size.width / 2,y + size.height / 2)
	self._ccnode:addChild(eff)
	--eff:getAnimation():play("addTime",-1,1)
	--]]

	--[[
	local eff = ccs.Armature:create("AddHpPowEffect")
	eff:setScaleX(-1)
	self.left.addHpEffect = eff
	eff:setAnchorPoint(0.5,0.5)
	eff:setPosition(240,117)
	self.left._ccnode:addChild(eff,1)
	eff:getAnimation():play("hp",-1,1)

	local eff = ccs.Armature:create("AddHpPowEffect")
	self.right.addHpEffect = eff
	eff:setAnchorPoint(0.5,0.5)
	eff:setPosition(145,117)
	self.right._ccnode:addChild(eff,1)
	eff:getAnimation():play("hp",-1,1)
	--]]

	--[[
	local eff = ccs.Armature:create("AddHpPowEffect")
	self.powLeft.powerEffect = eff
	eff:setAnchorPoint(0.5,0.5)
	eff:setPosition(178,16)
	self.powLeft._ccnode:addChild(eff,1)
	eff:getAnimation():play("pow",-1,1)

	local eff = ccs.Armature:create("AddHpPowEffect")
	eff:setScaleX(-1)
	self.powRight.powerEffect = eff
	eff:setAnchorPoint(0.5,0.5)
	eff:setPosition(124,16)
	self.powRight._ccnode:addChild(eff,1)
	eff:getAnimation():play("pow",-1,1)
	--]]
	self.powLeft.txpzbg:setVisible(false)
	
	local eff = ccs.Armature:create("SkillNameEffect")
	self.left.skillNameEffect = eff
	eff:setAnchorPoint(0.5,0.5)
	eff:setPosition(132,48)
	self.left._ccnode:addChild(eff,1)
	--eff:getAnimation():play("addPower",-1,1)

	local eff = ccs.Armature:create("SkillNameEffect")
	eff:setScaleX(-1)
	self.right.skillNameEffect = eff
	eff:setAnchorPoint(0.5,0.5)
	eff:setPosition(253,51)
	self.right._ccnode:addChild(eff,1)
	--eff:getAnimation():play("addPower",-1,1)

end

function onFrameEvent(self,event)
	local heroA = Stage.currentScene.heroA
	local heroB = Stage.currentScene.heroB
	if not heroA.curState or not heroB.curState then
		return
	end
    self:setPower()
    self:setHp()
	self:setAssist()
	self:updateBuf()

	for effect,parent in pairs(self.effectList) do
		parent._ccnode:removeChild(effect,true)
	end
	self.effectList = {}

end

function displayPowerTxt(self,node)
	node:setAnchorPoint(cc.p(0.5,0.5))
	local size = self.powLeft.txpzbg:getContentSize()
	local bone=ccs.Armature:create("FightTxtEffect")
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(size.width / 2,size.height)

    bone:getBone("Layer1"):addDisplay(node, 0)
	--bone:getBone("Layer1"):changeDisplayWithIndex(0, true)
	--bone:getBone("Layer1"):setIgnoreMovementBoneData(true)
	self.powLeft.txpzbg._ccnode:addChild(bone)

	bone:getAnimation():play('怒气消耗',-1,0)

	self.powLeft.txpzbg:setVisible(true)
	--print('=---------------------fuck----------------------')
    bone:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			self.powLeft.txpzbg:setVisible(false)
			self:addTimer(function() 
				self.powLeft.txpzbg._ccnode:removeChild(bone,true)
			end,0.000001,1, self)
		end
	end)
end

function displayCrtEffect(self,hero)
	local scaleBy = cc.ScaleBy:create(0.01,1.1)
	local seq = cc.Sequence:create(
		scaleBy,
		scaleBy:reverse()
	)
	if hero == Stage.currentScene.heroA then
		if self.left:numberOfRunningActions() <= 0 then
			self.left:runAction(seq)
		end
		--self.powLeft:runAction(seq:clone())
	else
		if self.right:numberOfRunningActions() <= 0 then
			self.right:runAction(seq)
		end
		--self.powRight:runAction(seq:clone())
	end
end

function displayHpEffect(self,hero)
	if hero == Stage.currentScene.heroA then
		--self.left.addHpEffect:getAnimation():play("血条",-1,0)
	else
		--self.right.addHpEffect:getAnimation():play("血条",-1,0)
	end
end

function displayAddPowerEffect(self,hero)
	if hero == Stage.currentScene.heroA then
		--self.powLeft.powerEffect:getAnimation():play("怒气条",-1,0)
	else
		--self.powRight.powerEffect:getAnimation():play("怒气条",-1,0)
	end
end

function displayDecPowerEffect(self,hero)
	if hero == Stage.currentScene.heroA then
		--self.powLeft.powerEffect:getAnimation():play("怒气条",-1,0)
	else
		--self.powRight.powerEffect:getAnimation():play("怒气条",-1,0)
	end
end

function displaySkillNameEffect(self,hero,skillName)
	self:removeSkillNameEffect(hero)
	if hero == Stage.currentScene.heroA then
		self:addTimer(function() 
			self.left.jnmz:setVisible(true)
			self.left.jnmz.txtjnmz:setString(skillName)
		end,0.2,1, self)
		self.left.skillNameEffect:getAnimation():play("技能",-1,0)
	else
		self:addTimer(function() 
			self.right.jnmz:setVisible(true)
			self.right.jnmz.txtjnmz:setString(skillName)
		end,0.2,1, self)
		self.right.skillNameEffect:getAnimation():play("技能",-1,0)
	end
end

function removeSkillNameEffect(self,hero)
	if hero == Stage.currentScene.heroA then
		self.left.jnmz:setVisible(false)
	else
		self.right.jnmz:setVisible(false)
	end
end

--设置左血条，value:0 ~ 1
function setHPLeft(self, value)
	self.left.hpLeft1:setPercent(value)
	--[[
	local x = self.left.hpLeft1:getPositionX()
	local size = self.left.hpLeft1:getContentSize()
	self.left.addHpEffect:setPositionX(x + size.width * value / 100)
	--]]

	local v = self.left.hpLeft2:getPercent()
	local rv = v + (value - v) * 0.05
	self.left.hpLeft2:setPercent(rv)
	--self.left.addHpEffect:setVisible(value > 0 and value < 100)

	--[[
	local x = self.left.hpLeft1:getPositionX()
	local size = self.left.hpLeft1:getContentSize()
	self.left.addHpEffect:setPositionX(x + size.width * rv / 100)
	--]]
end

--设置右血条，value:0 ~ 1
function setHPRight(self, value)
	self.right.hpRight1:setPercent(value)
	--[[
	local x = self.right.hpRight1:getPositionX()
	local size = self.right.hpRight1:getContentSize()
	self.right.addHpEffect:setPositionX(x + size.width * (100 - value) / 100)
	--]]

	local v = self.right.hpRight2:getPercent()
	local rv = v + (value - v) * 0.05
	self.right.hpRight2:setPercent(rv)
	--self.right.addHpEffect:setVisible(value > 0 and value < 100)
	--[[
	local x = self.right.hpRight1:getPositionX()
	local size = self.right.hpRight1:getContentSize()
	self.right.addHpEffect:setPositionX(x + size.width * (100 - rv) / 100)
	--]]
end

--开启CD倒计时, sec:倒计时秒数，一般30秒 
function startCD(self, sec)
	self.hpA = 1
	self.hpB = 1
	sec = sec or 60
	--sec = sec or 9999
	if sec <= 0 then
		return
	end
	
	if self.cdTimer then
		self:delTimer(self.cdTimer)
		self.cdTimer = nil
	end
	self:setCD(sec)
	self.cdTimer = self:addTimer(onCDTimer, 1, sec, self)
end

function stopCD(self,noRemoveBuf)
	if self.cdTimer then
		self:delTimer(self.cdTimer)
		self.cdTimer = nil
		if not noRemoveBuf then
			self:clearBuf()
		end
	end
end

function addCDTime(self,sec)
	if self.curSec and self.curSec > 0 then
		local rs = math.min(60,self.curSec + sec)
		local rs = math.max(rs,1)
		
		if self.cdTimer then
			self:delTimer(self.cdTimer)
			self.cdTimer = nil
		end
		self:setCD(rs)
		self.cdTimer = self:addTimer(onCDTimer, 1, rs, self)
	end
end

function timeOver(self)
	if self.cdTimer then
		self:delTimer(self.cdTimer)
		self.cdTimer = nil
	end
	self:setCD(0)
	self:dispatchEvent(Event.PlayEnd, {etype = Event.PlayEnd})
end

function onCDTimer(self, event)
	self.curSec = event.maxTimes
	self:setCD(event.maxTimes)
	if event.maxTimes == 0 then
		self:dispatchEvent(Event.PlayEnd, {etype = Event.PlayEnd})
	end
	local heroA = Stage.currentScene.heroA
	local heroB = Stage.currentScene.heroB
	heroA:getInfo():addPower(heroA:getPowerRecover())
	heroB:getInfo():addPower(heroB:getPowerRecover())

	--heroA:getInfo():addAssist(heroA:getAssistRecover())
	--heroB:getInfo():addAssist(heroB:getAssistRecover())
	local tmpBuf = {}
	self.left.bufList = self.left.bufList or {}
	for k,v in ipairs(self.left.bufList) do
		v.time = v.time - 1
		if v.time > 0 then
			table.insert(tmpBuf,v)
			if #tmpBuf ~= k then
				v.isDirty = true
			end
		end
	end
	self.left.bufList = tmpBuf

	local tmpBuf = {}
	self.right.bufList = self.right.bufList or {}
	for k,v in ipairs(self.right.bufList) do
		v.time = v.time - 1
		if v.time > 0 then
			table.insert(tmpBuf,v)
			if #tmpBuf ~= k then
				v.isDirty = true
			end
		end
	end
	self.right.bufList = tmpBuf
end

function setCD(self, sec)
	sec = sec or 60
	if not self.cd10 then
		local cd10 = Image.new(self.cd:getSkin()) 
		cd10.name = "cd10"
		self.cd10 = cd10 
		self:addChild(cd10)
		local x = self.cd:getPositionX()
		self.cd:setPositionX(x + 11)
		self.cd10:setPositionX(x - 9)
		self.cd10:setPositionY(self.cd10:getPositionY() + Stage.uiBottom * 2 / Stage.uiScale)
	end
	local n10 = sec - sec % 10
	local c1 =  sec - n10 - sec % 1
	local c10 = n10 / 10
	local skin = self.cd10:getStateSkinByName("cd" .. c10)
	if skin then
		self.cd10:show(skin)
	end
	skin = self.cd:getStateSkinByName("cd" .. c1)
	if skin then
		self.cd:show(skin)
	end
end

function setHeroIcon(self)
	local ctrl = self._parent.fightControl
	local setIcon = function(hero, img,careerImg, living, showing, sign)
		if not hero then
			img._ccnode:setVisible(false)
			if careerImg then
				careerImg._ccnode:setVisible(false)
			end
			return
		end
		img._ccnode:setVisible(true)
		if careerImg  then
			careerImg._ccnode:setVisible(self.isCareerVisiable)
		end
		if showing then
			local res = "res/hero/micon/" .. hero.name .. ".png"
			img._ccnode:setTexture(res)
			img._ccnode:setScaleX(1 * sign * -1)
			img._ccnode:setScaleY(1)
		else
			local res = "res/hero/icon/" .. hero.name .. ".png"
			img._ccnode:setTexture(res)
			img._ccnode:setScaleX(0.5 * sign)
			img._ccnode:setScaleY(0.5)

			if careerImg then
				careerImg._ccnode:setTexture("res/hero/career/" .. hero.career .. ".png")
				careerImg._ccnode:setScale(0.5)
			end
		end

		local x, y, w, h = img._skin.x, img._skin.y, img._skin.width, img._skin.height
		img._ccnode:setAnchorPoint(0.5, 0.5)
		img._ccnode:setPosition(x + w/2, y + h/2)

		if living then 
			img:shader()
		else
			img:shader(Shader.SHADER_TYPE_GRAY)
		end
	end

	setIcon(ctrl:getAssistA(), self.left.touxiang4,self.left.career4, true, false, -1)
	setIcon(ctrl:getAssistB(), self.right.touxiang4,self.right.career4, true, false, 1)

	local list = ctrl.heroAList
	local len = #list
	local id = ctrl.heroAIndex
	for i = 1, 3 do 
		local n = (i + 3 - id) % 3 + 1
		if i < len or len ==1 then
			setIcon(list[i], self.left["touxiang".. n],self.left["career" .. n], i >= id, n == 1, -1)
		else
			setIcon(nil, self.left["touxiang".. n],self.left["career" .. n])
		end
	end
	list = ctrl.heroBList
	len = #list
	id = ctrl.heroBIndex
	--[[
	for i = 1, 3 do 
		local n = (i + 3 - id) % 3 + 1
		if i < len or len == 1 then
			setIcon(list[i], self.right["touxiang".. (n+4)], i >= id, n == 1,1)
		else
			setIcon(nil, self.right["touxiang".. (n+4)])
		end
	end
	--]]
	for i=1,3 do
		local n = i + id -1		--当前pos
		if n > (len-1) then
			n = n - (len-1)
		end
		if i < len or len ==1 then
			setIcon(list[n], self.right["touxiang".. (i)],self.right["career" .. i], n >= id, i == 1,1)
		else
			setIcon(nil, self.right["touxiang".. (i)],self.right["career" .. i])
		end
	end

	--self.left.touxiang1:runAction(cc.Blink:create(2,10))
	--self.left.touxiang1:shader(Shader.SHADER_TYPE_BLINK)
end

function blinkHeroIcon(self,hero)
	if hero == Stage.currentScene.heroA then
		self.left.touxiang1:shader(Shader.SHADER_TYPE_BLINK)
		self:addTimer(function()
			self.left.touxiang1:shader(nil)
		end, 1, 1, self)
	else
		self.right.touxiang1:shader(Shader.SHADER_TYPE_BLINK)
		self:addTimer(function()
			self.right.touxiang1:shader(nil)
		end, 1, 1, self)
	end
end

function runReadyGo(self)
    self.readygo:setVisible(true)
    local ary = {}
    for i = 1,3 do
        local callFunc = cc.CallFunc:create(function() 
            self.readygo.ready1:setVisible(i == 1)
            self.readygo.ready2:setVisible(i == 2)
            self.readygo.ready3:setVisible(i == 3)
        end)
        local delay = cc.DelayTime:create(0.4)
        table.insert(ary,callFunc)
        table.insert(ary,delay)
    end
    action = cc.Sequence:create(ary)
    self:runAction(action)

    local ary = {}
    for i = 1,4 do
        local callFunc = cc.CallFunc:create(function() 
            self.readygo.go1:setVisible(i == 1)
            self.readygo.go2:setVisible(i == 2)
            self.readygo.go3:setVisible(i == 3)
            self.readygo.go4:setVisible(i == 4)
        end)
        local delay = cc.DelayTime:create(0.3)
        table.insert(ary,callFunc)
        table.insert(ary,delay)
    end
    table.insert(ary,cc.CallFunc:create(function()
        self.readygo:setVisible(false)
    end
    ))
    action = cc.Sequence:create(ary)
    self:runAction(action)

    
end

function onCombo(self,event)
    if event.etype == Event.Touch_ended then
		self.jie.eff:getAnimation():play("粒子",-1,0)
        local heroA = Stage.currentScene.heroA
        local heroB = Stage.currentScene.heroB
        if Stage.currentScene.fightLogic.aiState > Ai.AI_STATE_START 
			and Stage.currentScene.fightLogic.aiState < Ai.AI_STATE_ASSIST
			and not heroA:getInfo():isDie() 
			and not heroB:getInfo():isDie()
			and heroA:getInfo():canUsePower(Define.comboPower) 
			and Stage.currentScene.fightLogic.comboA then
            heroA:getInfo():decPower(Define.comboPower)
			Stage.currentScene.fightLogic:combo()

			local node = Helper.createFightEffect("fe_nq",-Define.comboPower,"fe_jz")
			--node:setScale(0.5)
			--Stage.currentScene:displayFightEffect("decPower",node,1,330,60,true)
			self:displayPowerTxt(node)
        end
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FOUR, step = 9})
	end
end

function onBreakPower(self,event)
    if event.etype == Event.Touch_ended then
		self.po.eff:getAnimation():play("粒子",-1,0)
		local fightLogic = Stage.currentScene.fightLogic
        local heroA = Stage.currentScene.heroA
        local heroB = Stage.currentScene.heroB
        if fightLogic.aiState > Ai.AI_STATE_START 
			and fightLogic.aiState < Ai.AI_STATE_POWER 
			and fightLogic.aiState ~= Ai.AI_STATE_END
			and not heroA:getInfo():isDie() 
			and not heroB:getInfo():isDie()
			and heroA:getInfo():canUsePower(Define.breakPower) 
			and not fightLogic.comboA 
			--and not fightLogic.comboB
			and heroA:isBeBeat() then
            heroA:getInfo():decPower(Define.breakPower)
			Stage.currentScene.fightLogic:power()

			local node = Helper.createFightEffect("fe_nq",-Define.breakPower,"fe_pz")
			--node:setScale(0.5)
			--Stage.currentScene:displayFightEffect("decPower",node,1,330,60,true)
			self:displayPowerTxt(node)
        end
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_THIRD, step = 9})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_THIRD, step = 8})
	end
end

function onPower(self,event)
    if event.etype == Event.Touch_ended then
		self.pow.eff:getAnimation():play("粒子",-1,0)
		local fightLogic = Stage.currentScene.fightLogic
        local heroA = Stage.currentScene.heroA
        local heroB = Stage.currentScene.heroB
        if fightLogic.aiState > Ai.AI_STATE_START 
			and fightLogic.aiState < Ai.AI_STATE_POWER
			and fightLogic.aiState ~= Ai.AI_STATE_END
			and not heroA:getInfo():isDie() 
			and not heroB:getInfo():isDie()
			and  heroA:getInfo():canUsePower(Define.powPower)
			--and not fightLogic.comboA 
			and not fightLogic.comboB
			and not heroA:isBeBeat() then
            heroA:getInfo():decPower(Define.powPower)
			Stage.currentScene.fightLogic:power()

			local node = Helper.createFightEffect("fe_nq",-Define.powPower,"fe_dz")
			--node:setScale(0.5)
			--Stage.currentScene:displayFightEffect("decPower",node,1,330,60,true)
			self:displayPowerTxt(node)
        end
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIRST, step = 22})
    end
end

function onAssist(self,event)
    if event.etype == Event.Touch_ended then
		self.assist.eff:getAnimation():play("粒子",-1,0)
        local heroA = Stage.currentScene.heroA
        local heroB = Stage.currentScene.heroB
        if Stage.currentScene.fightLogic.aiState > Ai.AI_STATE_START 
			and Stage.currentScene.fightLogic.aiState ~= Ai.AI_STATE_END
			--and Stage.currentScene.fightLogic.aiState < Ai.AI_STATE_END 
			and not heroA:getInfo():isDie() 
			and not heroB:getInfo():isDie()
			and not heroA:getAssist()
			and  heroA:getInfo():canUseAssist() then
			heroA:getInfo():decAssist()
			Stage.currentScene.fightLogic:assist()
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIRST, step = 16})
		end
    end
end

function setPause(self,flag)
	if flag then
		cc.Director:getInstance():getScheduler():setTimeScale(0)
	else
		cc.Director:getInstance():getScheduler():setTimeScale(1)
	end
end

function updateMusicBtn(self)
	if Master:getInstance():isMusicON() then
		self.pause.musicopen:setVisible(true)
		self.pause.openzi:setVisible(true)
		self.pause.musicclose:setVisible(false)
		self.pause.closezi:setVisible(false)
	else
		self.pause.musicopen:setVisible(false)
		self.pause.openzi:setVisible(false)
		self.pause.musicclose:setVisible(true)
		self.pause.closezi:setVisible(true)
	end
end

function onPause(self,event)
    if event.etype == Event.Touch_ended then
		self.pause:setTop()
		if self.pause:isVisible() then
			self:setPause(false)
			self.pause:setVisible(false)
			self.pauseLaycolor:setVisible(false)
			if Master:getInstance():isEffectON() then
				AudioEngine.resumeAllEffects()
			end
		else
			self:setPause(true)
			self.pause:setVisible(true)
			self.pauseLaycolor:setVisible(true)
			if Master:getInstance():isEffectON() then
				AudioEngine.pauseAllEffects()
			end
			
			self:updateMusicBtn()
		end
	end
end

function quit(self)
	self:setPause(false)
	if Master:getInstance():isEffectON() then
		--AudioEngine.resumeAllEffects()
		AudioEngine.stopAllEffects()
	end
	local scene = Stage.currentScene
	if scene.fightLogic then
		scene.fightLogic.winer = ""
		scene.fightLogic.isFinish = true
		scene.fightLogic.aiData.hasCheck = true
	end
	scene:exit()
end

function onQuit(self,event)
    if event.etype == Event.Touch_ended then
		if not Stage.currentScene.heroA or not Stage.currentScene.heroB then
			local scene = require("src/scene/MainScene").new()
			Stage.replaceScene(scene)
			return
		end
		if Stage.currentScene.fightType == Define.FightType.arena or Stage.currentScene.fightType == Define.FightType.trial then
			local tips = TipsUI.showTopTips("战斗过程中退出将判定您该次挑战失败，是否退出？")
			tips:addEventListener(Event.Confirm,function(self,event) 
				if event.etype == Event.Confirm_yes then
					self:quit()
				end
			end,self)
		else
			self:quit()
		end
				--[[
				scene:dispatchEvent(Event.FightEnd,{etype = Event.FightEnd,winer = "B",infoA = {index = scene.fightControl.heroAIndex,power = scene.heroA:getInfo():getPower(),assist = scene.heroA:getInfo():getAssist(),hp=scene.heroA:getInfo():getHp()},infoB = {index = scene.fightControl.heroBIndex,power = scene.heroB:getInfo():getPower(),assist = scene.heroB:getInfo():getAssist(),hp=scene.heroB:getInfo():getHp()}})
				--]]
	end
end

function onContinue(self,event)
    if event.etype == Event.Touch_ended then
		self:setPause(false)
		self.pause:setVisible(false)
		self.pauseLaycolor:setVisible(false)
		if Master:getInstance():isEffectON() then
			AudioEngine.resumeAllEffects()
		end
	end
end

function onMusicOpen(self,event)
    if event.etype == Event.Touch_ended then
		Master:getInstance():setMusicOn(false)
		self:updateMusicBtn()
	end
end

function onMusicClose(self,event)
    if event.etype == Event.Touch_ended then
		Master:getInstance():setMusicOn(true)
		self:updateMusicBtn()
	end
end

function showPowCntEffect(self,skin,cnt,parent)
	if cnt > (parent.p or 0) then
		local powE = Image.new(parent.powCnt:getSkin()) 
		powE:show(skin)
		powE:setAnchorPoint(0.5,0.5)
		powE.name = "effect_pow"
		local x,y = parent.powCnt:getPosition()
		local size = parent.powCnt:getContentSize()
		powE:setPosition(x + size.width / 2,y + size.height / 2)
		parent:removeChildByName("effect_pow")
		parent:addChild(powE)
		local seq = cc.Sequence:create(
			cc.Spawn:create(
				cc.EaseOut:create(cc.ScaleTo:create(1,3),2.5),
				cc.FadeOut:create(1)
			),
			cc.CallFunc:create(function() 
				powE:removeFromParent()
			end)
		)
		powE:runAction(seq)
	end
end

function setPower(self)
    local heroA = Stage.currentScene.heroA
    local heroB = Stage.currentScene.heroB
	self.powLeft.txtpow:setString(string.format("%d/100",heroA:getInfo():getPower() % 100))
	self.powRight.txtpow:setString(string.format("%d/100",heroB:getInfo():getPower() % 100))
    local leftPowerCnt = heroA:getInfo():getPowerCnt(Define.powPower)
	local leftPowerPercent = heroA:getInfo():getPowerPercent()

	self.powLeft.pow:setPercent(leftPowerPercent)
	local v = self.powLeft.pow2:getPercent()
	self.powLeft.pow2:setPercent(v + (leftPowerPercent - v) * 0.05)

	--[[
	local x = self.powLeft.pow:getPositionX()
	local size = self.powLeft.pow:getContentSize()
	--self.powLeft.powerEffect:setPositionX(x + size.width * leftPowerPercent / 100)
	--]]

	local skin = self.powLeft.powCnt:getStateSkinByName("pow" .. leftPowerCnt)
	if skin then
		self.powLeft.powCnt:show(skin)
		self:showPowCntEffect(skin,leftPowerCnt,self.powLeft)
	end

	self.powLeft.p = leftPowerCnt

    local leftPowerCnt = heroA:getInfo():getPowerCnt(Define.breakPower)

    local leftPowerCnt = heroA:getInfo():getPowerCnt(Define.comboPower)

    local rightPowerCnt = heroB:getInfo():getPowerCnt(Define.powPower)
	local rightPowerPercent = heroB:getInfo():getPowerPercent()

	self.powRight.pow:setPercent(rightPowerPercent)
	local v = self.powRight.pow2:getPercent()
	self.powRight.pow2:setPercent(v + (rightPowerPercent - v) * 0.05)

	--[[
	local x = self.powRight.pow:getPositionX()
	local size = self.powRight.pow:getContentSize()
	--self.powRight.powerEffect:setPositionX(x + size.width * (100 - rightPowerPercent) / 100)
	--]]

	local skin = self.powRight.powCnt:getStateSkinByName("pow" .. rightPowerCnt)
	if skin then
		self.powRight.powCnt:show(skin)
		self:showPowCntEffect(skin,rightPowerCnt,self.powRight)
	end

	local preFunction = function(component, canUseAssist)
		self.touchEnabled = true
		self.po.po1.touchEnabled = false
		self.pow.pow1.touchEnabled = false
		self.jie.jie1.touchEnabled = false
		if canUseAssist == nil then
			self.assist.yz.touchEnabled = false
		end
		component.touchEnabled = true
		self:stopFight()
	end
	local clickFunction = function()
		self:continueFight()
	end
	if Stage.currentScene.fightLogic.aiState > Ai.AI_STATE_START 
		and Stage.currentScene.fightLogic.aiState < Ai.AI_STATE_POWER
		and not heroA:getInfo():isDie() 
		and not heroB:getInfo():isDie() 
		and Stage.currentScene.fightLogic.aiState ~= Ai.AI_STATE_END then
		--and Stage.currentScene.fightModel ~= Define.FightModel.autoA_autoB
		--and Stage.currentScene.fightModel ~= Define.FightModel.autoA_handB then

		if heroA:getInfo():canUsePower(Define.breakPower) and heroA:isBeBeat() then
			self.po.po1:setVisible(true)
			--self.po.eff:setVisible(true)
			if not self.po.lastEff then
				self.po.eff:getAnimation():play("按钮",-1,0)
			end
			self.po.lastEff = true
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.po.po1, step = 9, mustJump = true, noDelayFun=function() 
				self.po.eff:getAnimation():stop()
			end, preFun = function() 
				preFunction(self.po.po1, true)
			end, clickFun = clickFunction, groupId = GuideDefine.GUIDE_CHAPTER_THIRD})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.po.po1, step = 8, nextTime=2.5, noDelayFun=function() 
				self.po.eff:getAnimation():stop()
			end, preFun = function() 
				preFunction(self.po.po1, true)
			end, clickFun = function()
				--GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 9, groupId = GuideDefine.GUIDE_CHAPTER_THIRD})
				clickFunction()
			end, groupId = GuideDefine.GUIDE_CHAPTER_THIRD})
		else
			GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 8, groupId = GuideDefine.GUIDE_CHAPTER_THIRD})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 9, groupId = GuideDefine.GUIDE_CHAPTER_THIRD})
			self.po.po1:setVisible(false)
			--self.po.eff:setVisible(false)
			self.po.lastEff = false
		end

		if heroA:getInfo():canUsePower(Define.powPower) and not heroA:isBeBeat() then
			self.pow.pow1:setVisible(true)
			--self.pow.eff:setVisible(true)
			if not self.pow.lastEff then
				self.pow.eff:getAnimation():play("按钮",-1,0)
			end
			self.pow.lastEff = true

			--redo never has not zanqi1 
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.pow.pow1, step = 22, delayTime = 0, preFun = function()
				preFunction(self.pow.pow1, true)
			end, clickFun = clickFunction, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
		else
			self.pow.pow1:setVisible(false)
			--self.pow.eff:setVisible(false)
			self.pow.lastEff = false
		end

	else
		self.po.po1:setVisible(false)
		self.po.lastEff = false

		self.pow.pow1:setVisible(false)
		self.pow.lastEff = false

    end

    if Stage.currentScene.fightLogic.aiState > Ai.AI_STATE_START 
		and Stage.currentScene.fightLogic.aiState < Ai.AI_STATE_ASSIST
		and Stage.currentScene.fightLogic.comboA
		and  heroA:getInfo():canUsePower(Define.comboPower) then
		--and Stage.currentScene.fightModel ~= Define.FightModel.autoA_autoB
		--and Stage.currentScene.fightModel ~= Define.FightModel.autoA_handB then

		self.jie.jie1:setVisible(true)
		self.jie.preEff:setVisible(false)
		--self.jie.eff:setVisible(true)
		if not self.jie.lastEff then
			self.jie.eff:getAnimation():play("按钮",-1,0)
		end
		self.jie.lastEff = true
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.jie.jie1, step = 9, nextTime = 1, preFun = function()
			preFunction(self.jie.jie1, true)	
		end, clickFun = function()	
			--self.hasGuideFinger = true
			clickFunction()
			Stage.currentScene:setComboStop(false)
		end, groupId = GuideDefine.GUIDE_CHAPTER_FOUR})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_COMBO)
	else
		GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 9, groupId = GuideDefine.GUIDE_CHAPTER_FOUR})
		self.jie.jie1:setVisible(false)
		--self.jie.eff:setVisible(false)
		self.jie.lastEff = false

		self.jie.preEff:setVisible(false)
		if heroA:getInfo():canUsePower(Define.comboPower) and Stage.currentScene.fightLogic.aiData.comboTips then
			self.jie.preEff:setVisible(true)
		end
	end

	--self:addGuideFinger()
end

function addGuideFinger(self)
	if self.hasGuideFinger then
    	local heroB = Stage.currentScene.heroB
		if heroB:isBeBeat() then
			if self.fingerEff == nil then
				self.fingerEff = ccs.Armature:create("Finger")
				self.fingerEff:getAnimation():play('特效', -1, 1)
				self.fingerEff:setPosition(self.jie:getContentSize().width/2, self.jie:getContentSize().height/2)
				self.jie._ccnode:addChild(self.fingerEff)
			end

			if self.finger == nil then
				self.finger = ccs.Armature:create("Finger")
				self.finger:getAnimation():play('手指', -1, 1)
				self.finger:getAnimation():setSpeedScale(6)
				self.finger:setPosition(self.jie:getContentSize().width/2, self.jie:getContentSize().height/2)
				self.jie._ccnode:addChild(self.finger)
			end
		else
			if self.fingerEff then
				self.fingerEff:removeFromParent()
				self.fingerEff = nil
			end
			if self.finger then
				self.finger:removeFromParent()
				self.finger = nil
			end
		end
	end
end

function stopFight(self)
	print("stopFight ========================================================")
	self:stopCD(true)

	Stage.currentScene.heroA:sleep()
	Stage.currentScene.heroB:sleep()
	Stage.currentScene:sleep()
	Stage.currentScene.fightLogic.isPause = true
end

function continueFight(self)
	print("continueFight =====================================================")
	self:startCD(self.curSec)
	----self:setCD(self.curSec)
	----self.cdTimer = self:addTimer(onCDTimer, 1, self.curSec, self)

	Stage.currentScene.heroA:wakeUp()
	Stage.currentScene.heroB:wakeUp()
	Stage.currentScene:wakeUp()

	Stage.currentScene.fightLogic.isPause = false

	--cc.Director:getInstance():getScheduler():setTimeScale(1)
end

function displayAssistEffect(self,hero,sp)
	if hero == Stage.currentScene.heroA then
		self.left:removeChildByName("assistEffect")
		self.left:addChild(sp)
		sp:setPosition(250,28)
	else
		self.right:removeChildByName("assistEffect")
		self.right:addChild(sp)
		sp:setPosition(10,28)
	end

end

function displayAddTimeEffect(self)
	self.addTimeEffect:setVisible(true)
	self.addTimeEffect:getAnimation():play("addTime",-1,1)

	local cd10 = Image.new(self.cd:getSkin()) 
	cd10:setAnchorPoint(0.5,0.5)
	cd10.name = "effect_cd10"
	local x,y = self.cd10:getPosition()
	local size = self.cd10:getContentSize()
	cd10:setPosition(x + size.width / 2,y + size.height / 2)
	self:addChild(cd10)
	local seq = cc.Sequence:create(
		cc.Spawn:create(
			cc.ScaleTo:create(1,2),
			cc.FadeOut:create(1)
		),
		cc.CallFunc:create(function() 
			cd10:removeFromParent()
			self.addTimeEffect:setVisible(false)
		end)
	)
	cd10:runAction(seq)

	local cd = Image.new(self.cd:getSkin()) 
	cd:setAnchorPoint(0.5,0.5)
	cd.name = "effect_cd"
	local x,y = self.cd:getPosition()
	local size = self.cd10:getContentSize()
	cd:setPosition(x + size.width / 2,y + size.height / 2)
	self:addChild(cd)
	local seq = cc.Sequence:create(
		cc.Spawn:create(
			cc.ScaleTo:create(1,2),
			cc.FadeOut:create(1)
		),
		cc.CallFunc:create(function() 
			cd:removeFromParent()
		end)
	)
	cd:runAction(seq)

	local sec = self.curSec or 0
	local n10 = sec - sec % 10
	local c1 =  sec - n10 - sec % 1
	local c10 = n10 / 10
	local skin = cd10:getStateSkinByName("cd" .. c10)
	if skin then
		cd10:show(skin)
	end
	skin = self.cd:getStateSkinByName("cd" .. c1)
	if skin then
		cd:show(skin)
	end
	self.cd:setTop()
	self.cd10:setTop()
end

function setAssist(self)
    local heroA = Stage.currentScene.heroA
    local heroB = Stage.currentScene.heroB

    local leftAssistCnt = heroA:getInfo():getAssistCnt()
	for k = 0,9 do
		self.assist.cnt["shuz" .. k]:setVisible(k == leftAssistCnt)
	end
	--self.assist.assistmask:setPercent(0)
	--local leftAssistPercent = heroA:getInfo():getAssistPercent()
	--self.assist.assistmask:setPercent(100 - leftAssistPercent)

	--[[
	self.lastLeftAssistCnt = self.lastLeftAssistCnt or 0
	if self.lastLeftAssistCnt < leftAssistCnt then
		self.assist.eff:getAnimation():play("援助爆发",-1,0)
	end
	self.lastLeftAssistCnt = leftAssistCnt
	--]]
	local assistVisible = leftAssistCnt > 0 and Stage.currentScene.fightLogic.aiState > Ai.AI_STATE_START and Stage.currentScene.fightLogic.aiState ~= Ai.AI_STATE_END
	--[[
	if Stage.currentScene.fightModel == Define.FightModel.autoA_autoB
		or Stage.currentScene.fightModel == Define.FightModel.autoA_handB then
		assistVisible = false
	end
	--]]
	self.assist.cnt:setVisible(assistVisible)
	self.assist.shuzibg:setVisible(assistVisible)
	self.assist.effLoop:setVisible(assistVisible)
	self.assist.yz:setVisible(assistVisible)
	--self.assist.yz:shader(leftAssistCnt <= 0 and Shader.SHADER_TYPE_GRAY or nil)
	--self.assist.assistmask:setVisible(leftAssistCnt > 0)


end

function setHp(self)
    local heroA = Stage.currentScene.heroA
    local heroB = Stage.currentScene.heroB
	local hpA = heroA:getInfo():getHpPercent() 
	local hpB = heroB:getInfo():getHpPercent() 
    self:setHPLeft(hpA)
    self:setHPRight(hpB)
	self.hpA = hpA
	self.hpB = hpB
	self.left.txthp:setString(string.format("%d/%d",heroA:getInfo():getHp(),heroA:getInfo():getMaxHp()))
	self.right.txthp:setString(string.format("%d/%d",heroB:getInfo():getHp(),heroB:getInfo():getMaxHp()))
end

function clearBuf(self)
	self.left.buf1:setVisible(false)
	self.left.buf2:setVisible(false)
	self.right.buf1:setVisible(false)
	self.right.buf2:setVisible(false)

	self.left.bufList = {}
	self.right.bufList = {}
end

function insertBuf(t,bufType,value,time)
	for k,v in ipairs(t) do
		if v.bufType == bufType then
			v.time = time
			v.isDirty = true
			return
		end
	end
	if #t < 2 then
		table.insert(t,{bufType = bufType,value = value,time = time,isDirty = true})
	end
end

function addBuf(self,hero,bufType,value,time)
	local heroA = Stage.currentScene.heroA
	local heroB = Stage.currentScene.heroB
	if hero == heroA then
		self.left.bufList = self.left.bufList or {}
		insertBuf(self.left.bufList,bufType,value,time)
	else
		self.right.bufList = self.right.bufList or {}
		insertBuf(self.right.bufList,bufType,value,time)
	end
end

function updateBuf(self)
	self.left.bufList = self.left.bufList or {}
	self.left.buf1:setVisible(false)
	self.left.buf2:setVisible(false)
	for k,v in ipairs(self.left.bufList) do
		local buf = self.left["buf" .. k]
		buf:setVisible(true)
		buf.time:setString(v.time .. "S")
		if v.isDirty then
			v.isDirty = false
			buf.icon._ccnode:setTexture("res/skill/buf/" .. v.bufType .. ".png")
			buf.icon._ccnode:setScale(1/Stage.uiScale)
		end
	end

	self.right.bufList = self.right.bufList or {}
	self.right.buf1:setVisible(false)
	self.right.buf2:setVisible(false)
	for k,v in ipairs(self.right.bufList) do
		local buf = self.right["buf" .. k]
		buf:setVisible(true)
		buf.time:setString(v.time .. "S")
		if v.isDirty then
			v.isDirty = false
			buf.icon._ccnode:setTexture("res/skill/buf/" .. v.bufType .. ".png")
			buf.icon._ccnode:setScale(1/Stage.uiScale)
		end
	end
end

function onBuf(self,event,target)
end

function onAWin(self)
	Stage.currentScene:setHeroBHp(0)
end

function onBWin(self)
	Stage.currentScene:setHeroAHp(0)
end

function updateFightModel(self)
	local flag = Stage.currentScene.fightModel == Define.FightModel.autoA_handB or Stage.currentScene.fightModel == Define.FightModel.autoA_autoB
	--[[
	self.pow.lock:setVisible(flag)
	self.pow.pow1:setEnabled(not flag)

	self.assist.lock:setVisible(flag)
	self.assist.yz:setEnabled(not flag)
	
	self.po.lock:setVisible(flag)
	self.po.po1:setEnabled(not flag)

	self.jie.lock:setVisible(flag)
	self.jie.jie1:setEnabled(not flag)
	--]]
	self.pow:setVisible(not flag)
	self.po:setVisible(not flag)
	self.assist:setVisible(not flag)
	self.jie:setVisible(not flag)

	self.zdzd:setVisible(flag)

	self.quxiao:setVisible(flag)
	self.zizhu:setVisible(not flag)
end

function onAuto(self,event)
	if event.etype == Event.Touch_ended then
		if Stage.currentScene.fightModel == Define.FightModel.handA_handB then
			Stage.currentScene.fightModel = Define.FightModel.autoA_handB
			Master:getInstance().fightModel = Define.FightModel.autoA_handB
		end

		if Stage.currentScene.fightModel == Define.FightModel.handA_autoB then
			Stage.currentScene.fightModel = Define.FightModel.autoA_autoB
			Master:getInstance().fightModel = Define.FightModel.autoA_autoB
		end
		self:updateFightModel()
	end
end

function onCancleAuto(self,event)
	if event.etype == Event.Touch_ended then
		if Stage.currentScene.fightModel == Define.FightModel.autoA_handB then
			Stage.currentScene.fightModel = Define.FightModel.handeA_handB
			Master:getInstance().fightModel = Define.FightModel.handeA_handB
		end

		if Stage.currentScene.fightModel == Define.FightModel.autoA_autoB then
			Stage.currentScene.fightModel = Define.FightModel.handA_autoB
			Master:getInstance().fightModel = Define.FightModel.handA_autoB
		end
		self:updateFightModel()
	end
end

function clear(self)
	Control.clear(self)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 11, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 8, groupId = GuideDefine.GUIDE_CHAPTER_THIRD})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 9, groupId = GuideDefine.GUIDE_CHAPTER_THIRD})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 9, groupId = GuideDefine.GUIDE_CHAPTER_FOUR})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 4, groupId = GuideDefine.GUIDE_CHAPTER_TEN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 5, groupId = GuideDefine.GUIDE_CHAPTER_TEN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 6, groupId = GuideDefine.GUIDE_CHAPTER_TEN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 7, groupId = GuideDefine.GUIDE_CHAPTER_TEN})
end
