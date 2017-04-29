module(..., package.seeall)
setmetatable(_M, {__index = Scene}) 

local FightLogic = require("src/modules/fight/FightLogic")
local Helper = require("src/modules/fight/KofHelper")
local Hero = require("src/modules/fight/Hero")
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")
local FightReport = require("src/modules/fight/FightReport")
local Flyer = require("src/modules/fight/Flyer")
local Ai = require("src/modules/fight/Ai")
local GiftDefine = require("src/modules/gift/GiftDefine")
local GiftLogic = require("src/modules/gift/GiftLogic")
local VipLevelLogic = require("src/modules/vip/VipLevelLogic")

--战斗场景
-- todo
--1 控制hero， 背景，摄像头
--2 控制左边碰撞，右边碰撞，2个hero最远距离限制

-- 高固定 640 宽默认2048
mapWidth = mapWidth or 2048  

local winWidth = Stage.winSize.width
local winHeight = Stage.winSize.height

local lockDistance = Stage.designSize.width * 0.8 --两英雄锁定间距
local half = lockDistance / 2 --最大锁定间距一半
--local heroBottom = 100  --英雄地面高度

local newing = false

function new(fightControl,fightModel,fightType,args)
	local scene = Scene.new("fight") 
	if newing then
		return  scene
	end
	newing = true
	scene.fightControl = fightControl
	scene.fightModel = fightModel or Master:getInstance().fightModel or Define.FightModel.handA_autoB
	scene.fightType = fightType or Define.FightType.default
	scene.args = args or {} --{noCombo=true,noBreak=true,noPow=true,noAssist=true}
	scene.arenaEffectList = {}
	scene.sceneEffectList = {}
	scene.viewDownEffectList = {}
	scene.viewUpEffectList = {}
	scene.arenaFlyerList = {}
	scene.hasTouchEff = false
	setmetatable(scene, {__index = _M})
	scene:init()
	return scene
end

function init(self)
	cc.Director:getInstance():getScheduler():setTimeScale(1)
	--[[
	self:addEventListener(Event.FightEnd,function(self,event)
		SoundManager.stopMusic(true)
		if event.winer == "A" then
			SoundManager.playEffect("common/Success.mp3")
		else
			--SoundManager.playEffect("common/success.mp3")
		end
	end,self)
	--]]

	self.res = {
		"res/armature/effect/effect/Effect.ExportJson",
		"res/armature/effect/Power.ExportJson",
		"res/armature/effect/TipsEffect.ExportJson",
		"res/armature/effect/HeroAttr.ExportJson",
		"res/armature/effect/FightTxtEffect.ExportJson",
		"res/armature/effect/PowerTips.ExportJson",
		"res/armature/effect/ComboHitEffect.ExportJson",
		"res/armature/effect/ComboAdd.ExportJson",
		--"res/armature/effect/BreakEffect.ExportJson",
		string.format("res/armature/%s/%s.ExportJson",string.lower(self.fightControl:getAssistA().name),self.fightControl:getAssistA().name),
		string.format("res/armature/%s/%s.ExportJson",string.lower(self.fightControl:getAssistB().name),self.fightControl:getAssistB().name),
		string.format("res/armature/%s/%s.ExportJson",string.lower(self.fightControl:getHeroA().name),self.fightControl:getHeroA().name),
		string.format("res/armature/%s/%s.ExportJson",string.lower(self.fightControl:getHeroB().name),self.fightControl:getHeroB().name)
	}

	local loadingUI = require("src/modules/fight/ui/LoadingUI").new()
	for k,v in ipairs(self.res) do
		loadingUI:addArmatureFileInfo(v)
	end
	self.loadingUI = loadingUI

	loadingUI:addEventListener(Event.Finish, function(self,event) 
		if self.loadingUI then
			for i = 1, #self.res - 2 do
				self:addArmatureFrame(self.res[i])
			end
			self:init2()
			self:removeChild(self.loadingUI)
			self.loadingUI = nil
			newing = false 
			self:dispatchEvent(Event.InitEnd)
		end
	end,self)

	self:addChild(loadingUI)
	loadingUI:start()
end

local mapTable = {
	"res/map/bg001.jpg",
	"res/map/bg002.jpg",
	"res/map/bg003.jpg",
	"res/map/bg004.jpg",
	"res/map/bg010.jpg",
	"res/map/bg012.jpg",
	"res/map/bg013.jpg",
	"res/map/bg014.jpg",
	"res/map/bg015.jpg",
	"res/map/bg016.jpg",
	"res/map/bg017.jpg",
}

function init2(self)
	--keyboard listener test
	---[[
    local function onKeyboardPress(keyCode,event)
        print('=======================keyCode:',keyCode)
        self:onKeyboardPress(keyCode,event)
    end
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyboardPress,cc.Handler.EVENT_KEYBOARD_PRESSED)

    local eventDispatcher = self._ccnode:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self._ccnode)
    --]]
	
	--决斗场背景
	local skin = {name="bg",type="Container",x=0,y=0,children={}}
	self.bg = Control.new(skin)
	self:addChild(self.bg)

	--场景特效
	local skin = {name="viewDown",type="Container",x=0,y=0,children={}}
	self.viewDown = Control.new(skin)
	self:addChild(self.viewDown)


	--决斗场 Arena
	local skin = {name="arena",type="Container",x=0,y=0,children={}}
	self.arena = Control.new(skin)
	self:addChild(self.arena)

	--场景特效
	local skin = {name="viewUp",type="Container",x=0,y=0,children={}}
	self.viewUp = Control.new(skin)
	self:addChild(self.viewUp)

	self.ui = require("src/modules/fight/ui/FightPanel").new()
	self:addChild(self.ui)
	self.ui:addEventListener(Event.PlayEnd,onTimeOver,self)
	--self.ui:setHeroIcon()
	self.ui:setCareerVisiable(self.isCareerVisiable)

	self:focus(mapWidth/2,Define.heroBottom)

	self:selectMap("2",mapTable[math.random(1,#mapTable)])
	self:playMusic()
	--self:addTimer(initLazy, 0.1, 1)
	self:initLazy()
end

function initLazy(self)
	self:addSpriteFrames("res/fight/ComboHit.plist")
	--self:addSpriteFrames("res/fight/FightHeroAttr.plist")
	self:addEventListener(Event.Frame, onFrame)
	self:initHero()
	self.ui:initLazy()
end

function playMusic(self)
	SoundManager.playMusic(string.format("common/BackgroundMusic%d.mp3",math.random(1,4)),true)
end

function clearRes(self)
	for k,v in ipairs(self.res) do
		ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(v)
	end
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function clear(self)
	SoundManager.stopMusic(true)
	cc.Director:getInstance():getScheduler():setTimeScale(1)
	Scene.clear(self)
end

function initHero(self)
	--self:selectMap("2", string.format("res/map/bg%03d.jpg" ,math.random(4,4)))
	--self:selectMap("2",mapTable[math.random(1,#mapTable)])
	--self:selectMap("2", "res/map/test.jpg")
    if self.heroA then
		self.arena:removeChild(self.heroA)
        self.heroA = nil
    end
    if self.heroB then
		self.arena:removeChild(self.heroB)
        self.heroB = nil
    end

	local heroA = Hero.new("heroA",self.fightControl:getHeroA())
	self:addHeroA(heroA)
	heroA:setDirection(Hero.DIRECTION_RIGHT)

	local heroB = Hero.new("heroB",self.fightControl:getHeroB())
	self:addHeroB(heroB)
	heroB:setDirection(Hero.DIRECTION_LEFT)

	self.fightLogic = FightLogic.new(heroA,heroB)
	local report = FightReport.new()
	report:setReport(self.fightControl:createReport())
	self.fightLogic:setReport(report)
	local callback2 = function()
		self.fightLogic:start()
	end
	self:offOn(0.8,nil,callback2)
	--self:displayFightAttr()
end

function map007(self,size)
	--print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>size.width,size.height:',size.width,size.height)
	self:addArmatureFrame("res/armature/effect/map/aircraftDay/AircraftDay.ExportJson")

	local bone=ccs.Armature:create("AircraftDay")
	--print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>:',bone:getContentSize().width,bone:getContentSize().height)
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(size.width / 2,size.height / 2)
	bone:getAnimation():play("彩旗",-1,1)
	self.map._ccnode:addChild(bone)

	local bone=ccs.Armature:create("AircraftDay")
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(size.width / 2,size.height / 2)
	bone:getAnimation():play("白鸽",-1,1)
	self.map._ccnode:addChild(bone)
	bone:runAction(cc.RepeatForever:create(
		cc.Sequence:create(
			cc.CallFunc:create(function() 
				bone:setPosition(-100,size.height / 2 + 60)
				bone:setScale(1)
			end),
			cc.Spawn:create(
				cc.MoveBy:create(size.width / 120,cc.p(size.width + 200,150)),
				cc.ScaleTo:create(size.width / 120,0.5)
			),
			cc.DelayTime:create(5)
		)
	))

	local bone=ccs.Armature:create("AircraftDay")
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(size.width / 2,size.height / 2)
	bone:getAnimation():play("飞机",-1,1)
	self.map._ccnode:addChild(bone)

end

function map008(self,size)
	self:addArmatureFrame("res/armature/effect/map/aircraftNight/AircraftNight.ExportJson")

	local bone=ccs.Armature:create("AircraftNight")
	--print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>:',bone:getContentSize().width,bone:getContentSize().height)
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(size.width / 2,size.height / 2)
	bone:getAnimation():play("彩旗",-1,1)
	self.map._ccnode:addChild(bone)

	local bone=ccs.Armature:create("AircraftNight")
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(size.width / 2,size.height / 2)
	bone:getAnimation():play("飞机",-1,1)
	self.map._ccnode:addChild(bone)
	bone:runAction(cc.RepeatForever:create(
		cc.Sequence:create(
			cc.MoveBy:create(1,cc.p(0,5)),
			cc.MoveBy:create(1,cc.p(0,-5))
			--cc.DelayTime:create(5)
		)
	))

end

function map017(self,size)
	self:addArmatureFrame("res/armature/effect/map/river/River.ExportJson")

	local bone=ccs.Armature:create("River")
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(size.width / 2,size.height / 2)
	bone:getAnimation():play("River1",-1,1)
	self.map._ccnode:addChild(bone)

	local bone=ccs.Armature:create("River")
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(size.width / 2,size.height / 2)
	bone:getAnimation():play("River2",-1,1)
	self.map._ccnode:addChild(bone)
end

local mapEffectTable = {
	--["res/map/bg004.jpg"] = "res/armature/effect/Roof.ExportJson"
	["res/map/bg004.jpg"] = {"roof/Roof.ExportJson","Roof"},
	["res/map/bg007.jpg"] = map007,
	["res/map/bg008.jpg"] = map008,
	["res/map/bg010.jpg"] = {"arena/Arena.ExportJson","Arena"},
	["res/map/bg014.jpg"] = {"arenaNight/ArenaNight.ExportJson","ArenaNight"},
	["res/map/bg015.jpg"] = {"arenaDay/ArenaDay.ExportJson","ArenaDay"},
	["res/map/bg016.jpg"] = {"egypt/Egypt.ExportJson","Egypt"},
	["res/map/bg017.jpg"] = map017,
}

function selectMap(self, name, url)
	local map = Sprite.new(name, url)
	self.bg:removeAllChildren()
	self.map = map
	self.bg:addChild(map)

	local size = map:getContentSize()
	local scale = Stage.winSize.height/ size.height
	map:setScale(scale*1.10)
	mapWidth = size.width * scale
	self.arena:setContentSize(cc.size(mapWidth, Stage.winSize.height))

	self:focus(1.10 * mapWidth/2,Define.heroBottom)

	self:dispatchEvent(Event.Selected, {etype=Event.Selected})
	--self.map:setVisible(false)

	local mapEffect = mapEffectTable[url]
	if mapEffect then
		if type(mapEffect) == "function" then
			mapEffect(self,size)
		else
			self:addArmatureFrame("res/armature/effect/map/" .. mapEffect[1])
			local bone=ccs.Armature:create(mapEffect[2])
			--bone:setScale(scale*1.02)
			bone:setAnchorPoint(0.5,0.5)
			bone:setPosition(size.width / 2,size.height / 2)
			bone:getAnimation():play(mapEffect[2],-1,1)
			self.map._ccnode:addChild(bone)
			self.mapEffect = bone
		end
	end

	--[[
	local node = Common.getDrawBoxNode(cc.rect(0,0,100,640))
	self.arena._ccnode:addChild(node)

	local node = Common.getDrawBoxNode(cc.rect(mapWidth - 100,0,mapWidth,640))
	self.arena._ccnode:addChild(node)
	--]]


	--self.bg:shader(Shader.SHADER_TYPE_NEGATIVE)
	--self.bg:shader(Shader.SHADER_TYPE_BLUR, 0.0038, 0.0005)
end

function addFlyer(self,flyer)
	self.arena:addChild(flyer,2)
end

function hasFlyer(self)
	local ret = self.arena:getChildByType(Flyer.UI_FLYER_TYPE) and true or false
	return ret
end

function reorderHero(self,hero,order)
	local orderA = order or 1
	local orderB = (orderA == 1) and 2 or 1
	if self.heroB == hero then
		orderA,orderB = orderB,orderA
	end
	self.heroA:reorder(orderA)
	self.heroB:reorder(orderB)
end

function addHeroA(self, hero)
	if self.heroA then
		self.arena:removeChild(self.heroA)
	end
	self.heroA = hero
	self.arena:addChild(hero,1)
	hero.posx = self.focusX - half + 215
	hero:setPosition(hero.posx, Define.heroBottom)
	if self.heroB then
		self.heroB.posx = self.focusX + half - 215
		self.heroB:setPosition(self.heroB.posx, Define.heroBottom)
		self.heroB:setEnemy(hero)
		hero:setEnemy(self.heroB)
	end
	GiftLogic.checkGift(self.heroA,GiftDefine.ConditionType.all)
end

function addHeroB(self, hero)
	if self.heroB then
		self.arena:removeChild(self.heroB)
	end
	self.heroB = hero
	self.arena:addChild(hero,2)
	hero.posx = self.focusX + half - 215
	hero:setPosition(hero.posx, Define.heroBottom)
	if self.heroA then
		self.heroA.posx = self.focusX - half + 215
		self.heroA:setPosition(self.heroA.posx, Define.heroBottom)
		self.heroA:setEnemy(hero)
		hero:setEnemy(self.heroA)
	end
	GiftLogic.checkGift(self.heroB,GiftDefine.ConditionType.all)
end

function addAssistA(self)
	self.arena:removeChildByName("AssistA")
	if self.assistA then
		--self.arena:removeChild(self.assistA)
	end
	local assist = Hero.new("AssistA",self.fightControl:getAssistA(),true)
	--self.assistA = assist
	self.arena:addChild(assist,3)
	assist:setEnemy(self.heroB)
	assist:setMaster(self.heroA)
	self.heroA:setAssist(assist)
	local xa = self.heroA:getPositionX()
	local xb = self.heroB:getPositionX()
	if xa > xb then
		assist:setPosition(self:getRight(),Define.heroBottom)
		assist:setDirection(Hero.DIRECTION_LEFT)
	else
		assist:setPosition(self:getLeft(),Define.heroBottom)
		assist:setDirection(Hero.DIRECTION_RIGHT)
	end
	return assist
end

function addAssistB(self)
	self.arena:removeChildByName("AssistB")
	if self.assistB then
		--self.arena:removeChild(self.assistB)
	end
	local assist = Hero.new("AssistB",self.fightControl:getAssistB(),true)
	--self.assistB = assist 
	self.arena:addChild(assist,3)
	assist:setEnemy(self.heroA)
	assist:setMaster(self.heroB)
	self.heroB:setAssist(assist)
	local xa = self.heroA:getPositionX()
	local xb = self.heroB:getPositionX()
	if xa < xb then
		assist:setPosition(self:getRight(),Define.heroBottom)
		assist:setDirection(Hero.DIRECTION_LEFT)
	else
		assist:setPosition(self:getLeft(),Define.heroBottom)
		assist:setDirection(Hero.DIRECTION_RIGHT)
	end
	return assist
end

function onFrame(self,event) 
	if self.heroA and self.heroB then
		self:doCloseUpDown() --处理镜头拉近

		local heroLeft = self.heroA
		local heroRight = self.heroB
		local xl = heroLeft:getPositionX()
		local xr = heroRight:getPositionX()
		--print('=------==========xl,xr:',xl,xr)

		if xl > xr then
			heroLeft, heroRight = heroRight, heroLeft
			xl, xr = xr, xl
		end
		local oxl, oxr = xl, xr

		-----地图边界限制
		if xl < 110 then
			xl = xl + 2
		elseif xl < 100 then
			xl = 100 
		end
		if xr > mapWidth - 110 then
			xr = xr - 2
		elseif xr > mapWidth - 100 then
			xr = mapWidth - 100
		end

		-----挤压检测
		if heroLeft.curState and heroRight.curState then
			local isCollide, minx, miny, maxx = Helper.isPushCollide(heroLeft,heroRight)
			if isCollide then
				local d = (maxx - minx) / 2
				xl = xl - d
				xr = xr + d
			end
		end

		--if not heroLeft:getPenetrate() and not heroRight:getPenetrate() then
			-----英雄距离锁定
			if xr - xl > lockDistance then
				if xl < heroLeft.posx then
					xl = heroLeft.posx
				end
				if xr > heroRight.posx then
					xr = heroRight.posx
				end
			end
		--end

		if math.abs(xl - oxl) > 1 then 
			heroLeft:setPositionX(xl)
		end
		if math.abs(xr - oxr) > 1 then
			heroRight:setPositionX(xr)
		end

		heroLeft.posx = xl
		heroRight.posx = xr

		--摄像头移动
		local dx = (xr + xl) / 2 - self.focusX --焦点偏移量
		if dx > 50 then
			dx = 3 
		elseif dx < -50 then 
			dx = -3
		else
			dx = 0
		end

		local dy = (heroLeft:getBodyBoxReal().y + heroRight:getBodyBoxReal().y) / 2 - self.focusY
		if dy > 80 then
			dy = 2
		elseif dy < 0 then
			dy = -2
		else
			dy = 0
		end

		if dx ~= 0 or dy ~= 0 then
			self:focus(self.focusX + dx, self.focusY + dy)
		end

		----------------------------------方向判断-------------------------------
		if xl > xr then
			heroLeft, heroRight = heroRight, heroLeft
			xl, xr = xr, xl
		end
		if not heroLeft:getNoTurn() and not heroRight:getNoTurn() then
			if (not heroLeft:isJump() and not heroRight:isJump()) or Helper.heroDistance(heroLeft,heroRight) > 500 then 
				if heroLeft:getDirection() == Hero.DIRECTION_LEFT or heroRight:getDirection() == Hero.DIRECTION_RIGHT then
					heroLeft:setDirection(Hero.DIRECTION_RIGHT)
					heroRight:setDirection(Hero.DIRECTION_LEFT)
				end
			end
		end
		-----------------------------------移除特效-------------------------------
		self:removeEffect()

		----------------------------------战斗逻辑--------------------------------
		self.fightLogic:update(event.delay)
		self:checkFinish()
	end

end

function handleTurn(self)
	local heroLeft = self.heroA
	local heroRight = self.heroB
	local xl = heroLeft:getPositionX()
	local xr = heroRight:getPositionX()

	if xl > xr then
		heroLeft, heroRight = heroRight, heroLeft
		xl, xr = xr, xl
	end
	if not heroLeft:getNoTurn() and not heroRight:getNoTurn() then
		--if (not heroLeft:isJump() and not heroRight:isJump()) or Helper.heroDistance(heroLeft,heroRight) > 500 then 
		if (heroLeft.curState and heroLeft.curState.lock < Define.AttackLock.attack and heroLeft:isJump()) 
			or (heroRight.curState and heroRight.curState.lock < Define.AttackLock.attack and heroRight:isJump()) then

		else
			--if heroLeft:getDirection() == Hero.DIRECTION_LEFT or heroRight:getDirection() == Hero.DIRECTION_RIGHT then
				heroLeft:setDirection(Hero.DIRECTION_RIGHT)
				heroRight:setDirection(Hero.DIRECTION_LEFT)
			--end
		end
	end
end

function onTimeOver(self,event)
	self.fightLogic:timeOver()
end

function pause(self)
	self.isPause = true
end

function resume(self)
	self.isPause = nil
end

function sleep(self)
	if self.powBone then
		self.powBone:getAnimation():setSpeedScale(0)
	end

	if self.bgEffect then
		self.bgEffect:getAnimation():setSpeedScale(0)
	end
end

function wakeUp(self)
	if self.powBone then
		self.powBone:getAnimation():setSpeedScale(1)
	end

	if self.bgEffect then
		self.bgEffect:getAnimation():setSpeedScale(1)
	end
end

function nextHero(self)
	local isFinish = false
	local callback1
	if self.fightLogic.winer == "A" then
		if self.fightControl:nextHeroB() then
			callback1 = function()
				local info = self.heroB:getInfo()
				local gift = self.heroB.gift
				local heroB = Hero.new("heroB",self.fightControl:getHeroB())
				self:addHeroB(heroB)
				--heroB:getInfo():setPower(info:getPower())
				--heroB:getInfo():setAssist(info:getAssist())
				heroB:getInfo():addPower(info:getPower())
				heroB:getInfo():setAssist(info:getAssist() + 100)
				GiftLogic.doEffectByNextHero(heroB,gift.nextHero)

				self.heroA:getInfo():addPower(self.heroA.hero.dyAttr.rageRByWin)
				self.heroA:play("stand",true)
				--self:displayFightAttr()
			end
		else
			isFinish = true
			print('---------------A win---------------')
		end
		self.heroA:getInfo():addHp(self.heroA:getInfo():getMaxHp() * self.heroA:getHpRecover() / 100)
	else
		if self.fightControl:nextHeroA() then
			callback1 = function()
				local info = self.heroA:getInfo()
				local gift = self.heroB.gift
				local heroA = Hero.new("heroA",self.fightControl:getHeroA())
				self:addHeroA(heroA)
				GiftLogic.doEffectByNextHero(heroA,gift.nextHero)
				--heroA:getInfo():setPower(info:getPower())
				--heroA:getInfo():setAssist(info:getAssist())
				heroA:getInfo():addPower(info:getPower())
				heroA:getInfo():setAssist(info:getAssist() + 100)

				self.heroB:getInfo():addPower(self.heroB.hero.dyAttr.rageRByWin)
				self.heroB:play("stand",true)
				--self:displayFightAttr()

			end
		else
			isFinish = true
			print('---------------B win---------------')
		end
		self.heroB:getInfo():addHp(self.heroB:getInfo():getMaxHp() * self.heroB:getHpRecover() / 100)
	end
	if not isFinish then
		local callback2 = function()
			self.heroB:setDirection(Hero.DIRECTION_LEFT)
			self.heroA:setDirection(Hero.DIRECTION_RIGHT)
			self.ui:initRound()
			self.fightLogic = FightLogic.new(self.heroA,self.heroB)
			local report = FightReport.new()
			report:setReport(self.fightControl:createReport())
			self.fightLogic:setReport(report)
			self.fightLogic:start()
		end
		self:offOn(0.8,callback1,callback2)
		--self.ui:setHeroIcon()
		cc.Director:getInstance():getScheduler():setTimeScale(1)
		--self:playMusic()
	else
		self:exit()
	end
end

function exit(self)
	self.heroA.animation:getAnimation():stop()
	self.heroB.animation:getAnimation():stop()
	self.ui:closeTimer()
	self:closeTimer()
	self.arena:removeAllChildren()
	--self.bg:removeAllChildren()
	self.viewDown:removeAllChildren()
	self.viewUp:removeAllChildren()

	self:dispatchEvent(Event.FightEnd,{etype = Event.FightEnd,winer = self.fightLogic.winer,infoA = {index = self.fightControl.heroAIndex,power = self.heroA:getInfo():getPower(),assist = self.heroA:getInfo():getAssist(),hp=self.heroA:getInfo():getHp()},infoB = {index = self.fightControl.heroBIndex,power = self.heroB:getInfo():getPower(),assist = self.heroB:getInfo():getAssist(),hp=self.heroB:getInfo():getHp()}})
	self.heroA = nil
	self.heroB = nil
	self:clearRes()
end

function setReport(self, report)
	if self.fightLogic then
		local rp = FightReport.new()
		rp:setReport(report)
		self.fightLogic:setReport(rp)
	end
end

function getFightControl(self)
	return self.fightControl
end

function checkFinish(self)
	if self.fightLogic.isFinish and not self.fightLogic.aiData.hasCheck then
		--self.fightLogic.isFinish = false
		self.fightLogic.aiData.hasCheck = true
		self.ui:stopCD()
		self.ui:setCD()
		self.heroA:setComboCnt(0)
		self.heroB:setComboCnt(0)
		self.heroA.tmpSkillAttr = {}
		self.heroB.tmpSkillAttr = {}
		self:dispatchEvent(Event.FightDie, {etype=Event.FightDie,winer = self.fightLogic.winer,heroA = self.heroA,heroB = self.heroB})
		if self.isPause then
		else
			self:nextHero()
		end
	end
end

function getLeft(self)
	return -self.arena:getPositionX()
end

function getRight(self)
	return self:getLeft() + winWidth
end

function inCorner(self,isAHit)
	local ax = self.heroA:getPositionX()
	local bx = self.heroB:getPositionX()
	local dis = Helper.heroDistance(self.heroA,self.heroB)
	if isAHit then
		return (ax > bx and bx < 400 and dis < 200) or (ax < bx and bx > mapWidth - 400 and dis < 200)
	else
		return (bx > ax and ax < 400 and dis < 200) or (bx < ax and ax > mapWidth - 400 and dis < 200)
	end
	--return  < 200 and (lx < 300 or rx > mapWidth - 300 )
end

function focus(self, x, y)
	if self.arena:getScale() > 1 then
		return 
	end
	if x >= winWidth/2 and x <= mapWidth - winWidth/2 then
		self.focusX = x
		local px = winWidth/2 - x 
		self.arena:setPositionX(px)
		self.bg:setPositionX(px)
		--print("------>focus", x)
	end
	if y >= Define.heroBottom and y <= Define.heroBottom + 64 then
		self.focusY = y
		local py = Define.heroBottom - y
		self.arena:setPositionY(py)
		self.bg:setPositionY(py)
	end
end

local closeFrameCnt = 0
function doCloseUpDown(self)
	if not self.mScale then
		return
	end
	--[[
	closeFrameCnt = closeFrameCnt + 1
	if closeFrameCnt % 2 == 1 then
		return
	end
	--]]

	local nScale = self.arena:getScale()

	local dx 
	if nScale < self.mScale then
		nScale = nScale + 0.1
		dx = 0.1
		if nScale > self.mScale then
			self.mScale = nil
			self.mx = nil
			return
		end
	elseif nScale > self.mScale then
		nScale = nScale - 0.1
		dx = -0.1
		if nScale < self.mScale then
			self.mScale = nil
			self.mx = nil
			return
		end
	else
		return
	end
	local x,y = self.arena:getPosition()
	self.arena:setScale(nScale)
	self.arena:setPosition(x - self.mx * dx ,y - Define.heroBottom * dx)
	if nScale == 1 then
		local x,y = self.bg:getPosition()
		self.arena:setPosition(x,y)
	end
end

function closeUp(self,x)
	if self.mScale == 1.25 then
		return
	end
	self.mScale = 1.25
	self.mx = x
end

function closeDown(self,x)
	if self.mScale == 1 then
		return
	end
	self.mScale = 1
	self.mx = x
end

function removeBgEffect(self)
	--[[
	if self.bgEffect then
		self.viewDownEffectList[self.bgEffect] = true
		self.bgEffect = nil
	end
	--]]
end

function displayBgEffect(self,hero,effectName)
	--[[
	if self.bgEffect then
		return
	end
	--]]
	---[[
	--1星以上的才显示
	if hero.name == "heroA" and hero.hero.quality and hero.hero.quality < 2 then
		return
	end
	--]]
	hero:addArmatureFrame(string.format("res/armature/effect/%s/%s.ExportJson",string.lower(effectName),effectName))
	local bone=ccs.Armature:create(effectName)
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(Stage.winSize.width / 2,Stage.winSize.height / 2)
	bone:getAnimation():play(effectName,-1,0)
	bone:setScaleX(hero:getBgEffectDirect() or 1)
	self.viewDown._ccnode:addChild(bone)
	self.bgEffect = bone
	---[[
    bone:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			self.viewDownEffectList[bone] = true
			self.bgEffect = nil
		end
	end)
	--]]

end

function displayEffect(self,effectName,x,y,scaleX,underHero)
	--print('------------displayEffect:',effectName)
	local bone=ccs.Armature:create("Effect")
	bone:setScaleX(scaleX )
	--bone:setScaleY(1.8)
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(x,y)
	bone:getAnimation():play(effectName,-1,0)
	self.arena._ccnode:addChild(bone,underHero and -1 or 5)
    bone:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			self.arenaEffectList[bone] = true
		end
	end)
end

function removePowerAfter(self)
	if self.powBone then
		self.arenaEffectList[self.powBone] = true
		self.powBone = nil
	end
end

function displayPowerAfter(self,x)
	local bone=ccs.Armature:create("Effect")
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(x,Define.heroBottom + 190)
	bone:getAnimation():play("大招晕",-1,1)
	self.arena._ccnode:addChild(bone,3)
	self.powBone = bone
end

function displayPower(self,hero,callback)
	local bone =ccs.Armature:create("Power")
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(Stage.winSize.width / 2,Stage.winSize.height / 2)

	for k = 1,3 do
		local skin = ccs.Skin:create("res/hero/bicon/" .. hero.heroName .. ".png")
		bone:getBone("icon" .. k):addDisplay(skin, 0)
		bone:getBone("icon" .. k):changeDisplayWithIndex(0, true)
		bone:getBone("icon" .. k):setScale(1.3)
	end

	if hero:getSex() == 1 then	--
		bone:getAnimation():play("放大招男",-1,0)
	else
		bone:getAnimation():play("放大招女",-1,0)
	end
	self.viewUp._ccnode:addChild(bone)
    bone:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			self.viewUpEffectList[bone] = true
			if callback then
				callback()
			end
		end
	end)
end

function displayFightAttr(self,callback)
	local FightHeroAttr = require("src/modules/fight/ui/FightHeroAttr")
	local left = FightHeroAttr.new(true,self.heroA.hero)
	local right = FightHeroAttr.new(false,self.heroB.hero)


	local bone=ccs.Armature:create("HeroAttr")
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(Stage.winSize.width / 2,Stage.winSize.height / 2)

    bone:getBone("zuo"):addDisplay(left._ccnode, 0)
	bone:getBone("zuo"):changeDisplayWithIndex(0,true)

    bone:getBone("you"):addDisplay(right._ccnode, 0)
	bone:getBone("you"):changeDisplayWithIndex(0, true)

	bone:getAnimation():play('HeroAttr',-1,0)
	self.viewUp._ccnode:addChild(bone,1)
    bone:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			self.viewUpEffectList[bone] = true
			if callback then
				callback()
			end
			--redo
			self:displayRound(self.fightControl:getRoundNum(),function() 
				self:displayReadyGo(function()
					self.ui:startCD()
					self.fightLogic:changeAiState(Ai.AI_STATE_HIT)
				end)
			end)
		end
	end)

end

function displayRound(self,num,callback)
	num = math.max(num,1)
	num = math.min(num,5)
	SoundManager.playEffect("common/Round" .. num .. ".mp3")
	local bone=ccs.Armature:create("TipsEffect")
	bone:setAnchorPoint(0.5,0)
	bone:setPosition(Stage.winSize.width / 2,Stage.winSize.height / 2)

	local skin = ccs.Skin:createWithSpriteFrameName("r" .. num .. ".png")
    bone:getBone("1"):addDisplay(skin, 0)
	bone:getBone("1"):changeDisplayWithIndex(0, true)

	bone:getAnimation():play('Round',-1,0)
	self.viewUp._ccnode:addChild(bone)
    bone:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			self.viewUpEffectList[bone] = true
			if callback then
				callback()
			end
		end
	end)
end

function displayReadyGo(self,callback)
	local bone=ccs.Armature:create("TipsEffect")
	bone:setAnchorPoint(0.5,0)
	bone:setPosition(Stage.winSize.width / 2,Stage.winSize.height / 2)

	bone:getAnimation():play('ReadyGo',-1,0)
	self.viewUp._ccnode:addChild(bone)
    bone:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			self.viewUpEffectList[bone] = true
			if callback then
				callback()
			end
			self:dispatchEvent(Event.FightStart, {etype=Event.FightStart,round = self.fightControl:getRoundNum()})
		end
	end)
end

function displayKO(self,callback)
	SoundManager.playEffect("common/KO.mp3")
	local bone=ccs.Armature:create("TipsEffect")
	bone:setAnchorPoint(0.5,0)
	bone:setPosition(Stage.winSize.width / 2,Stage.winSize.height / 2)

	bone:getAnimation():play('KO',-1,0)
	self.viewUp._ccnode:addChild(bone)
    bone:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			self.viewUpEffectList[bone] = true
			if callback then
				callback()
			end
		end
	end)
end

function displayTimeOver(self,callback)
	local bone=ccs.Armature:create("TipsEffect")
	bone:setAnchorPoint(0.5,0)
	bone:setPosition(Stage.winSize.width / 2,Stage.winSize.height / 2)

	bone:getAnimation():play('TimeOver',-1,0)
	self.viewUp._ccnode:addChild(bone)
    bone:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			self.viewUpEffectList[bone] = true
			if callback then
				callback()
			end
		end
	end)
end

function removeEffect(self)
	for effect,_ in pairs(self.arenaEffectList) do
		self.arena._ccnode:removeChild(effect,true)
	end
	self.arenaEffectList = {}

	for flyer,_ in pairs(self.arenaFlyerList) do
		self.arena:removeChild(flyer)
	end
	self.arenaFlyerList = {}

	for effect,_ in pairs(self.sceneEffectList) do
		self._ccnode:removeChild(effect,true)
	end
	self.sceneEffectList = {}

	for effect,_ in pairs(self.viewDownEffectList) do
		self.viewDown._ccnode:removeChild(effect,true)
	end
	self.viewDownEffectList = {}

	for effect,_ in pairs(self.viewUpEffectList) do
		self.viewUp._ccnode:removeChild(effect,true)
	end
	self.viewUpEffectList = {}
end

function removeComboAdd(self)
	if self.comboAdd then
		self.ui._ccnode:removeChild(self.comboAdd,true)
		self.comboAdd = nil
	end
end

function displayComboAdd(self,hero,num)
	if num == 0 then
		return
	end

	local bone 
	if not self.comboAdd then
		bone = ccs.Armature:create("ComboAdd")
		bone:getAnimation():play("ComboAdd",-1,0)
		self.ui._ccnode:addChild(bone,1)
		bone:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
			if movementType == ccs.MovementEventType.complete then
				self:addTimer(function() self.ui._ccnode:removeChild(bone,true) end, 0.0001, 1)
			end
		end)
	end
	self:removeComboAdd()
	
	--bone:setScale(Stage.uiScale)


	local node = Helper.createComboAdd(num)
	local size = node:getContentSize()
	node:setScale(1/Stage.uiScale)
	if hero == self.heroA then
		node:setAnchorPoint(cc.p(0,0))
		node:setPosition(cc.p(10 / Stage.uiScale,(400 - size.height - 30) / Stage.uiScale))
		if bone then
			bone:setPosition(cc.p(-50 + size.width / 2,(400 - size.height - 30) / Stage.uiScale))
		end
	else
		node:setAnchorPoint(cc.p(1,0))
		node:setPosition(cc.p((winWidth - 10) / Stage.uiScale,(400 - size.height - 30) / Stage.uiScale))
		if bone then
			bone:setPosition(cc.p(winWidth + 50 - size.width / 2,(400 - size.height - 30) / Stage.uiScale))
		end
	end

	self.ui._ccnode:addChild(node)
	--node:setVisible(false)
	local seq = cc.Sequence:create(
		cc.FadeOut:create(0.001),
		cc.DelayTime:create(0.2),
		cc.FadeIn:create(0.001)
	)
	node:runAction(seq)
	self.comboAdd = node
	if self.comboAddTimer then
		self:delTimer(self.comboAddTimer)
	end
	self.comboAddTimer = self:addTimer(removeComboAdd, 1, 1)
end

function removeComboHit(self)
	if self.comboHit then
		self.ui._ccnode:removeChild(self.comboHit,true)
		self.comboHit = nil
	end
	if self.comboEffect then
		self.comboEffect:setVisible(false)
	end
end

function displayComboHit(self,hero,num)
	self:removeComboHit()

	if not self.comboEffect then
		self.comboEffect = ccs.Armature:create("ComboHitEffect")
		self.comboEffect:getAnimation():play("ComboHit",-1,1)
		self.ui._ccnode:addChild(self.comboEffect,1)
		self.comboEffect:setVisible(false)
		--self.comboEffect:setScale(1/Stage.uiScale)
	end
	--redo
	self.comboEffect:setVisible(num > 9)


	local node = Helper.createComboHit(num)
	local size = node:getContentSize()
	node:setScale(1/Stage.uiScale)
	if hero == self.heroA then
		node:setAnchorPoint(cc.p(0,0))
		node:setPosition(cc.p(10 / Stage.uiScale,400 / Stage.uiScale))
		self.comboEffect:setPosition(cc.p((10 + size.width / 2) / Stage.uiScale ,(350 + size.height / 2) / Stage.uiScale))
	else
		node:setAnchorPoint(cc.p(1,0))
		node:setPosition(cc.p((winWidth - 10) / Stage.uiScale,400 / Stage.uiScale))
		self.comboEffect:setPosition(cc.p((winWidth - 10 - size.width / 2) / Stage.uiScale ,(350 + size.height / 2) / Stage.uiScale))
	end

	self.ui._ccnode:addChild(node)
	self.comboHit = node
	if self.comboHitTimer then
		self:delTimer(self.comboHitTimer)
	end
	self.comboHitTimer = self:addTimer(removeComboHit, 1, 1)
end

function displayPowerTips(self,name)
	local bone =ccs.Armature:create("PowerTips")
	bone:getAnimation():play(name,-1,0)
	bone:setAnchorPoint(cc.p(0.5,0.5))
	bone:setPosition(Stage.winSize.width / 2,400)
	self.viewUp._ccnode:addChild(bone)
    bone:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			self.viewUpEffectList[bone] = true
		end
	end)
end

function displayDecHp(self,num,x,y)
	local node = Helper.createDecHp(num)
	node:runAction(cc.Sequence:create(
	    cc.Spawn:create(
			cc.MoveBy:create(0.33,cc.p(0,90)),
			cc.FadeOut:create(0.33)
		),
		cc.CallFunc:create(function() 
			self.arena._ccnode:removeChild(node,true)
		end)
	))
	node:setPosition(cc.p(x,y))
	self.arena._ccnode:addChild(node)
end

function displaySkillName(self,name,x,y)
	local nameList = Common.utf2tb(name)
	for k,name in ipairs(nameList) do
		local skin = {
			name="skillName" .. k,type="Label",x=0,y=0,width=36,height=24,
			normal={txt=name,font="SimSun",size=20,bold=false,italic=false,color={255,189,76}}
		}
		local lable = Label.new(skin)
		lable:enableStroke(81,46,30)
		lable:setAnchorPoint(0.5,0.5)
		lable:setPosition(x + k * 30,y)
		lable:runAction(cc.Sequence:create(
			cc.DelayTime:create(k * 0.3),
			cc.Spawn:create(
				cc.MoveBy:create(1,cc.p(0,90)),
				cc.FadeOut:create(1)
			),
			cc.CallFunc:create(function() 
				self.arena:removeChild(lable)
			end)
		))
		self.arena:removeChildByName("skillName" .. k)
		self.arena:addChild(lable)
	end
end

local harmIndex = 0
function displayFightEffect(self,txtType,node,direction,x,y,inView)
	local bone=ccs.Armature:create("FightTxtEffect")
	bone:setAnchorPoint(0.5,0.5)
	bone:setPosition(x,y)

    bone:getBone("Layer1"):addDisplay(node, 0)
	bone:getBone("Layer1"):changeDisplayWithIndex(0, true)

	if inView then
		self.viewUp._ccnode:addChild(bone)
	else
		self.arena._ccnode:addChild(bone)
	end
    bone:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			if inView then
				self.viewUpEffectList[bone] = true
			else
				self.arenaEffectList[bone] = true
			end
		end
	end)
	if txtType == "harm" then
		---[[
		harmIndex = harmIndex + 1
		if harmIndex > 3 then
			harmIndex = 1
		end
		bone:getAnimation():play('伤害' .. harmIndex,-1,0)
		--]]
		if direction == Hero.DIRECTION_RIGHT then
			bone:getAnimation():play('伤害' .. 3 + harmIndex,-1,0)
		else
			bone:getAnimation():play('伤害' .. harmIndex ,-1,0)
		end
	elseif txtType == "pow_hp" then
		bone:getAnimation():play('怒气加血',-1,0)
	elseif txtType == "crit" then
		bone:getAnimation():play('暴击',-1,0)
	elseif txtType == "block" then
		if direction == Hero.DIRECTION_RIGHT then
			bone:getAnimation():play('格挡2',-1,0)
		else
			bone:getAnimation():play('格挡1',-1,0)
		end
		--bone:getAnimation():play('格挡',-1,0)
	elseif txtType == "break" then
		bone:getAnimation():play('破招',-1,0)
	elseif txtType == "def" then
		if direction == Hero.DIRECTION_RIGHT then
			bone:getAnimation():play('降防2',-1,0)
		else
			bone:getAnimation():play('降防1',-1,0)
		end
	elseif txtType == "atk" then
		if direction == Hero.DIRECTION_RIGHT then
			bone:getAnimation():play('加攻2',-1,0)
		else
			bone:getAnimation():play('加攻1',-1,0)
		end
	elseif txtType == "decPower" then
		bone:getAnimation():play('怒气消耗',-1,0)
	elseif txtType == "career" then
		if direction == Hero.DIRECTION_RIGHT then
			bone:getAnimation():play('属性被克1',-1,0)
		else
			bone:getAnimation():play('属性被克2',-1,0)
		end
	else
		if inView then
			self.viewUpEffectList[bone] = true
		else
			self.arenaEffectList[bone] = true
		end
	end
end

-- 过场动画特效 (关门开门)
function offOn(self, sec,callback1,callback2,delay,c4b)
	if not self.fx_offon then
		self.fx_offon = true
		sec = sec or 0.5
		local c4b = c4b or cc.c4b(0,0,0,255)
		local h2 = Stage.winSize.height/2 + 50 --多加50防止门缝

		self.upDoor = LayerColor.new2("offon_updoor", c4b, Stage.winSize.width, h2)
		self.upDoor:setPositionY(Stage.winSize.height)
		self.viewUp:addChild(self.upDoor)

		self.downDoor = LayerColor.new2("offon_downdoor", c4b, Stage.winSize.width, h2)
		self.downDoor:setPositionY(-h2)
		self.viewUp:addChild(self.downDoor)

		self.upDoor:runAction(cc.Sequence:create({
			cc.MoveBy:create(sec/2, cc.p(0, -h2)),
			cc.CallFunc:create(function()
				if callback1 then
					callback1()
				end
			end),
			cc.DelayTime:create(delay or 0),
			cc.MoveBy:create(sec/2, cc.p(0, h2)),
			cc.CallFunc:create(function()
				if callback2 then
					callback2()
				end
				self.viewUp:removeChild(self.upDoor)
				self.viewUp:removeChild(self.downDoor)
				self.fx_offon = nil

				--这里是每个回拿的开始，调用 
				--GiftLogic.checkGift(self.heroA,GiftDefine.ConditionType.all)
				GiftLogic.checkGift(self.heroA,GiftDefine.ConditionType.teammateFight)
				GiftLogic.checkGift(self.heroA,GiftDefine.ConditionType.teammateAssist)
				GiftLogic.checkGift(self.heroA,GiftDefine.ConditionType.opponent)
				GiftLogic.checkGift(self.heroA,GiftDefine.ConditionType.heroIndex)
				GiftLogic.checkGift(self.heroA,GiftDefine.ConditionType.enemyIndex)

				---[[
				--GiftLogic.checkGift(self.heroB,GiftDefine.ConditionType.all)
				GiftLogic.checkGift(self.heroB,GiftDefine.ConditionType.teammateFight)
				GiftLogic.checkGift(self.heroB,GiftDefine.ConditionType.teammateAssist)
				GiftLogic.checkGift(self.heroB,GiftDefine.ConditionType.opponent)
				GiftLogic.checkGift(self.heroB,GiftDefine.ConditionType.heroIndex)
				GiftLogic.checkGift(self.heroB,GiftDefine.ConditionType.enemyIndex)
				--]]

				-- vip副本加成
				if self.fightType == Define.FightType.vipLevel then
					VipLevelLogic.checkAttr(self.heroA,self.heroB,self.args.vipLevelId)
					local maxHp = self.heroA.vipLevelAttr.maxHp
					if maxHp and maxHp > 0 then 
						self.heroA:getInfo():setMaxHp(maxHp)
					end
				end
			end)
		}))

		self.downDoor:runAction(cc.Sequence:create({
			cc.MoveBy:create(sec/2, cc.p(0, h2)),
			cc.DelayTime:create(delay or 0),
			cc.MoveBy:create(sec/2, cc.p(0, -h2)),
		}))
	end
end

-- 闪屏特效 sec:闪屏时间 cnt:闪屏次数 c4b:闪烁色 bgc4b:底色
function flash(self, sec, cnt, c4b, bgc4b,force)
	if self.fx_flash and force then
		--self.red:stopAction(self.fx_flash)
		self.fx_flash = nil
		self.bg:removeChild(self.red)
		self.red = nil
		self.bg:removeChild(self.black)
		self.black = nil
	end
	if self.fx_flash then
		return
	end
	c4b = c4b or cc.c4b(255,0,0,255) --红
	bgc4b = bgc4b or cc.c4b(0,0,0,255) --黑
	--bgc4b = bgc4b or cc.c4b(0,0,0,0) --透明
	self.red = LayerColor.new2("flash_red", c4b, mapWidth * 1.2, Stage.winSize.height * 1.2)
	self.black = LayerColor.new2("flash_black", bgc4b, mapWidth * 1.2, Stage.winSize.height * 1.2)
	self.bg:addChild(self.black)
	self.bg:addChild(self.red)
	local seq = cc.Sequence:create({
		cc.Blink:create(sec, cnt), 
		--cc.EaseIn:create(cc.Blink:create(sec, cnt), 1.05), 
		cc.CallFunc:create(function()
			self.bg:removeChild(self.black)
			self.bg:removeChild(self.red)
			self.fx_flash = nil
		end)})
	self.red:runAction(seq)
	self.fx_flash = true
end

function flashHash(self,index)
		-- self:flash(0.12,1,cc.c4b(220,220,220,160),cc.c4b(0,0,0,0)) --白色轻闪
		--self:flash(0.12,1,cc.c4b(75,138,252,80),cc.c4b(0,0,0,0)) --青色轻闪
	local hash = {
		--[1] = function() self:flash(0.06,1,cc.c4b(220,220,220,160),cc.c4b(0,0,0,0)) end,	--白色轻闪
		[1] = function() self:flash(0.06,1,cc.c4b(220,220,220,70),cc.c4b(0,0,0,0)) end,	--白色轻闪
		--[2] = function() self:flash(0.06,1,cc.c4b(75,138,252,80),cc.c4b(0,0,0,0)) end,	--青色轻闪
		[2] = function() self:flash(0.06,1,cc.c4b(255,0,0,255),cc.c4b(0,0,0,0)) end,	--红色轻闪
	}
	if hash[index] then
		hash[index]()
	else
		self:flash(0.12,1,cc.c4b(220,220,220,160),cc.c4b(0,0,0,0)) --白色轻闪
	end
end

-- 地震特效 sec:每次震荡时间 cnt:震荡次数 dis:震幅  dir:震动方向 ddis:震幅变化
function shock(self, sec, cnt, dis, dir, ddis)
	if not self.fx_shock then
		self.fx_shock = true 
		sec = sec or 0.6
		cnt = cnt or 5 
		dis = dis or 15 
		dir = dir or 90 
		ddis = ddis or 0 
		local ary = {}
		for i=1, cnt do
			--local d = dis * (cnt - i + 1) / cnt
			local d = dis + i * ddis 
			local dy = math.sin(dir/160*math.pi) * d
			local dx = math.cos(dir/160*math.pi) * d
			local move = cc.MoveBy:create(sec/2, cc.p(-dx, -dy))
			--local sine = cc.EaseSineOut:create(move)
			--table.insert(ary, sine)
			table.insert(ary, move)

			move = cc.MoveBy:create(sec/2, cc.p(dx, dy))
			--sine = cc.EaseSineIn:create(move)
			--table.insert(ary, sine)
			table.insert(ary, move)
		end
		table.insert(ary, cc.CallFunc:create(function()
			self.fx_shock = nil
		end))
		local seq = cc.Sequence:create(ary)
		self.map:runAction(seq)
		self.arena:runAction(seq:clone())
		if self.bgEffect then
			self.bgEffect:runAction(seq:clone())
		end
	end
end

function shockHash(self,index)
	--index = 2
	local hash = {
		--[1] = function() self:shock(0.04,1,2,90) end, -- 小小震
		[1] = function() self:shock(0.04,1,4,80) end,-- 小震
		[2] = function() self:shock(0.04,1,4,80) end,-- 小震
		[3] = function() self:shock(0.05,5,5,90) end,--中震
		[4] = function() self:shock(0.05,6,8,90,0.5) end,--大震
		[5] = function() self:shock(0.09,3,19,0,0.9) end,--超大震
		[6] = function() self:shock(0.05,5,5,0) end,--横中震
		[7] = function() self:shock(0.09,1,18) end,--倒地震
		[8] = function() self:shock(0.09,3,23) end,--超超大震
		[9] = function() self:shock(0.02,1,59) end,--陈国汗专用大震

		--[-1] = function() self:shock(0.04,1,2,90) end, -- 小小震
		[-1] = function() self:shock(0.04,1,4,80) end,-- 小震
		[-2] = function() self:shock(0.04,1,4,80) end,-- 小震
		[-3] = function() self:shock(0.05,5,5,90) end,--中震
		[-4] = function() self:shock(0.05,6,8,90,0.5) end,--大震
		[-5] = function() self:shock(0.09,3,19,0,0.9) end,--超大震
		[-6] = function() self:shock(0.05,5,5,0) end,--横中震
	}
	if hash[index] then
		hash[index]()
	else
		self:shock(0.05,1,7) --轻震1次
	end
end

function startBlackScreen(self)
	if not self.sbScreen then
		self.sbScreen = LayerColor.new2("sbScreen", cc.c4b(0,0,0,255), mapWidth * 1.2, Stage.winSize.height * 1.2)
		self.bg:addChild(self.sbScreen)
	end
end

function endBlackScreen(self)
	if self.sbScreen then
		self.bg:removeChild(self.sbScreen)
		self.sbScreen = nil
	end
end

-- 黑屏效果
function blackScreen(self, sec,c4b,callback)
	if not self.fx_black then
		self.fx_black = true
		sec = sec or 0.5
		c4b = c4b or cc.c4b(0,0,0,255) --黑
		self.blackLayer = LayerColor.new2("blackScreen_black", c4b, mapWidth * 1.2, Stage.winSize.height * 1.2)
		self.bg:addChild(self.blackLayer)
		local seq = cc.Sequence:create({
			cc.DelayTime:create(sec), 
			cc.CallFunc:create(function()
				self.bg:removeChild(self.blackLayer)
				self.blackLayer = nil
				self.fx_black= nil
				if callback then
					callback()
				end
			end)})
		self.blackLayer:runAction(seq)
	end
end

--shader
--bg:shader(Shader.SHADER_TYPE_BLUR, 0.0038, 0.0005)
function setShader(self,shaderName,...)
	--bg:shader(Shader.SHADER_TYPE_BLUR, 0.0038, 0.0005)
	if self.mapEffect then
		self.mapEffect:setVisible(false)
	end
	if shaderName == "Black" then
		self:startBlackScreen()
	end
	if shaderName == nil or shaderName == "" then
		self:endBlackScreen()
		if self.mapEffect then
			self.mapEffect:setVisible(true)
		end
	end
	self.map:shader(shaderName,...)
end

local keyCodeForHeroA = {
    [-cc.KeyCode.KEY_A] = 'back_run',
    --[-cc.KeyCode.KEY_A] = 'break_heat',
    [cc.KeyCode.KEY_A] = 'forward_run',
    [-cc.KeyCode.KEY_D] = 'forward_run',
    [cc.KeyCode.KEY_D] = 'back_run',
    --[cc.KeyCode.KEY_D] = 'stand_heavy_defense',
    [cc.KeyCode.KEY_W] = 'jump',
    [cc.KeyCode.KEY_S] = 'jump_forward',

	[cc.KeyCode.KEY_H]  = 4211,
    [cc.KeyCode.KEY_J]  = 4202,
    [cc.KeyCode.KEY_K]  = 4203,
    [cc.KeyCode.KEY_L]  = 4204,
    [cc.KeyCode.KEY_U]  = 4205,
    [cc.KeyCode.KEY_I]  = 4206,
    [cc.KeyCode.KEY_O]  = 4207,
    [cc.KeyCode.KEY_P]  = 4208,
    [cc.KeyCode.KEY_N]  = 4209,
    [cc.KeyCode.KEY_M]  = 4210,

}
--4177-4179 左上右下 
local keyCodeForHeroB = {
    [-cc.KeyCode.KEY_LEFT_ARROW] = 'back',
    --[-cc.KeyCode.KEY_LEFT_ARROW] = 'stand_light_defense',
    [cc.KeyCode.KEY_LEFT_ARROW] = 'forward',
    [cc.KeyCode.KEY_UP_ARROW] = 'jump',
    [-cc.KeyCode.KEY_RIGHT_ARROW] = 'forward',
    [cc.KeyCode.KEY_RIGHT_ARROW] = 'back',
    --[cc.KeyCode.KEY_RIGHT_ARROW] = 'stand_heavy_defense',
    [cc.KeyCode.KEY_DOWN_ARROW] = 'jump_forward',
    
    [cc.KeyCode.KEY_1]  = 4211,
    [cc.KeyCode.KEY_2]  = 4212,
    [cc.KeyCode.KEY_3]  = 4213,
    [cc.KeyCode.KEY_4]  = 4214,
    [cc.KeyCode.KEY_5]  = 4215,
    [cc.KeyCode.KEY_6]  = 4216,
    [cc.KeyCode.KEY_7]  = 4217,
	[cc.KeyCode.KEY_8]  = 4218,
	[cc.KeyCode.KEY_9]  = 4226,
	[cc.KeyCode.KEY_0]  = 4225,
    
}
function onKeyboardPress(self,keyCode,event)
	if not self.heroA or not self.heroB then
		return 
	end
	
	if keyCode == cc.KeyCode.KEY_Q then
		self.heroA:getInfo():addPower(100)
	end

	if keyCode == cc.KeyCode.KEY_E then
		self.heroA:getInfo():addAssist(100)
	end

    if keyCodeForHeroA[keyCode * self.heroA:getDirection()] then
        self.heroA:play(keyCodeForHeroA[keyCode * self.heroA:getDirection()],false,false)
    else
        if keyCodeForHeroA[keyCode] then
            self.heroA:play(keyCodeForHeroA[keyCode],false,false)
        end
    end

    if keyCodeForHeroB[keyCode * self.heroB:getDirection()] then
        self.heroB:play(keyCodeForHeroB[keyCode * self.heroB:getDirection()],false,false)
        --self.heroA:play(keyCodeForHeroB[keyCode * self.heroB:getDirection()],false,false)
    else
        if keyCodeForHeroB[keyCode] then
            self.heroB:play(keyCodeForHeroB[keyCode],false,false)
            --self.heroA:play(keyCodeForHeroB[keyCode],false,false)
        end
    end

	--测试特效
	--self:testFx(keyCode)

    ---[[
    if keyCode == cc.KeyCode.KEY_SPACE then
		--self.ui:displayCrtEffect(self.heroA)
		--self.ui:displayCrtEffect(self.heroB)
		--local node = Helper.createFightEffect("fe_nq",-Define.comboPower,"fe_jz")
		--self.ui:displayPowerTxt(node)
		--self:displayPowerTips("Combo")
--]]
		local xa = self.heroA:getPositionX()
		local xb = self.heroB:getPositionX()
		self.heroA:setPositionX(xb)
		self.heroB:setPositionX(xa)
			
		--self:setHeroAHp(0)
		--self:sperateHero()
		--self.ui:displayAssistEffect(self.heroA,Helper.createAssistEffect())
		--self.ui:displayAssistEffect(self.heroB,Helper.createAssistEffect())
		--[[
		if math.random(1,2) == 1 then
		else
			cc.Director:getInstance():getScheduler():setTimeScale(1)
		end
		--]]
    end
    --]]
    --print('========================heroA:',self.heroA:getShadowRect())
    --print('========================heroB:',self.heroB:getShadowRect())
end

local sec, cnt, dis, dir, ddis, sign = 0.05, 1, 5, 90, 0.1, 1
function testFx(self, keyCode)

    if keyCode == cc.KeyCode.KEY_SPACE then
		--self:flash(1.2, 8)
		--self:flash(0.12,1,cc.c4b(220,220,220,160),cc.c4b(0,0,0,0)) --白色轻闪
		--self:flash(0.12,1,cc.c4b(75,138,252,80),cc.c4b(0,0,0,0)) --青色轻闪
		--self:blackScreen(0.1)
		--self:offOn(0.5)
		--self:displayRound(math.random(1,5))
		--self:shock(0.05,1,5) --轻震1次
		self:shock(sec, cnt, dis, dir, ddis) --轻震1次
		--self:shock(0.5,10,5)
        --FightLogic.power(self.heroB,self.heroA)
		--self:shock(0.05,1,8)
	elseif keyCode == cc.KeyCode.KEY_SHIFT then
		sign = sign * -1
	elseif keyCode == cc.KeyCode.KEY_Z then
		sec = sec + 0.01 * sign
	elseif keyCode == cc.KeyCode.KEY_X then
		cnt = cnt + 1 * sign
	elseif keyCode == cc.KeyCode.KEY_C then
		dis = dis + 1 * sign
	elseif keyCode == cc.KeyCode.KEY_V then
		dir = dir + 10 * sign
	elseif keyCode == cc.KeyCode.KEY_B then
		ddis = ddis + 0.1 * sign
	end

	if not self.fxtxt then
		local labelSkin = {
			name="fxtxt",type="Label",x=0,y=100,width=100,height=30,
			normal={txt = '',font="Helvetica",size=20,bold=false,italic=false,color={201,251,251}}
		}
		self.fxtxt = Label.new(labelSkin) 
		self:addChild(self.fxtxt)
	end
	self.fxtxt:setString(string.format(
	"%d 地震特效 sec:次时间Z=%f cnt:次数X=%d dis:震幅C=%d  dir:方向V=%d ddis:震幅变化B=%f",
	sign, sec, cnt, dis, dir, ddis))

end

--[[
function onPlayEnd(self,event,target)
    --self:dispatchEvent(Event.PlayEnd, {etype = Event.PlayEnd,isFinish = false,stateName = self.curState.name,playId = self.playId})
	if event.isFinish then
		if event.stateName == 1001 or event.stateName == 1002 then
			target:play(event.stateName + 1)
		end
	else
	end
end
--]]

----------------------------------interface----------------------------------
function decHeroBHp(self,hp)
	if not self.heroB then
		return
	end
	self.heroB:getInfo():decHp(hp)
end

function addHeroBHp(self,hp)
	if not self.heroB then
		return
	end
	self.heroB:getInfo():addHp(hp)
end

function setHeroBHp(self,hp)
	if not self.heroB then
		return
	end
	self.heroB:getInfo():setHp(hp)
end

function addHeroBAssist(self,val)
	if not self.heroB then
		return
	end
	self.heroB:getInfo():addAssist(val)
end

function addHeroBPower(self,val)
	if not self.heroB then
		return
	end
	self.heroB:getInfo():addPower(val)
end

function decHeroAHp(self,hp)
	if not self.heroA then
		return
	end
	self.heroA:getInfo():decHp(hp)
end

function setHeroAHp(self,hp)
	if not self.heroA then
		return
	end
	self.heroA:getInfo():setHp(hp)
end

function addHeroAHp(self,hp)
	if not self.heroA then
		return
	end
	self.heroA:getInfo():addHp(hp)
end

function addHeroAAssist(self,val)
	if not self.heroA then
		return
	end
	self.heroA:getInfo():addAssist(val)
end

function addHeroAPower(self,val)
	if not self.heroA then
		return
	end
	self.heroA:getInfo():addPower(val)
end

function setHeroANoAddPower(self,flag)
	if self.heroA then
		self.heroA:getInfo():setNoAddPower(flag)
	end
end

function setHeroBNoAddPower(self,flag)
	if self.heroB then
		self.heroB:getInfo():setNoAddPower(flag)
	end
end

function sperateHero(self)
		local heroLeft = self.heroA
		local heroRight = self.heroB
		local xl = heroLeft:getPositionX()
		local xr = heroRight:getPositionX()
		if xl > xr then
			heroLeft, heroRight = heroRight, heroLeft
			xl, xr = xr, xl
		end
		heroLeft:setPositionX(self:getLeft() + 150)
		heroRight:setPositionX(self:getRight() - 150)
		heroLeft.posx = self:getLeft() + 150
		heroRight.posx = self:getRight() - 150
		--cc.Director:getInstance():getScheduler():setTimeScale(0)
end

function changeAiState(self, state)
	if self.fightLogic then
		self.fightLogic:changeAiState(state)
	end
end

function setComboStop(self,flag)
	self.fightLogic.isComboStop = flag
end

function setCareerVisiable(self,flag)
	self.isCareerVisiable = flag
end
