-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Kyo", _M)
Helper.initHeroConfig(require("src/config/hero/KyoConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "kyo/Shengli.mp3",
	["start"] = "kyo/Kaichang.mp3",
	["dead"] = "kyo/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "kyo/Shouji1.mp3"
	else
		return "kyo/Shouji2.mp3"
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
	if event.stateName == 3312 then		--_1
		self:play("rush",true)
		self.kyo_rushId = 3325 --_2
		self.canRun = true
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 3312 then
		self.kyo_rushPlayId = arg.playId
		self:onPlayEnd(arg)
		return
	elseif arg.stateName == 3325 then
		arg.playId = self.kyo_rushPlayId
		self.kyo_rushPlayId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end

function hit_3325(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.hiting and self.enemy.curState.lock ~= Define.AttackLock.defense then
		local boundBox = bone:getDisplayManager():getBoundingBox()
		local rect = self:changeToRealRect(boundBox)
		local isHit,hitX,hitY = self.enemy:isHit(rect)
		if isHit and originFrameIndex == 7 then
			self.enemy:setPosition(hitX + 10 * self.animation:getScaleX(),hitY - 90)
		end
	end
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end

local hitSpecialCallback = {
	[3325] = hit_3325
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function getFlyName(self)
	return nil,"百百八式·暗拂_地波特效",nil
end

function getBgEffectDirect(self)
	return self:getDirection()
end

function update(self,event)
	local delay = event.delay
	if self.curState.name == "rush" then
		if self:getEnemyDis() < 150 then
			self:play(self.kyo_rushId,true,true)
			self.kyo_rushId = nil
			self.canRun = nil
		end
	end
end

local boneRes = {
	["右手22"] = {
		"kyo_ 364.png",
		"kyo_ 363.png",
		"kyo_ 362.png",
		"kyo_ 375.png",
		"kyo_ 374.png",
	},

	["左手下"] = {
		"kyo_ 374.png",
		"kyo_ 375.png",
		"kyo_ 362.png",
		"kyo_ 364.png",
		"kyo_ 371.png",
		"kyo_ 363.png",
		"kyo_ 373.png",
	},

	["左手上"] = {
		"kyo_ 371.png",
		"kyo_ 372.png",
		"kyo_ 364.png",
		"kyo_ 375.png",
		"kyo_ 361.png",
	},

	["头"] = {
		"kyo_ 323.png",
		"kyo_ 322.png",
		"kyo_ 325.png",
		"kyo_ 326.png",
		"kyo_ 324.png",
	},

	["身体22"] = {
		"kyo_ 306.png",
		"kyo_ 304.png",
		"kyo_ 305.png",
		"kyo_ 360.png",
	},

	["右手下"] = {
		"kyo_ 363.png",
		"kyo_ 364.png",
		"kyo_ 361.png",
		"kyo_ 362.png",
		"kyo_ 373.png",
		"kyo_ 375.png",
		"kyo_ 371.png",
		"kyo_ 357.png",
		"kyo_ 374.png",
	},

	["右手上"] = {
		"kyo_ 361.png",
		"kyo_ 364.png",
		"kyo_ 371.png",
		"kyo_ 374.png",
		"kyo_ 363.png",
		"kyo_ 305.png",
	},

	["身体"] = {
		"kyo_ 305.png",
		"kyo_ 306.png",
		"kyo_ 304.png",
		"kyo_ 361.png",
	},

	["右脚上"] = {
		"kyo_ 356.png",
		"kyo_ 366.png",
		"kyo_ 367.png",
		"kyo_ 365.png",
		"kyo_ 357.png",
	},

	["右脚下"] = {
		"kyo_ 359.png",
		"kyo_ 369.png",
		"kyo_ 370.png",
		"kyo_ 360.png",
		"kyo_ 368.png",
		"kyo_ 337.png",
	},

	["右鞋子"] = {
		"kyo_ 339.png",
		"kyo_ 342.png",
		"kyo_ 343.png",
		"kyo_ 337.png",
		"kyo_ 335.png",
		"kyo_ 336.png",
		"kyo_ 340.png",
		"kyo_ 360.png",
		"kyo_ 341.png",
	},

	["左脚上"] = {
		"kyo_ 366.png",
		"kyo_ 356.png",
		"kyo_ 367.png",
		"kyo_ 355.png",
		"kyo_ 365.png",
		"kyo_ 360.png",
		"kyo_ 357.png",
	},

	["左脚下"] = {
		"kyo_ 369.png",
		"kyo_ 359.png",
		"kyo_ 360.png",
		"kyo_ 370.png",
		"kyo_ 358.png",
		"kyo_ 368.png",
		"kyo_ 356.png",
	},

	["左鞋子"] = {
		"kyo_ 342.png",
		"kyo_ 339.png",
		"kyo_ 337.png",
		"kyo_ 335.png",
		"kyo_ 336.png",
		"kyo_ 338.png",
		"kyo_ 341.png",
		"kyo_ 340.png",
	},

}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/kyo/KyoSkin.plist")
	Hero.setSkin(self,boneRes)
end
