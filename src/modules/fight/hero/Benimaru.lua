-- Benimaru,  特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Benimaru", _M)
Helper.initHeroConfig(require("src/config/hero/BenimaruConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "benimaru/Shengli.mp3",
	--["start"] = "benimaru/Shengli.mp3",
	["dead"] = "benimaru/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "benimaru/Shouji1.mp3"
	else
		return "benimaru/Shouji2.mp3"
	end
end

local boneRes = {
	["侧_右手下2"] = {
		"benimaru_ 223.png",
		"benimaru_ 240.png",
		"benimaru_ 216.png",
		"benimaru_ 237.png",
	},

	["侧_右脚上2"] = {
		"benimaru_ 224.png",
		"benimaru_ 223.png",
		"benimaru_ 216.png",
	},

	["侧_左手下"] = {
		"benimaru_ 228.png",
		"benimaru_ 216.png",
		"benimaru_ 243.png",
		"benimaru_ 211.png",
	},

	["侧_左手上"] = {
		"benimaru_ 227.png",
		"benimaru_ 215.png",
		"benimaru_ 242.png",
	},

	["侧_头"] = {
		"benimaru_ 218.png",
		"benimaru_ 207.png",
		"benimaru_ 237.png",
		"benimaru_ 235.png",
		"benimaru_ 234.png",
	},

	["侧_身体"] = {
		"benimaru_ 217.png",
		"benimaru_ 206.png",
		"benimaru_ 236.png",
	},

	["侧_右脚上"] = {
		"benimaru_ 219.png",
		"benimaru_ 224.png",
		"benimaru_ 208.png",
		"benimaru_ 212.png",
	},

	["侧_右脚下"] = {
		"benimaru_ 220.png",
		"benimaru_ 225.png",
		"benimaru_ 238.png",
		"benimaru_ 209.png",
		"benimaru_ 213.png",
		"benimaru_ 230.png",
	},

	["侧_右脚掌"] = {
		"benimaru_ 221.png",
		"benimaru_ 229.png",
		"benimaru_ 231.png",
		"benimaru_ 232.png",
		"benimaru_ 230.png",
		"benimaru_ 233.png",
		"benimaru_ 220.png",
		"benimaru_ 241.png",
	},

	["侧_左脚上"] = {
		"benimaru_ 224.png",
		"benimaru_ 219.png",
		"benimaru_ 212.png",
		"benimaru_ 208.png",
	},

	["侧_左脚下"] = {
		"benimaru_ 225.png",
		"benimaru_ 220.png",
		"benimaru_ 213.png",
		"benimaru_ 209.png",
	},

	["侧_左脚掌"] = {
		"benimaru_ 226.png",
		"benimaru_ 231.png",
		"benimaru_ 229.png",
		"benimaru_ 232.png",
		"benimaru_ 221.png",
		"benimaru_ 233.png",
		"benimaru_ 214.png",
		"benimaru_ 230.png",
	},

	["侧_身体2"] = {
		"benimaru_ 216.png",
		"benimaru_ 217.png",
		"benimaru_ 207.png",
		"benimaru_ 228.png",
	},

	["侧_右手上"] = {
		"benimaru_ 222.png",
		"benimaru_ 210.png",
		"benimaru_ 239.png",
	},

	["侧_右手下"] = {
		"benimaru_ 223.png",
		"benimaru_ 211.png",
		"benimaru_ 240.png",
		"benimaru_ 216.png",
		"benimaru_ 228.png",
	},

}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/benimaru/BenimaruSkin.plist")
	Hero.setSkin(self,boneRes)
end

function hit_3410(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.hiting and self.enemy.curState.lock ~= Define.AttackLock.defense then
		local boundBox = bone:getDisplayManager():getBoundingBox()
		local rect = self:changeToRealRect(boundBox)
		local isHit,hitX,hitY = self.enemy:isHit(rect)
		local mx = self:getPositionX()
		if originFrameIndex == 29 then
			self.enemy:setPosition(mx + 1 * self:getDirection(),hitY - 40)
		elseif originFrameIndex == 3 then
			self.enemy:setPosition(mx - 80 * self:getDirection(),Define.heroBottom + 30)
		elseif originFrameIndex == 9 or originFrameIndex == 37 then
			self.enemy:setPosition(mx - 30 * self:getDirection(),Define.heroBottom)
		else
			self.enemy:setPosition(mx + 30 * self:getDirection(),Define.heroBottom)
		end
	end
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end

local hitSpecialCallback = {
	[3410] = hit_3410
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end
