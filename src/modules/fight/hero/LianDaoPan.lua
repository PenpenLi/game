-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("LianDaoPan", _M)
Helper.initHeroConfig(require("src/config/hero/LianDaoPanConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "chang/Shengli.mp3",
	["start"] = "chang/Kaichang.mp3",
	["dead"] = "chang/Siwang.mp3",
	["forward_run"] = "chang/Jiaobu.mp3",
	["back_run"] = "chang/Jiaobu.mp3",
}
function getSoundTable(self)
	return soundTable
end


function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "chang/Shouji1.mp3"
	else
		return "chang/Shouji2.mp3"
	end
end

function init(self)
	Hero.init(self)
	self:addEventListener(Event.PlayEnd,onPlayEnd,self)

end

function setTarget(self)
	self:addArmatureFrame("res/armature/liandaopan/LianDaoPanTarget.ExportJson",0)
end

function onPlayEnd(self,event)
	if not event.isFinish then
		return
	end
	if event.stateName == 5418 then		--_1
		self:play("rush",true)
		self.chang_rushId = 5419 --_2
		self.canRun = true
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 5418 then
		self.chang_rushPlayId = arg.playId
		self:onPlayEnd(arg)
		return
	elseif arg.stateName == 5419 then
		arg.playId = self.chang_rushPlayId
		self.chang_rushPlayId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end

local boneRes = {
}

function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	--self:addSpriteFrames("res/armature/liandaopan/LianDaoPanSkin.plist")
	--Hero.setSkin(self,boneRes)
end
local hitSpecialCallback = {
	[5409] = Hero.hitOnce,		--
	[5411] = Hero.hitOnce,		--
	["assist"] = Hero.hitOnce,		--
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
		if self:getEnemyDis() < 150 then
			--self:setCurSkill(self:getPowerSkill())
			self:play(self.chang_rushId,true,true)
			self.chang_rushId = nil
			self.canRun = nil
		end
	end
end

function startAssist(self)
	Hero.startAssistAtk(self)
end
