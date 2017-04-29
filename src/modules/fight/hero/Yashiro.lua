-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Yashiro", _M)
Helper.initHeroConfig(require("src/config/hero/YashiroConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "yashiro/Shengli.mp3",
	["dead"] = "yashiro/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "yashiro/Shouji1.mp3"
	else
		return "yashiro/Shouji2.mp3"
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
	["另补上2"] = {
		"yashiro_0024.png",
		"yashiro_0023.png",
		"yashiro_0032.png",
		"yashiro_0025.png",
		"yashiro_0040.png",
		"yashiro_0002.png",
		"yashiro_0013.png",
		"yashiro_0001.png",
		"yashiro_tx03.png",
		"yashiro_0014.png",
		"yashiro_0031.png",
		"yashiro_0027.png",
		"yashiro_tx46_1.png",
	},

	["另补上1"] = {
		"yashiro_0024.png",
		"yashiro_0002.png",
		"yashiro_0014.png",
		"yashiro_0011.png",
		"yashiro_0023.png",
		"yashiro_0037.png",
		"yashiro_0018.png",
		"yashiro_0027.png",
		"yashiro_0016.png",
		"yashiro_0025.png",
		"yashiro_0028.png",
		"yashiro_0040.png",
		"yashiro_0013.png",
	},

	["另补上"] = {
		"yashiro_0027.png",
		"yashiro_0028.png",
		"yashiro_0034.png",
		"yashiro_0025.png",
		"yashiro_0011.png",
		"yashiro_0013.png",
		"yashiro_0001.png",
		"yashiro_0024.png",
		"yashiro_0014.png",
		"yashiro_0022.png",
		"yashiro_0040.png",
		"yashiro_0018.png",
		"yashiro_0031.png",
		"yashiro_0002.png",
		"yashiro_0023.png",
	},

	["左手下"] = {
		"yashiro_0024.png",
		"yashiro_0013.png",
		"yashiro_0011.png",
		"yashiro_tx02.png",
		"yashiro_0014.png",
		"yashiro_0023.png",
		"yashiro_0002.png",
		"yashiro_0025.png",
		"yashiro_0028.png",
	},

	["头"] = {
		"yashiro_0026.png",
		"yashiro_0042.png",
		"yashiro_0012.png",
		"yashiro_0000.png",
		"yashiro_0043.png",
	},

	["右手下"] = {
		"yashiro_0025.png",
		"yashiro_0024.png",
		"yashiro_0011.png",
		"yashiro_0002.png",
		"yashiro_0023.png",
		"yashiro_0014.png",
		"yashiro_0028.png",
		"yashiro_0027.png",
	},

	["右手上"] = {
		"yashiro_0028.png",
		"yashiro_0027.png",
		"yashiro_0001.png",
		"yashiro_0013.png",
		"yashiro_0025.png",
		"yashiro_0024.png",
	},

	["另补中3"] = {
		"yashiro_0028.png",
		"yashiro_0016.png",
		"yashiro_0027.png",
		"yashiro_0023.png",
		"yashiro_0025.png",
		"yashiro_0002.png",
	},

	["身"] = {
		"yashiro_0029.png",
		"yashiro_0003.png",
		"yashiro_0015.png",
		"yashiro_0014.png",
	},

	["另补中2"] = {
		"yashiro_0030.png",
		"yashiro_0034.png",
		"yashiro_0002.png",
		"yashiro_0023.png",
		"yashiro_0028.png",
		"yashiro_0008.png",
		"yashiro_0004.png",
		"yashiro_0013.png",
		"yashiro_0040.png",
		"yashiro_0016.png",
		"yashiro_0031.png",
		"yashiro_0012.png",
		"yashiro_0032.png",
		"yashiro_0017.png",
		"yashiro_0027.png",
		"yashiro_0020.png",
		"yashiro_0006.png",
	},

	["另补中1"] = {
		"yashiro_0023.png",
		"yashiro_0001.png",
		"yashiro_0030.png",
		"yashiro_0028.png",
		"yashiro_0008.png",
		"yashiro_0032.png",
		"yashiro_0034.png",
		"yashiro_0016.png",
		"yashiro_0003.png",
		"yashiro_0011.png",
		"yashiro_0012.png",
		"yashiro_0014.png",
		"yashiro_0004.png",
		"yashiro_0031.png",
		"yashiro_0036.png",
		"yashiro_0017.png",
	},

	["另补中"] = {
		"yashiro_0028.png",
		"yashiro_0017.png",
		"yashiro_0023.png",
		"yashiro_0011.png",
		"yashiro_0038.png",
		"yashiro_0040.png",
		"yashiro_0025.png",
		"yashiro_0039.png",
		"yashiro_0035.png",
		"yashiro_0022.png",
		"yashiro_0030.png",
		"yashiro_0010.png",
		"yashiro_0013.png",
		"yashiro_0031.png",
		"yashiro_0027.png",
		"yashiro_0004.png",
		"yashiro_0032.png",
		"yashiro_0034.png",
		"yashiro_0018.png",
		"yashiro_0024.png",
		"yashiro_0012.png",
	},

	["左手上"] = {
		"yashiro_0027.png",
		"yashiro_0018.png",
		"yashiro_0030.png",
		"yashiro_0032.png",
		"yashiro_0023.png",
		"yashiro_0022.png",
		"yashiro_0028.png",
	},

	["右脚上"] = {
		"yashiro_0030.png",
		"yashiro_0004.png",
		"yashiro_0005.png",
		"yashiro_0031.png",
		"yashiro_0017.png",
		"yashiro_0016.png",
	},

	["右脚下"] = {
		"yashiro_0032.png",
		"yashiro_0034.png",
		"yashiro_0018.png",
		"yashiro_0008.png",
		"yashiro_0006.png",
		"yashiro_0020.png",
	},

	["鞋子右"] = {
		"yashiro_0033.png",
		"yashiro_0038.png",
		"yashiro_0035.png",
		"yashiro_0007.png",
		"yashiro_0039.png",
		"yashiro_0009.png",
		"yashiro_0019.png",
		"yashiro_0021.png",
		"yashiro_0040.png",
		"yashiro_0036.png",
	},

	["左脚上"] = {
		"yashiro_0031.png",
		"yashiro_0032.png",
		"yashiro_0030.png",
		"yashiro_0023.png",
		"yashiro_0016.png",
		"yashiro_0004.png",
		"yashiro_0017.png",
		"yashiro_0034.png",
		"yashiro_0014.png",
		"yashiro_0005.png",
	},

	["左脚下"] = {
		"yashiro_0034.png",
		"yashiro_0030.png",
		"yashiro_0032.png",
		"yashiro_0006.png",
		"yashiro_0018.png",
		"yashiro_0009.png",
		"yashiro_0016.png",
		"yashiro_0002.png",
		"yashiro_0023.png",
		"yashiro_0008.png",
	},

	["鞋子左"] = {
		"yashiro_0035.png",
		"yashiro_0038.png",
		"yashiro_0007.png",
		"yashiro_0009.png",
		"yashiro_0032.png",
		"yashiro_0018.png",
		"yashiro_0033.png",
		"yashiro_0039.png",
		"yashiro_0036.png",
		"yashiro_0021.png",
		"yashiro_0016.png",
		"yashiro_0019.png",
	},

	["另补下"] = {
		"yashiro_0032.png",
		"yashiro_0028.png",
		"yashiro_0007.png",
		"yashiro_0039.png",
		"yashiro_0030.png",
		"yashiro_0003.png",
		"yashiro_0022.png",
		"yashiro_0010.png",
		"yashiro_0038.png",
		"yashiro_0004.png",
		"yashiro_0025.png",
		"yashiro_0024.png",
		"yashiro_0023.png",
		"yashiro_0014.png",
		"yashiro_0018.png",
		"yashiro_0002.png",
		"yashiro_0016.png",
		"yashiro_0012.png",
		"yashiro_0027.png",
		"yashiro_0005.png",
	},

	["另补下1"] = {
		"yashiro_0007.png",
		"yashiro_0028.png",
		"yashiro_0011.png",
		"yashiro_0023.png",
		"yashiro_0027.png",
		"yashiro_0034.png",
		"yashiro_0013.png",
		"yashiro_0025.png",
		"yashiro_0010.png",
		"yashiro_0022.png",
		"yashiro_0018.png",
		"yashiro_0002.png",
		"yashiro_0016.png",
		"yashiro_0024.png",
		"yashiro_0014.png",
		"yashiro_0032.png",
	},

	["另补下2"] = {
		"yashiro_0023.png",
		"yashiro_0010.png",
		"yashiro_0022.png",
		"yashiro_0024.png",
		"yashiro_0002.png",
		"yashiro_0035.png",
		"yashiro_0014.png",
		"yashiro_0028.png",
		"yashiro_0011.png",
		"yashiro_0007.png",
		"yashiro_0016.png",
	},


}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/yashiro/YashiroSkin.plist")
	Hero.setSkin(self,boneRes)
end
