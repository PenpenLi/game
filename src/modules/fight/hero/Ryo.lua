-- ryo, 板琦良 特写状态

module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Ryo", _M)
local config = require("src/config/hero/RyoConfig").Config
Helper.initHeroConfig(config)
config[1311].hitEvent.cnt = config[1311].hitEvent.cnt + 6
--Common.printR(require("src/config/hero/RyoConfig").Config[1311].hitEvent)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "ryo/Shengli.mp3",
	--["start"] = "ryo/Shengli.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "ryo/Shouji1.mp3"
	else
		return "ryo/Shouji2.mp3"
	end
end

boneRes = {
	["前手下"] = {
		"ryo_ 104.png",
		"ryo_ 94.png",
		"ryo_ 85.png",
		"ryo_ 91.png",
		"ryo_ 159.png",
		"ryo_ 114.png",
	},

	["前手上"] = {
		"ryo_ 103.png",
		"ryo_ 93.png",
		"ryo_ 113.png",
		"ryo_ 84.png",
	},

	["(+手前）"] = {
		"ryo_ 91.png",
		"ryo_ 117.png",
		"ryo_ 105.png",
		"ryo_ 83.png",
		"ryo_ 92.png",
		"ryo_ 118.png",
		"ryo_ 104.png",
	},

	["头"] = {
		"ryo_ 105.png",
		"ryo_ 83.png",
		"ryo_ 121.png",
		"ryo_ 92.png",
		"ryo_ 120.png",
		"ryo_ 119.png",
		"ryo_ 106.png",
		"ryo_ 117.png",
	},

	["带子"] = {
		"ryo_ 106.png",
		"ryo_ 107.png",
		"ryo_ 95.png",
		"ryo_ 86.png",
	},

	["衣服"] = {
		"ryo_ 107.png",
		"ryo_ 95.png",
		"ryo_ 86.png",
		"ryo_ 108.png",
		"ryo_ 96.png",
	},

	["前脚上"] = {
		"ryo_ 108.png",
		"ryo_ 110.png",
		"ryo_ 96.png",
		"ryo_ 109.png",
		"ryo_ 97.png",
	},

	["前脚中"] = {
		"ryo_ 109.png",
		"ryo_ 111.png",
		"ryo_ 97.png",
		"ryo_ 110.png",
		"ryo_ 99.png",
		"ryo_ 87.png",
	},

	["后脚上"] = {
		"ryo_ 110.png",
		"ryo_ 99.png",
		"ryo_ 111.png",
		"ryo_ 100.png",
		"ryo_ 88.png",
	},

	["后脚中"] = {
		"ryo_ 111.png",
		"ryo_ 100.png",
		"ryo_ 112.png",
		"ryo_ 118.png",
		"ryo_ 116.png",
		"ryo_ 117.png",
		"ryo_ 89.png",
	},

	["后脚下"] = {
		"ryo_ 112.png",
		"ryo_ 98.png",
		"ryo_ 118.png",
		"ryo_ 89.png",
		"ryo_ 114.png",
		"ryo_ 91.png",
		"ryo_ 102.png",
		"ryo_ 159.png",
		"ryo_ 85.png",
	},

	["后手下"] = {
		"ryo_ 114.png",
		"ryo_ 91.png",
		"ryo_ 112.png",
		"ryo_ 113.png",
		"ryo_ 101.png",
		"ryo_ 90.png",
		"ryo_ 102.png",
	},

	["后手上"] = {
		"ryo_ 113.png",
		"ryo_ 115.png",
		"ryo_ 116.png",
		"ryo_ 117.png",
		"ryo_ 118.png",
		"ryo_ 112.png",
		"ryo_ 98.png",
	},

	["前脚下"] = {
		"ryo_ 115.png",
		"ryo_ 112.png",
		"ryo_ 116.png",
		"ryo_ 118.png",
		"ryo_ 98.png",
		"ryo_ 117.png",
		"ryo_ 89.png",
		"ryo_ 92.png",
		"ryo_ 105.png",
	},

	["头前"] = {
		"ryo_ 105.png",
		"ryo_ 92.png",
	},

	["另补下1"] = {
		"ryo_ 91.png",
		"ryo_ 106.png",
	},

	["另补下2"] = {
		"ryo_ 113.png",
	},
}

function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/ryo/RyoSkin.plist")
	Hero.setSkin(self,boneRes)
end

function hit_1313(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.hiting then
		local x = self:getPositionX()
		self.enemy:setPositionX(x - 100 * self:getDirection())
	end
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end

local hitSpecialCallback = {
	[1313] = hit_1313,		--前摔
	--[1315] = Hero.hitOnce,		--霸王翔吼拳
	--[[
	[1301] = Hero.hitStop,			--提前收招
	[1302] = Hero.hitStop,			--提前收招
	[1303] = Hero.hitStop,			--提前收招
	[1304] = Hero.hitStop,			--提前收招
	--]]
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

--使用大招时黑屏
function pow(self,bone,evt,originFrameIndex,currentFrameIndex)
	local boundBox = bone:getDisplayManager():getBoundingBox()
	local rect = self:changeToRealRect(boundBox)
	Stage.currentScene:displayEffect("必杀",rect.x,rect.y,self:getDirection(),true)
	Stage.currentScene:displayEffect("大招",rect.x,rect.y,self:getDirection())
	SoundManager.playEffect("common/Bishashanping.mp3")
end

function rush(self,bone,evt,originFrameIndex,currentFrameIndex)
	local x,y = self.enemy:getPosition()
	local mx,my = self:getPosition()
	local moveBy = cc.MoveBy:create(math.abs(x-mx)/1500,cc.p(x - mx + self:getDirection() * 60,40))
	self:pause()
	local callback = cc.CallFunc:create(function() 
		self:resume()
		self:setPositionY(Define.heroBottom)
		self.animation:getAnimation():gotoAndPlay(23)
		if self.enemy.curState.name == "forward" or self.enemy.curState.name == "forward_run" then
			self.enemy:play("stand",true)
		end
	end)
    local seq = cc.Sequence:create(moveBy, callback)
	self:runAction(seq)
end

function getFlyName(self)
	return nil,"霸王翔吼拳-波飞行","霸王翔吼拳-波击中"
end

function replay(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.replayId ~= self.playId then
		self.replayId = self.playId 
		self.animation:getAnimation():gotoAndPlay(25)
	end
end

--[[
function startAssist(self)
	local skill = self:getAssistSkill()
	self:setCurSkill(skill)
	self:play(1308,true,true)
	self.animation:getAnimation():gotoAndPause(5)

	local ex = self.enemy:getPositionX()
	self:setPosition(ex - self.enemy:getDirection() * 450,Stage.winSize.height)
	self:runAction(
		cc.Sequence:create(
			cc.MoveTo:create(0.5,cc.p(ex - self.enemy:getDirection() * 100,Define.heroBottom)),
			cc.CallFunc:create(function() 
				self:setPositionX(self.enemy:getPositionX() - self.enemy:getDirection() * 100)
				self:resume()
				Stage.currentScene:shockHash(4)
			end)
		)
	)

	self:addEventListener(Event.PlayEnd,function(self,event) 
		if event.stateName == 1308 then
			self.animation:runAction(cc.Sequence:create(
				cc.FadeOut:create(0.2),
				cc.CallFunc:create(function() 
					self:removeFromParent()
				end)
			))
			--self:play(1318,true,true)
		elseif event.stateName == 1318 then
		end
	end)
end

function updateAssist(self)
end
--]]
