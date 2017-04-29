-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Chris2", _M)
Helper.initHeroConfig(require("src/config/hero/Chris2Config").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "chris/Shengli.mp3",
	["start"] = "chris/Kaichang.mp3",
	["dead"] = "chris/Siwang.mp3",
}

function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "chris/Shouji1.mp3"
	else
		return "chris/Shouji2.mp3"
	end
end

local hitSpecialCallback = {
	[4310] = Hero.hitOnce,
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

local boneRes = {

	["左手上22"] = {
		"chris2_ 107.png",
		"chris2_ 91.png",
		"chris2_ 125.png",
		"chris2_ 114.png",
	},

	["左手下22"] = {
		"chris2_ 126.png",
		"chris2_ 114.png",
		"chris2_ 125.png",
		"chris2_ 130.png",
		"chris2_ 115.png",
		"chris2_ 120.png",
		"chris2_ 112.png",
		"chris2_ 129.png",
	},

	["右手下"] = {
		"chris2_ 114.png",
		"chris2_ 126.png",
		"chris2_ 125.png",
		"chris2_ 130.png",
		"chris2_ 112.png",
		"chris2_ 113.png",
		"chris2_ 115.png",
		"chris2_ 129.png",
	},

	["右手上"] = {
		"chris2_ 112.png",
		"chris2_ 129.png",
		"chris2_ 125.png",
		"chris2_ 124.png",
		"chris2_ 123.png",
	},

	["头"] = {
		"chris2_ 104.png",
		"chris2_ 103.png",
		"chris2_ 107.png",
		"chris2_ 105.png",
		"chris2_ 106.png",
	},

	["身体"] = {
		"chris2_ 101.png",
		"chris2_ 102.png",
		"chris2_ 100.png",
	},

	["左脚"] = {
		"chris2_ 127.png",
		"chris2_ 110.png",
		"chris2_ 109.png",
		"chris2_ 111.png",
		"chris2_ 93.png",
		"chris2_ 128.png",
		"chris2_ 91.png",
		"chris2_ 92.png",
		"chris2_ 132.png",
	},

	["左脚下"] = {
		"chris2_ 135.png",
		"chris2_ 134.png",
		"chris2_ 120.png",
		"chris2_ 93.png",
		"chris2_ 109.png",
	},

	["左脚上"] = {
		"chris2_ 132.png",
		"chris2_ 133.png",
		"chris2_ 131.png",
		"chris2_ 118.png",
		"chris2_ 117.png",
		"chris2_ 135.png",
		"chris2_ 134.png",
	},

	["右脚"] = {
		"chris2_ 109.png",
		"chris2_ 110.png",
		"chris2_ 111.png",
		"chris2_ 91.png",
		"chris2_ 108.png",
		"chris2_ 117.png",
		"chris2_ 93.png",
		"chris2_ 127.png",
		"chris2_ 92.png",
		"chris2_ 116.png",
	},

	["右脚下"] = {
		"chris2_ 120.png",
		"chris2_ 121.png",
		"chris2_ 119.png",
		"chris2_ 135.png",
		"chris2_ 109.png",
		"chris2_ 93.png",
		"chris2_ 127.png",
		"chris2_ 111.png",
	},

	["右脚上"] = {
		"chris2_ 117.png",
		"chris2_ 118.png",
		"chris2_ 116.png",
		"chris2_ 132.png",
		"chris2_ 120.png",
		"chris2_ 119.png",
	},

	["左手上"] = {
		"chris2_ 129.png",
		"chris2_ 112.png",
		"chris2_ 115.png",
		"chris2_ 123.png",
	},

	["左手下"] = {
		"chris2_ 130.png",
		"chris2_ 114.png",
		"chris2_ 113.png",
		"chris2_ 126.png",
		"chris2_ 115.png",
		"chris2_ 112.png",
		"chris2_ 125.png",
	},

	["另补1"] = {
		"chris2_ 114.png",
		"chris2_ 95.png",
		"chris2_ 94.png",
		"chris2_ 98.png",
		"chris2_ 99.png",
	},

	["cy_yuohua1"] = {
		"chris2_youhuatx_18.png",
		"chris2_youhuatx_14.png",
		"chris2_youhuatx_13.png",
		"chris2_youhuatx_12.png",
		"chris2_youhuatx_11.png",
		"chris2_youhuatx_10.png",
		"chris2_youhuatx_9.png",
		"chris2_youhuatx_8.png",
		"chris2_youhuatx_7.png",
		"chris2_youhuatx_6.png",
		"chris2_youhuatx_19.png",
		"chris2_youhuatx_17.png",
	},

	["cy_yuohua2"] = {
		"chris2_youhuatx_18.png",
		"chris2_youhuatx_14.png",
		"chris2_youhuatx_13.png",
		"chris2_youhuatx_12.png",
		"chris2_youhuatx_11.png",
		"chris2_youhuatx_10.png",
		"chris2_youhuatx_9.png",
		"chris2_youhuatx_8.png",
		"chris2_youhuatx_7.png",
		"chris2_youhuatx_6.png",
	},

}



function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/chris2/Chris2Skin.plist")
	Hero.setSkin(self,boneRes)
end

function getFlyName(self)
	return nil,"佛大地之禁果特效_飞行物",nil
end
