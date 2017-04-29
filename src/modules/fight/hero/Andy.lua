-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Andy", _M)
Helper.initHeroConfig(require("src/config/hero/AndyConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "andy/Shengli.mp3",
	--["start"] = "andy/Shengli.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "andy/Shouji1.mp3"
	else
		return "andy/Shouji2.mp3"
	end
end
local boneRes = {
	["右手下22"] = {
		"andy_ 185.png",
		"andy_ 133.png",
		"andy_ 134.png",
		"andy_ 95.png",
		"andy_ 97.png",
		"andy_ 96.png",
		"andy_ 184.png",
		"andy_ 132.png",
	},

	["左手下"] = {
		"andy_ 185.png",
		"andy_ 182.png",
		"andy_ 184.png",
		"andy_ 95.png",
		"andy_ 134.png",
		"andy_ 133.png",
		"andy_ 130.png",
		"andy_ 132.png",
	},

	["左手上"] = {
		"andy_ 182.png",
		"andy_ 108.png",
		"andy_ 130.png",
		"andy_ 95.png",
		"andy_ 134.png",
		"andy_ 184.png",
	},

	["头"] = {
		"andy_ 108.png",
		"andy_ 185.png",
		"andy_ 112.png",
		"andy_ 107.png",
		"andy_ 111.png",
		"andy_ 110.png",
	},

	["身体上"] = {
		"andy_ 105.png",
		"andy_ 106.png",
		"andy_ 104.png",
	},

	["胯裆前"] = {
		"andy_ 102.png",
		"andy_ 100.png",
		"andy_ 99.png",
	},

	["左鞋"] = {
		"andy_ 121.png",
		"andy_ 122.png",
		"andy_ 115.png",
		"andy_ 113.png",
		"andy_ 118.png",
		"andy_ 119.png",
		"andy_ 114.png",
		"andy_ 139.png",
		"andy_ 116.png",
		"andy_ 120.png",
	},

	["左脚上"] = {
		"andy_ 136.png",
		"andy_ 137.png",
		"andy_ 124.png",
		"andy_ 135.png",
		"andy_ 125.png",
	},

	["左脚下"] = {
		"andy_ 139.png",
		"andy_ 140.png",
		"andy_ 127.png",
		"andy_ 115.png",
		"andy_ 138.png",
		"andy_ 128.png",
		"andy_ 122.png",
	},

	["右鞋"] = {
		"andy_ 118.png",
		"andy_ 115.png",
		"andy_ 119.png",
		"andy_ 113.png",
		"andy_ 122.png",
		"andy_ 114.png",
		"andy_ 121.png",
		"andy_ 120.png",
		"andy_ 117.png",
		"andy_ 116.png",
	},

	["右脚上"] = {
		"andy_ 124.png",
		"andy_ 123.png",
		"andy_ 125.png",
		"andy_ 137.png",
	},

	["右脚下"] = {
		"andy_ 127.png",
		"andy_ 126.png",
		"andy_ 128.png",
		"andy_ 140.png",
	},

	["右手下"] = {
		"andy_ 133.png",
		"andy_ 134.png",
		"andy_ 130.png",
		"andy_ 95.png",
		"andy_ 97.png",
		"andy_ 182.png",
		"andy_ 184.png",
		"andy_ 132.png",
	},

	["右手上"] = {
		"andy_ 130.png",
		"andy_ 182.png",
		"andy_ 133.png",
		"andy_ 95.png",
		"andy_ 184.png",
	},

	["胯裆后"] = {
		"andy_ 101.png",
	},

	["头发后"] = {
		"andy_ 96.png",
		"andy_ 97.png",
		"andy_ 98.png",
	},


}



function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/andy/AndySkin.plist")
	Hero.setSkin(self,boneRes)
end

--升龙
function hit_1915(self,bone,evt,originFrameIndex,currentFrameIndex)
	if originFrameIndex > 3 and self.hiting and self.enemy.curState.lock ~= Define.AttackLock.defense then
		local boundBox = bone:getDisplayManager():getBoundingBox()
		local rect = self:changeToRealRect(boundBox)
		local isHit,hitX,hitY = self.enemy:isHit(rect)
		self.enemy:setPosition(hitX - 10 * self.animation:getScaleX(),hitY - 60)
	end
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end

local hitSpecialCallback = {
	[1916] = Hero.hitOnce,		--
	[1915] = hit_1915,		--
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

--[[
function startAssist(self)
	self.assistX = self:getPositionX()
	self:play("forward_run")
	self:addEventListener(Event.PlayEnd,function(self,event) 
		if event.stateName == "succeed" then
			self.master:getInfo():addHp(50)
			--Stage.currentScene.ui:displayHpEffect(self.master)
			self.animation:runAction(cc.Sequence:create(
				cc.FadeOut:create(0.2),
				cc.CallFunc:create(function() 
					self:removeFromParent()
				end)
			))
		end
	end)
end

function updateAssist(self)
	local x = self:getPositionX()
	if math.abs(x - self.assistX) > Stage.winSize.width / 2 and not self.firstUpdate then
		self:play("succeed",true)
		self.firstUpdate = true
	end
end
--]]
