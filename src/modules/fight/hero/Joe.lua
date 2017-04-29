-- Joe,特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Joe", _M)
Helper.initHeroConfig(require("src/config/hero/JoeConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "joe/Shengli.mp3",
	["start"] = "joe/Kaichang.mp3",
	["dead"] = "joe/Siwang.mp3",
}

function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "joe/Shouji1.mp3"
	else
		return "joe/Shouji2.mp3"
	end
end

local boneRes = {
	["带子结2"] = {
		"joe_ 140.png",
		"joe_ 182.png",
	},

	["带子左下2"] = {
		"joe_ 144.png",
		"joe_ 179.png",
	},

	["带子左上2"] = {
		"joe_ 143.png",
		"joe_ 152.png",
		"joe_ 181.png",
	},

	["带子右下2"] = {
		"joe_ 142.png",
		"joe_ 147.png",
		"joe_ 167.png",
		"joe_ 182.png",
	},

	["左脚上2"] = {
		"joe_ 174.png",
		"joe_ 171.png",
		"joe_ 141.png",
		"joe_ 183.png",
		"joe_ 181.png",
		"joe_ 154.png",
	},

	["左手下"] = {
		"joe_ 182.png",
		"joe_ 169.png",
		"joe_ 183.png",
		"joe_ 171.png",
		"joe_ 181.png",
	},

	["左手上"] = {
		"joe_ 179.png",
		"joe_ 177.png",
		"joe_ 180.png",
	},

	["头"] = {
		"joe_ 150.png",
		"joe_ 151.png",
		"joe_ 149.png",
		"joe_ 152.png",
		"joe_ 145.png",
		"joe_ 154.png",
	},

	["身"] = {
		"joe_ 147.png",
		"joe_ 146.png",
		"joe_ 174.png",
		"joe_ 148.png",
	},

	["右手下"] = {
		"joe_ 171.png",
		"joe_ 158.png",
		"joe_ 183.png",
		"joe_ 172.png",
	},

	["右手上"] = {
		"joe_ 169.png",
		"joe_ 167.png",
		"joe_ 170.png",
	},

	["鞋子左"] = {
		"joe_ 161.png",
		"joe_ 158.png",
		"joe_ 153.png",
		"joe_ 159.png",
		"joe_ 177.png",
		"joe_ 164.png",
		"joe_ 155.png",
		"joe_ 176.png",
		"joe_ 156.png",
		"joe_ 162.png",
	},

	["左脚下"] = {
		"joe_ 177.png",
		"joe_ 176.png",
		"joe_ 154.png",
		"joe_ 178.png",
	},

	["左脚上"] = {
		"joe_ 174.png",
		"joe_ 173.png",
		"joe_ 175.png",
	},

	["鞋子右"] = {
		"joe_ 158.png",
		"joe_ 155.png",
		"joe_ 156.png",
		"joe_ 157.png",
		"joe_ 159.png",
		"joe_ 160.png",
		"joe_ 167.png",
		"joe_ 161.png",
		"joe_ 153.png",
		"joe_ 162.png",
	},

	["右脚下"] = {
		"joe_ 167.png",
		"joe_ 166.png",
		"joe_ 154.png",
		"joe_ 168.png",
	},

	["右脚上"] = {
		"joe_ 164.png",
		"joe_ 163.png",
		"joe_ 165.png",
	},

	["身2"] = {
		"joe_ 147.png",
		"joe_ 182.png",
		"joe_ 171.png",
	},

	["带子结"] = {
		"joe_ 140.png",
	},

	["带子左下"] = {
		"joe_ 144.png",
	},

	["带子左上"] = {
		"joe_ 143.png",
	},

	["带子右下"] = {
		"joe_ 142.png",
	},

	["带子右上"] = {
		"joe_ 141.png",
	},

}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/joe/JoeSkin.plist")
	Hero.setSkin(self,boneRes)
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
