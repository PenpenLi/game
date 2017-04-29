module(..., package.seeall)

local Hero = require("src/modules/hero/Hero")
local FightHeroDefine = require("src/modules/fight/Define")
local HeroDefine = require("src/modules/hero/HeroDefine")

local SkillLogic = require("src/modules/skill/SkillLogic")
local SkillConfig = require("src/config/SkillConfig").Config
local SkillGroupConfig = require("src/config/SkillGroupConfig").Config
local SkillExpConfig = require("src/config/SkillExpConfig").Config
local Define = require("src/modules/skill/SkillDefine")


function new(heroName,node,callback)
	local o = {
		alive = true,
		heroName = heroName,
		parent = node, 
		heroBody = nil,	
		fly = nil,	--飞行物
		callback = callback,
	}
	setmetatable(o,{__index = _M})
	o:init()
end

function init(self)
	local heroName = self.heroName
	self.armatureCfg = require(string.format("src/config/hero/%sConfig",heroName)).Config
	local bigBody = string.format("res/armature/%s/%s.ExportJson",string.lower(heroName),heroName)
	local loader = AsyncLoader.new()
	loader:addEventListener(loader.Event.Load,function(s,event) 
		if self.alive and event.etype == AsyncLoader.Event.Finish then
			heroBody = self:loadHeroBody(bigBody,self.heroName)
			self.callback(self)
		else
			self.loader:removeAllArmatureFileInfo()
		end
	end)
	loader:addArmatureFileInfo(bigBody)
	loader:start()
	self.loader = loader
end

function loadHeroBody(self,resUrl,name)
	self.parent:addArmatureFrame(resUrl)
	self.armatureFile = resUrl
	self.heroBody = ccs.Armature:create(name)
	self.heroBodyX = self.heroBody:getContentSize().width
	--self.heroBodyY = self.heroBody:getPositionY()
	self.heroBodyY = 20 
	self.heroBody:setAnchorPoint(0,0.5)
	--self.heroBody:setPositionX(self.heroBodyX)
	self.heroBody:setPosition(self.heroBodyX,self.heroBodyY)
	self.heroBody:setScaleX(-1)
	self.heroBody:setVisible(false)
	--self.parent._ccnode:addChild(self.heroBody,1)
	return self.heroBody
end

function show(self,groupId)
	if not self.heroBody then return end
	print("show======>",groupId)
	self.heroBody:setVisible(true)
	self.heroBody:setPositionX(self.posX)
	self.heroBody:setPositionY(self.posY)
	--action
	local groupConf = SkillGroupConfig[groupId]
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
			elseif actionId == "break_heat" then
				animations[#animations+1] = "暴气"
			end
		end
	end
	animations[#animations+1] = "待机"
	--play
	local actionIndex = 1
	local shadowBone = self.heroBody:getBone("影子")
    self.heroBody:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
		if movementType == ccs.MovementEventType.complete then
			actionIndex = actionIndex + 1
			local boundBox = shadowBone:getDisplayManager():getBoundingBox()
			local x = self.heroBody:getPositionX()
			local offsetX = boundBox.x + boundBox.width / 2
			if #animations == 1 then
				self.heroBody:setPositionX(self.posX)
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
	Common.printR(animations)
	--技能摇起来
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
			animation:setPosition(cc.p(rect.x,self.posY))
			animation:getAnimation():play(state,-1,0)
    		animation:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
				if movementType == ccs.MovementEventType.complete then
					if state == startName then
						state = loopName
						animation:getAnimation():play(state,-1,1)
					elseif state == endName then
						self.parent._ccnode:removeChild(animation)
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
					self.parent._ccnode:removeChild(animation)
					self.flyer = nil
				end
			end)
			animation:runAction(cc.Sequence:create({action, call}))
			self.parent._ccnode:addChild(animation)
			self.flyer = animation
		end
	end)
end

function changeToRealRect(self,boundBox)
	local x,y = self.heroBody:getPosition()
	local minX = x + boundBox.x * (-1)
	local maxX = x + (boundBox.x + boundBox.width) * (-1)
	if minX > maxX then
		minX,maxX = maxX,minX
	end
	local minY = y + boundBox.y
	local maxY = y + boundBox.y + boundBox.height
	return cc.rect(minX,minY,maxX-minX,maxY-minY)
end


function getContentSize(self)
	return self.heroBody:getContentSize()
end

function setVisible(self, value)
	if self.fly then self.fly:setVisible(value) end
	if self.heroBody then print("===setVisible==",value) self.heroBody:setVisible(value) end
end

function remove(self)
	self.alive = false
	if self.heroBody then
		print("remove heroBody========>")
		self.parent._ccnode:removeChild(self.heroBody)
		self.heroBody = nil
	end
	self.loader:removeAllArmatureFileInfo()
end

function setPosition(self,x,y)
	self.posX = x
	self.posY = y
	self.heroBody:setPosition(x,y)
end

function setScale(self,val)
	self.heroBody:setScale(val)
end

function setScaleX(self,val)
	self.heroBody:setScaleY(val)
end

function setScaleY(self,val)
	self.heroBody:setScaleY(val)
end






