module(..., package.seeall)
setmetatable(_M, {__index = Control})





local Def = require("src/modules/hero/HeroDefine")
local HeroQualityConfig = require("src/config/HeroQualityConfig").Config
local HeroStarConfig = require("src/config/HeroStarConfig").Config
local Hero = require("src/modules/hero/Hero")
local BagData = require("src/modules/bag/BagData")
local BaseMath = require("src/modules/public/BaseMath")
local SkillLogic = require("src/modules/skill/SkillLogic")
local SkillDefine = require("src/modules/skill/SkillDefine")
local SkillConfig = require("src/config/SkillConfig").Config
local SkillGroupConfig = require("src/config/SkillGroupConfig").Config
function new(name,star)
	-- star 2--5
	local ctrl = Control.new(require("res/hero/HeroStarPreviewSkin"),{"res/hero/HeroStarPreview.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(name,star)
	return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP_RAW
end
function addStage(self)
	self:setPositionY(Stage.uiBottom)
end
function setAttr(self,name,star,attr)
	self.txtstar:setString("+1")
	local hero = Hero.getHero(name)
	if hero then
		if attr then
			self.txtatkspeed:setString("+"..attr.atkSpeed-hero.dyAttr.atkSpeed)
			self.txtmaxhp:setString("+"..attr.maxHp-hero.dyAttr.maxHp)
			self.txtskillatk:setString("+"..attr.finalAtk - hero.dyAttr.finalAtk)
			self.txtskilldef:setString("+"..attr.finalDef - hero.dyAttr.finalDef)
		else
			self.txtatkspeed:setString("+0")
			self.txtmaxhp:setString("+0")
			self.txtskillatk:setString("+0")
			self.txtskilldef:setString("+0")
		end
	end
end
function init(self,name,star)
	assert(star >=2 and star <= Def.MAX_QUALITY)
	local heroConf = Def.DefineConfig[name]

	self:setAttr(name,star)
	Network.sendMsg(PacketID.CG_HERO_STAR_ATTR,name,star)

	self.hero = Hero.getHero(name)
	self.heroName = name
	-- Common.setLabelCenter(self.txtname)
	-- self.txtname:setString(self.hero.cname)
	self.herolook:setVisible(false)
	Common.setLabelCenter(self.txtname)
	local heroName = string.format("(%d星)%s",star,heroConf.cname)
	self.txtname:setString(heroName)

	AudioEngine.playEffect("res/sound/fight/common/Success.mp3",false)


	-- self:addArmatureFrame('res/common/effect/starsuccess/starsuccess.ExportJson')
	-- local ani = ccs.Armature:create('starsuccess')
	-- ani:setAnchorPoint(0.5,0.5)
	-- local px,py = self.activated:getPosition()
	-- local size = self.activated:getContentSize()
	-- ani:setPosition(px+size.width/2,py+size.height/2)
	-- self._ccnode:addChild(ani)
	-- ani:getAnimation():play('Animation1',-1,0)
	self:openTimer()
	if star == 2 then
		self:showGroup(name,SkillDefine.TYPE_FINAL)
	elseif star == 3 then
		self:showBreak(name)
	elseif star == 4 then
		self:showGroup(name,SkillDefine.TYPE_COMBO)
	elseif star == 5 then
		self:showStandby(name)
	end

	local function onClose(self,event,target)
		if event.etype == Event.Touch_ended then
			UIManager.removeUI(self)
		end
	end
	self:addEventListener(Event.TouchEvent,onClose,self)
end

function getStandPosition(self)
	local size = self.herolook:getContentSize()
	local px,py = self.herolook:getPosition()
	-- return (px+size.width/2)*Stage.uiScale,(py + 50)*Stage.uiScale
	return px+size.width/2,py
end

function showStandby(self,name)
	local url = string.format("res/armature/%s/%s.ExportJson",string.lower(name),name)
	self:addArmatureFrame(url)
	self.heroBody = ccs.Armature:create(name)
	-- self.heroBodyX,self.heroBodyY = self.heroicon:getPosition()
	local x,y = self:getStandPosition()
	self.heroBody:setAnchorPoint(0.5,0.5)
	self.heroBody:setPosition(x,y)
	-- self.heroBody:setScaleX(-1)
	self.heroBody:setVisible(true)
	self._ccnode:addChild(self.heroBody,1)
	self.heroBody:getAnimation():playWithNames({'胜利'},0,false)
	self.heroBody:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			self.heroBody:getAnimation():playWithNames({'待机'},0,true)
		end
	end)

	-- local shineDown = self:displayEffect("res/armature/effect/shineEffect/ShineEffect.ExportJson",'ShineEffect',"ShineDown",0,nil,-1,1)
	-- self._ccnode:addChild(shineDown,1)
	-- shineDown:setPosition(x,y)

	local shineUp = self:displayEffect("res/armature/effect/shineEffect/ShineEffect.ExportJson",'ShineEffect',"ShineEffect",0,nil,nil,1)
	self._ccnode:addChild(shineUp,1)
	shineUp:setPosition(x,y)
end

function displayEffect(self,url,exportJson,actionName,x,y,zorder,loop)
	local skin = {name="myCtrl" .. actionName,type="Container",x=0,y=0,width=0,height=0,children={}}
	local ctrl = Control.new(skin)
	ctrl:addArmatureFrame(url)
    local bone = ccs.Armature:create(exportJson)
    bone:setAnchorPoint(0.5,0)
    bone:setPosition(x,y)
    ctrl._ccnode:addChild(bone)
	self:addChild(ctrl,zorder or 0)
	bone:getAnimation():play(actionName,-1,loop or 0)


    bone:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
		if movementType == ccs.MovementEventType.complete then
			self:addTimer(function() 
				self:removeChild(ctrl)
			end,0.0001,1)
		end
	end)
	return ctrl 
end

function displayBreakEffect(self)
	if self.hero.quality and self.hero.quality < 3 then
		return
	end
	--self.breakEffect:getAnimation():play(HeroDefine.CAREER_NAMES[self.hero.career],-1,0)
	self:displayEffect("res/armature/effect/BreakEffect.ExportJson",'BreakEffect','BreakEffect',0,self:getBodyBoxReal().height / 2)
end

function displayComboEffect(self)
	if self.hero.quality and self.hero.quality < 4 then
		return
	end
	--self.comboEffect:getAnimation():play("Combo",-1,0)
	self:displayEffect("res/armature/effect/ComboEffect.ExportJson",'ComboEffect',"Combo",0,nil,-1)
end



function showBreak(self,name)
	local url = string.format("res/armature/%s/%s.ExportJson",string.lower(name),name)
	self:addArmatureFrame(url)
	self.heroBody = ccs.Armature:create(name)
	self.heroBodyX = self.heroBody:getContentSize().width
	self.heroBodyY = 20 
	self.heroBody:setAnchorPoint(0.5,0.5)
	local x,y = self:getStandPosition()
	self.heroBody:setPosition(x,y)
	self.heroBody:setScaleX(-1)
	self.heroBody:setVisible(true)
	self._ccnode:addChild(self.heroBody,1)
	self.heroBody:getAnimation():playWithNames({'暴气'},0,false)
	self.heroBody:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			self.heroBody:getAnimation():playWithNames({'待机'},0,true)
		end
	end)
	self:displayEffect("res/armature/effect/breakEffect/BreakEffect.ExportJson",'BreakEffect','BreakEffect',x,y+50)

end

-- function showCombo(self,name)
-- 	local url = string.format("res/armature/%s/%s.ExportJson",string.lower(name),name)
-- 	self:addArmatureFrame(url)
-- 	self.heroBody = ccs.Armature:create(name)
-- 	self.heroBodyX = self.heroBody:getContentSize().width
-- 	self.heroBodyY = 20 
-- 	self.heroBody:setAnchorPoint(0,0.5)
-- 	self.heroBody:setPosition(self.heroBodyX,self.heroBodyY)
-- 	self.heroBody:setScaleX(-1)
-- 	self.heroBody:setVisible(true)
-- 	self._ccnode:addChild(self.heroBody,1)
-- 	self.heroBody:getAnimation():playWithNames({'暴气'},0,false)
-- 	self.heroBody:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
-- 		if movementType == ccs.MovementEventType.complete then
-- 			self.heroBody:getAnimation():playWithNames({'待机'},0,true)
-- 		end
-- 	end)
-- 	self:displayEffect("res/armature/effect/ComboEffect.ExportJson",'ComboEffect',"Combo",x,y+100)
-- end

function showGroup(self,name,groupId)
	local url = string.format("res/armature/%s/%s.ExportJson",string.lower(name),name)
	self:addArmatureFrame(url)
	self.heroBody = ccs.Armature:create(name)
	self.heroBodyX = self.heroBody:getContentSize().width
	self.heroBodyY = 20 
	self.heroBody:setAnchorPoint(0.5,0.5)
	local x,y = self:getStandPosition()
	self.heroBody:setPosition(x,y)
	self.heroBody:setScaleX(-1)
	self.heroBody:setVisible(true)
	self._ccnode:addChild(self.heroBody,1)

	self.armatureCfg = require(string.format("src/config/hero/%sConfig",name)).Config
	local finalGroupId = SkillLogic.getSkillGroup(self.hero,groupId).groupId
	local groupConf = SkillGroupConfig[finalGroupId]
	local skillList = groupConf.skill
	local animations = {}
	local actionList = {}
	if next(groupConf.showAction) then
		for _,actionId in ipairs(groupConf.showAction) do
			actionList[#actionList+1] = actionId
			local cfg = self.armatureCfg[actionId]
			if cfg then
				animations[#animations+1] = cfg.action
			end
		end
	else
		for _,skillId in ipairs(skillList) do
			local conf = SkillConfig[skillId]
			assert(conf,"lost skill conf===>" .. skillId)
			local actionCfg = conf.action
			local actionId = actionCfg[math.random(1,#actionCfg)]
			actionList[#actionList+1] = actionId
			local cfg = self.armatureCfg[actionId]
			if cfg then
				animations[#animations+1] = cfg.action
			end
		end
	end
	local lastActionId = actionList[#actionList]
	if name == "Shingo" then
		lastActionId = actionList[1]
	end
	animations[#animations+1] = "待机"

	local actionIndex = 1
	local shadowBone = self.heroBody:getBone("影子")
    self.heroBody:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			actionIndex = actionIndex + 1
			local boundBox = shadowBone:getDisplayManager():getBoundingBox()
			local x = self.heroBody:getPositionX()
			local offsetX = boundBox.x + boundBox.width / 2
			if #animations == 1 then
				self.heroBody:setPositionX(posX)
			elseif #animations > 1 then
				self.heroBody:setPositionX(x - offsetX)
			end
			if #animations == 1 then
				self.heroBody:getAnimation():playWithNames({table.remove(animations,1)},0,true)
			elseif #animations > 1 then
				self.heroBody:getAnimation():playWithNames({table.remove(animations,1)},0,false)
			end
		end
	end)

    self.heroBody:getAnimation():playWithNames({table.remove(animations,1)},0,false)


	--飞行物
    self.heroBody:getAnimation():setFrameEventCallFunc(function(bone,evt,originFrameIndex,currentFrameIndex) 
		if evt == "fly" then
			local FHero = require("src/modules/fight/hero/" .. self.heroName)
			local startName,loopName,endName = FHero.getFlyName({curState={name=actionList[actionIndex]}})
			if not startName then startName = loopName end
			if not endName then endName = "end" end
			local boundBox = bone:getDisplayManager():getBoundingBox()
			local rect = self:changeToRealRect(boundBox)
    		local animation = ccs.Armature:create(self.heroName)
			local state = startName 
			animation:setScaleX(-1)
			animation:setAnchorPoint(cc.p(0.5,0.5))
			animation:setPosition(cc.p(rect.x,posY))
			animation:getAnimation():play(state,-1,0)
    		animation:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
				if movementType == ccs.MovementEventType.complete then
					if state == startName then
						state = loopName
						animation:getAnimation():play(state,-1,1)
					elseif state == endName then
						self._ccnode:removeChild(animation)
					end
				end
			end)
			--飞起来
			local action = cc.MoveBy:create(0.5,cc.p(200,0))
			local call = cc.CallFunc:create(function()
				state = endName 
				if state ~= "end" then
					animation:getAnimation():play(state,-1,0)
				else
					self._ccnode:removeChild(animation)
				end
			end)
			animation:runAction(cc.Sequence:create({action, call}))
			self._ccnode:addChild(animation)
			self.flyer = animation
		end
	end)

	-- 播放背景特效
	local effect = self.armatureCfg[lastActionId].effect
	if effect ~= '' then
		self:addArmatureFrame(string.format("res/armature/effect/%s/%s.ExportJson",string.lower(effect),effect))
		local arm = ccs.Armature:create(effect)
		arm:setAnchorPoint(0.5,0.5)
		arm:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
		self._ccnode:addChild(arm)
		arm:getAnimation():play(effect,-1,0)
		arm:getAnimation():setMovementEventCallFunc(function (armatureBack,movementType,movementID)
				if movementType == ccs.MovementEventType.complete then
					self:addTimer(function() 
						self._ccnode:removeChild(arm)
					end,0.0001,1)
				end
			end)
	elseif self.armatureCfg[lastActionId].noHitEvent ~= {} then
		self.heroBody:getAnimation():setFrameEventCallFunc(function(bone,evt,originFrameIndex,currentFrameIndex)
				if evt == "noHit" then
					local e = self.armatureCfg[lastActionId].noHitEvent[originFrameIndex]
					if e and e.bgEffect then
						local bgEffect = e.bgEffect
						if bgEffect then
							self:addArmatureFrame(string.format("res/armature/effect/%s/%s.ExportJson",string.lower(bgEffect),bgEffect))
							local arm = ccs.Armature:create(bgEffect)
							arm:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
							self._ccnode:addChild(arm)
							arm:getAnimation():play(bgEffect,-1,0)
							arm:getAnimation():setMovementEventCallFunc(function (armatureBack,movementType,movementID)
									if movementType == ccs.MovementEventType.complete then
										self:addTimer(function() 
											self._ccnode:removeChild(arm)
										end,0.0001,1)
									end
								end)
						end
					end
				end
			end)
	end
	if groupId == SkillDefine.TYPE_COMBO then
		self:displayEffect("res/armature/effect/ComboEffect.ExportJson",'ComboEffect',"Combo",x,y+100)
	end
end	

