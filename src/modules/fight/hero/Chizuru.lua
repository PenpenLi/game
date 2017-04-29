-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Chizuru", _M)
Helper.initHeroConfig(require("src/config/hero/ChizuruConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	--["succeed"] = "chizuru/Shengli.mp3",
	["start"] = "chizuru/Kaichang.mp3",
	["dead"] = "chizuru/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "chizuru/Shouji1.mp3"
	else
		return "chizuru/Shouji2.mp3"
	end
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

local boneRes = {
	["脚22"] = {
		"chizuru_ 124.png",
	},

	["另补1"] = {
		"chizuru_ 121.png",
	},

	["另补2"] = {
		"chizuru_ 144.png",
		"chizuru_ 131.png",
		"chizuru_ 137.png",
		"chizuru_ 136.png",
		"chizuru_ 134.png",
		"chizuru_ 117.png",
		"chizuru_ 142.png",
		"chizuru_ 143.png",
	},

	["右手上"] = {
		"chizuru_ 134.png",
		"chizuru_ 141.png",
		"chizuru_ 142.png",
		"chizuru_ 136.png",
		"chizuru_ 144.png",
	},

	["右手下"] = {
		"chizuru_ 136.png",
		"chizuru_ 143.png",
		"chizuru_ 144.png",
		"chizuru_ 137.png",
		"chizuru_ 134.png",
		"chizuru_ 141.png",
		"chizuru_ 117.png",
	},

	["头"] = {
		"chizuru_ 117.png",
		"chizuru_ 116.png",
		"chizuru_ 118.png",
		"chizuru_ 119.png",
		"chizuru_ 123.png",
	},

	["头发后22"] = {
		"chizuru_ 120.png",
		"chizuru_ 130.png",
		"chizuru_ 113.png",
	},

	["身体"] = {
		"chizuru_ 114.png",
		"chizuru_ 115.png",
		"chizuru_ 113.png",
		"chizuru_ 133.png",
	},

	["右裙摆"] = {
		"chizuru_ 132.png",
		"chizuru_ 133.png",
		"chizuru_ 129.png",
		"chizuru_ 145.png",
	},

	["左裙摆"] = {
		"chizuru_ 140.png",
		"chizuru_ 145.png",
		"chizuru_ 138.png",
	},

	["左脚上"] = {
		"chizuru_ 138.png",
		"chizuru_ 130.png",
		"chizuru_ 125.png",
	},

	["左鞋"] = {
		"chizuru_ 127.png",
		"chizuru_ 125.png",
		"chizuru_ 91.png",
		"chizuru_ 128.png",
		"chizuru_ 92.png",
		"chizuru_ 124.png",
		"chizuru_ 90.png",
		"chizuru_ 126.png",
		"chizuru_ 139.png",
	},

	["左脚下"] = {
		"chizuru_ 139.png",
		"chizuru_ 131.png",
		"chizuru_ 130.png",
	},

	["右脚上"] = {
		"chizuru_ 130.png",
		"chizuru_ 138.png",
		"chizuru_ 125.png",
	},

	["右鞋"] = {
		"chizuru_ 124.png",
		"chizuru_ 125.png",
		"chizuru_ 128.png",
		"chizuru_ 92.png",
		"chizuru_ 91.png",
		"chizuru_ 90.png",
		"chizuru_ 131.png",
		"chizuru_ 126.png",
		"chizuru_ 127.png",
	},

	["右脚下"] = {
		"chizuru_ 131.png",
		"chizuru_ 139.png",
		"chizuru_ 134.png",
	},

	["左手上"] = {
		"chizuru_ 141.png",
		"chizuru_ 134.png",
		"chizuru_ 142.png",
		"chizuru_ 135.png",
	},

	["左手下"] = {
		"chizuru_ 143.png",
		"chizuru_ 136.png",
		"chizuru_ 135.png",
		"chizuru_ 137.png",
		"chizuru_ 134.png",
		"chizuru_ 144.png",
	},

	["头发后"] = {
		"chizuru_ 121.png",
		"chizuru_ 122.png",
		"chizuru_ 80.png",
	},

}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/chizuru/ChizuruSkin.plist")
	Hero.setSkin(self,boneRes)
end
