-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Orochi", _M)
Helper.initHeroConfig(require("src/config/hero/OrochiConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "orochi/Shengli.mp3",
	--["start"] = "orochi/Shengli.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "ryo/Shouji1.mp3"
	else
		return "ryo/Shouji2.mp3"
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 2412 then
		self.orochi_playId = arg.playId
		return
	elseif arg.stateName == 2414 then
		arg.playId = self.orochi_playId
		self.orochi_playId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end

function hit_2412(self,bone,evt,originFrameIndex,currentFrameIndex)
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	self:pause()
	self.enemy:pause()
	local mx = self:getPositionX()
	local ex = self.enemy:getPositionX()
	self.enemy:runAction(cc.Sequence:create(
		cc.MoveTo:create(math.abs(mx - ex) / 1500,cc.p(mx,Define.heroBottom)),
		cc.CallFunc:create(function() 
			self:resume()
			self.enemy:pause()
			--test
			--self:setCurSkill(self:getPowerSkill())
			self:play(2414,true,true)
		end)
	))
end

local hitSpecialCallback = {
	[2412] = hit_2412
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function getFlyName(self)
	if self.curState.name == 2408 then	--
		return nil,"灵气柱_地波_循环","灵气柱_地波_命中"
	elseif self.curState.name == 2410 then	--
		return "黑粒子_释放阶段特效","黑粒子_飞行循环特效",'黑粒子_击中效果特效'
	elseif self.curState.name == 2411 then	
		return "反弹盾_.释放阶段特效","反弹盾_飞行循环特效","反弹盾_击中效果特效"
	else
		return Hero.getFlyName(self)
	end
end

function getFlySpeed(self)
	return 1850
end

local boneRes = {

	["左脚下_侧"] = {
		"orochi_ 475.png",
		"orochi_ 324.png",
		"orochi_ 325.png",
		"orochi_ 326.png",
		"orochi_ 327.png",
		"orochi_ 328.png",
		"orochi_ 329.png",
		"orochi_ 330.png",
		"orochi_ 331.png",
		"orochi_ 332.png",
	},

	["左脚上_侧"] = {
		"orochi_ 442.png",
		"orochi_ 476.png",
		"orochi_ 440.png",
	},

	["右手下_侧"] = {
		"orochi_ 472.png",
		"orochi_ 471.png",
		"orochi_ 496.png",
		"orochi_ 497.png",
		"orochi_ 440.png",
		"orochi_ 448.png",
		"orochi_ 446.png",
		"orochi_ 444.png",
		"orochi_ 473.png",
	},

	["左手下_侧"] = {
		"orochi_ 497.png",
		"orochi_ 496.png",
		"orochi_ 471.png",
		"orochi_ 498.png",
		"orochi_ 472.png",
	},

	["左手上_侧"] = {
		"orochi_ 494.png",
		"orochi_ 495.png",
		"orochi_ 493.png",
	},

	["多手2"] = {
		"orochi_ 477.png",
		"orochi_ 478.png",
		"orochi_ 479.png",
		"orochi_ 480.png",
		"orochi_ 482.png",
		"orochi_ 483.png",
		"orochi_ 484.png",
		"orochi_ 485.png",
		"orochi_ 486.png",
		"orochi_ 487.png",
		"orochi_ 488.png",
		"orochi_ 489.png",
		"orochi_ 490.png",
		"orochi_ 491.png",
		"orochi_ 492.png",
		"orochi_ 481.png",
	},

	["头_侧"] = {
		"orochi_ 441.png",
		"orochi_ 443.png",
		"orochi_ 436.png",
		"orochi_ 440.png",
	},

	["身_侧"] = {
		"orochi_ 438.png",
		"orochi_ 439.png",
		"orochi_ 437.png",
	},

	["左脚上_侧2"] = {
		"orochi_ 474.png",
		"orochi_ 442.png",
		"orochi_ 452.png",
	},

	["左脚下_侧2"] = {
		"orochi_ 476.png",
		"orochi_ 455.png",
		"orochi_ 442.png",
		"orochi_ 475.png",
	},

	["鞋子左_侧"] = {
		"orochi_ 449.png",
		"orochi_ 447.png",
		"orochi_ 446.png",
		"orochi_ 450.png",
		"orochi_ 445.png",
		"orochi_ 448.png",
		"orochi_ 444.png",
	},

	["右脚上_侧"] = {
		"orochi_ 452.png",
		"orochi_ 451.png",
		"orochi_ 453.png",
	},

	["右脚下_侧"] = {
		"orochi_ 455.png",
		"orochi_ 454.png",
	},

	["鞋子右_侧"] = {
		"orochi_ 446.png",
		"orochi_ 448.png",
		"orochi_ 445.png",
		"orochi_ 447.png",
		"orochi_ 450.png",
	},

	["右手下_侧2"] = {
		"orochi_ 472.png",
		"orochi_ 471.png",
		"orochi_ 473.png",
		"orochi_ 497.png",
	},

	["右手上_侧"] = {
		"orochi_ 469.png",
		"orochi_ 468.png",
		"orochi_ 470.png",
	},

}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/orochi/OrochiSkin.plist")
	Hero.setSkin(self,boneRes)
end
