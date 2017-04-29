-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Leona", _M)
Helper.initHeroConfig(require("src/config/hero/LeonaConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "leona/Shengli.mp3",
	["start"] = "leona/Kaichang.mp3",
	["dead"] = "leona/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "leona/Shouji1.mp3"
	else
		return "leona/Shouji2.mp3"
	end
end

function init(self)
	Hero.init(self)
	self:addEventListener(Event.PlayEnd,onPlayEnd,self)
end

function onPlayEnd(self,event)
	if not event.isFinish then
		return
	end
	if event.stateName == 2810 then		--_旋转的火花1
		self:play("rush",true)
		self.leona_rushId = 2825		--_2
		self.canRun = true
	elseif event.stateName == 2813 then	--威武军刀
		self:play("rush",true)
		self.leona_rushId = 2826		--_2
		self.canRun = true
	elseif event.stateName == 2814 then --粉碎者
		self:play("rush",true)
		self.leona_rushId = 2827		--_2
		self.canRun = true
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 2810 or arg.stateName == 2813 or arg.stateName == 2814 then
		self.leona_rushPlayId = arg.playId
		self:onPlayEnd(arg)
		return
	elseif arg.stateName == 2825 or arg.stateName == 2826 or arg.stateName == 2827 then
		arg.playId = self.leona_rushPlayId
		self.leona_rushPlayId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end
local hitSpecialCallback = {
	[2815] = Hero.hitOnce,
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
			--test
			--self:setCurSkill(self:getPowerSkill())
			self:play(self.leona_rushId,true,true)
			self.leona_rushId = nil
			self.canRun = nil
		end
	end
end

local boneRes = {

	["头发11"] = {
		"leona_ 329.png",
		"leona_ 292.png",
	},

	["右手下22"] = {
		"leona_ 422.png",
		"leona_ 423.png",
		"leona_ 292.png",
		"leona_ 293.png",
		"leona_ 424.png",
		"leona_ 295.png",
		"leona_ 390.png",
		"leona_ 391.png",
		"leona_ 389.png",
	},

	["左手下"] = {
		"leona_ 423.png",
		"leona_ 422.png",
		"leona_ 420.png",
		"leona_ 424.png",
		"leona_ 390.png",
		"leona_ 332.png",
		"leona_ 391.png",
		"leona_ 389.png",
	},

	["左手上"] = {
		"leona_ 420.png",
		"leona_ 414.png",
		"leona_ 419.png",
		"leona_ 421.png",
		"leona_ 388.png",
	},

	["左脚上"] = {
		"leona_ 414.png",
		"leona_ 384.png",
		"leona_ 383.png",
		"leona_ 413.png",
		"leona_ 365.png",
		"leona_ 415.png",
		"leona_ 382.png",
	},

	["左脚下"] = {
		"leona_ 365.png",
		"leona_ 366.png",
		"leona_ 362.png",
		"leona_ 363.png",
		"leona_ 361.png",
		"leona_ 360.png",
		"leona_ 417.png",
		"leona_ 364.png",
	},

	["左脚中"] = {
		"leona_ 417.png",
		"leona_ 387.png",
		"leona_ 416.png",
		"leona_ 383.png",
		"leona_ 418.png",
		"leona_ 385.png",
		"leona_ 386.png",
	},

	["右脚上"] = {
		"leona_ 383.png",
		"leona_ 414.png",
		"leona_ 384.png",
		"leona_ 382.png",
		"leona_ 362.png",
		"leona_ 413.png",
		"leona_ 415.png",
	},

	["右脚下"] = {
		"leona_ 362.png",
		"leona_ 363.png",
		"leona_ 366.png",
		"leona_ 360.png",
		"leona_ 361.png",
		"leona_ 387.png",
		"leona_ 364.png",
	},

	["右脚中"] = {
		"leona_ 387.png",
		"leona_ 417.png",
		"leona_ 386.png",
		"leona_ 335.png",
		"leona_ 385.png",
		"leona_ 416.png",
		"leona_ 418.png",
	},

	["头"] = {
		"leona_ 335.png",
		"leona_ 333.png",
		"leona_ 337.png",
		"leona_ 330.png",
		"leona_ 336.png",
		"leona_ 334.png",
	},

	["身体"] = {
		"leona_ 330.png",
		"leona_ 329.png",
		"leona_ 390.png",
		"leona_ 331.png",
	},

	["右手下"] = {
		"leona_ 390.png",
		"leona_ 389.png",
		"leona_ 391.png",
		"leona_ 423.png",
		"leona_ 424.png",
		"leona_ 388.png",
		"leona_ 332.png",
		"leona_ 422.png",
	},

	["右手上"] = {
		"leona_ 388.png",
		"leona_ 293.png",
		"leona_ 390.png",
		"leona_ 421.png",
		"leona_ 391.png",
		"leona_ 420.png",
		"leona_ 424.png",
		"leona_ 389.png",
	},

	["头发1"] = {
		"leona_ 293.png",
		"leona_ 296.png",
		"leona_ 294.png",
	},

	["头发2"] = {
		"leona_ 296.png",
		"leona_ 295.png",
		"leona_ 328.png",
		"leona_ 297.png",
	},
}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/leona/LeonaSkin.plist")
	Hero.setSkin(self,boneRes)
end
