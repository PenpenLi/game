-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Ralf", _M)
Helper.initHeroConfig(require("src/config/hero/RalfConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "ralf/Shengli.mp3",
	["start"] = "ralf/Kaichang.mp3",
	["dead"] = "ralf/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "ralf/Shouji1.mp3"
	else
		return "ralf/Shouji2.mp3"
	end
end

function getBgEffectDirect(self)
	return self:getDirection()
end

function setTarget(self)
	self:addArmatureFrame("res/armature/ralf/RalfTarget.ExportJson",0)
end

local boneRes = {
	
	["另补上3"] = {
		"ralf_017.png",
		"ralf_037.png",
		"ralf_040.png",
		"ralf_0130001.png",
		"ralf_109.png",
		"ralf_0130007.png",
		"ralf_0130011.png",
		"ralf_0130009.png",
		"ralf_0130003.png",
		"ralf_0130013.png",
		"ralf_036.png",
		"ralf_004.png",
		"ralf_053.png",
	},

	["另补上2"] = {
		"ralf_003.png",
		"ralf_036.png",
		"ralf_027.png",
		"ralf_004.png",
		"ralf_034.png",
		"ralf_040.png",
		"ralf_033.png",
		"ralf_041.png",
		"ralf_0130001.png",
		"ralf_0130003.png",
		"ralf_109.png",
		"ralf_0130007.png",
		"ralf_0130011.png",
		"ralf_0130009.png",
		"ralf_0130013.png",
		"ralf_017.png",
		"ralf_018.png",
		"ralf_046.png",
		"ralf_014.png",
		"ralf_037.png",
	},

	["另补上1"] = {
		"ralf_036.png",
		"ralf_004.png",
		"ralf_037.png",
		"ralf_027.png",
		"ralf_018.png",
		"ralf_033.png",
		"ralf_034.png",
		"ralf_040.png",
		"ralf_017.png",
		"ralf_028.png",
		"ralf_041.png",
		"ralf_tx020.png",
		"ralf_016.png",
	},

	["另补上"] = {
		"ralf_028.png",
		"ralf_036.png",
		"ralf_004.png",
		"ralf_027.png",
		"ralf_037.png",
		"ralf_tx018.png",
		"ralf_tx022.png",
		"ralf_tx023.png",
		"ralf_tx017.png",
		"ralf_tx020.png",
		"ralf_018.png",
		"ralf_033.png",
	},

	["头_侧"] = {
		"ralf_038.png",
		"ralf_001.png",
		"ralf_025.png",
		"ralf_056.png",
		"ralf_055.png",
	},

	["带子结"] = {
		"ralf_006.png",
		"ralf_020.png",
	},

	["带子左下"] = {
		"ralf_007.png",
		"ralf_051.png",
	},

	["带子左上"] = {
		"ralf_050.png",
		"ralf_010.png",
	},

	["带子右上"] = {
		"ralf_051.png",
		"ralf_007.png",
	},

	["带子右下"] = {
		"ralf_010.png",
		"ralf_050.png",
	},

	["左手下"] = {
		"ralf_004.png",
		"ralf_028.png",
		"ralf_018.png",
		"ralf_027.png",
		"ralf_036.png",
		"ralf_034.png",
	},

	["左手上"] = {
		"ralf_037.png",
		"ralf_003.png",
		"ralf_040.png",
		"ralf_026.png",
		"ralf_017.png",
		"ralf_033.png",
		"ralf_036.png",
	},

	["另补中2"] = {
		"ralf_002.png",
		"ralf_015.png",
		"ralf_036.png",
		"ralf_025.png",
		"ralf_031.png",
		"ralf_053.png",
		"ralf_035.png",
		"ralf_038.png",
		"ralf_016.png",
		"ralf_027.png",
		"ralf_043.png",
		"ralf_047.png",
		"ralf_046.png",
		"ralf_040.png",
		"ralf_003.png",
		"ralf_029.png",
	},

	["另补中1"] = {
		"ralf_016.png",
		"ralf_047.png",
		"ralf_044.png",
		"ralf_036.png",
		"ralf_027.png",
		"ralf_004.png",
		"ralf_037.png",
		"ralf_041.png",
		"ralf_003.png",
		"ralf_013.png",
		"ralf_053.png",
		"ralf_019.png",
		"ralf_002.png",
		"ralf_040.png",
		"ralf_045.png",
	},

	["另补中"] = {
		"ralf_045.png",
		"ralf_004.png",
		"ralf_018.png",
		"ralf_040.png",
		"ralf_042.png",
		"ralf_037.png",
		"ralf_036.png",
		"ralf_026.png",
		"ralf_033.png",
		"ralf_003.png",
		"ralf_029.png",
		"ralf_019.png",
		"ralf_035.png",
		"ralf_053.png",
		"ralf_047.png",
	},

	["身_侧"] = {
		"ralf_039.png",
		"ralf_028.png",
		"ralf_005.png",
	},

	["另补中4"] = {
		"ralf_025.png",
		"ralf_033.png",
		"ralf_040.png",
	},

	["另补中3"] = {
		"ralf_053.png",
		"ralf_014.png",
		"ralf_025.png",
	},

	["右手下"] = {
		"ralf_041.png",
		"ralf_018.png",
		"ralf_034.png",
		"ralf_004.png",
		"ralf_027.png",
		"ralf_036.png",
		"ralf_037.png",
		"ralf_040.png",
		"ralf_003.png",
	},

	["右手上"] = {
		"ralf_040.png",
		"ralf_017.png",
		"ralf_037.png",
		"ralf_003.png",
	},

	["鞋子左"] = {
		"ralf_043.png",
		"ralf_015.png",
		"ralf_012.png",
		"ralf_046.png",
		"ralf_035.png",
		"ralf_053.png",
		"ralf_032.png",
		"ralf_030.png",
	},

	["左脚上"] = {
		"ralf_042.png",
		"ralf_029.png",
		"ralf_045.png",
		"ralf_011.png",
		"ralf_014.png",
		"ralf_031.png",
	},

	["左脚下"] = {
		"ralf_044.png",
		"ralf_013.png",
		"ralf_016.png",
		"ralf_047.png",
		"ralf_030.png",
	},

	["鞋子右"] = {
		"ralf_046.png",
		"ralf_012.png",
		"ralf_035.png",
		"ralf_053.png",
		"ralf_043.png",
		"ralf_015.png",
		"ralf_030.png",
		"ralf_002.png",
		"ralf_032.png",
		"ralf_019.png",
	},

	["右脚上"] = {
		"ralf_045.png",
		"ralf_031.png",
		"ralf_011.png",
		"ralf_042.png",
		"ralf_014.png",
		"ralf_029.png",
	},

	["右脚下"] = {
		"ralf_047.png",
		"ralf_016.png",
		"ralf_044.png",
		"ralf_013.png",
		"ralf_030.png",
		"ralf_046.png",
		"ralf_045.png",
		"ralf_032.png",
	},

	["另补下"] = {
		"ralf_018.png",
		"ralf_012.png",
		"ralf_019.png",
		"ralf_025.png",
		"ralf_042.png",
		"ralf_056.png",
		"ralf_035.png",
		"ralf_031.png",
		"ralf_045.png",
		"ralf_037.png",
		"ralf_017.png",
		"ralf_003.png",
		"ralf_038.png",
		"ralf_039.png",
		"ralf_043.png",
		"ralf_030.png",
		"ralf_041.png",
		"ralf_034.png",
		"ralf_026.png",
		"ralf_029.png",
		"ralf_033.png",
		"ralf_014.png",
		"ralf_040.png",
		"ralf_046.png",
		"ralf_004.png",
	},

	["另补下1"] = {
		"ralf_040.png",
		"ralf_031.png",
		"ralf_015.png",
		"ralf_045.png",
		"ralf_014.png",
		"ralf_012.png",
		"ralf_005.png",
		"ralf_041.png",
		"ralf_025.png",
		"ralf_038.png",
		"ralf_019.png",
		"ralf_034.png",
		"ralf_033.png",
		"ralf_003.png",
		"ralf_029.png",
		"ralf_004.png",
		"ralf_018.png",
		"ralf_046.png",
		"ralf_027.png",
		"ralf_053.png",
		"ralf_035.png",
	},

	["另补下2"] = {
		"ralf_004.png",
		"ralf_016.png",
		"ralf_047.png",
		"ralf_044.png",
		"ralf_037.png",
		"ralf_034.png",
		"ralf_027.png",
		"ralf_041.png",
		"ralf_030.png",
		"ralf_032.png",
		"ralf_036.png",
		"ralf_025.png",
		"ralf_003.png",
		"ralf_018.png",
		"ralf_033.png",
		"ralf_051.png",
		"ralf_tx022.png",
		"ralf_017.png",
		"ralf_040.png",
		"ralf_046.png",
		"ralf_031.png",
		"ralf_014.png",
		"ralf_005.png",
	},

	["另补下3"] = {
		"ralf_025.png",
		"ralf_012.png",
		"ralf_015.png",
		"ralf_053.png",
		"ralf_030.png",
		"ralf_018.png",
		"ralf_007.png",
		"ralf_004.png",
		"ralf_034.png",
		"ralf_019.png",
		"ralf_038.png",
		"ralf_003.png",
		"ralf_027.png",
		"ralf_035.png",
		"ralf_050.png",
		"ralf_006.png",
		"ralf_041.png",
		"ralf_013.png",
		"ralf_016.png",
	},

	["另补下4"] = {
		"ralf_037.png",
		"ralf_030.png",
		"ralf_032.png",
		"ralf_050.png",
		"ralf_014.png",
		"ralf_045.png",
		"ralf_025.png",
		"ralf_019.png",
		"ralf_044.png",
		"ralf_034.png",
		"ralf_003.png",
		"ralf_004.png",
		"ralf_033.png",
		"ralf_007.png",
		"ralf_010.png",
		"ralf_027.png",
		"ralf_005.png",
		"ralf_041.png",
	},

	["另补下5"] = {
		"ralf_018.png",
		"ralf_041.png",
		"ralf_004.png",
		"ralf_036.png",
		"ralf_027.png",
		"ralf_010.png",
		"ralf_016.png",
		"ralf_047.png",
		"ralf_034.png",
		"ralf_019.png",
		"ralf_030.png",
		"ralf_025.png",
		"ralf_035.png",
		"ralf_033.png",
		"ralf_050.png",
	},
}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/ralf/RalfSkin.plist")
	Hero.setSkin(self,boneRes)
end
local hitSpecialCallback = {
	[3916] = Hero.hitOnce,
	[3910] = Hero.hitOnce,
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end
