-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Yuri", _M)
Helper.initHeroConfig(require("src/config/hero/YuriConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "yuri/Shengli.mp3",
	["start"] = "yuri/Kaichang.mp3",
	["dead"] = "yuri/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "yuri/Shouji1.mp3"
	else
		return "yuri/Shouji2.mp3"
	end
end

function getBgEffectDirect(self)
	return self:getDirection()
end

local boneRes = {

	["另补上3"] = {
		"yuri_0031.png",
		"yuri_0019.png",
		"yuri_0016.png",
		"yuri_0020.png",
		"yuri_0015.png",
		"yuri_0002.png",
		"yuri_0034.png",
	},

	["另补上2"] = {
		"yuri_0045.png",
		"yuri_0002.png",
		"yuri_0034.png",
		"yuri_0019.png",
		"yuri_0010.png",
		"yuri_0015.png",
		"yuri_0020.png",
		"yuri_0017.png",
		"yuri_0008.png",
		"yuri_0032.png",
		"yuri_0013.png",
		"yuri_0031.png",
	},

	["另补上1"] = {
		"yuri_0015.png",
		"yuri_0019.png",
		"yuri_0036.png",
		"yuri_0002.png",
		"yuri_0034.png",
		"yuri_0014.png",
		"yuri_0009.png",
		"yuri_0043.png",
		"yuri_0049.png",
		"yuri_0033.png",
		"yuri_0013.png",
		"yuri_0020.png",
	},

	["左手下"] = {
		"yuri_0032.png",
		"yuri_0020.png",
		"yuri_0002.png",
		"yuri_0019.png",
		"yuri_0034.png",
		"yuri_0013.png",
	},

	["左手上"] = {
		"yuri_0033.png",
		"yuri_0001.png",
		"yuri_0029.png",
		"yuri_0019.png",
		"yuri_0036.png",
	},

	["头"] = {
		"yuri_0031.png",
		"yuri_0000.png",
		"yuri_0016.png",
		"yuri_0051.png",
		"yuri_0052.png",
	},

	["另补中"] = {
		"yuri_0045.png",
		"yuri_0036.png",
	},

	["另补中1"] = {
		"yuri_0015.png",
	},

	["另补中2"] = {
	},

	["右手下"] = {
		"yuri_0034.png",
		"yuri_0013.png",
		"yuri_0020.png",
		"yuri_0002.png",
		"yuri_0033.png",
		"yuri_0032.png",
	},

	["另补中3"] = {
		"yuri_0036.png",
		"yuri_0019.png",
		"yuri_0033.png",
		"yuri_0045.png",
	},

	["身_侧"] = {
		"yuri_0035.png",
		"yuri_0021.png",
		"yuri_0003.png",
	},

	["另补中4"] = {
		"yuri_0032.png",
		"yuri_0034.png",
		"yuri_0039.png",
		"yuri_0033.png",
		"yuri_0019.png",
		"yuri_0036.png",
		"yuri_0002.png",
	},

	["右手上"] = {
		"yuri_0036.png",
		"yuri_0019.png",
		"yuri_0033.png",
		"yuri_0016.png",
	},

	["左裤摆"] = {
		"yuri_0037.png",
		"yuri_0022.png",
		"yuri_0004.png",
	},

	["右裤摆"] = {
		"yuri_0038.png",
		"yuri_0005.png",
		"yuri_0022.png",
	},

	["另补中5"] = {
		"yuri_0034.png",
		"yuri_0036.png",
		"yuri_0033.png",
		"yuri_0002.png",
		"yuri_0030.png",
		"yuri_0031.png",
	},

	["辫子上"] = {
		"yuri_0045.png",
		"yuri_0017.png",
		"yuri_0033.png",
	},

	["辫子下"] = {
		"yuri_0015.png",
	},

	["另补中6"] = {
		"yuri_0034.png",
		"yuri_0035.png",
		"yuri_0039.png",
		"yuri_0010.png",
		"yuri_0002.png",
		"yuri_0013.png",
		"yuri_0023.png",
		"yuri_0021.png",
		"yuri_0030.png",
		"yuri_0032.png",
		"yuri_0020.png",
		"yuri_0033.png",
		"yuri_0016.png",
		"yuri_0036.png",
	},

	["另补中7"] = {
		"yuri_0019.png",
		"yuri_0042.png",
		"yuri_0024.png",
		"yuri_0036.png",
		"yuri_0012.png",
		"yuri_0021.png",
		"yuri_0009.png",
		"yuri_0030.png",
		"yuri_0022.png",
		"yuri_0015.png",
		"yuri_0034.png",
		"yuri_0033.png",
		"yuri_0049.png",
		"yuri_0013.png",
		"yuri_0032.png",
	},

	["另补中8"] = {
		"yuri_0042.png",
		"yuri_0048.png",
		"yuri_0011.png",
		"yuri_0034.png",
		"yuri_0013.png",
		"yuri_0022.png",
		"yuri_0020.png",
		"yuri_0032.png",
		"yuri_0039.png",
		"yuri_0006.png",
		"yuri_0024.png",
		"yuri_0040.png",
	},

	["鞋子左"] = {
		"yuri_0041.png",
		"yuri_0010.png",
		"yuri_0043.png",
		"yuri_0049.png",
		"yuri_0025.png",
		"yuri_0020.png",
		"yuri_0008.png",
	},

	["左脚上"] = {
		"yuri_0039.png",
		"yuri_0040.png",
		"yuri_0006.png",
		"yuri_0023.png",
		"yuri_0043.png",
		"yuri_0041.png",
		"yuri_0027.png",
		"yuri_0049.png",
		"yuri_0007.png",
	},

	["左脚下"] = {
		"yuri_0042.png",
		"yuri_0009.png",
		"yuri_0026.png",
		"yuri_0011.png",
		"yuri_0028.png",
	},

	["另补中9"] = {
		"yuri_0048.png",
		"yuri_0034.png",
	},

	["鞋子右"] = {
		"yuri_0043.png",
		"yuri_0010.png",
		"yuri_0041.png",
		"yuri_0049.png",
		"yuri_0008.png",
		"yuri_0025.png",
		"yuri_0027.png",
		"yuri_0047.png",
	},

	["另补中10"] = {
		"yuri_0038.png",
	},

	["右脚上"] = {
		"yuri_0040.png",
		"yuri_0023.png",
		"yuri_0006.png",
		"yuri_0024.png",
		"yuri_0007.png",
		"yuri_0039.png",
	},

	["右脚下"] = {
		"yuri_0044.png",
		"yuri_0028.png",
		"yuri_0026.png",
		"yuri_0011.png",
	},

	["另补下"] = {
		"yuri_0037.png",
		"yuri_0048.png",
		"yuri_0034.png",
		"yuri_0015.png",
		"yuri_0036.png",
		"yuri_0009.png",
		"yuri_0043.png",
		"yuri_0038.png",
		"yuri_0039.png",
	},

	["另补下1"] = {
		"yuri_0048.png",
		"yuri_0002.png",
		"yuri_0020.png",
		"yuri_0033.png",
		"yuri_0043.png",
		"yuri_0032.png",
		"yuri_0009.png",
		"yuri_0041.png",
		"yuri_0006.png",
		"yuri_0025.png",
		"yuri_0038.png",
		"yuri_0019.png",
		"yuri_0036.png",
	},

	["另补下2"] = {
		"yuri_0048.png",
		"yuri_0034.png",
		"yuri_0029.png",
		"yuri_0019.png",
		"yuri_0044.png",
		"yuri_0015.png",
		"yuri_0011.png",
		"yuri_0036.png",
		"yuri_0039.png",
	},

	["另补下3"] = {
		"yuri_0048.png",
		"yuri_0034.png",
		"yuri_0036.png",
		"yuri_0025.png",
		"yuri_0019.png",
		"yuri_0020.png",
		"yuri_0045.png",
		"yuri_0030.png",
		"yuri_0011.png",
	},

}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/yuri/YuriSkin.plist")
	Hero.setSkin(self,boneRes)
end
local hitSpecialCallback = {
	[3614] = Hero.hitOnce
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function getFlyName(self)
	return nil,"霸王翔吼拳_飞行循环","霸王翔吼拳_击中的表现"
end

