module(..., package.seeall)
setmetatable(_M, {__index = Control}) 

UI_HERO_TYPE = "Hero"
isHero = true

--方向
DIRECTION_RIGHT = -1
DIRECTION_LEFT = 1
--默认宽高
DEFAULT_WIDTH = 100
DEFAULT_HEIGHT = 200

--默认速度
--local defaultSpeed = 3    --pix / Framef
--local heroBottom = 100  --英雄地面高度

local Define = require("src/modules/fight/Define")
local Rule = require("src/modules/fight/FightRule")
local Helper = require("src/modules/fight/KofHelper")
local HeroInfo = require("src/modules/fight/HeroInfo")
local Ai = require("src/modules/fight/Ai")
local SoundManager = require("src/modules/fight/SoundManager")
local SkillLogic = require('src/modules/skill/SkillLogic')
local SkillDefine = require('src/modules/skill/SkillDefine')
local HeroDefine = require("src/modules/hero/HeroDefine")
local SkillConfig = require("src/config/SkillConfig").Config
local Flyer = require("src/modules/fight/Flyer")
local Target = require("src/modules/fight/Target")
local GiftDefine = require("src/modules/gift/GiftDefine")
local GiftLogic = require("src/modules/gift/GiftLogic")

--构造器集合
local _Ctors = _Ctors or {} 

local playId = 0	--每一次播放一个动作自增1，为保证唯一

local speedScale = 1

function new(name,hero,isAssist)
	local o = { 
		name = name, 
		heroName = hero.name,
		hero = hero,
		isAssist = isAssist,
		animation = nil,
		lastState = nil,
		curState = nil,
		uiType = UI_HERO_TYPE,
		config = nil,
		--info = HeroInfo.new(hero.dyAttr.maxHp,hero.fightAttr and hero.fightAttr.hp,hero.fightAttr and hero.fightAttr.rage or hero.dyAttr.initRage, hero.fightAttr and hero.fightAttr.assist or hero.dyAttr.assist * 100),
		hiting = nil,
		direction = nil,--DIRECTION_LEFT,
		shadowBone = nil,
		nextStateTime = 0,
		playId = 0,
		hitId = 0,
		isPause = false,
		comboCnt = 0,
		isHarm = nil,
		invincible = nil,	--无敌
		isShadowVisible = true,
		noHold = false,	--不hold
		canPenetrate = false,	--不能穿透
		noTurn = false,		--不交换方向
		assist = nil,		--援助
		isOpenGhost = false, --是否开残影
		gift = {cnt={},cd={},timer={},dyAttr={},dyAttrR={},nextHero={}},			--天赋
	}

	local ctor = _Ctors[hero.name] or _M
	setmetatable(o, {__index = ctor})

	o:init()
	--[[
	if name == "heroB" then
		o:setScale(1.5)
	else
		--o:setScale(0.5)
	end
	--]]
    return o
end

--注册需要特写的英雄构造
function regHeroCtor(heroName, ctor)
	_Ctors[heroName] = ctor
end

function init(self)
    --config
    --
    self.config = require("src/config/hero/" .. self.heroName .. "Config").Config
    setmetatable(self.config, {__index = Define.HeroState}) 
	self.curState = self.config["stand"]
	self.lastState = self.config["stand"]

	local node = cc.Node:create()
	node:setPosition(0, 0)
    node:setAnchorPoint(0, 0)
	self._ccnode = node 
	
	self:addSpriteFrames("res/armature/target/Target.plist")
    --ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/armature/iori/iori.png","res/armature/iori/iori.plist","res/armature/iori/iori.ExportJson")
	--self:addArmatureFrame(Define.resUrl[self.heroName])
	self:addArmatureFrame(string.format("res/armature/%s/%s.ExportJson",string.lower(self.heroName),self.heroName))
	--[[
	--援助特效（只有粒子）
	self:addArmatureFrame("res/armature/effect/assist/addAtk/AssistAddAtk.ExportJson")
	self:addArmatureFrame("res/armature/effect/assist/addHp/AssistAddHp.ExportJson")
	self:addArmatureFrame("res/armature/effect/assist/decDef/AssistDecDef.ExportJson")
	self:addArmatureFrame("res/armature/effect/assist/power/AssistPower.ExportJson")

	---克制特效
	self:addArmatureFrame("res/armature/effect/SkillCareer.ExportJson")

	--破招
	self:addArmatureFrame("res/armature/effect/BreakEffect.ExportJson")

	--接招
	self:addArmatureFrame("res/armature/effect/ComboEffect.ExportJson")
	--]]

    self.animation =ccs.Armature:create(self.heroName)
    --self.animation:getAnimation():setSpeedScale(1.3)
    self.animation:getAnimation():setSpeedScale(speedScale)
    self.animation:setAnchorPoint(0.5,0.5)
    --self.animation:setAnchorPoint(0.5,0)
    self.animation:setPosition(0,0)
    self._ccnode:addChild(self.animation)
	self.shadowBone = self.animation:getBone("影子")
	if self.name == "heroA" then
		self.shadowBone:addDisplay(ccs.Skin:create("res/armature/1pShadow.png"),0)
		--self.shadowBone:getDisplayManager():setColor(cc.c3b(255,255,255))
		--self.animation:setColor(cc.c3b(math.random(1,255),math.random(1,255),math.random(1,255)))
		--self.animation:setColor(cc.c3b(0,0,0))
		--self.animation:setColor(cc.c3b(182,111,179))
		--self.animation:setColor(cc.c3b(98,120,251))
		--self.animation:setColor(cc.c3b(126,255,129))
		--self.animation:setColor(cc.c3b(251,96,242))
	end
	--test
	--[[
	if self.name == "heroA" then
		self.animation:setScale(2)
	end
	--]]
    self:setDirection(DIRECTION_RIGHT)

    self.animation:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) self:onAnimationEvent(armatureBack,movementType,movementID) end)
    self.animation:getAnimation():setFrameEventCallFunc(function(bone,evt,originFrameIndex,currentFrameIndex) self:onAnimationFrameEvent(bone,evt,originFrameIndex,currentFrameIndex) end)


	self:setSkin()
	self:setTarget()

	if self.isAssist then
		self:initAssist()
	end

	--self:initEffect()
	self.effectList = {}

	if self.hero.quality >= 5 then
		--self.shineDown = self:displayEffect("res/armature/effect/shineEffect/ShineEffect.ExportJson",'ShineEffect',"ShineDown",0,nil,-1,1)
		self.shineUp = self:displayEffect("res/armature/effect/shineEffect/ShineEffect.ExportJson",'ShineEffect',"ShineEffect",0,0,nil,1)
	end

	self:openTimer()
	self:addEventListener(Event.Frame,onFrameEvent,self)

	--self:fxFire()
	if self.name == "heroA" then
		self.assistRAttr = Stage.currentScene.fightControl.assistRAttrA
	else
		self.assistRAttr = Stage.currentScene.fightControl.assistRAttrB
	end

	self.info = HeroInfo.new(self:getDyAttr("maxHp"),self.hero.fightAttr and self.hero.fightAttr.hp,self.hero.fightAttr and self.hero.fightAttr.rage or self:getDyAttr('initRage'), self.hero.fightAttr and self.hero.fightAttr.assist or self:getDyAttr('assist') * 100)
	self.info:setHero(self)
end

function clear(self)
	if self.isAssist then
		self.master:setAssist(nil)
	end
	Control.clear(self)
end

function initAssist(self)
end

local effectNameId = 0
function displayEffect(self,url,exportJson,actionName,x,y,zorder,loop)
	effectNameId = effectNameId + 1
	local skin = {name="myCtrl" .. effectNameId,type="Container",x=0,y=0,width=0,height=0,children={}}
	local ctrl = Control.new(skin)
	ctrl:addArmatureFrame(url)
    local bone = ccs.Armature:create(exportJson)
    bone:setAnchorPoint(0.5,0.5)
    bone:setPosition(0,0)
    ctrl._ccnode:addChild(bone)
	self:addChild(ctrl,zorder or 0)
	bone:getAnimation():play(actionName,-1,loop or 0)

	self.effectList[ctrl] = {x = x,y = y}
    bone:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
		if movementType == ccs.MovementEventType.complete then
			self.effectList[ctrl] = nil
			self:addTimer(function() 
				self:removeChild(ctrl)
			end,0.0001,1)
		end
	end)
	return ctrl 
end

function initEffect(self)

    self.assistAddAtk= ccs.Armature:create("AssistAddAtk")
    self.assistAddAtk:setAnchorPoint(0.5,0.5)
    self.assistAddAtk:setPosition(0,0)
	--self.assistAddAtk:setVisible(false)
    self._ccnode:addChild(self.assistAddAtk,-1)

    self.assistDecDef = ccs.Armature:create("AssistDecDef")
    self.assistDecDef:setAnchorPoint(0.5,0.5)
    self.assistDecDef:setPosition(0,0)
	--self.assistDecDef:setVisible(false)
    self._ccnode:addChild(self.assistDecDef)

    self.assistPower = ccs.Armature:create("AssistPower")
    self.assistPower:setAnchorPoint(0.5,0.5)
    self.assistPower:setPosition(0,0)
	--self.assistPower:setVisible(false)
    self._ccnode:addChild(self.assistPower)

    self.assistAddHp = ccs.Armature:create("AssistAddHp")
    self.assistAddHp:setAnchorPoint(0.5,0.5)
    self.assistAddHp:setPosition(0,0)
	--self.assistAddHp:setVisible(false)
    self._ccnode:addChild(self.assistAddHp)

	------skill power
    self.careerEffect = ccs.Armature:create("SkillCareer")
    self.careerEffect:setAnchorPoint(0.5,0.5)
    self.careerEffect:setPosition(0,0)
	--self.careerEffect:setVisible(false)
    self._ccnode:addChild(self.careerEffect)

	------break power
    self.breakEffect = ccs.Armature:create("BreakEffect")
    self.breakEffect:setAnchorPoint(0.5,0.5)
    self.breakEffect:setPosition(0,0)
	--self.breakEffect:setVisible(false)
    self._ccnode:addChild(self.breakEffect)

	------break power
    self.comboEffect = ccs.Armature:create("ComboEffect")
    self.comboEffect:setAnchorPoint(0.5,0.5)
    self.comboEffect:setPosition(0,0)
	--self.comboEffect:setVisible(false)
    self._ccnode:addChild(self.comboEffect,-1)
end

function setSkin(self,boneRes)
	boneRes = boneRes or {}
	for name,res in pairs(boneRes) do
		local bone = self.animation:getBone(name)
		for k,v in pairs(res) do
			local skin = ccs.Skin:createWithSpriteFrameName(v)
			if skin then
				bone:addDisplay(skin,k - 1)
			end
		end
	end
end

function getBgEffectDirect(self)
	return 1
end

function setTarget(self)
end

function setEnemy(self, enemy)
	self.enemy = enemy
end

function setMaster(self,master)
	self.master = master
end

function setAssist(self,assist)
	self.assist = assist
end

function getAssist(self)
	return self.assist
end

function getAssistType(self)
	return Define.AssistType.none
end

function getEnemyDis(self)
	return Helper.heroDistance(self,self.enemy)
end

function getSoundEffect(self,stateName)
	local soundTable = self:getSoundTable()
	return soundTable[stateName or self.curState.name] or self.curState.sound
	--return self.curState.sound
end

function getSoundTable(self)
end

function getHitSoundEffect(self)
	return "common/HitHeavy.mp3"
end

function isHit(self,rect)
	local boundBox = self:getBodyBox()
	local bRect = self:changeToRealRect(boundBox)
	--print('---------------------........................isHit:',rect.x,rect.y,rect.width,rect.height,bRect.x,bRect.y,bRect.width,bRect.height)
	local ret,minx,miny,maxx,maxy = Helper.isIntersect(rect,bRect)
	--print('-------------------ret,minx,miny,maxx,maxy:',ret,minx,miny,maxx,maxy)
	return ret,(minx + maxx) / 2,(miny + maxy) / 2
end

function setDirection(self,direction,force)
    if direction == DIRECTION_RIGHT or direction == DIRECTION_LEFT then
        if self.direction ~= direction or force then
			local x = self:getPositionX()
            self.direction = direction
			local scale = self.animation:getScaleY()
            self.animation:setScaleX(direction == DIRECTION_LEFT and 1 * scale or -1 * scale)
			self:setPositionX(x)
        end
    end
end

function getDirection(self)
    return self.direction or 1
end

function getConfig(self)
    return self.config
end

function setComboCnt(self,cnt)
	self.comboCnt = cnt or 0
	GiftLogic.checkGift(self,GiftDefine.ConditionType.hit,self.comboCnt)
end

function getInfo(self)
    return self.info
end

function setInfo(self,info)
	self.info = info
end

function setNoHold(self,flag)
	self.noHold = flag
end

function getPenetrate(self)
	return self.canPenetrate
end

--穿透
function setPenetrate(self,flag)
	--print(debug.traceback())
	self.canPenetrate = flag
end

function setNoTurn(self,flag)
	self.noTurn = flag
end

function getNoTurn(self)
	return self.noTurn
end

--残影
function setGhost(self, isOpen)
	self.isOpenGhost = isOpen
	self.step = nil
end

function setNextStateTime(self,time)
	self.nextStateTime = time
end

function decHp(self,hp,isAssist)
	local preHp = self:getInfo():getHp()
	local preHpR = self:getInfo():getHpPercent()
	hp = math.floor(hp)
	if hp <= 0 then
		return
	end
	--天赋减伤
	--hp = hp * (1 - (self.gift.decHarmR or 0))
	self:getInfo():addPower(100 * self.hero.dyAttr.rageRByHp * math.min(hp,self:getInfo():getHp()) / self:getInfo():getMaxHp() )
	self:getInfo():decHp(hp)
	--[[
	GiftLogic.checkGift(self,GiftDefine.ConditionType.hp,preHp)
	GiftLogic.checkGift(self,GiftDefine.ConditionType.hpR,preHpR/100)
	GiftLogic.checkGift(self,GiftDefine.ConditionType.hpGt)
	GiftLogic.checkGift(self,GiftDefine.ConditionType.hpLt)
	--]]
	GiftLogic.checkGift(self,GiftDefine.ConditionType.decHp,hp)
	GiftLogic.checkGift(self,GiftDefine.ConditionType.decHpR,hp / self:getInfo():getMaxHp())

	if self.hero.fightAttr and self.hero.fightAttr.hp then
		self.hero.fightAttr.hp = self:getInfo():getHp()
	end
	local rect = self:getBodyBoxReal()
	local needDecHpEffect = true
	if self.enemy.curSkill then
		--暴击
		if self.enemy.curSkill.isCrtHit then
			needDecHpEffect = false
			self:displayFightEffect("crit","fe_bj",-hp)
			Stage.currentScene.ui:displayCrtEffect(self)
			GiftLogic.checkGift(self,GiftDefine.ConditionType.crtHit)
			GiftLogic.checkGift(self.enemy,GiftDefine.ConditionType.enemyCrtHit)
		end

		--格挡
		if self.enemy.curSkill.isBlock then
			needDecHpEffect = false
			self:displayFightEffect("block","fe_gd",-hp)
			GiftLogic.checkGift(self,GiftDefine.ConditionType.block)
			GiftLogic.checkGift(self.enemy,GiftDefine.ConditionType.enemyBlock)
		end

		--[[
		if self.enemy.curSkill.comboCntFactor then
		end
		--]]
	end
	if isAssist then
		needDecHpEffect = false
		self:displayFightEffect("harm","fe_zhgj",-hp)
	end
	if needDecHpEffect then
		self:displayFightEffect("harm","fe_kx",-hp)
		--Stage.currentScene:displayDecHp(hp,rect.x + rect.width / 2,rect.y + rect.height + 10)
	end
	Stage.currentScene:dispatchEvent(Event.FightHarm,{etype = Event.FightHarm,name=self.name,harm=hp,curHp=self:getInfo():getHp(),maxHp=self:getInfo():getMaxHp()})
end

function onAnimationFrameEvent(self,bone,evt,originFrameIndex,currentFrameIndex)
	print('===================bone,evt,originFrameIndex,currentFrameIndex:',bone,evt,originFrameIndex,currentFrameIndex)
	--if _M[evt] then
	if self[evt] then
		self[evt](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		print('---------------------------------error:,evt,state:',evt,self.curState.name)
	end
end

function update(self,event)
end

function onFrameEvent(self,event)
    if self.curState then
		--print('========================<<<<<<<>>>>>>>>>>======================onFrame:',self.name,self.heroName,self.curState.name)
		if (self.curState.speedX or self.speedX) and (self.curState.canRun or self.canRun) then
			self:run(event.delay)
		--else
			--print('----------------------onFrame,speedX,,canRun,,:',self.name,self.heroName,self.curState.name,self.curState.speedX,self.speedX,self.curState.canRun,self.canRun)
		end

		local y = self._ccnode:getPositionY()
		if y > Define.heroBottom then
			--jason
			if not self:isJump() and self.curState.lock < Define.AttackLock.defense then
				local dy = y - Define.heroBottom 
				self._ccnode:setPositionY(dy < 5 and y - dy or y-5)
			end

			self:setShadowVisible(false)
			--[[
			if self.shineUp then
				self.shineUp:setVisible(false)
			end
			if self.shineDown then
				self.shineDown:setVisible(false)
			end
			--]]
		else
			if y < Define.heroBottom then
				self._ccnode:setPositionY(Define.heroBottom)
			end
			self:setShadowVisible(true)
			--[[
			if self.shineUp then
				self.shineUp:setVisible(true)
			end
			if self.shineDown then
				self.shineDown:setVisible(true)
			end
			--]]
		end

		if self.targetAnimation and not self.noAdjustTarget then
			local box = self.targetAnimation:getBone("身体"):getDisplayManager():getBoundingBox()
			local rBox = self:changeToRealRect(box)
			self.enemy:setPositionX(rBox.x + rBox.width / 2)

			local tx = self.targetAnimation:getPositionX()
			local nx = self._ccnode:getPositionX()
			local x = nx + tx + (box.x + box.width / 2) * self:getDirection()
			local lx = Stage.currentScene:getLeft()
			local rx = Stage.currentScene:getRight()
			--print('=================================target,tx,nx,x,lx,rx:',tx,nx,x,lx,rx)
			if x < lx + 100 then
				self.targetAnimation:setPositionX((lx + 100) - nx -((box.x + box.width / 2) * self:getDirection()))
			elseif x > rx - 100 then
				self.targetAnimation:setPositionX((rx - 100) - nx -((box.x + box.width / 2) * self:getDirection()))
			else
				if tx ~= 0 then
					self.targetAnimation:setPositionX(tx - math.abs(tx) / tx)
				end
			end
		end

		--援助特效
		local boundBox = self:getShadowBox()
		local x = (boundBox.x + boundBox.width / 2) * self:getDirection()
		local boundBox = self:getBodyBox()
		local y = boundBox.y --+ boundBox.height / 2
		--[[
		self.assistAddAtk:setPosition(x,y + boundBox.height / 2)
		self.assistDecDef:setPosition(x,y + boundBox.height / 2)
		self.careerEffect:setPosition(x,y + boundBox.height / 2)
		self.breakEffect:setPosition(x,y + boundBox.height / 2)
		self.comboEffect:setPosition(x,0)
		self.assistAddHp:setPosition(x,y)
		self.assistPower:setPosition(x,y)
		--]]
		for k,v in pairs(self.effectList) do
			if v.x then
				k:setPositionX(x + v.x)
			end
			if v.y then
				k:setPositionY(y + v.y)
			end
		end

		self:update(event)
		if self.isAssist then
			self:updateAssist()
		end

		GiftLogic.checkGift(self,GiftDefine.ConditionType.hp)
		GiftLogic.checkGift(self,GiftDefine.ConditionType.hpR)
		GiftLogic.checkGift(self,GiftDefine.ConditionType.hpGt)
		GiftLogic.checkGift(self,GiftDefine.ConditionType.hpLt)

		--[[残影测试
		local box = self.animation:getBoundingBox()
		if self._drawBox then
			self._ccnode:removeChild(self._drawBox)
		end
		self._drawBox = Common.getDrawBoxNode(box,cc.c4b(255,255,0,100))
		self._ccnode:addChild(self._drawBox)
		]]
		--self:fxGhost()
		self:refreshGhost()
		--]]
    end
end

function refreshGhost(self)
	if self.isOpenGhost == true then
		if self.step == nil or self.step % 10 == 0 then
			if self.afterImgList == nil then
				self.afterImgList = {}
			end
			if self.lastPosX ~= self._ccnode:getPositionX() or self.lastPosY ~= self._ccnode:getPositionY() then
				local afterImg = cc.Node:create()
				afterImg:setPosition(0, 0)
    			afterImg:setAnchorPoint(0, 0)
    			local afterAnimation =ccs.Armature:create(self.heroName)
    			afterAnimation:getAnimation():setSpeedScale(speedScale)
    			afterAnimation:setAnchorPoint(0.5,0.1)
    			afterImg:addChild(afterAnimation)
				afterImg:setCascadeOpacityEnabled(true)
				self._ccnode:getParent():addChild(afterImg)

				if self.animation:getAnimation():getCurrentMovementID() ~= "" then
					afterAnimation:getAnimation():play(self.animation:getAnimation():getCurrentMovementID())
				end
				afterAnimation:setScaleX(self:getDirection())
				afterAnimation:getAnimation():gotoAndPlay(self.animation:getAnimation():getCurrentFrameIndex())
				afterImg:setPosition(self._ccnode:getPosition())

				afterImg:runAction(cc.Sequence:create(
					cc.FadeOut:create(2),
					cc.CallFunc:create(function()
						afterImg:removeFromParent()
						for index,img in ipairs(self.afterImgList) do
							if img == afterImg then
								table.remove(self.afterImgList, index)
								break
							end
						end
					end)
				))
				table.insert(self.afterImgList, afterImg)
				if #self.afterImgList > 5 then
					local temp = table.remove(self.afterImgList, 1)
					temp:stopAllActions()
					temp:removeFromParent()
				end
			end
			self.lastPosX,self.lastPosY = self._ccnode:getPosition()
		end
		if self.step == nil then
			self.step = 1
		else
			self.step = self.step + 1
		end
	end
	--if self.afterImgList == nil then
	--	self.afterImgList = {}
	--	self.afterAnimationList = {}
	--	for i=1,5 do
	--		local afterImg = cc.Node:create()
	--		afterImg:setPosition(0, 0)
    --		afterImg:setAnchorPoint(0, 0)
	--		
    --		local afterAnimation =ccs.Armature:create(self.heroName)
    --		afterAnimation:getAnimation():setSpeedScale(speedScale)
    --		afterAnimation:setAnchorPoint(0.5,0.1)
    --		afterImg:addChild(afterAnimation)
	--		afterImg:setCascadeOpacityEnabled(true)
	--		afterImg:setOpacity(200 - i * 20)
	--		self._ccnode:addChild(afterImg)

	--		table.insert(self.afterImgList, afterImg)
	--		table.insert(self.afterAnimationList, afterAnimation)
	--	end
	--end
	--for i=1,5 do
	--	local afterAnimation = self.afterAnimationList[i]
	--	local afterImg = self.afterImgList[i]
	--	if self.animation:getAnimation():getCurrentMovementID() ~= "" then
	--		afterAnimation:getAnimation():play(self.animation:getAnimation():getCurrentMovementID())
	--	end
	--	afterAnimation:setScaleX(self:getDirection())
	--	afterAnimation:getAnimation():gotoAndPlay(self.animation:getAnimation():getCurrentFrameIndex())
	--	if self:getDirection() == -1 then
	--		afterImg:setPosition(cc.p(-10 * i * i, 0))
	--	else
	--		afterImg:setPosition(cc.p(10 * i * i, 0))
	--	end
	--end
end

function changeToRealRect(self,boundBox)
	local x,y = self._ccnode:getPosition()
	local minX = x + boundBox.x * self:getDirection()
	local maxX = x + (boundBox.x + boundBox.width) * self:getDirection()
	if minX > maxX then
		minX,maxX = maxX,minX
	end
	local minY = y + boundBox.y
	local maxY = y + boundBox.y + boundBox.height
	return cc.rect(minX,minY,maxX-minX,maxY-minY)
end

function getContentSize(self)
    local boundBox = self.animation:getBoundingBox()
	return cc.size(boundBox.width,boundBox.height)
end

function setShadowVisible(self,flag)
	flag = flag and true or false
	if flag ~= self.isShadowVisible then
		self.shadowBone:getDisplayManager():setVisible(flag)
		self.isShadowVisible = flag
	end
end

function getShadowBox(self)
    return self.shadowBone:getDisplayManager():getBoundingBox()
end

function getShadowRect(self)
    local boundBox = self.shadowBone:getDisplayManager():getBoundingBox()
    return boundBox
end

function getBodyBoxReal(self)
	local boundBox = self:getBodyBox()
	local realBox = self:changeToRealRect(boundBox)

	------外框
	--[[
	local node = Common.getDrawBoxNode(realBox)
	if self.drawNode then
		Stage.currentScene.arena._ccnode:removeChild(self.drawNode,true)
		self.drawNode = nil
	end
	self.drawNode = node
	Stage.currentScene.arena._ccnode:addChild(node)

	if self.animation:getBone("攻击点") then
		local bb = self.animation:getBone("攻击点"):getDisplayManager():getBoundingBox()
		local rb = self:changeToRealRect(bb)
		local node = Common.getDrawBoxNode(rb,cc.c4b(255,255,0,100))
		if self.drawNode2 then
			Stage.currentScene.arena._ccnode:removeChild(self.drawNode2,true)
		end
		self.drawNode2 = node
		Stage.currentScene.arena._ccnode:addChild(node)
	end

	--]]

	return realBox
end

function getBodyBox(self)
	local minX,maxX,minY,maxY
	--print('----------------------------name:',self.name,self.heroName,self.curState.name)
	local bodyBone = Define.bodyBone[self.heroName] or {"受击框"}
	for _,v in ipairs(bodyBone)do
		--print('-----------------v:',v)
		local boundBox = self.animation:getBone(v):getDisplayManager():getBoundingBox()
		--print('-----------------boundBox:',boundBox.x,boundBox.y,boundBox.width,boundBox.height)
		--print('>>>>>>>>>>>>>>>>>>>b,x,y,width,height:',v,boundBox.x,boundBox.y,boundBox.width,boundBox.height)
		--if boundBox.x == 0 and boundBox.y == 0 and boundBox.width == 0 and boundBox.height == 0 then
		--else
			minX = minX and math.min(minX,boundBox.x) or boundBox.x
			maxX = maxX and math.max(maxX,boundBox.x + boundBox.width) or (boundBox.x + boundBox.width)
			minY = minY and math.min(minY,boundBox.y) or boundBox.y
			maxY = maxY and math.max(maxY,boundBox.y + boundBox.height) or (boundBox.y + boundBox.height)
		--end
	end
	--print('========================minX,maxX,minY,maxY:',minX,maxX,minY,maxY)

	--return cc.rect(minX,minY,maxX-minX,maxY + 80 -minY)
	--redo
	--[[
	if self.heroName ~= "Robert" and self.heroName ~= "Terry" and self.heroName ~="Mai" and self.heroName ~= "Ryo" then
		maxY = maxY + 80
	end
	--]]
	return cc.rect(minX,minY,maxX-minX,maxY -minY)
end

function getPosition(self)
    local boundBox = self:getShadowBox()
    local x,y = self._ccnode:getPosition()
    return x + (boundBox.x + boundBox.width / 2) * self:getDirection(),y
end

function getPositionX(self)
    local boundBox = self:getShadowBox()
    local x = self._ccnode:getPositionX()
    return x + (boundBox.x + boundBox.width / 2) * self:getDirection()
end

function getPositionY(self)
    --???????
    local y = self._ccnode:getPositionY()
    return y
end

function adjustX(x)
	x = math.max(x,100)
	x = math.min(x,Stage.currentScene.mapWidth - 100)
	return x
end

function setPosition(self,x,y)
	x = adjustX(x)
    local boundBox = self:getShadowBox()
	local rx = x - (boundBox.x + boundBox.width /2) * self:getDirection()
    self._ccnode:setPosition(rx,y)
	--print(debug.traceback())
end

function setPositionX(self,x)
	--print('-------------------------x:',x)
	x = adjustX(x)
    local boundBox = self:getShadowBox()
	local rx = x - (boundBox.x + boundBox.width / 2) * self:getDirection()
    self._ccnode:setPositionX(rx)
	--print(debug.traceback())
end

function setPositionY(self,y)
    self._ccnode:setPositionY(y)
end

function isInvincible(self)
	--倒地瞬间要不要打人？
	--return self.invincible or self.curState.invincible
	return self.curState.invincible
end

function getBeBeatState(self,skillId)
	local v = self.config[skillId].beBeat
	local stateName = v[math.random(1,#v)]
	return stateName or "stand"
end

function canHit(self,skillId)
	local v = self.config[skillId]
	local dis = self:getEnemyDis()
	if v and  v.rangeMin <= dis and dis <= v.rangeMax then
		return not self.enemy:isInvincible()
		--return self.enemy.curState.lock < Define.AttackLock.fall
	end
end

--当前状态能不能前进
function canForward(self)
	return self.curState.lock <= Define.AttackLock.defense and not self:isJump() and self.curState.canBreak
end

--当前状态是否准备好可以打人
function isReadyToBeat(self)
	--hit_fly_a b  --倒地瞬间应该不能打，，todo
	--return self.curState.lock < Define.AttackLock.attack and self.enemy.curState.lock < Define.AttackLock.fall
	return self.curState.lock < Define.AttackLock.attack and not self:isJump() and not self.enemy:isInvincible()
end

function isHiting(self)
	return self.hiting or self.enemy.curState.lock == Define.AttackLock.beat or self.enemy.curState.lock == Define.AttackLock.fall
end

function isBeBeat(self)
	--print('-------------------------------self.name,state,enemyState:',self.name,self.curState.lock,self.enemy.curState.lock,self.enemy.lastState.lock)
	return (self.curState.lock == Define.AttackLock.beat or self.curState.lock == Define.AttackLock.fall or self.enemy.targetAnimation) and (self.enemy.curState.lock == Define.AttackLock.attack or self.enemy.lastState.lock == Define.AttackLock.attack)
end

function getHitCnt(self)
	local cfg = self.config[self.curState.name]
	if not cfg then
		return 0
	end
	if not cfg.hitEvent then
		return 0
	end
	return cfg.hitEvent.cnt or 0
end

--切换成给挨打状态
function changeToBeBeat(self,stateName)
	if self.curState.name == "stand_defense" then
		self:play(stateName,true)
		return
	end
	if self.curState.lock <= Define.AttackLock.attack and not self:isJump() then
		self:play(stateName,true)
		return
	end
end

function isJump(self)
	return self.curState and self.curState.isJump
end

function getSex(self)
	return self.hero.gender
end

function getAi(self)
	if Stage.currentScene.fightType == Define.FightType.arena then
		return 110
	end
	return self.hero.ai or 1
end

function getDyAttr(self,field)
	--print('---------------------getDyAttr,field:',self.name,field)
	local res = self.hero.dyAttr[field] or 0
	local resA = 0
	local resR = 0
	--天赋加成
	self.gift = self.gift or {}
	self.gift.dyAttr = self.gift.dyAttr or {}
	resA = resA + (self.gift.dyAttr[field] or 0)

	self.gift.dyAttrR = self.gift.dyAttrR or {}
	resR = resR + res * (self.gift.dyAttrR[field] or 0)
	--援助加成
	resA = resA + (self.assistRAttr.dyAttr[field] or 0)
	resR = resR + res * (self.assistRAttr.dyAttrR[field] or 0)

	-- vip副本加成
	if self.vipLevelAttr then
		resA = resA + (self.vipLevelAttr[field] or 0)
	end

	return res  + resA + resR
end

function getAssistSkill(self)
	local skill = SkillLogic.getSkillGroup(self.hero,SkillDefine.TYPE_ASSIST):getSkillObjList()[1]
	skill:randomActionId()
	return skill
end

function getPowerSkill(self)
	--return SkillLogic.skillId2ActionId(SkillLogic.getSkillByType(self.hero,SkillDefine.TYPE_FINAL).skillId)
	local skill = SkillLogic.getSkillGroup(self.hero,SkillDefine.TYPE_FINAL):getSkillObjList()[1]
	skill:randomActionId()
	return skill
end

function getComboSkill(self)
	--return SkillLogic.skillId2ActionId(SkillLogic.getSkillByType(self.hero,SkillDefine.TYPE_FINAL).skillId)
	local skill = SkillLogic.getSkillGroup(self.hero,SkillDefine.TYPE_COMBO):getSkillObjList()[1]
	skill:randomActionId()
	return skill
end

function getHpRecover(self)
	return self:getDyAttr("hpR")
	--return self.hero.dyAttr.hpR or 0
end

function getPowerRecover(self)
	--print('--------------------------------------rageR:',self.hero.dyAttr.rageR)
	return self:getDyAttr("rageR")
	--return self.hero.dyAttr.rageR or 0
end

function getAssistRecover(self)
	return self.hero.dyAttr.assistR or 0
end

function actionId2SkillId(self,actionId)
	return self.config[actionId].skillId
end

function getAtk(self)
	--[[
	do
		return self.curSkill and self.curSkill:getAtk() or 0
	end
	--]]
	if not self.curSkill then
		assert(false)
		return 0
	end
	local damageType = SkillConfig[self.curSkill.skillId].damageType
	local atk = self.hero.dyAttr[damageType] or 0
	--atk = atk + self.curSkill:getAtk()
	return atk
end

function getEnemyDef(self)
	if not self.curSkill then
		assert(false)
		return 0
	end
	local damageType = SkillConfig[self.curSkill.skillId].damageType 
	local def = self.enemy.hero.dyAttr[HeroDefine.DyAttrAtk2Def[damageType]] or 0
	return def
end

function getBreakHarm(self)
	local skill = SkillLogic.getSkillGroup(self.hero,SkillDefine.TYPE_BROKE):getSkillObjList()[1]
	--skill:randomActionId()
	skill:randomHarm(self)
	return skill:getHarm(self)
end

function randomHarm(self)
	if not self.curSkill then
		assert(false)
		return 0
	end
	--self.curSkill:randomHarm(self.enemy.hero)
	self.curSkill:randomHarm(self)
end

--(INT((最终伤害*1.5)^0.85*(1-4*(最终抵挡*1.5)^1.15/((最终伤害*1.5)+4*(最终抵挡*1.5)^1.15)))^1.3)
--最终拳脚伤害 = 最终攻方拳脚攻击值 * 最终攻方拳脚攻击值 / ( 最终攻方拳脚攻击值 + 最终守方拳脚防御值 )
function getHarm(self)
	--[[
	do
		return 0
	end
	--]]
	if not self.curSkill then
		assert(false)
		return 0
	end
	--return self.curSkill:getHarm(self.enemy.hero)
	return self.curSkill:getHarm(self)
	--[[
	local atk = self:getAtk()
	--print('------------------------------------------------------------------atk:',atk)
	local def = self:getEnemyDef()
	--print('------------------------------------------------------------------def:',def)
	--local harm = math.pow((math.pow((atk*1.5),0.85)*(1-math.pow(4*(def*1.5),1.15)/((atk*1.5)+4*(def*1.5)^1.15))),1.3)
	--local harm = math.floor(((atk*1.5)^0.85*(1-4*(def*1.5)^1.15/((atk*1.5)+4*(def*1.5)^1.15))))^1.3
	--print('----------------------------actionId,harm:',actionId,harm)
	local harm = atk * atk / (atk + def)
	return self.curSkill:getAtk(harm)
	--return harm
	--]]
end

function doAfterRound(self)
end

function doAfterBeatByAssist(self)
	 if self:getInfo():isDie() then
		 if not self.curState.isFloor then
			 self:play("dead",true)
		 end
	 end
end

function doAfterBeat(self,force)
	self.animation:getAnimation():setSpeedScale(1)

	local tmpPlayId = self.playId
	local tmpEnemyPlayId = self.enemy.playId
	--[[
	if self:getAssist() then
		self:getAssist():doAfterBeat(force)
	end
	--]]
	 if self.curState.lock == Define.AttackLock.defense then
		 if Stage.currentScene:hasFlyer() then
			 self:addTimer(function() 
				 if self.playId == tmpPlayId then
					self:play("stand",true)
				 end
			 end,1.8,1)
		 else
			self:play("stand",true)
		 end
	 --elseif self.curState.lock == Define.AttackLock.power then

	 else
	 --elseif self.curState.lock == Define.AttackLock.beat then
		 if self:getInfo():isDie() then
			 --self:endBurn()
			 if not self.curState.isFloor then
				 self:play("dead",true)
			 end
		 else
			 if not self:isJump() and self.curState.lock ~= Define.AttackLock.fall then
				 local delayTime = 0.2
				 self:addTimer(function() 
					 if self.playId == tmpPlayId then
						 if not self.enemy.hiting or force then
							self:endBurn()
							self:play("stand",true)
						end
					 end
				 end,0.2,1)
			 end
		 end
     end
end

function onFinishAction(self)
	--清除shader
	if self.curState.shader and self.curState.shader ~= "" then
		Stage.currentScene:setShader()
	end

	--清除背景特效
	Stage.currentScene:removeBgEffect()

	local nowStateName = self.curState.name
	if not self.curState.hold or self.noHold then
		self:setNoHold(false)
		self:setPenetrate(false)
		self:setNoTurn(false)
		self.invincible = nil
		self.canRun = nil

		local finishAction = function()
			self:endTarget()
			--self:endBurn()
			--处理方向
			--Stage.currentScene:handleTurn()
			if self.curState.lock == Define.AttackLock.attack then
			  --完成攻击后
			  if self.isAssist then
				  self.enemy:doAfterBeatByAssist()
			  else
				  self.enemy:doAfterBeat()
			  end
			  self.hiting = false
			end
			local nx = self:getPositionX()
			local nextState = self.curState.nextState or "stand"
			print('==================================finishAction:',nowStateName,nextState)
			if self:getInfo():isDie() and self.curState.isFloor then
				--nextState = "dead"
				if self.rawAnimation then
					self:endBurn()
				end
			else
				self.lastState = self.curState
				self.curState = nil
				self:playAnimation(self.config[nextState])
			end

			self:dispatchEvent(Event.PlayEnd, {etype = Event.PlayEnd,isFinish = true,stateName = nowStateName,playId = self.playId})
		end

		if self.nextStateTime > 0 then
			self:addTimer(finishAction,self.nextStateTime,1)
		else
			finishAction()
		end
		self.nextStateTime = 0
	else
		self:dispatchEvent(Event.PlayEnd, {etype = Event.PlayEnd,isFinish = true,stateName = nowStateName,playId = self.playId,isHold = true})
		if self.curState.lock == Define.AttackLock.beat then
			if self.beatAction then
				self:stopAction(self.beatAction)
				self.beatAction = nil
			end
			local ms = 7
			if Stage.currentScene.powBone then
				ms = 3
			end
			local seq = cc.Sequence:create(
				cc.MoveBy:create(0.04,cc.p(ms,0)),
				cc.MoveBy:create(0.04,cc.p(-ms,0))
			)
			self.beatAction = cc.RepeatForever:create(seq)
			self:runAction(self.beatAction)
		end
	end
end

function onAnimationEvent(self,armatureBack,movementType,movementID)
	local id = movementID
	print('=============onAnimationEvent====================:',armatureBack,movementType,movementID,armatureBack == self.animation)
	if armatureBack == self.animation and movementType == ccs.MovementEventType.complete then
		self:onFinishAction()
	end
end


--播放动画
function playAnimation(self,state,x)
	if self.beatAction then
		self:stopAction(self.beatAction)
		self.beatAction = nil
	end
    x = self:getPositionX()
    print('======================animation:',self.name,state.name,x)
	--强制切动作的。。
	--
    if self.curState and self.curState.name ~= "stand" then
		--清除shader
		if self.curState.shader and self.curState.shader ~= "" then
			Stage.currentScene:setShader()
		end

		--清除背景特效
		Stage.currentScene:removeBgEffect()

		if self.curState.lock == Define.AttackLock.attack then
		  --完成攻击后
		  if self.isAssist then
			  self.enemy:doAfterBeatByAssist()
		  else
			  self.enemy:doAfterBeat()
		  end
		  self.hiting = false
		end
		self:setNoHold(false)
		self:setPenetrate(false)
		self:setNoTurn(false)
		self.invincible = nil
		self.canRun = nil
		self:endTarget()
		--self:endBurn()
        --x = self:getPositionX()
        self:dispatchEvent(Event.PlayEnd, {etype = Event.PlayEnd,isFinish = false,stateName = self.curState.name,playId = self.playId})
        self.animation:getAnimation():stop()
    end
	self.lastState = self.curState or self.lastState
    self.curState = state
	print('==================================playAnimation:',self.curState.name)
	--if state.name == "somesault_up_a" or state.name == "somesault_up_b" then
	if state.lock ~= Define.AttackLock.beat and state.lock ~= Define.AttackLock.fall or state.name == "somesault_up_a" or state.name == "somesault_up_b" then
		self:endBurn()
	end
    self.animation:getAnimation():play(state.action,-1,state.loop or 0)
    --if x then
    self:setPositionX(x)
	Stage.currentScene:handleTurn()
    --end

end

function sleep(self)
	self.isSleep = true
	self.animation:getAnimation():setSpeedScale(0)
	if self.targetAnimation then
		self.targetAnimation:getAnimation():setSpeedScale(0)
	end
	--cc.Director:getInstance():getActionManager():pauseTarget(self._ccnode)
	self:pauseAction()
end

function wakeUp(self)
	self.isSleep = false
	self.animation:getAnimation():setSpeedScale(speedScale)
	if self.targetAnimation then
		self.targetAnimation:getAnimation():setSpeedScale(speedScale)
	end
	self:resumeAction()
end

function pause(self)
	self.isPause = true
	self.animation:getAnimation():pause()
	if self.targetAnimation then
		self.targetAnimation:getAnimation():pause()
	end
end

function resume(self)
	self.isPause = false
	self.animation:getAnimation():resume()
	if self.targetAnimation then
		self.targetAnimation:getAnimation():resume()
	end
end

function setCurSkill(self,skill)
	self.curSkill = skill
	--local rect = self:getBodyBoxReal()
	--Stage.currentScene:displaySkillName("小小你好",rect.x + rect.width / 2,rect.y + rect.height + 90)
	--print('==============================================self.curSkill:',self.curSkill,self.curSkill.skillid)
end

function doAfterPlay(self,isHarm)
	---shader
	if self.curState.shader and self.curState.shader ~= "" then
		Stage.currentScene:setShader(self.curState.shader,0.0038*2,0.0005*2)
	end

	if self.curState.effect and self.curState.effect ~= "" then
		Stage.currentScene:displayBgEffect(self,self.curState.effect)
	end

	--变小
	Stage.currentScene:closeDown(self:getPositionX())
	--现身
	self.animation:setOpacity(255)

	--self:wakeUp()
	self:resume()


	--
	if self.curState.name == "forward_run" or self.curState.name == "rush" then
		local x,y = self:getPosition()
		Stage.currentScene:displayEffect("跑烟",x,y,self:getDirection())
	end

	if self.curState.name == "rush" then
		self:setPenetrate(true)
	end

	self.isHarm = false
	if self.curState.lock == Define.AttackLock.attack then
		Stage.currentScene:reorderHero(self,2)
		Stage.currentScene.ui:blinkHeroIcon(self)
		local dis = self:getEnemyDis()
		print('==========================dis:',dis)
		if (--[[dis >= self.curState.rangeMin and --]] dis <= self.curState.rangeMax) or self.isAssist or self.enemy.isAssist then
			self.hiting = true
		end
		if self.enemy.curState.lock ~= Define.AttackLock.defense then
			self.isHarm = isHarm
		end
	end
	--if not self.hiting and self.curState.lock >= Define.AttackLock.defense then
	--if not self.isHarm and self.curState.lock > Define.AttackLock.defense and self.curState.name ~= "break_heat" then
	if self.curState.lock == Define.AttackLock.beat or self.curState.lock == Define.AttackLock.fall then
		--self.comboCnt = 0
		self:setComboCnt(0)
	end
	

	self.speedX = nil
	--self.canRun = nil

	local sound = self:getSoundEffect()
	if sound then
		if self.curState.name ~= "dead" then
			SoundManager.playEffect(sound)
		end
	end

	self:startTarget()
end

--播放指定名状态
function play(self, stateName,force,isHarm)
	print('----------------------------------isHarm:',self.heroName,stateName,isHarm)
    local st = self.config[stateName]
	if st then
		if not (force or Rule.lockRule(self.curState,st))  then
			print("state forbidden by lockRule! ",st.name,self.curState.name)
			return false
		end
		if self.floorSeq then
			self:stopAction(self.floorSeq)
			self.floorSeq = nil
		end
		--self.curState = nil
		self:playAnimation(st)
		self:doAfterPlay(isHarm)

		playId = playId + 1
		self.playId = playId
		return playId
	else
		assert(false, "invalid state! " .. stateName)
		return -1
	end
end

function doAfterStartTarget(self)
end

function startTarget(self)
	if self.curState.target and next(self.curState.target) then
		Stage.currentScene:removePowerAfter()
		self.enemy:setVisible(false)
		self:setPenetrate(true)
		self:setNoTurn(true)

		--self.targetAnimation = ccs.Armature:create("Target")
		self.targetAnimation = Target.create(self,self.heroName .. "Target",self.enemy.heroName,self.enemy.name)
		self.targetAnimation:setScaleX(self:getDirection())
		self.targetAnimation:setAnchorPoint(0.5,0.5)
		self.targetAnimation:setPosition(0,0)
		self._ccnode:addChild(self.targetAnimation,-1)
		self.targetAnimation:getAnimation():play(self.curState.target[1],-1,0)
		if self.name == "heroB" then
			self.targetAnimation:getBone("影子"):addDisplay(ccs.Skin:create("res/armature/1pShadow.png"),0)
		end
		self:doAfterStartTarget()
	end

end

function endTarget(self)
	if self.curState.target and next(self.curState.target) then
		if not self.targetAnimation then
			return
		end
		self.enemy:setVisible(true)
		self:setPenetrate(nil)
		self:setNoTurn(nil)

		local box = self.targetAnimation:getBone("身体"):getDisplayManager():getBoundingBox()
		local rBox = self:changeToRealRect(box)
		--self.enemy:play("somesault_up_b",true)
		self.enemy:play(self.curState.target[2],true)
		if self.enemy:getInfo():isDie() then
			self.enemy:play("dead",true)
			self.enemy.animation:getAnimation():gotoAndPlay(-1)
		end
		self.enemy:setPositionX(rBox.x + rBox.width / 2)

		self._ccnode:removeChild(self.targetAnimation,true)

		self.targetAnimation = nil

		Stage.currentScene:handleTurn()
	end
end

function startBurn(self,burn)
	if not self.rawAnimation then
		self:addArmatureFrame(string.format("res/armature/burn/%s/%s.ExportJson",string.lower(burn),burn))
		self.rawAnimation = self.animation
		self.rawAnimation:setVisible(false)
		self.burnCnt = 1

		local ox,oy = self:getPosition()
		local oDirection = self:getDirection()

		self.animation =ccs.Armature:create(burn)
		self.animation:getAnimation():setSpeedScale(speedScale)
		self.animation:setAnchorPoint(0.5,0.5)
		self.shadowBone = self.animation:getBone("影子")
		if self.name == "heroA" then
			self.shadowBone:addDisplay(ccs.Skin:create("res/armature/1pShadow.png"),0)
		end
		self.isShadowVisible = nil
		self.animation:setPosition(0,0)
		self._ccnode:addChild(self.animation)
		self.animation:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) self:onAnimationEvent(armatureBack,movementType,movementID) end)
		self.animation:getAnimation():setFrameEventCallFunc(function(bone,evt,originFrameIndex,currentFrameIndex) self:onAnimationFrameEvent(bone,evt,originFrameIndex,currentFrameIndex) end)
		--print('======================================burn,ox,oy:',ox,oy,oDirection)
		self:setPosition(ox,oy)
		self:setDirection(oDirection,true)
	end
end

function endBurn(self)
	self.burnCnt = self.burnCnt or 0
	if self.rawAnimation then
		if self.burnCnt > 0 then
			self.burnCnt = self.burnCnt - 1
			--return
		end
		local ox,oy = self:getPosition()
		local oDirection = self:getDirection()
		self._ccnode:removeChild(self.animation,true)
		self.animation = self.rawAnimation
		self.rawAnimation = nil
		self.animation:setVisible(true)
		self.shadowBone = self.animation:getBone("影子")
		self.isShadowVisible = nil
		self:setPosition(ox,oy)
		self:setDirection(oDirection,true)

		if self:getInfo():isDie() then
			if self.curState.name == "fall_down_a" then
				self:play("fall_down_a",true)
			else
				self:play("fall_down_b",true)
			end
			self.animation:getAnimation():gotoAndPlay(-1)
		end

		print('==================================endBurn,ox,oy:',ox,oy,oDirection)
	end
end

function run(self,delay)
	--[[
	if self.enemy.curState and self.enemy.curState.lock == Define.AttackLock.attack and Helper.isPushCollide(self,self.enemy) and self.curState.speedX > 0 then
		return
	end
	--]]
	if self.isPause then
		--print('................................................run,isPause....................................')
		return
	end
	if self.isSleep then
		--print('................................................run,isSleep....................................')
		return
	end
    local dx = -self:getDirection() * (self.speedX or self.curState.speedX) * delay
	if self.isAssist then
		dx = dx * 3
	end
    self:setPositionX(self:getPositionX() + dx)
end

function removeSelf(self)
	self.animation:runAction(cc.Sequence:create(
		cc.FadeOut:create(0.2),
		cc.CallFunc:create(function() 
			self:removeFromParent()
		end)
	))
end

--[[
function startAssist(self)
	self.assistX = self:getPositionX()
	self:play("forward_run")
	self:addEventListener(Event.PlayEnd,function(self,event) 
		if event.stateName == "succeed" then
			self.master:getInfo():addHp(50)
			--Stage.currentScene.ui:displayHpEffect(self.master)
			self.animation:runAction(cc.Sequence:create(
				self:removeSelf()
			))
		end
	end)
	self:addTimer(function() 
		self:removeSelf()
	end,5,1)
end

function updateAssist(self)
	local x = self:getPositionX()
	if math.abs(x - self.assistX) > Stage.winSize.width / 2 and not self.firstUpdate then
		self:play("succeed",true)
		self.firstUpdate = true
	end
end
--]]
--

function startAssistAtk(self)
	local skill = self:getAssistSkill()
	self:setCurSkill(skill)
	self:play("assist",true,true)
	self:pause()
	--self.animation:getAnimation():pause(5)

	local ex = self.enemy:getPositionX()
	self:setPosition(ex - self.enemy:getDirection() * 450,Stage.winSize.height)
	self:runAction(
		cc.Sequence:create(
			cc.MoveTo:create(0.2,cc.p(ex - self.enemy:getDirection() * 100,Define.heroBottom)),
			cc.CallFunc:create(function() 
				self:setPositionX(self.enemy:getPositionX() - self.enemy:getDirection() * 100)
				self:resume()
				Stage.currentScene:shockHash(4)
				--local ret = skill:use(self.master.hero,self.enemy)
				local useType,useValue,useTime = skill:use(self.master)
				self:displayAssistEffect(useType,useValue,useTime)
			end)
		)
	)

	self:addEventListener(Event.PlayEnd,function(self,event) 
		if event.stateName == "assist" then
			self.animation:runAction(cc.Sequence:create(
				cc.DelayTime:create(0.3),
				cc.FadeOut:create(0.2),
				cc.CallFunc:create(function() 
					self:removeFromParent()
				end)
			))
		end
	end)
end

function startAssistBuf(self,isPause)
	local skill = self:getAssistSkill()
	self:setCurSkill(skill)
	self:play("jump",true)
	self:pause()
	self.animation:getAnimation():gotoAndPause(10)

	local lx = Stage.currentScene:getLeft() 
	local rx = Stage.currentScene:getRight()
	local tx = (lx + rx) / 2 + self:getDirection() * 150
	--[[
	local mx = self.master:getPositionX()
	if math.abs(mx - tx) < 50 then
		tx = mx + self.getDirection() * 100
		if tx < lx or tx > rx then
			tx = mx - self.getDirection() * 100
		end
	end
	--]]
	self:setPosition(self.master:getDirection() == DIRECTION_RIGHT and lx or rx,Stage.winSize.height)
	self:runAction(
		cc.Sequence:create(
			cc.MoveTo:create(0.2,cc.p(tx,Define.heroBottom)),
			cc.CallFunc:create(function() 
				self:resume()
			end)
		)
	)

	self:addEventListener(Event.PlayEnd,function(self,event) 
		if event.stateName == "jump" then
			self:play("assist",true)
			if isPause then
				--Stage.currentScene.ui:stopFight()
				--[[
				self.master:sleep()
				self.enemy:sleep()
				Stage.currentScene:sleep()
				--]]
			end
			local useType,useValue,useTime = skill:use(self.master)
			self:displayAssistEffect(useType,useValue,useTime)
		elseif event.stateName == "assist" then
			self.animation:runAction(cc.Sequence:create(
				cc.DelayTime:create(0.3),
				cc.FadeOut:create(0.2),
				cc.CallFunc:create(function() 
					if isPause then
						--Stage.currentScene.ui:continueFight()
						--[[
						self.master:wakeUp()
						self.enemy:wakeUp()
						Stage.currentScene:wakeUp()
						--]]
					end
					self:removeFromParent()
				end)
			))

			--local useType,useValue,useTime = skill:use(self.master)
			--self:displayAssistEffect(useType,useValue,useTime)
		end
	end)
end

function startAssist(self)
	self:startAssistBuf(true)
end

function updateAssist(self)
end

--function displayEffect(self,url,exportJson,actionName,x,y,zorder)
function displayAssistEffect(self,assistType,value,time)
	print('--------------displayAssistEffect,assistType,value:',assistType,value)
	--Stage.currentScene.ui:displayAssistEffect(self.master,Helper.createAssistEffect(assistType))
	if assistType == "hp" or assistType == "hpR" then
		self.master:displayFightEffect("pow_hp","fe_jx","+" .. math.floor(value * 100) .. "%")
		self:displayEffect("res/armature/effect/assist/assistAddHp/AssistAddHp.ExportJson",'AssistAddHp',"AssistAddHpA",0,0)
		self.master:displayEffect("res/armature/effect/assist/assistAddHp/AssistAddHp.ExportJson",'AssistAddHp',"AssistAddHpH",0,0)
		Stage.currentScene.ui:displayHpEffect(self.master)
	elseif assistType == "rageA" then
		self.master:displayFightEffect("pow_hp","fe_nq","+" .. value)
		self.master:displayEffect("res/armature/effect/assist/assistAddPowH/AssistAddPowH.ExportJson",'AssistAddPowH',"AssistAddPowH",0,self.master:getBodyBoxReal().height / 2)
		self:displayEffect("res/armature/effect/assist/assistAddPowA/AssistAddPowA.ExportJson",'AssistAddPowA',"AssistAddPowA",0,0)
		Stage.currentScene.ui:displayAddPowerEffect(self.master)
	elseif assistType == "rageD" then
		self.enemy:displayFightEffect("pow_hp","fe_nq",-value)
		self.enemy:displayEffect("res/armature/effect/assist/assistDecPowH/AssistDecPowH.ExportJson",'AssistDecPowH',"AssistDecPowH",0,self.master:getBodyBoxReal().height / 2)
		self:displayEffect("res/armature/effect/assist/assistDecPowA/AssistDecPowA.ExportJson",'AssistDecPowA',"AssistDecPowAUp",0,0)
		self:displayEffect("res/armature/effect/assist/assistDecPowA/AssistDecPowA.ExportJson",'AssistDecPowA',"AssistDecPowADown",0,0,-1)
		Stage.currentScene.ui:displayDecPowerEffect(self.enemy)
	elseif assistType == "atkBuf" then
		self.master:displayFightEffect("atk","fe_zygj",value)
		self.master:displayEffect("res/armature/effect/assist/assistAddAtkH/AssistAddAtkH.ExportJson",'AssistAddAtkH',"AssistAddAtkH",0,self.master:getBodyBoxReal().height / 2)
		self:displayEffect("res/armature/effect/assist/assistAddAtkA/AssistAddAtkA.ExportJson",'AssistAddAtkA',"AssistAddAtkA",0,0)
		Stage.currentScene.ui:addBuf(self.master,assistType,value,time)
	elseif assistType == "atk" then
		self:displayEffect("res/armature/effect/assist/assistHitA/AssistHitA.ExportJson",'AssistHitA',"AssistHitAUp",0,0)
		self:displayEffect("res/armature/effect/assist/assistHitA/AssistHitA.ExportJson",'AssistHitA',"AssistHitADown",0,0,-1)
	elseif assistType == "defD" then
		self.enemy:displayFightEffect("def","fe_fy",-value)
		self.enemy:displayEffect("res/armature/effect/assist/assistDecDefH/AssistDecDefH.ExportJson",'AssistDecDefH',"AssistDecDefH",0,self.master:getBodyBoxReal().height / 2)
		self:displayEffect("res/armature/effect/assist/assistDecDefA/AssistDecDefA.ExportJson",'AssistDecDefA',"AssistDecDefA",0,0)
		Stage.currentScene.ui:addBuf(self.enemy,assistType,value,time)
	end
end

function displayFightEffect(self,txtType,name,num)
	local rect = self:getBodyBoxReal()
	local node = Helper.createFightEffect(name,num)
	--if txtType == "harm" then
		--node:setColor(cc.c3b(0,255,0))
		--self.animation:setColor(cc.c3b(0,0,0))
	--end
	Stage.currentScene:displayFightEffect(txtType,node,self:getDirection(),rect.x + rect.width / 2,rect.y + rect.height + 30)
end

function displayCareer(self)
	if self.curSkill and self.curSkill:isOpposite(self.enemy.hero) then
		if self.hero.lv < 19 then
			--不显示
			--print('====================================fuck shu zhi gege=====================')
			return
		end
		--local careerTable = {[1]='炎',[2]='雷',[3]='地',[4]='风',[5]='暗'}
		--self.enemy.careerEffect:getAnimation():play(HeroDefine.CAREER_NAMES[self.curSkill.group.career],-1,0)
		self.enemy:displayEffect("res/armature/effect/SkillCareer.ExportJson",'SkillCareer',HeroDefine.CAREER_NAMES[self.curSkill.group.career],0,self:getBodyBoxReal().height / 2)

		self.enemy:displayFightEffect("career","fe_sxbkz","")
	end
end

function displayBreakEffect(self)
	if self.hero.quality and self.hero.quality < 3 then
		return
	end
	--self.breakEffect:getAnimation():play(HeroDefine.CAREER_NAMES[self.hero.career],-1,0)
	self:displayEffect("res/armature/effect/breakEffect/BreakEffect.ExportJson",'BreakEffect',"BreakEffect",0,self:getBodyBoxReal().height / 2)
end

function displayComboEffect(self)
	if self.hero.quality and self.hero.quality < 4 then
		return
	end
	--self.comboEffect:getAnimation():play("Combo",-1,0)
	self:displayEffect("res/armature/effect/comboEffect/ComboEffect.ExportJson",'ComboEffect',"Combo",0,self:getBodyBoxReal().height / 2,-1)
end

--[[
---- states begin --
jump = function(self, state)


end

---- states end --
--]]

--frame callback 
---[[
function preJump(self,bone,evt,originFrameIndex,currentFrameIndex)
	self.canRun = true
	if self.curState.lock <= Define.AttackLock.normal then
		local x,y = self:getPosition()
		Stage.currentScene:displayEffect("跳烟",x,y,self:getDirection())
	end
end

function endJump(self,bone,evt,originFrameIndex,currentFrameIndex)
	self.canRun = nil
	if self.curState.lock <= Define.AttackLock.normal then
		local x,y = self:getPosition()
		Stage.currentScene:displayEffect("跳烟",x,y,self:getDirection())
	end
end

--直接冲到对方位置，例如八神的八稚女
function rush(self,bone,evt,originFrameIndex,currentFrameIndex)
	local x,y = self.enemy:getPosition()
	local mx,my = self:getPosition()
	local moveBy = cc.MoveBy:create(math.abs(x-mx) / 1500,cc.p(x - mx + self:getDirection() * 60,0))
	local callback = cc.CallFunc:create(function() 
		self:resume()
		if self.enemy.curState and self.enemy.curState.lock == Define.AttackLock.defense then
			self:play("stand",true)
			self.enemy:play("stand",true)
			--self:setNextStateTime(0.5)
			--self.enemy:setNextStateTime(0.5)
		end
		if self.enemy.curState.name == "forward" or self.enemy.curState.name == "forward_run" then
			self.enemy:play("stand",true)
		end
	end)
    local seq = cc.Sequence:create(moveBy, callback)
	self:pause()
	self:runAction(seq)
end

--多个攻击点只打中一次的情况
function hitOnce(self,bone,evt,originFrameIndex,currentFrameIndex)
	local v = self.curState.hitEvent[originFrameIndex]
	self.curState.hitEvent.cnt = 1
	v.cnt = 1
	--if self.hiting then
		if self.hitId ~= self.playId then
			hit(self,bone,evt,originFrameIndex,currentFrameIndex)
		end
	--end
end

--打完一次攻击就收招
function hitStop(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.hiting then
		hit(self,bone,evt,originFrameIndex,currentFrameIndex)
		self.animation:getAnimation():gotoAndPlay(-1)
	end
end

function handleHit(self,cfg,isHit,hitX,hitY,flyArgList)
	--if self.hiting or flyArgList then
	if isHit then
		local assist = self.enemy:getAssist()
		--受击动作
		if self.enemy.curState.lock ~= Define.AttackLock.defense and not (assist and assist:getAssistType() == Define.AssistType.defense and assist.canDefense) then

			if cfg.burn and not self.isAssist then
				self.enemy:startBurn(cfg.burn)
			end

			if cfg.reac and not self.isAssist then
				--redo	如果是在空中被打，则应该调用击飞
				if self.enemy:isJump() and not cfg.forceReac then
					if cfg.reac == "hit_fly_b" then
						self.enemy:play("hit_fly_b",true)
					else
						self.enemy:play("hit_fly_a",true)
					end
					self.enemy:setPositionY(hitY - 60)
				else
					self.enemy:play(cfg.reac,true)
				end
			end
			--self.comboCnt = self.comboCnt + 1
			self:setComboCnt(self.comboCnt + 1)
			if self.comboCnt > 1 then
				Stage.currentScene:displayComboHit(self,self.comboCnt)
			end
			if self.curSkill and self.curSkill.comboCntFactor then
				Stage.currentScene:displayComboAdd(self,self.curSkill.comboCntFactor)
			end
		end

		if self.enemy.curState.lock == Define.AttackLock.defense or (assist and assist:getAssistType() == Define.AssistType.defense and assist.canDefense) then
			if assist then
				assist.isDefensed = true
			end
			--防守特效
			if cfg.deffect then
				Stage.currentScene:displayEffect(cfg.deffect,hitX,hitY,self.enemy:getDirection())	
			end
		else
			--受击特效
			if cfg.effect then
				Stage.currentScene:displayEffect(cfg.effect,hitX,hitY,self:getDirection())	
			end
			if cfg.effect2 then
				Stage.currentScene:displayEffect(cfg.effect2,hitX,hitY,self:getDirection())	
			end
		end

		--击退距离
		local dx =  self.enemy.curState.lock == Define.AttackLock.defense and cfg.deback or cfg.back
		dx = -self:getDirection() * (dx or 0)
		if self.enemy:isJump() then
			dx = 0
		end

		if not self.isAssist then
			--卡帧时间
			local oldPlayIdA = self.playId
			if cfg.delayA then
				local delayTimeA = cc.DelayTime:create(cfg.delayA / speedScale)
				local callback = cc.CallFunc:create(function() 
					--if self.playId == oldPlayIdA or Stage.currentScene:hasFlyer() then
						self:resume()
					--end
				end)
				self:pause()
				self:runAction(cc.Sequence:create(delayTimeA,callback))
			end
			if cfg.delayB then
				local delayTime = cc.DelayTime:create(cfg.delayB /  speedScale)
				local callback = cc.CallFunc:create(function() 
					--if self.playId == oldPlayIdA  or Stage.currentScene:hasFlyer() then
						self.enemy:resume()
						--[[
						if self.targetAnimation then
							self.targetAnimation:getAnimation():resume()
						end
						--]]
					--end
				end)
				local moveBy = cc.MoveBy:create(math.abs(dx) / 600,cc.p(dx,0))
				self.enemy:pause()
				--[[
				if self.targetAnimation then
					self.targetAnimation:getAnimation():pause()
				end
				--]]
				self.enemy:runAction(cc.Sequence:create(delayTime,moveBy,callback))
			else
				local moveBy = cc.MoveBy:create(math.abs(dx) / 600,cc.p(dx,0))
				self.enemy:runAction(moveBy)
			end
		end


		--下一个动作时间,倒地时间
		if cfg.fall then
			self.enemy.nextStateTime = cfg.fall
		end
		
		--击飞速度
		if cfg.speed then
			self.enemy.speedX = cfg.speed
		end

		--闪屏
		if cfg.flash then
			Stage.currentScene:flashHash(cfg.flash)
		end

		--震屏
		if cfg.shock then
			Stage.currentScene:shockHash(cfg.shock)
		end

		if cfg.sound then
			SoundManager.playEffect(cfg.sound)
		end

		--受击方的速度 
		if cfg.scale then
			self.enemy.animation:getAnimation():setSpeedScale(cfg.scale)
		end
		if self.hitId ~= self.playId then
			--redo
			if self.enemy.curState.lock ~= Define.AttackLock.defense then
				local sound = self.enemy:getHitSoundEffect()
				SoundManager.playEffect(sound)
			end
			if self.isHarm then
				self:randomHarm()
			end


			Stage.currentScene:removePowerAfter()


		end
		self.hitId = self.playId

		--redo
		if self.isHarm then
			--self:randomHarm()
			self.enemy:decHp(self:getHarm() / (cfg.cnt or 1),self.isAssist)
			local powSelf,powEnemy = self.curSkill:getRage(self,self.enemy)
			self:getInfo():addPower(powSelf / (cfg.cnt or 1))
			self.enemy:getInfo():addPower(powEnemy / (cfg.cnt or 1))
		end

		if self.enemy:getInfo():isDie() and not self.enemy.hasDie then
			self.enemy.hasDie = true
			Stage.currentScene:flash(1.2,8,nil,nil,true)
			cc.Director:getInstance():getScheduler():setTimeScale(0.4)
			self:addTimer(function() 
				cc.Director:getInstance():getScheduler():setTimeScale(1)
			end,1.6,1)

			local sound = self.enemy:getSoundEffect("dead")
			--print('====================sound,,,,,:',sound)
			if sound then
				SoundManager.playEffect(sound)
			end
		end

	--end
	else
		print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<not hit,self.isHarm,hitX,hitY:",self.isHarm,hitX,hitY)
		if cfg.nshock then
			Stage.currentScene:shockHash(cfg.nshock)
		end
	end

	if cfg.bgEffect then
		Stage.currentScene:displayBgEffect(self,cfg.bgEffect)
	end
end

function thit(self,bone,evt,originFrameIndex,currentFrameIndex)
	local v = self.curState.hitEvent[originFrameIndex]
	if not v then
		print('................................not hit points event:',self.curState.name,originFrameIndex)
		return
	end
	local boundBox = bone:getDisplayManager():getBoundingBox()
	local rect = self:changeToRealRect(boundBox)
	v.cnt = v.cnt or self.curState.hitEvent.cnt
	self:handleHit(v,true,rect.x,rect.y)
end

--攻击点事件
function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if not self.curState.hitEvent then
		print('=-================================self.name,.......:',self.name,self.heroName,self.curState.name)
		--assert(false,'=-================================self.name,.......:'..self.name..self.heroName..self.curState.name)
		return
	end
	local v = self.curState.hitEvent[originFrameIndex]
	if not v then
		print('................................not hit points event:',self.curState.name,originFrameIndex)
		return
	end

	local boundBox = bone:getDisplayManager():getBoundingBox()
	local rect = self:changeToRealRect(boundBox)
	local isHit,hitX,hitY = self.enemy:isHit(rect)
	v.cnt = v.cnt or self.curState.hitEvent.cnt
	print('=======================================.............,,,,,,,,,,,,,isHit:',isHit,hitX,hitY)
	self:handleHit(v,isHit,hitX,hitY)
end

--非攻击点事件
function noHit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if not self.curState.noHitEvent then
		return
	end
	local cfg = self.curState.noHitEvent[originFrameIndex]
	if not cfg then
		print('................................not noHit points event:',self.curState.name,originFrameIndex)
		return
	end

	---[[
	local boundBox = bone:getDisplayManager():getBoundingBox()
	local rect = self:changeToRealRect(boundBox)
	--]]
	--闪屏
	if cfg.flash then
		Stage.currentScene:flashHash(cfg.flash)
	end

	--震屏
	if cfg.shock then
		Stage.currentScene:shockHash(cfg.shock)
	end

	--特效
	if cfg.effect then
		Stage.currentScene:displayEffect(cfg.effect,rect.x,rect.y,self:getDirection())	
	end

	if cfg.bgEffect then
		Stage.currentScene:displayBgEffect(self,cfg.bgEffect)
	end

	if cfg.sound then
		SoundManager.playEffect(cfg.sound)
	end
end

--双方同时定住
function hold(self,bone,evt,originFrameIndex,currentFrameIndex)
	--[[
	if self.hiting then
		--self.animation:getAnimation():pause()
		self:pause()
		self.enemy:pause()
		local delayTime = cc.DelayTime:create(0.5)
		local callback = cc.CallFunc:create(function() 
			self:resume()
			self.enemy:resume()
		end)
		local seq = cc.Sequence:create(delayTime, callback)
		self:runAction(seq)
	end
	--]]
	if self.hiting then
		self:pause()
		local delayTime = cc.DelayTime:create(0.32)
		local callback = cc.CallFunc:create(function() 
			self:resume()
		end)
		local seq = cc.Sequence:create(delayTime, callback)
		self:runAction(seq)
	end
end

--受击方延迟卡帧
function delay(self,bone,evt,originFrameIndex,currentFrameIndex)
	local delayTime = cc.DelayTime:create(self.delayTime or 0)
	local callback = cc.CallFunc:create(function() 
		self:resume()
	end)
	local moveBy = cc.MoveBy:create(math.abs(self.back or 0) / 600,cc.p(self.back,0))
	self:pause()
	self:runAction(cc.Sequence:create(delayTime,moveBy,callback))
	self.back = nil
	self.delayTime = nil
end

--黑屏
function black(self,bone,evt,originFrameIndex,currentFrameIndex)
	Stage.currentScene:blackScreen(0.3,nil)
end

--使用大招时黑屏
function pow(self,bone,evt,originFrameIndex,currentFrameIndex)
	local boundBox = bone:getDisplayManager():getBoundingBox()
	local rect = self:changeToRealRect(boundBox)
	Stage.currentScene:displayEffect("必杀",rect.x,rect.y,self:getDirection(),true)
	Stage.currentScene:displayEffect("大招",rect.x,rect.y,self:getDirection())

	self:pause()
	self.enemy:pause()
	local callback = function() 
		self:resume()
		self.enemy:resume()
	end
	Stage.currentScene:blackScreen(0.3,nil,callback)
	SoundManager.playEffect("common/Bishashanping.mp3")
end

--小黑人落地
function tfloor(self,bone,evt,originFrameIndex,currentFrameIndex)
	local boundBox = bone:getDisplayManager():getBoundingBox()
	local rect = self:changeToRealRect(boundBox)
	Stage.currentScene:displayEffect("倒地1",rect.x,rect.y,self:getDirection())
	Stage.currentScene:shock(0.09,1.7,18)
	SoundManager.playEffect("common/Tongyongdaodi.mp3")
end

--击飞时如果离地面更高则让掉落
function floor(self,bone,evt,originFrameIndex,currentFrameIndex)
	local x,y = self._ccnode:getPosition()
	local nx,ny = self:getPosition()
	if y > Define.heroBottom then
		local moveTo = cc.MoveTo:create(math.abs(y - Define.heroBottom) / 2000,cc.p(x,Define.heroBottom))
		local callback = cc.CallFunc:create(function() 
			self.floorSeq = nil
			self:resume()
			Stage.currentScene:shock(0.09,1.7,18)
			local nx,ny = self:getPosition()
			if ny <= Define.heroBottom then
				if y > Define.heroBottom or self.curState.name == "hit_fly_b" then
					Stage.currentScene:displayEffect("倒地2",nx,ny,self:getDirection())
				else
					Stage.currentScene:displayEffect("倒地1",nx,ny,self:getDirection())
				end
			end
			if self.curState.invincible or self.curState.name == "hit_fly_a" or self.curState.name == "hit_fly_b" then
				self.invincible = true
			end
		end)
		local seq = cc.Sequence:create(moveTo, callback)
		self:pause()
		self:runAction(seq)
		self.floorSeq = seq
	else
		Stage.currentScene:shock(0.09,1.7,18)
		Stage.currentScene:displayEffect("倒地1",nx,ny,self:getDirection())
	end
	SoundManager.playEffect("common/Tongyongdaodi.mp3")
end

--暴气
function burst(self,bone,evt,originFrameIndex,currentFrameIndex)
	local boundBox = bone:getDisplayManager():getBoundingBox()
	local rect = self:changeToRealRect(boundBox)
	Stage.currentScene:displayEffect("曝气",rect.x,rect.y,self:getDirection())
	Stage.currentScene:shockHash(3)
end


function closeUp(self,bone,evt,originFrameIndex,currentFrameIndex)
	--if self.hiting then
		Stage.currentScene:closeUp(self:getPositionX())
	--end
end

function closeDown(self,bone,evt,originFrameIndex,currentFrameIndex)
	Stage.currentScene:closeDown(self:getPositionX())
end

function replay(self,bone,evt,originFrameIndex,currentFrameIndex)
end

function getFlyName(self)
	return "波_开始","波_循环","波_结束"
end

function getFlySpeed(self)
	--return 900
end

function fly(self,bone,evt,originFrameIndex,currentFrameIndex)
	local boundBox = bone:getDisplayManager():getBoundingBox()
	local rect = self:changeToRealRect(boundBox)

	local startName,loopName,endName = self:getFlyName()
	local speed = self:getFlySpeed()

	local flyer = Flyer.new({
		startName = startName,
		loopName = loopName,
		endName = endName,
		stateName = self.curState.name,
		direction = self:getDirection(),
		master = self,
		enemy = self.enemy,
		offsetX = rect.x,
		offsetY = rect.y,
		speed = speed,
	})
	Stage.currentScene:addFlyer(flyer)
end

function penetrate(self,bone,evt,originFrameIndex,currentFrameIndex)
	self:setPenetrate(true)
end

function top(self,bone,evt,originFrameIndex,currentFrameIndex)
	Stage.currentScene:reorderHero(self,2)
end

function bottom(self,bone,evt,originFrameIndex,currentFrameIndex)
	Stage.currentScene:reorderHero(self,1)
end

function finish(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.hiting and self.enemy.curState.lock ~= Define.AttackLock.defense then
		self:onFinishAction()
	end
end




-- 特效：残影 
function fxGhost(self, isOpen, sec, cnt)
    local box = self.animation:getBoundingBox()

	if self.rt then
		self._ccnode:removeChild(self.rt)
	end

    local x,y = self.animation:getPosition()
    local hx,hy = self._ccnode:getPosition()

	print("=============ghost:x,y,hx,hy", x, y, hx, hy)
	print("=============ghost:bx,by,bw,bh", box.x, box.y, box.width, box.height)

	local w = box.width + 400
	local h = box.height + 400
	local rt = cc.RenderTexture:create(w, h)
	rt:setAnchorPoint(cc.p(0.5,0))
	rt:setPosition(cc.p(0,400))
	--rt:setKeepMatrix(true)

	self._ccnode:addChild(rt)
	rt:beginWithClear(0,0,0,0)
		self.animation:visit()
	rt["end"](rt) 
	
	self.rt = rt

	if self.rtbox then
		self._ccnode:removeChild(self.rtbox)
	end
	local tbox =  {x=0,y=400,width=w,height=h}
	self.rtbox = Common.getDrawBoxNode(tbox)
	self._ccnode:addChild(self.rtbox)


	--rt:retain()

	--[[
	local tex = rt:getSprite():getTexture()
	local size = tex:getContentSize()
	local tbox = {x=0,y=0,width=size.width,height=size.height}
	local spr = self:getChild("ghost")
	if spr then
		self:removeChild(spr)
	end
	spr = Sprite.new("ghost")
	spr:setTexture(tex)
	spr:setPosition(x+200,y+200)
	spr:setAnchorPoint(0, 0)
	--spr:setFlippedY(1)
	--spr:setScaleY(-1);
	spr:setScale(0.5)
	--spr:setOpacity(200)
	self:addChild(spr)
	spr._ccnode:setFlippedY(true)
	spr._ccnode:addChild(Common.getDrawBoxNode(tbox))

	
	rt:retain()

	self:addTimer(function()
		local tex = rt:getSprite():getTexture()
		--tex:setAliasTexParameters()
		local spr = self:getChild("ghost")
		if spr then
			self:removeChild(spr)
		end
		spr = Sprite.new("ghost")
		spr:setTexture(tex)
		spr:setPosition(x+100,y)
		spr:setAnchorPoint(0, 0)
		--spr:setScaleY(-1);
		--spr:setScale(0.5)
		--spr:setOpacity(200)
		self:addChild(spr)
		print("+++++++++self:addChild(spr)")

		local x,y = spr:getPosition()
		local size = spr:getContentSize()
		box = cc.rect(x,y,size.width,size.height)
		self._ccnode:addChild(Common.getDrawBoxNode(box, cc.c4b(0,0,200,200)))


		local labelSkin = {
			name="memory",type="Label",x=0,y=0,width=10,height=10,
			normal={txt = 'x',font="Helvetica",size=20,bold=false,italic=false,color={255,255,255}}
		}
		local lb = Label.new(labelSkin)
		spr:addChild(lb)

		local dt = cc.DelayTime:create(0.5)
		local cb = cc.CallFunc:create(function() 
			self._ccnode:removeChild(spr)
		end)
		local seq = cc.Sequence:create({dt,cb})
		--spr:runAction(seq)

		rt:release()
	
	end,0.01,1)
	--]]

end

-- 特效：粒子火焰
function fxFire(self)
	local boneRes = self.boneRes or {}
	--for _,v in ipairs(Define.bodyBone[self.heroName]) do
	--for _,v in ipairs({"影子","攻击点","受击框"}) do
	--for _,v in ipairs({"影子"}) do
	local i = 1
	for v,_ in pairs(boneRes) do
		i = i + 1
		if i % 2 == 1 then
			print("---=====-->>>>>>",v)
			--local fire = cc.ParticleSystemQuad:create("res/particles/BoilingFoam.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/BurstPipe.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/ButterFly.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/ButterFlyYFlipped.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/Comet.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/debian.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/ExplodingRing.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/Fire.plist")
			local fire = cc.ParticleSystemQuad:create("res/particles/Fire5.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/Flower.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/Galaxy.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/lines.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/Phoenix.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/SmallSun.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/SpinningPeas.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/Spiral.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/SpookyPeas.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/TestPremultipliedAlpha.plist")
			--local fire = cc.ParticleSystemQuad:create("res/particles/Upsidedown.plist")
			fire:setPositionType(2)

			local bone  = ccs.Bone:create(v .. "_fire")
			bone:addDisplay(fire, 0)
			bone:changeDisplayWithIndex(0, true)
			bone:setIgnoreMovementBoneData(true)
			bone:setLocalZOrder(100)
			--bone:setScale(0.1)
			self.animation:addBone(bone, v)
		end
	end
end

--]]
