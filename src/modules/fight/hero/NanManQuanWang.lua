-- 小怪NanManQuanWang,特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("NanManQuanWang", _M)
Helper.initHeroConfig(require("src/config/hero/NanManQuanWangConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
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

function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	--self:addSpriteFrames("res/armature/joe/NanManQuanWangSkin.plist")
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
