-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Kensou", _M)
Helper.initHeroConfig(require("src/config/hero/KensouConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "kensou/Shengli.mp3",
	["start"] = "kensou/Kaichang.mp3",
	["dead"] = "kensou/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "kensou/Shouji1.mp3"
	else
		return "kensou/Shouji2.mp3"
	end
end
local hitSpecialCallback = {
	[2515] = Hero.hitOnce,
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function getFlyName(self)
	return nil,"超球弹_飞行循环特效","超球弹_击中特效"
end

local boneRes = {

	["另补上7"] = {
		"kensou_ 127.png",
		"kensou_ 132.png",
		"kensou_ 129.png",
		"kensou_ 100.png",
		"kensou_ 103.png",
		"kensou_ 128.png",
		"kensou_ 130.png",
	},

	["另补上6"] = {
		"kensou_ 133.png",
		"kensou_ 127.png",
		"kensou_ 129.png",
		"kensou_ 130.png",
		"kensou_ 132.png",
		"kensou_ 107.png",
	},

	["另补上5"] = {
		"kensou_ 116.png",
		"kensou_ 133.png",
		"kensou_ 129.png",
		"kensou_ 130.png",
		"kensou_ 119.png",
		"kensou_ 97.png",
		"kensou_ 123.png",
		"kensou_ 113.png",
		"kensou_ 132.png",
	},

	["另补上4"] = {
		"kensou_ 129.png",
		"kensou_ 97.png",
		"kensou_ 119.png",
		"kensou_ 127.png",
		"kensou_ 108.png",
		"kensou_ 106.png",
		"kensou_ 131.png",
		"kensou_ 109.png",
		"kensou_ 121.png",
		"kensou_ 125.png",
		"kensou_ 132.png",
	},

	["另补上3"] = {
		"kensou_ 129.png",
		"kensou_ 111.png",
		"kensou_ 109.png",
		"kensou_ 108.png",
		"kensou_ 97.png",
		"kensou_ 130.png",
		"kensou_ 133.png",
		"kensou_ 127.png",
		"kensou_ 132.png",
		"kensou_ 100.png",
		"kensou_ 103.png",
		"kensou_ 128.png",
		"kensou_ 123.png",
		"kensou_ 106.png",
		"kensou_ 125.png",
		"kensou_ 119.png",
		"kensou_ 118.png",
	},

	["另补上2"] = {
		"kensou_ 109.png",
		"kensou_ 118.png",
		"kensou_ 108.png",
		"kensou_ 97.png",
		"kensou_ 119.png",
		"kensou_ 112.png",
		"kensou_ 121.png",
		"kensou_ 132.png",
		"kensou_ 133.png",
		"kensou_ 130.png",
		"kensou_ 127.png",
		"kensou_ 128.png",
		"kensou_ 113.png",
		"kensou_ 103.png",
		"kensou_ 106.png",
		"kensou_ 100.png",
		"kensou_ 122.png",
		"kensou_ 125.png",
		"kensou_ 131.png",
	},

	["另补上1"] = {
		"kensou_ 122.png",
		"kensou_ 123.png",
		"kensou_ 106.png",
		"kensou_ 108.png",
		"kensou_ 118.png",
		"kensou_ 109.png",
		"kensou_ 97.png",
		"kensou_ 121.png",
		"kensou_ 119.png",
		"kensou_ 127.png",
		"kensou_ 129.png",
		"kensou_ 116.png",
		"kensou_ 133.png",
		"kensou_ 125.png",
		"kensou_ 130.png",
		"kensou_ 131.png",
		"kensou_ 128.png",
	},

	["另补上"] = {
		"kensou_ 119.png",
		"kensou_ 99.png",
		"kensou_ 109.png",
		"kensou_ 118.png",
		"kensou_ 121.png",
		"kensou_ 113.png",
		"kensou_ 136.png",
		"kensou_ 97.png",
		"kensou_ 125.png",
		"kensou_ 127.png",
		"kensou_ 108.png",
		"kensou_ 102.png",
		"kensou_ 130.png",
		"kensou_ 128.png",
		"kensou_ 132.png",
		"kensou_ 122.png",
		"kensou_ 123.png",
	},

	["头_侧"] = {
		"kensou_ 120.png",
		"kensou_ 135.png",
		"kensou_ 107.png",
		"kensou_ 136.png",
		"kensou_ 95.png",
		"kensou_ 138.png",
	},

	["左手下_侧"] = {
		"kensou_ 109.png",
		"kensou_ 121.png",
		"kensou_ 132.png",
		"kensou_ 119.png",
		"kensou_ 106.png",
		"kensou_ 97.png",
		"kensou_ 96.png",
	},

	["右手下_侧"] = {
		"kensou_ 123.png",
		"kensou_ 97.png",
		"kensou_ 119.png",
		"kensou_ 118.png",
		"kensou_ 106.png",
		"kensou_ 127.png",
		"kensou_ 109.png",
		"kensou_ 129.png",
	},

	["右手上_侧"] = {
		"kensou_ 122.png",
		"kensou_ 121.png",
		"kensou_ 108.png",
		"kensou_ 96.png",
		"kensou_ 102.png",
		"kensou_ 123.png",
	},

	["另补层中"] = {
		"kensou_ 98.png",
		"kensou_ 122.png",
		"kensou_ 130.png",
		"kensou_ 108.png",
		"kensou_ 131.png",
	},

	["身_侧"] = {
		"kensou_ 124.png",
		"kensou_ 110.png",
		"kensou_ 98.png",
		"kensou_ 129.png",
	},

	["另补中1"] = {
		"kensou_ 129.png",
		"kensou_ 118.png",
		"kensou_ 126.png",
		"kensou_ 109.png",
		"kensou_ 121.png",
		"kensou_ 103.png",
		"kensou_ 125.png",
		"kensou_ 120.png",
		"kensou_ 122.png",
		"kensou_ 108.png",
		"kensou_ 97.png",
		"kensou_ 116.png",
		"kensou_ 107.png",
		"kensou_ 127.png",
		"kensou_ 106.png",
		"kensou_ 132.png",
		"kensou_ 130.png",
		"kensou_ 119.png",
	},

	["另补中2"] = {
		"kensou_ 99.png",
		"kensou_ 117.png",
		"kensou_ 112.png",
		"kensou_ 127.png",
		"kensou_ 121.png",
		"kensou_ 120.png",
		"kensou_ 107.png",
		"kensou_ 130.png",
		"kensou_ 129.png",
		"kensou_ 111.png",
		"kensou_ 97.png",
		"kensou_ 125.png",
		"kensou_ 118.png",
		"kensou_ 108.png",
		"kensou_ 103.png",
		"kensou_ 132.png",
		"kensou_ 122.png",
		"kensou_ 113.png",
		"kensou_ 106.png",
		"kensou_ 128.png",
		"kensou_ 116.png",
		"kensou_ 126.png",
	},

	["另补中3"] = {
		"kensou_ 125.png",
		"kensou_ 102.png",
		"kensou_ 130.png",
		"kensou_ 127.png",
		"kensou_ 129.png",
		"kensou_ 133.png",
		"kensou_ 116.png",
		"kensou_ 132.png",
		"kensou_ 111.png",
		"kensou_ 122.png",
		"kensou_ 100.png",
		"kensou_ 103.png",
		"kensou_ 128.png",
	},

	["左手上_侧"] = {
		"kensou_ 121.png",
		"kensou_ 117.png",
		"kensou_ 105.png",
		"kensou_ 125.png",
		"kensou_ 122.png",
		"kensou_ 108.png",
		"kensou_ 111.png",
		"kensou_ 96.png",
	},

	["左脚上_侧"] = {
		"kensou_ 128.png",
		"kensou_ 99.png",
		"kensou_ 113.png",
		"kensou_ 125.png",
		"kensou_ 116.png",
		"kensou_ 102.png",
	},

	["左脚下_侧"] = {
		"kensou_ 130.png",
		"kensou_ 125.png",
		"kensou_ 112.png",
		"kensou_ 128.png",
		"kensou_ 115.png",
		"kensou_ 127.png",
		"kensou_ 116.png",
		"kensou_ 99.png",
	},

	["右脚上_侧"] = {
		"kensou_ 102.png",
		"kensou_ 99.png",
		"kensou_ 116.png",
		"kensou_ 125.png",
		"kensou_ 128.png",
		"kensou_ 113.png",
	},

	["右脚下_侧"] = {
		"kensou_ 104.png",
		"kensou_ 101.png",
		"kensou_ 127.png",
		"kensou_ 115.png",
		"kensou_ 118.png",
		"kensou_ 133.png",
	},

	["另补中4"] = {
		"kensou_ 121.png",
		"kensou_ 108.png",
		"kensou_ 118.png",
		"kensou_ 127.png",
		"kensou_ 129.png",
	},

	["鞋子右_侧"] = {
		"kensou_ 126.png",
		"kensou_ 133.png",
		"kensou_ 100.png",
		"kensou_ 129.png",
		"kensou_ 132.png",
		"kensou_ 111.png",
		"kensou_ 103.png",
	},

	["鞋子左_侧"] = {
		"kensou_ 129.png",
		"kensou_ 103.png",
		"kensou_ 133.png",
		"kensou_ 100.png",
		"kensou_ 132.png",
		"kensou_ 114.png",
		"kensou_ 111.png",
		"kensou_ 126.png",
		"kensou_ 116.png",
		"kensou_ 113.png",
	},

	["另补下"] = {
		"kensou_ 101.png",
		"kensou_ 125.png",
		"kensou_ 116.png",
		"kensou_ 118.png",
		"kensou_ 108.png",
		"kensou_ 133.png",
		"kensou_ 120.png",
		"kensou_ 107.png",
		"kensou_ 130.png",
		"kensou_ 127.png",
		"kensou_ 119.png",
		"kensou_ 123.png",
		"kensou_ 106.png",
		"kensou_ 96.png",
		"kensou_ 122.png",
		"kensou_ 128.png",
	},

	["另补下1"] = {
		"kensou_ 102.png",
		"kensou_ 118.png",
		"kensou_ 100.png",
		"kensou_ 122.png",
		"kensou_ 127.png",
		"kensou_ 105.png",
		"kensou_ 108.png",
		"kensou_ 119.png",
		"kensou_ 116.png",
		"kensou_ 130.png",
		"kensou_ 125.png",
		"kensou_ 97.png",
	},

	["另补下2"] = {
		"kensou_ 130.png",
		"kensou_ 101.png",
		"kensou_ 104.png",
		"kensou_ 102.png",
		"kensou_ 127.png",
		"kensou_ 115.png",
		"kensou_ 112.png",
		"kensou_ 123.png",
		"kensou_ 109.png",
		"kensou_ 133.png",
		"kensou_ 129.png",
		"kensou_ 106.png",
		"kensou_ 119.png",
		"kensou_ 122.png",
		"kensou_ 118.png",
		"kensou_ 126.png",
		"kensou_ 100.png",
		"kensou_ 108.png",
		"kensou_ 97.png",
	},

	["另补下3"] = {
		"kensou_ 127.png",
		"kensou_ 101.png",
		"kensou_ 104.png",
		"kensou_ 133.png",
		"kensou_ 115.png",
		"kensou_ 130.png",
		"kensou_ 129.png",
		"kensou_ 98.png",
		"kensou_ 107.png",
		"kensou_ 97.png",
		"kensou_ 118.png",
		"kensou_ 123.png",
		"kensou_ 122.png",
		"kensou_ 119.png",
		"kensou_ 113.png",
		"kensou_ 106.png",
		"kensou_ 116.png",
	},

	["另补下4"] = {
		"kensou_ 133.png",
		"kensou_ 121.png",
		"kensou_ 105.png",
		"kensou_ 112.png",
		"kensou_ 109.png",
		"kensou_ 118.png",
		"kensou_ 127.png",
		"kensou_ 115.png",
		"kensou_ 97.png",
		"kensou_ 119.png",
		"kensou_ 130.png",
		"kensou_ 122.png",
	},

	["另补下5"] = {
		"kensou_ 106.png",
		"kensou_ 97.png",
		"kensou_ 119.png",
		"kensou_ 109.png",
		"kensou_ 118.png",
	},

}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/kensou/KensouSkin.plist")
	Hero.setSkin(self,boneRes)
end
