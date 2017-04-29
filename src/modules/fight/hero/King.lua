-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("King", _M)
Helper.initHeroConfig(require("src/config/hero/KingConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "king/Shengli.mp3",
	["start"] = "king/Kaichang.mp3",
	["dead"] = "king/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "king/Shouji1.mp3"
	else
		return "king/Shouji2.mp3"
	end
end

local boneRes = {
	["图层2"] = {
		"king_ 78.png",
	},

	["图层4"] = {
		"king_ 106.png",
		"king_ 87.png",
		"king_ 82.png",
		"king_ 75.png",
		"king_ 78.png",
		"king_ 139.png",
	},

	["king_侧_左手下"] = {
		"king_ 87.png",
		"king_ 139.png",
		"king_ 75.png",
		"king_ 82.png",
		"king_ 143.png",
		"king_ 106.png",
	},

	["king_侧_左手上"] = {
		"king_ 86.png",
		"king_ 138.png",
		"king_ 105.png",
		"king_ 143.png",
	},

	["king_侧_头"] = {
		"king_ 77.png",
		"king_ 96.png",
		"king_ 134.png",
		"king_ 94.png",
		"king_ 93.png",
	},

	["king_侧_身体"] = {
		"king_ 76.png",
		"king_ 95.png",
		"king_ 133.png",
	},

	["king_侧_右脚上"] = {
		"king_ 78.png",
		"king_ 83.png",
		"king_ 102.png",
		"king_ 135.png",
		"king_ 97.png",
		"king_ 140.png",
	},

	["king_侧_右脚下"] = {
		"king_ 79.png",
		"king_ 98.png",
		"king_ 136.png",
		"king_ 84.png",
		"king_ 103.png",
		"king_ 141.png",
	},

	["king_侧_右脚掌"] = {
		"king_ 80.png",
		"king_ 91.png",
		"king_ 85.png",
		"king_ 90.png",
		"king_ 88.png",
		"king_ 92.png",
		"king_ 104.png",
		"king_ 89.png",
		"king_ 142.png",
	},

	["king_侧_右手下"] = {
		"king_ 82.png",
		"king_ 139.png",
		"king_ 75.png",
		"king_ 101.png",
		"king_ 138.png",
		"king_ 81.png",
	},

	["king_侧_右手上"] = {
		"king_ 81.png",
		"king_ 138.png",
		"king_ 86.png",
		"king_ 139.png",
		"king_ 82.png",
		"king_ 100.png",
	},

	["king_侧_左脚上"] = {
		"king_ 83.png",
		"king_ 78.png",
		"king_ 135.png",
		"king_ 102.png",
	},

	["king_侧_左脚下"] = {
		"king_ 84.png",
		"king_ 79.png",
		"king_ 98.png",
		"king_ 141.png",
		"king_ 103.png",
		"king_ 136.png",
	},

	["king_侧_左脚掌"] = {
		"king_ 85.png",
		"king_ 104.png",
		"king_ 91.png",
		"king_ 80.png",
		"king_ 88.png",
		"king_ 89.png",
		"king_ 90.png",
		"king_ 92.png",
		"king_ 99.png",
		"king_ 142.png",
		"king_ 137.png",
	},

}

function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/king/KingSkin.plist")
	Hero.setSkin(self,boneRes)
end
local hitSpecialCallback = {
	[2316] = Hero.hitOnce,
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function getFlyName(self)
	return nil,"毒蛇双击_特效飞行循环","毒蛇双击_特效击中"
end

--[[
function startAssist(self)
end

function updateAssist(self)
end
--]]

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
