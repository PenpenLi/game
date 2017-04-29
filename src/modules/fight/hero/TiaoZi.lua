-- athena, 雅典娜特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("TiaoZi", _M)
Helper.initHeroConfig(require("src/config/hero/TiaoZiConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	--["succeed"] = "athena/Shengli.mp3",
	--["start"] = "athena/Kaichang.mp3",
	--["dead"] = "athena/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "athena/Shouji1.mp3"
	else
		return "athena/Shouji2.mp3"
	end
end

local boneRes = {

	--[[
	["头发上2"] = {
		"athena_ 299.png",
	},

	["头发上1"] = {
		"athena_ 303.png",
		"athena_ 301.png",
	},

	["左手上"] = {
		"athena_ 301.png",
		"athena_ 333.png",
		"athena_ 309.png",
		"athena_ 332.png",
	},

	["右手"] = {
		"athena_ 301.png",
		"athena_ 309.png",
		"athena_ 315.png",
		"athena_ 332.png",
		"athena_ 339.png",
	},

	["右手臂"] = {
		"athena_ 304.png",
		"athena_ 305.png",
		"athena_ 312.png",
		"athena_ 301.png",
		"athena_ 329.png",
	},

	["头部"] = {
		"athena_ 308.png",
		"athena_ 307.png",
		"athena_ 300.png",
		"athena_ 297.png",
		"athena_ 304.png",
		"athena_ 341.png",
		"athena_ 340.png",
	},

	["身体"] = {
		"athena_ 310.png",
		"athena_ 311.png",
		"athena_ 316.png",
		"athena_ 308.png",
	},

	["裙子"] = {
		"athena_ 313.png",
		"athena_ 314.png",
		"athena_ 319.png",
		"athena_ 310.png",
	},

	["右腿"] = {
		"athena_ 320.png",
		"athena_ 321.png",
		"athena_ 328.png",
		"athena_ 306.png",
		"athena_ 324.png",
		"athena_ 318.png",
		"athena_ 313.png",
		"athena_ 323.png",
		"athena_ 317.png",
		"athena_ 325.png",
		"athena_ 327.png",
	},

	["右脚"] = {
		"athena_ 325.png",
		"athena_ 298.png",
		"athena_ 323.png",
		"athena_ 324.png",
		"athena_ 328.png",
		"athena_ 326.png",
		"athena_ 320.png",
		"athena_ 318.png",
	},

	["左腿"] = {
		"athena_ 317.png",
		"athena_ 318.png",
		"athena_ 331.png",
		"athena_ 302.png",
		"athena_ 327.png",
		"athena_ 325.png",
		"athena_ 320.png",
		"athena_ 322.png",
		"athena_ 306.png",
	},

	["左脚"] = {
		"athena_ 322.png",
		"athena_ 323.png",
		"athena_ 298.png",
		"athena_ 327.png",
		"athena_ 331.png",
		"athena_ 326.png",
		"athena_ 317.png",
		"athena_ 328.png",
	},

	["左手臂"] = {
		"athena_ 329.png",
		"athena_ 330.png",
		"athena_ 336.png",
		"athena_ 301.png",
		"athena_ 339.png",
		"athena_ 305.png",
		"athena_ 298.png",
		"athena_ 304.png",
		"athena_ 332.png",
	},

	["左手"] = {
		"athena_ 332.png",
		"athena_ 333.png",
		"athena_ 339.png",
		"athena_ 329.png",
		"athena_ 301.png",
		"athena_ 315.png",
		"athena_ 309.png",
	},

	["头发下1"] = {
		"athena_ 334.png",
		"athena_ 335.png",
	},

	["头发下2"] = {
		"athena_ 337.png",
		"athena_ 338.png",
	},
	--]]
}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	--self:addSpriteFrames("res/armature/athena/TiaoZiSkin.plist")
	--Hero.setSkin(self,boneRes)
end

function hit_5213(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.hiting and self.enemy.curState.lock ~= Define.AttackLock.defense then
		local boundBox = bone:getDisplayManager():getBoundingBox()
		local rect = self:changeToRealRect(boundBox)
		local isHit,hitX,hitY = self.enemy:isHit(rect)
		self.enemy:setPosition(hitX - 30 * self.animation:getScaleX(),hitY - 60)
	end
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end

local hitSpecialCallback = {
	[5213] = hit_5213,		--划空光剑
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

---[[
function doAfterPlay(self,isHarm)
	Hero.doAfterPlay(self,isHarm)
	if self.curState.name == 5210 then
		Stage.currentScene:blackScreen(4.6,nil)
	end
end
--]]
function pow(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.curState.name == 5210 then
		---[[
		local boundBox = bone:getDisplayManager():getBoundingBox()
		local rect = self:changeToRealRect(boundBox)
		Stage.currentScene:displayEffect("必杀",rect.x,rect.y,self:getDirection(),true)
		Stage.currentScene:displayEffect("大招",rect.x,rect.y,self:getDirection())

		--Stage.currentScene:blackScreen(4.8,nil,callback)
		SoundManager.playEffect("common/Bishashanping.mp3")
		---]]
	else
		Hero.pow(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function rush(self,bone,evt,originFrameIndex,currentFrameIndex)
	--redo-
	--加上分身
	--
	local x,y = self.enemy:getPosition()
	local mx,my = self:getPosition()
	local flag = 1
	if math.random(1,10) <= 5 then
		flag = -1
	end
	local t = math.abs(x - mx) / 1500
	local moveTo = cc.MoveTo:create(t,cc.p(x + flag * self:getDirection() * 60,Define.heroBottom))
	--local fadeOut = cc.FadeOut:create(t/2)
	--local spawn = cc.Spawn:create(moveTo,fadeOut)
	self:pause()
	self.enemy:pause()
	self:setPenetrate(true)
	local callback = cc.CallFunc:create(function() 
		self:resume()
		self.enemy:resume()
		self:setPenetrate(false)
		self.animation:runAction(cc.FadeIn:create(0.0001))
		if self.enemy.curState.name == "forward" or self.enemy.curState.name == "forward_run" then
			self.enemy:play("stand",true)
		end
	end)
    local seq = cc.Sequence:create(moveTo, callback)
	self:runAction(seq)
	self.animation:runAction(cc.FadeOut:create(t/2))
end

function getFlyName(self)
	return nil,"精神力球_飞行道具飞行循环","精神力球_飞行道具击中"
end
