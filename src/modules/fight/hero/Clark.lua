-- clark,克拉克 特写状态

module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Clark", _M)
Helper.initHeroConfig(require("src/config/hero/ClarkConfig").Config)
local Define = require("src/modules/fight/Define")
local Flyer = require("src/modules/fight/Flyer")

local soundTable = {
	["succeed"] = "clark/Shengli.mp3",
	--["start"] = "clark/Shengli.mp3",
	["dead"] = "clark/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "clark/Shouji1.mp3"
	else
		return "clark/Shouji2.mp3"
	end
end

function init(self)
	Hero.init(self)
	self:addEventListener(Event.PlayEnd,onPlayEnd,self)
end

function setTarget(self)
	self:addArmatureFrame("res/armature/clark/ClarkTarget.ExportJson",0)
end

function onPlayEnd(self,event)
	if not event.isFinish then
		return
	end
	if event.stateName == 1609 then		--奔袭投掷_1
		self:play("rush",true)
		self.clark_rushId = 1610		--奔袭投掷_2
		self.canRun = true
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 1609 then
		self.clark_rushPlayId = arg.playId
		self:onPlayEnd(arg)
		return
	elseif arg.stateName == 1610 then
		arg.playId = self.clark_rushPlayId
		self.clark_rushPlayId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end

local boneRes = {

	["另补上1"] = {
		"clark_ 102.png",
		"clark_ 101.png",
		"clark_ 120.png",
		"clark_ 117.png",
		"clark_ 113.png",
		"clark_ 114.png",
		"clark_ 111.png",
		"clark_ 108.png",
		"clark_ 96.png",
		"clark_ 92.png",
	},

	["另补上2"] = {
		"clark_ 92.png",
		"clark_ 111.png",
		"clark_ 109.png",
		"clark_ 108.png",
		"clark_ 120.png",
		"clark_ 113.png",
		"clark_ 119.png",
		"clark_ 96.png",
		"clark_ 110.png",
		"clark_ 107.png",
		"clark_ 102.png",
		"clark_ 117.png",
		"clark_ 94.png",
		"clark_ 100.png",
		"clark_ 115.png",
	},

	["前手上"] = {
		"clark_ 109.png",
		"clark_ 113.png",
		"clark_ 108.png",
		"clark_ 111.png",
		"clark_ 96.png",
		"clark_ 94.png",
		"clark_ 92.png",
		"clark_ 116.png",
		"clark_ 112.png",
		"clark_ 110.png",
		"clark_ 120.png",
	},

	["前手下"] = {
		"clark_ 112.png",
		"clark_ 110.png",
		"clark_ 108.png",
		"clark_ 111.png",
		"clark_ 103.png",
		"clark_ 120.png",
	},

	["衣服"] = {
		"clark_ 122.png",
		"clark_ 121.png",
		"clark_ 113.png",
	},

	["头"] = {
		"clark_ 117.png",
		"clark_ 115.png",
		"clark_ 120.png",
		"clark_ 118.png",
		"clark_ 104.png",
		"clark_ 102.png",
		"clark_ 112.png",
		"clark_ 111.png",
		"clark_ 119.png",
	},

	["前脚上"] = {
		"clark_ 102.png",
		"clark_ 101.png",
		"clark_ 85.png",
		"clark_ 121.png",
		"clark_ 115.png",
		"clark_ 106.png",
	},

	["前脚中"] = {
		"clark_ 106.png",
		"clark_ 99.png",
		"clark_ 89.png",
		"clark_ 98.png",
		"clark_ 107.png",
		"clark_ 105.png",
		"clark_ 100.png",
		"clark_ 97.png",
		"clark_ 90.png",
		"clark_ 117.png",
	},

	["前脚下"] = {
		"clark_ 104.png",
		"clark_ 103.png",
		"clark_ 87.png",
		"clark_ 101.png",
		"clark_ 86.png",
	},

	["后脚上"] = {
		"clark_ 85.png",
		"clark_ 84.png",
		"clark_ 101.png",
		"clark_ 89.png",
	},

	["后脚中"] = {
		"clark_ 89.png",
		"clark_ 99.png",
		"clark_ 98.png",
		"clark_ 88.png",
		"clark_ 100.png",
		"clark_ 105.png",
		"clark_ 106.png",
		"clark_ 90.png",
		"clark_ 103.png",
		"clark_ 109.png",
		"clark_ 107.png",
	},

	["后脚下"] = {
		"clark_ 87.png",
		"clark_ 86.png",
		"clark_ 103.png",
		"clark_ 104.png",
		"clark_ 105.png",
		"clark_ 84.png",
	},

	["后手上"] = {
		"clark_ 92.png",
		"clark_ 94.png",
		"clark_ 96.png",
		"clark_ 109.png",
		"clark_ 113.png",
		"clark_ 111.png",
		"clark_ 91.png",
		"clark_ 89.png",
		"clark_ 95.png",
	},

	["后手下"] = {
		"clark_ 95.png",
		"clark_ 91.png",
		"clark_ 93.png",
		"clark_ 113.png",
		"clark_ 86.png",
		"clark_ 111.png",
	},

	["另补下1"] = {
		"clark_ 111.png",
		"clark_ 94.png",
		"clark_ 92.png",
		"clark_ 96.png",
		"clark_ 113.png",
		"clark_ 95.png",
		"clark_ 115.png",
		"clark_ 120.png",
	},

	["另补下2"] = {
		"clark_ 96.png",
		"clark_ 120.png",
		"clark_ 111.png",
	},

}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/clark/ClarkSkin.plist")
	Hero.setSkin(self,boneRes)
end

local hitSpecialCallback = {

	--跳攻
	--[[
	--]]

}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function update(self,event)
	local delay = event.delay
	if self.curState.name == "rush" then
		if self:getEnemyDis() < 150 then
			self:play(self.clark_rushId,true,true)
			self.clark_rushId = nil
			self.canRun = nil
		end
	end
end


function startAssist(self)
	Hero.startAssistAtk(self)
end
