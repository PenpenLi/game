-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Chin", _M)
Helper.initHeroConfig(require("src/config/hero/ChinConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "chin/Shengli.mp3",
	--["start"] = "chin/Kaichang.mp3",
	["dead"] = "chin/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "chin/Shouji1.mp3"
	else
		return "chin/Shouji2.mp3"
	end
end
function hit_3013(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.enemy.curState.lock ~= Define.AttackLock.defense then
		local boundBox = bone:getDisplayManager():getBoundingBox()
		local rect = self:changeToRealRect(boundBox)
		local isHit,hitX,hitY = self.enemy:isHit(rect)
		if isHit then
			self.enemy:setPositionY(Define.heroBottom)
			--self.enemy:setPosition(hitX - self.animation:getScaleX(),hitY - 60 + originFrameIndex * 10)
		end
	end
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end

local hitSpecialCallback = {
	--[3009] = Hero.hitOnce,
	[3011] = Hero.hitOnce,
	--[3025] = Hero.hitOnce,
	[3013] = hit_3013,
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

local boneRes = {
	
	["另补上4"] = {
		"chin_0045.png",
		"chin_0020.png",
		"chin_0053.png",
		"chin_0021.png",
		"chin_0036.png",
		"chin_0019.png",
		"chin_0055.png",
		"chin_0068.png",
		"chin_0069.png",
		"chin_0067.png",
		"chin_0071.png",
		"chin_0057.png",
		"chin_0070.png",
		"chin_0052.png",
	},

	["另补上3"] = {
		"chin_0053.png",
		"chin_0042.png",
		"chin_0010.png",
		"chin_0021.png",
		"chin_0051.png",
		"chin_0020.png",
		"chin_0052.png",
		"chin_0057.png",
		"chin_0007.png",
		"chin_0055.png",
		"chin_0018.png",
		"chin_0000.png",
		"chin_0061.png",
		"chin_0028.png",
		"chin_0023.png",
		"chin_0043.png",
		"chin_0046.png",
		"chin_0017.png",
	},

	["另补上2"] = {
		"chin_0007.png",
		"chin_0021.png",
		"chin_0042.png",
		"chin_0010.png",
		"chin_0020.png",
		"chin_0006.png",
		"chin_0057.png",
		"chin_0036.png",
		"chin_0026.png",
		"chin_0012.png",
		"chin_0052.png",
		"chin_0053.png",
		"chin_0025.png",
		"chin_0054.png",
		"chin_0055.png",
		"chin_0028.png",
		"chin_0060.png",
		"chin_0016.png",
		"chin_0046.png",
		"chin_0018.png",
		"chin_0049.png",
		"chin_0064.png",
		"chin_0030.png",
	},

	["另补上1"] = {
		"chin_0042.png",
		"chin_0060.png",
		"chin_0053.png",
		"chin_0045.png",
		"chin_0010.png",
		"chin_0020.png",
		"chin_0012.png",
		"chin_0025.png",
		"chin_0021.png",
		"chin_0007.png",
		"chin_0051.png",
		"chin_0043.png",
		"chin_0047.png",
		"chin_0055.png",
		"chin_0019.png",
		"chin_0026.png",
		"chin_0046.png",
		"chin_0067.png",
		"chin_0017.png",
		"chin_0057.png",
	},

	["另补上"] = {
		"chin_0007.png",
		"chin_0053.png",
		"chin_0012.png",
		"chin_0046.png",
		"chin_0006.png",
		"chin_0045.png",
		"chin_0021.png",
		"chin_0052.png",
		"chin_0042.png",
		"chin_0019.png",
		"chin_0020.png",
		"chin_0013.png",
		"chin_0011.png",
		"chin_0055.png",
		"chin_0025.png",
		"chin_0047.png",
		"chin_0015.png",
		"chin_0051.png",
		"chin_0017.png",
		"chin_0043.png",
		"chin_0049.png",
		"chin_0010.png",
	},

	["头"] = {
		"chin_0036.png",
		"chin_0062.png",
		"chin_0061.png",
		"chin_0018.png",
		"chin_0063.png",
		"chin_0000.png",
		"chin_0046.png",
		"chin_0010.png",
	},

	["左手下"] = {
		"chin_0042.png",
		"chin_0010.png",
		"chin_0007.png",
		"chin_0030.png",
		"chin_0021.png",
		"chin_0015.png",
		"chin_0051.png",
		"chin_0036.png",
		"chin_0062.png",
	},

	["右手下"] = {
		"chin_0051.png",
		"chin_0007.png",
		"chin_0021.png",
		"chin_0015.png",
		"chin_0030.png",
		"chin_0042.png",
	},

	["左手上"] = {
		"chin_0043.png",
		"chin_0020.png",
		"chin_0006.png",
		"chin_0029.png",
		"chin_0052.png",
		"chin_0016.png",
		"chin_0051.png",
	},

	["飘带"] = {
		"chin_0037.png",
		"chin_0043.png",
	},

	["飘带左1"] = {
		"chin_0002.png",
		"chin_0037.png",
	},

	["飘带左"] = {
		"chin_0039.png",
		"chin_0002.png",
	},

	["飘带右1"] = {
		"chin_0004.png",
		"chin_0039.png",
	},

	["飘带右"] = {
		"chin_0005.png",
		"chin_0004.png",
	},

	["另补中4"] = {
		"chin_0006.png",
		"chin_0013.png",
		"chin_0007.png",
		"chin_0051.png",
		"chin_0046.png",
		"chin_0049.png",
		"chin_0057.png",
		"chin_0020.png",
		"chin_0048.png",
		"chin_0045.png",
		"chin_0005.png",
	},

	["另补中3"] = {
		"chin_0052.png",
		"chin_0045.png",
		"chin_0053.png",
		"chin_0012.png",
		"chin_0020.png",
		"chin_0049.png",
	},

	["身"] = {
		"chin_0044.png",
		"chin_0009.png",
		"chin_0008.png",
		"chin_0022.png",
		"chin_0057.png",
		"chin_0048.png",
		"chin_0020.png",
	},

	["右手上"] = {
		"chin_0052.png",
		"chin_0060.png",
		"chin_0013.png",
		"chin_0012.png",
		"chin_0029.png",
		"chin_0020.png",
		"chin_0006.png",
		"chin_0008.png",
		"chin_0022.png",
		"chin_0044.png",
	},

	["另补中2"] = {
		"chin_0051.png",
		"chin_0053.png",
		"chin_0045.png",
		"chin_0052.png",
		"chin_0047.png",
		"chin_0061.png",
		"chin_0048.png",
		"chin_0020.png",
		"chin_0018.png",
		"chin_0058.png",
		"chin_0021.png",
		"chin_0030.png",
		"chin_0055.png",
		"chin_0059.png",
		"chin_0060.png",
		"chin_0007.png",
		"chin_0014.png",
		"chin_0046.png",
		"chin_0017.png",
		"chin_0015.png",
	},

	["另补中1"] = {
		"chin_0052.png",
		"chin_0010.png",
		"chin_0053.png",
		"chin_0046.png",
		"chin_0008.png",
		"chin_0022.png",
		"chin_0044.png",
		"chin_0060.png",
		"chin_0020.png",
		"chin_0051.png",
		"chin_0029.png",
		"chin_0012.png",
		"chin_0009.png",
		"chin_0043.png",
	},

	["另补中"] = {
		"chin_0012.png",
		"chin_0044.png",
		"chin_0047.png",
		"chin_0046.png",
		"chin_0023.png",
		"chin_0052.png",
		"chin_0010.png",
		"chin_0053.png",
		"chin_0060.png",
		"chin_0043.png",
		"chin_0059.png",
		"chin_0018.png",
		"chin_0045.png",
		"chin_0021.png",
	},

	["葫芦"] = {
		"chin_0053.png",
		"chin_0029.png",
		"chin_0055.png",
		"chin_0019.png",
		"chin_0046.png",
		"chin_0017.png",
	},

	["左脚上"] = {
		"chin_0045.png",
		"chin_0009.png",
		"chin_0048.png",
		"chin_0044.png",
		"chin_0025.png",
		"chin_0018.png",
		"chin_0014.png",
		"chin_0028.png",
		"chin_0053.png",
	},

	["左脚下"] = {
		"chin_0046.png",
		"chin_0012.png",
		"chin_0045.png",
		"chin_0010.png",
		"chin_0053.png",
		"chin_0023.png",
		"chin_0026.png",
		"chin_0049.png",
		"chin_0057.png",
	},

	["另补中5"] = {
		"chin_0006.png",
		"chin_0048.png",
		"chin_0018.png",
		"chin_0058.png",
		"chin_0046.png",
		"chin_0012.png",
	},

	["右脚上"] = {
		"chin_0048.png",
		"chin_0026.png",
		"chin_0014.png",
		"chin_0045.png",
		"chin_0010.png",
		"chin_0049.png",
		"chin_0028.png",
		"chin_0025.png",
		"chin_0009.png",
	},

	["右脚下"] = {
		"chin_0049.png",
		"chin_0010.png",
		"chin_0012.png",
		"chin_0048.png",
		"chin_0026.png",
		"chin_0025.png",
		"chin_0046.png",
		"chin_0023.png",
	},

	["鞋子右"] = {
		"chin_0050.png",
		"chin_0013.png",
		"chin_0059.png",
		"chin_0047.png",
		"chin_0058.png",
		"chin_0011.png",
		"chin_0024.png",
		"chin_0025.png",
		"chin_0048.png",
		"chin_0056.png",
		"chin_0027.png",
		"chin_0060.png",
		"chin_0049.png",
		"chin_0057.png",
	},

	["鞋子左"] = {
		"chin_0047.png",
		"chin_0011.png",
		"chin_0046.png",
		"chin_0013.png",
		"chin_0050.png",
		"chin_0058.png",
		"chin_0026.png",
		"chin_0049.png",
		"chin_0024.png",
		"chin_0059.png",
		"chin_0048.png",
		"chin_0025.png",
		"chin_0045.png",
		"chin_0056.png",
		"chin_0010.png",
	},

	["另补下"] = {
		"chin_0047.png",
		"chin_0059.png",
		"chin_0050.png",
		"chin_0007.png",
		"chin_0010.png",
		"chin_0052.png",
		"chin_0045.png",
		"chin_0051.png",
		"chin_0058.png",
		"chin_0024.png",
		"chin_0056.png",
		"chin_0014.png",
		"chin_0019.png",
		"chin_0054.png",
		"chin_0012.png",
		"chin_0046.png",
		"chin_0055.png",
		"chin_0017.png",
		"chin_0005.png",
		"chin_0048.png",
		"chin_0028.png",
		"chin_0030.png",
	},

	["另补下1"] = {
		"chin_0016.png",
		"chin_0013.png",
		"chin_0052.png",
		"chin_0048.png",
		"chin_0025.png",
		"chin_0045.png",
		"chin_0047.png",
		"chin_0009.png",
		"chin_0021.png",
		"chin_0012.png",
		"chin_0028.png",
		"chin_0046.png",
		"chin_0024.png",
		"chin_0058.png",
		"chin_0030.png",
		"chin_0039.png",
		"chin_0000.png",
		"chin_0018.png",
		"chin_0036.png",
		"chin_0010.png",
		"chin_0007.png",
		"chin_0051.png",
		"chin_0049.png",
		"chin_0026.png",
		"chin_shengzitx_11.png",
	},

	["另补下2"] = {
		"chin_0059.png",
		"chin_0013.png",
		"chin_0012.png",
		"chin_0046.png",
		"chin_0021.png",
		"chin_0010.png",
		"chin_0053.png",
		"chin_0052.png",
		"chin_0019.png",
		"chin_0051.png",
		"chin_0026.png",
		"chin_0047.png",
		"chin_0002.png",
		"chin_0030.png",
		"chin_0058.png",
		"chin_0017.png",
		"chin_0016.png",
		"chin_0024.png",
		"chin_0027.png",
	},

	["另补下3"] = {
		"chin_0024.png",
		"chin_0058.png",
		"chin_0047.png",
		"chin_0059.png",
		"chin_0030.png",
		"chin_0055.png",
		"chin_0053.png",
		"chin_0009.png",
		"chin_0052.png",
		"chin_0013.png",
		"chin_0019.png",
		"chin_0004.png",
		"chin_0043.png",
		"chin_0029.png",
		"chin_0000.png",
		"chin_0044.png",
		"chin_0005.png",
		"chin_0051.png",
		"chin_0048.png",
	},

	["另补下7"] = {
		"chin_0005.png",
		"chin_0008.png",
		"chin_0021.png",
		"chin_0007.png",
		"chin_0004.png",
		"chin_0016.png",
		"chin_0046.png",
		"chin_0061.png",
	},

	["另补下4"] = {
		"chin_0030.png",
		"chin_0044.png",
		"chin_0008.png",
		"chin_0051.png",
		"chin_0043.png",
		"chin_0039.png",
		"chin_0009.png",
		"chin_0042.png",
		"chin_0007.png",
	},

	["另补下5"] = {
		"chin_0037.png",
		"chin_0051.png",
		"chin_0016.png",
		"chin_0029.png",
		"chin_0030.png",
		"chin_0009.png",
		"chin_0076.png",
		"chin_0077.png",
		"chin_0002.png",
		"chin_0069.png",
		"chin_0046.png",
		"chin_0068.png",
		"chin_0047.png",
		"chin_0070.png",
	},

	["另补下6"] = {
		"chin_0055.png",
		"chin_0052.png",
		"chin_0065.png",
		"chin_0067.png",
		"chin_0068.png",
		"chin_0069.png",
		"chin_0071.png",
		"chin_0009.png",
		"chin_0007.png",
		"chin_0074.png",
		"chin_0019.png",
		"chin_0070.png",
		"chin_0037.png",
		"chin_0072.png",
		"chin_0077.png",
		"chin_0075.png",
		"chin_0076.png",
		"chin_0017.png",
		"chin_0058.png",
		"chin_0008.png",
		"chin_0018.png",
		"chin_0013.png",
		"chin_0047.png",
		"chin_0027.png",
		"chin_0064.png",
		"chin_0053.png",
	},

	["绳子"] = {
		"chin_shengzitx_1.png",
		"chin_shengzitx_3.png",
		"chin_shengzitx_2.png",
		"chin_shengzitx_4.png",
		"chin_shengzitx_6.png",
		"chin_shengzitx_8.png",
		"chin_shengzitx_10.png",
		"chin_shengzitx_11.png",
		"chin_shengzitx_5.png",
		"chin_shengzitx_7.png",
		"chin_shengzitx_9.png",
	},

}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/chin/ChinSkin.plist")
	Hero.setSkin(self,boneRes)
end

