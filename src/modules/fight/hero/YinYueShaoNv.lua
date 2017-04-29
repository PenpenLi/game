-- YinYueShaoNv, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("YinYueShaoNv", _M)
Helper.initHeroConfig(require("src/config/hero/YinYueShaoNvConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "mary/Shengli.mp3",
	["start"] = "mary/Kaichang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "mary/Shouji1.mp3"
	else
		return "mary/Shouji2.mp3"
	end
end

function init(self)
	Hero.init(self)
	self:addEventListener(Event.PlayEnd,onPlayEnd,self)
end

function setTarget(self)
	self:addArmatureFrame("res/armature/yinyueshaonv/YinYueShaoNvTarget.ExportJson",0)
end

function onPlayEnd(self,event)
	if not event.isFinish then
		return
	end
	if event.stateName == 5509 then		--_1
		self:play("rush",true)
		self.mary_rushId = 5525		--_2
		self.canRun = true
	elseif event.stateName == 5510 then
		self:play("rush",true)
		self.mary_rushId = 5526		--_2
		self.canRun = true
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 5509 or arg.stateName == 5510 then
		self.mary_rushPlayId = arg.playId
		self:onPlayEnd(arg)
		return
	elseif arg.stateName == 5525 or arg.stateName == 5526 then
		arg.playId = self.mary_rushPlayId
		self.mary_rushPlayId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end

local hitSpecialCallback = {
	[5513] = Hero.hitOnce
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function update(self,event)
	local delay = event.delay
	if self.curState.name == "rush" then
		if self:getEnemyDis() < 140 then
			--test
			--self:setCurSkill(self:getPowerSkill())
			self:play(self.mary_rushId,true,true)
			self.mary_rushId = nil
			self.canRun = nil
		end
	end
end


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	--self:addSpriteFrames("res/armature/mary/YinYueShaoNvSkin.plist")
	--Hero.setSkin(self,boneRes)
end
