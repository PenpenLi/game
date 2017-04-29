-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Athena", _M)
Helper.initHeroConfig(require("src/config/hero/AthenaConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "mai/Shouji1.mp3"
	else
		return "mai/Shouji2.mp3"
	end
end

local boneRes = {
}

function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	--self:addSpriteFrames("res/armature/ryo/RyoSkin.plist")
	--Hero.setSkin(self,boneRes)
end
local hitSpecialCallback = {
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function getFlyName(self)
	--return nil,"霸王翔吼拳-波飞行","霸王翔吼拳-波击中"
end

--[[
function startAssist(self)
end

function updateAssist(self)
end
--]]

--[[
function removeSelf(self)
	self.animation:runAction(cc.Sequence:create(
		cc.FadeOut:create(0.2),
		cc.CallFunc:create(function() 
			self:removeFromParent()
		end)
	))
end

function startAssist(self)
	self.assistX = self:getPositionX()
	self:play("forward_run")
	self:addEventListener(Event.PlayEnd,function(self,event) 
		if event.stateName == "succeed" then
			self.master:getInfo():addHp(50)
			--Stage.currentScene.ui:displayHpEffect(self.master)
			self.animation:runAction(cc.Sequence:create(
				cc.FadeOut:create(0.2),
				cc.CallFunc:create(function() 
					self:removeFromParent()
				end)
			))
		end
	end)
end

function updateAssist(self)
	local x = self:getPositionX()
	if math.abs(x - self.assistX) > Stage.winSize.width / 2 and not self.firstUpdate then
		self:play("succeed",true)
		self.firstUpdate = true
	end
end
--]]

--[[
function startAssist(self)
	--跳跃重脚
	local skill = self:getAssistSkill()
	self:setCurSkill(skill)
	self:play("jump",true)
	self:pause()
	self.animation:getAnimation():pause(10)

	local lx = Stage.currentScene:getLeft() 
	local rx = Stage.currentScene:getRight()
	local tx = (lx + rx) / 2 + self:getDirection() * 150
	self:setPosition(self.master:getDirection() == Hero.DIRECTION_RIGHT and lx or rx,Stage.winSize.height)
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
			self:play(1528,true)
		elseif event.stateName == 1528 then
			self.animation:runAction(cc.Sequence:create(
				cc.DelayTime:create(0.3),
				cc.FadeOut:create(0.2),
				cc.CallFunc:create(function() 
					self:removeFromParent()
				end)
			))

			--redo 加血
			skill:use(self.enemy)
		end
	end)
end
--]]
