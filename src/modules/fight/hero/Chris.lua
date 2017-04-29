-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Chris", _M)
Helper.initHeroConfig(require("src/config/hero/ChrisConfig").Config)
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
----
function hit_2709(self,bone,evt,originFrameIndex,currentFrameIndex)
	--print('----------------self.hiting,state:',self.hiting,self.enemy.curState)
	if self.hiting and self.enemy.curState.lock ~= Define.AttackLock.defense then
		local boundBox = bone:getDisplayManager():getBoundingBox()
		--[[
		local x,y = self._ccnode:getPosition()
		local hitX = x + (boundBox.x + boundBox.width / 2) * self.animation:getScaleX()
		local hitY = y + boundBox.y + boundBox.height / 2
		--]]
		local rect = self:changeToRealRect(boundBox)
		local isHit,hitX,hitY = self.enemy:isHit(rect)
		if isHit then
			self.enemy:setPosition(hitX - 30 * self.animation:getScaleX(),hitY - 60)
		end
	end
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end
local hitSpecialCallback = {
	[2709] = hit_2709,
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
		"chris_ 107.png",
		"chris_ 91.png",
		"chris_ 125.png",
		"chris_ 114.png",
	},

	["左手下22"] = {
		"chris_ 126.png",
		"chris_ 114.png",
		"chris_ 125.png",
		"chris_ 130.png",
		"chris_ 115.png",
		"chris_ 120.png",
		"chris_ 112.png",
		"chris_ 129.png",
	},

	["右手下"] = {
		"chris_ 114.png",
		"chris_ 126.png",
		"chris_ 125.png",
		"chris_ 130.png",
		"chris_ 112.png",
		"chris_ 113.png",
		"chris_ 115.png",
		"chris_ 129.png",
	},

	["右手上"] = {
		"chris_ 112.png",
		"chris_ 129.png",
		"chris_ 125.png",
		"chris_ 124.png",
		"chris_ 123.png",
	},

	["头"] = {
		"chris_ 104.png",
		"chris_ 103.png",
		"chris_ 107.png",
		"chris_ 105.png",
		"chris_ 106.png",
	},

	["身体"] = {
		"chris_ 101.png",
		"chris_ 102.png",
		"chris_ 100.png",
	},

	["左脚"] = {
		"chris_ 127.png",
		"chris_ 110.png",
		"chris_ 109.png",
		"chris_ 111.png",
		"chris_ 93.png",
		"chris_ 128.png",
		"chris_ 91.png",
		"chris_ 92.png",
		"chris_ 132.png",
	},

	["左脚下"] = {
		"chris_ 135.png",
		"chris_ 134.png",
		"chris_ 120.png",
		"chris_ 93.png",
		"chris_ 109.png",
	},

	["左脚上"] = {
		"chris_ 132.png",
		"chris_ 133.png",
		"chris_ 131.png",
		"chris_ 118.png",
		"chris_ 117.png",
		"chris_ 135.png",
		"chris_ 134.png",
	},

	["右脚"] = {
		"chris_ 109.png",
		"chris_ 110.png",
		"chris_ 111.png",
		"chris_ 91.png",
		"chris_ 108.png",
		"chris_ 117.png",
		"chris_ 93.png",
		"chris_ 127.png",
		"chris_ 92.png",
		"chris_ 116.png",
	},

	["右脚下"] = {
		"chris_ 120.png",
		"chris_ 121.png",
		"chris_ 119.png",
		"chris_ 135.png",
		"chris_ 109.png",
		"chris_ 93.png",
		"chris_ 127.png",
		"chris_ 111.png",
	},

	["右脚上"] = {
		"chris_ 117.png",
		"chris_ 118.png",
		"chris_ 116.png",
		"chris_ 132.png",
		"chris_ 120.png",
		"chris_ 119.png",
	},

	["左手上"] = {
		"chris_ 129.png",
		"chris_ 112.png",
		"chris_ 115.png",
		"chris_ 123.png",
	},

	["左手下"] = {
		"chris_ 130.png",
		"chris_ 114.png",
		"chris_ 113.png",
		"chris_ 126.png",
		"chris_ 115.png",
		"chris_ 112.png",
		"chris_ 125.png",
	},

	["另补1"] = {
		"chris_ 114.png",
		"chris_ 95.png",
		"chris_ 94.png",
		"chris_ 98.png",
		"chris_ 99.png",
	},

	["cy_yuohua1"] = {
		"chris_youhuatx_18.png",
		"chris_youhuatx_14.png",
		"chris_youhuatx_13.png",
		"chris_youhuatx_12.png",
		"chris_youhuatx_11.png",
		"chris_youhuatx_10.png",
		"chris_youhuatx_9.png",
		"chris_youhuatx_8.png",
		"chris_youhuatx_7.png",
		"chris_youhuatx_6.png",
		"chris_youhuatx_19.png",
		"chris_youhuatx_17.png",
	},

	["cy_yuohua2"] = {
		"chris_youhuatx_18.png",
		"chris_youhuatx_14.png",
		"chris_youhuatx_13.png",
		"chris_youhuatx_12.png",
		"chris_youhuatx_11.png",
		"chris_youhuatx_10.png",
		"chris_youhuatx_9.png",
		"chris_youhuatx_8.png",
		"chris_youhuatx_7.png",
		"chris_youhuatx_6.png",
	},


}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/chris/ChrisSkin.plist")
	Hero.setSkin(self,boneRes)
end

