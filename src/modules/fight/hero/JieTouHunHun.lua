-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("JieTouHunHun", _M)
Helper.initHeroConfig(require("src/config/hero/JieTouHunHunConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	--["succeed"] = "terry/Shengli.mp3",
	--["start"] = "terry/Kaichang.mp3",
	--["dead"] = "terry/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "terry/Shouji1.mp3"
	else
		return "terry/Shouji2.mp3"
	end
end

local boneRes = {
}

function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	--self:addSpriteFrames("res/armature/ryo/RyoSkin.plist")
	--Hero.setSkin(self,boneRes)
end

----倒跃踢
function hit_5001(self,bone,evt,originFrameIndex,currentFrameIndex)
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
			self.enemy:setPosition(hitX - self.animation:getScaleX(),hitY - 60)
		end
	end
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end
function hit_5007(self,bone,evt,originFrameIndex,currentFrameIndex)
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.hiting and originFrameIndex > 33 then
		if self.enemy.curState.lock ~= Define.AttackLock.beat or self.enemy.curState.name == "be_caught" then
			self.enemy:play("hit_fly_a",true)
		end
	end
end

local hitSpecialCallback = {
	[5001] = hit_5001,		--倒跃踢
	[5003] = Hero.hitOnce,		--能量波
	[5007] = hit_5007,			--max高轨

	[5006] = Hero.hitOnce,		--火焰冲拳
	[5013] = Hero.hitOnce,		--跳跃轻拳
	[5014] = Hero.hitOnce,		--跳跃轻脚
	[5015] = Hero.hitOnce,		--跳跃重拳
	[5016] = Hero.hitOnce,		--跳跃重脚
	--前跳
	[5020] = Hero.hitOnce,
	[5021] = Hero.hitOnce,
	[5022] = Hero.hitOnce,
	[5023] = Hero.hitOnce,
	--后跳
	[5024] = Hero.hitOnce,
	[5025] = Hero.hitOnce,
	[5026] = Hero.hitOnce,
	[5027] = Hero.hitOnce,

}


function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function getFlyName(self)
	--return nil,"霸王翔吼拳-波飞行","霸王翔吼拳-波击中"
end
