-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Leona2", _M)
Helper.initHeroConfig(require("src/config/hero/Leona2Config").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "leona2/Shengli.mp3",
	["start"] = "leona2/Kaichang.mp3",
	["dead"] = "leona2/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "leona2/Shouji1.mp3"
	else
		return "leona2/Shouji2.mp3"
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
	if event.stateName == 4410 then		--_旋转的火花1
		self:play("rush",true)
		self.leona2_rushId = 4425		--_2
		self.canRun = true
	elseif event.stateName == 4413 then	--威武军刀
		self:play("rush",true)
		self.leona2_rushId = 4426		--_2
		self.canRun = true
	elseif event.stateName == 4414 then --粉碎者
		self:play("rush",true)
		self.leona2_rushId = 4427		--_2
		self.canRun = true
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 4410 or arg.stateName == 4413 or arg.stateName == 4414 then
		self.leona2_rushPlayId = arg.playId
		self:onPlayEnd(arg)
		return
	elseif arg.stateName == 4425 or arg.stateName == 4426 or arg.stateName == 4427 then
		arg.playId = self.leona2_rushPlayId
		self.leona2_rushPlayId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end
local hitSpecialCallback = {
	[4415] = Hero.hitOnce,
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
			self:play(self.leona2_rushId,true,true)
			self.leona2_rushId = nil
			self.canRun = nil
		end
	end
end

local boneRes = {
	["头发11"] = {
		"leona2_ 329.png",
		"leona2_ 292.png",
	},

	["右手下22"] = {
		"leona2_ 422.png",
		"leona2_ 423.png",
		"leona2_ 292.png",
		"leona2_ 293.png",
		"leona2_ 424.png",
		"leona2_ 295.png",
		"leona2_ 390.png",
		"leona2_ 391.png",
		"leona2_ 389.png",
	},

	["左手下"] = {
		"leona2_ 423.png",
		"leona2_ 422.png",
		"leona2_ 420.png",
		"leona2_ 424.png",
		"leona2_ 390.png",
		"leona2_ 332.png",
		"leona2_ 391.png",
		"leona2_ 389.png",
	},

	["左手上"] = {
		"leona2_ 420.png",
		"leona2_ 414.png",
		"leona2_ 419.png",
		"leona2_ 421.png",
		"leona2_ 388.png",
	},

	["左脚上"] = {
		"leona2_ 414.png",
		"leona2_ 384.png",
		"leona2_ 383.png",
		"leona2_ 413.png",
		"leona2_ 365.png",
		"leona2_ 415.png",
		"leona2_ 382.png",
	},

	["左脚下"] = {
		"leona2_ 365.png",
		"leona2_ 366.png",
		"leona2_ 362.png",
		"leona2_ 363.png",
		"leona2_ 361.png",
		"leona2_ 360.png",
		"leona2_ 417.png",
		"leona2_ 364.png",
	},

	["左脚中"] = {
		"leona2_ 417.png",
		"leona2_ 387.png",
		"leona2_ 416.png",
		"leona2_ 383.png",
		"leona2_ 418.png",
		"leona2_ 385.png",
		"leona2_ 386.png",
	},

	["右脚上"] = {
		"leona2_ 383.png",
		"leona2_ 414.png",
		"leona2_ 384.png",
		"leona2_ 382.png",
		"leona2_ 362.png",
		"leona2_ 413.png",
		"leona2_ 415.png",
	},

	["右脚下"] = {
		"leona2_ 362.png",
		"leona2_ 363.png",
		"leona2_ 366.png",
		"leona2_ 360.png",
		"leona2_ 361.png",
		"leona2_ 387.png",
		"leona2_ 364.png",
	},

	["右脚中"] = {
		"leona2_ 387.png",
		"leona2_ 417.png",
		"leona2_ 386.png",
		"leona2_ 335.png",
		"leona2_ 385.png",
		"leona2_ 416.png",
		"leona2_ 418.png",
	},

	["头"] = {
		"leona2_ 335.png",
		"leona2_ 333.png",
		"leona2_ 337.png",
		"leona2_ 330.png",
		"leona2_ 336.png",
		"leona2_ 334.png",
	},

	["身体"] = {
		"leona2_ 330.png",
		"leona2_ 329.png",
		"leona2_ 390.png",
		"leona2_ 331.png",
	},

	["右手下"] = {
		"leona2_ 390.png",
		"leona2_ 389.png",
		"leona2_ 391.png",
		"leona2_ 423.png",
		"leona2_ 424.png",
		"leona2_ 388.png",
		"leona2_ 332.png",
		"leona2_ 422.png",
	},

	["右手上"] = {
		"leona2_ 388.png",
		"leona2_ 293.png",
		"leona2_ 390.png",
		"leona2_ 421.png",
		"leona2_ 391.png",
		"leona2_ 420.png",
		"leona2_ 424.png",
		"leona2_ 389.png",
	},

	["头发1"] = {
		"leona2_ 293.png",
		"leona2_ 296.png",
		"leona2_ 294.png",
	},

	["头发2"] = {
		"leona2_ 296.png",
		"leona2_ 295.png",
		"leona2_ 328.png",
		"leona2_ 297.png",
	},

}



function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/leona2/Leona2Skin.plist")
	Hero.setSkin(self,boneRes)
end
