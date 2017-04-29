-- kim,  特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Kim", _M)
Helper.initHeroConfig(require("src/config/hero/KimConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "kim/Shengli.mp3",
	["start"] = "kim/Kaichang.mp3",
	--["fail"] = "kim/Shibai.mp3",
	["dead"] = "kim/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "kim/Shouji1.mp3"
	else
		return "kim/Shouji2.mp3"
	end
end

local boneRes = {

	["左手前臂2"] = {
		"kim_ 121.png",
		"kim_ 172.png",
		"kim_ 157.png",
	},

	["右手前臂"] = {
		"kim_ 157.png",
		"kim_ 121.png",
		"kim_ 156.png",
		"kim_ 171.png",
		"kim_ 158.png",
		"kim_ 172.png",
	},

	["右手上臂"] = {
		"kim_ 160.png",
		"kim_ 159.png",
		"kim_ 161.png",
		"kim_ 157.png",
	},

	["头_侧"] = {
		"kim_ 145.png",
		"kim_ 147.png",
		"kim_ 144.png",
		"kim_ 146.png",
		"kim_ 140.png",
		"kim_ 160.png",
	},

	["身_侧"] = {
		"kim_ 142.png",
		"kim_ 141.png",
		"kim_ 143.png",
		"kim_ 145.png",
	},

	["带子右"] = {
		"kim_ 128.png",
		"kim_ 129.png",
		"kim_ 142.png",
	},

	["带子左"] = {
		"kim_ 130.png",
		"kim_ 131.png",
		"kim_ 128.png",
	},

	["裤摆"] = {
		"kim_ 138.png",
		"kim_ 137.png",
		"kim_ 139.png",
		"kim_ 130.png",
	},

	["右脚大腿"] = {
		"kim_ 149.png",
		"kim_ 162.png",
		"kim_ 148.png",
		"kim_ 150.png",
		"kim_ 163.png",
		"kim_ 139.png",
	},

	["右脚小腿"] = {
		"kim_ 154.png",
		"kim_ 153.png",
		"kim_ 155.png",
		"kim_ 169.png",
		"kim_ 149.png",
	},

	["右脚脚掌"] = {
		"kim_ 151.png",
		"kim_ 166.png",
		"kim_ 152.png",
		"kim_ 133.png",
		"kim_ 135.png",
		"kim_ 167.png",
		"kim_ 165.png",
		"kim_ 136.png",
		"kim_ 134.png",
		"kim_ 132.png",
		"kim_ 154.png",
	},

	["左脚大腿"] = {
		"kim_ 163.png",
		"kim_ 162.png",
		"kim_ 164.png",
		"kim_ 149.png",
		"kim_ 167.png",
	},

	["左脚小腿"] = {
		"kim_ 169.png",
		"kim_ 168.png",
		"kim_ 170.png",
		"kim_ 154.png",
		"kim_ 163.png",
	},

	["左脚脚掌"] = {
		"kim_ 166.png",
		"kim_ 151.png",
		"kim_ 134.png",
		"kim_ 167.png",
		"kim_ 133.png",
		"kim_ 136.png",
		"kim_ 165.png",
		"kim_ 135.png",
		"kim_ 132.png",
		"kim_ 169.png",
	},

	["左手上臂"] = {
		"kim_ 174.png",
		"kim_ 173.png",
		"kim_ 175.png",
		"kim_ 166.png",
	},

	["左手前臂"] = {
		"kim_ 121.png",
		"kim_ 171.png",
		"kim_ 172.png",
		"kim_ 174.png",
		"kim_ 156.png",
	},

	["另补层2"] = {
		"kim_ 144.png",
		"kim_ 145.png",
		"kim_ 160.png",
	},

	["另补层1"] = {
		"kim_ 121.png",
	},

}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/kim/KimSkin.plist")
	Hero.setSkin(self,boneRes)
end

------------------帧回调事件
function hit_3716(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.hiting and self.enemy.curState.lock ~= Define.AttackLock.defense then
		if originFrameIndex > 15 then
			local boundBox = bone:getDisplayManager():getBoundingBox()
			local rect = self:changeToRealRect(boundBox)
			local isHit,hitX,hitY = self.enemy:isHit(rect)
			if isHit then
				self.enemy:setPosition(hitX - self.animation:getScaleX(),hitY - 80)
			end
		end
	end
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end

local hitSpecialCallback = {
	[3716] = hit_3716
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end
