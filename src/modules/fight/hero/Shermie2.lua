-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Shermie2", _M)
Helper.initHeroConfig(require("src/config/hero/Shermie2Config").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "shermie/Shengli.mp3",
	["start"] = "shermie/Kaichang.mp3",
	["dead"] = "shermie/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "shermie/Shouji1.mp3"
	else
		return "shermie/Shouji2.mp3"
	end
end

local boneRes = {
	

	["右手下22"] = {
		"shermie2_ 64.png",
		"shermie2_ 69.png",
		"shermie2_ 68.png",
		"shermie2_ 65.png",
		"shermie2_ 63.png",
	},

	["头发11"] = {
		"shermie2_ 75.png",
	},

	["头发22"] = {
		"shermie2_ 77.png",
	},

	["左手下"] = {
		"shermie2_ 68.png",
		"shermie2_ 67.png",
		"shermie2_ 69.png",
		"shermie2_ 64.png",
		"shermie2_ 66.png",
	},

	["左手上"] = {
		"shermie2_ 66.png",
		"shermie2_ 62.png",
		"shermie2_ 67.png",
	},

	["头"] = {
		"shermie2_ 71.png",
		"shermie2_ 74.png",
		"shermie2_ 70.png",
		"shermie2_ 72.png",
		"shermie2_ 73.png",
	},

	["身体"] = {
		"shermie2_ 60.png",
		"shermie2_ 59.png",
		"shermie2_ 61.png",
	},

	["裙子"] = {
		"shermie2_ 56.png",
		"shermie2_ 55.png",
		"shermie2_ 57.png",
	},

	["左脚下"] = {
		"shermie2_ 54.png",
		"shermie2_ 44.png",
		"shermie2_ 47.png",
		"shermie2_ 53.png",
		"shermie2_ 43.png",
		"shermie2_ 49.png",
		"shermie2_ 50.png",
	},

	["左脚上"] = {
		"shermie2_ 52.png",
		"shermie2_ 42.png",
	},

	["右脚下"] = {
		"shermie2_ 44.png",
		"shermie2_ 54.png",
		"shermie2_ 53.png",
		"shermie2_ 42.png",
		"shermie2_ 47.png",
		"shermie2_ 52.png",
		"shermie2_ 49.png",
		"shermie2_ 50.png",
		"shermie2_ 48.png",
		"shermie2_ 46.png",
		"shermie2_ 43.png",
	},

	["右脚上"] = {
		"shermie2_ 42.png",
		"shermie2_ 52.png",
		"shermie2_ 50.png",
		"shermie2_ 54.png",
		"shermie2_ 51.png",
		"shermie2_ 41.png",
		"shermie2_ 45.png",
	},

	["右手下"] = {
		"shermie2_ 64.png",
		"shermie2_ 63.png",
		"shermie2_ 68.png",
		"shermie2_ 62.png",
		"shermie2_ 67.png",
	},

	["右手上"] = {
		"shermie2_ 62.png",
		"shermie2_ 66.png",
		"shermie2_ 63.png",
		"shermie2_ 64.png",
	},

	["头发1"] = {
		"shermie2_ 75.png",
		"shermie2_ 64.png",
	},

	["头发2"] = {
		"shermie2_ 77.png",
		"shermie2_ 64.png",
		"shermie2_ 76.png",
	},


}


function init(self)
	Hero.init(self)
	self:addEventListener(Event.PlayEnd,onPlayEnd,self)
end

function onPlayEnd(self,event)
	if not event.isFinish then
		return
	end
	if event.stateName == 4215 then		--_1
		self:play("rush",true)
		self:setPenetrate(true)
		self.shermie_rushId = 4224 --_2
		self.canRun = true
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 4215 then
		self.shermie_rushPlayId = arg.playId
		self:onPlayEnd(arg)
		return
	elseif arg.stateName == 4224 then
		arg.playId = self.shermie_rushPlayId
		self.shermie_rushPlayId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/shermie/Shermie2Skin.plist")
	Hero.setSkin(self,boneRes)
end


function setTarget(self)
	self:addArmatureFrame("res/armature/shermie2/Shermie2Target.ExportJson",0)
end

--[[
function doAfterStartTarget(self)
	if self.curState.name == 1811 then
		self.noAdjustTarget = true
		self.enemy:setVisible(true)
	end
end

function startTarget(self)
	if self.curState.name == 1814 then
		return
	end
	Hero.startTarget(self)
end
--]]

--[[
function rush(self,bone,evt,originFrameIndex,currentFrameIndex)
	self:setPenetrate(true)
	local x,y = self.enemy:getPosition()
	local mx,my = self:getPosition()
	local moveBy = cc.MoveBy:create(math.abs(x-mx) / 1500,cc.p(x - mx ,0))
	local callback = cc.CallFunc:create(function() 
		self.enemy:setVisible(false)
		self:resume()
		self.noAdjustTarget = nil
		Hero.startTarget(self)
		if self.enemy.curState and self.enemy.curState.lock == Define.AttackLock.defense then
			self:play("stand",true)
			self.enemy:play("stand",true)
			--self:setNextStateTime(0.5)
			--self.enemy:setNextStateTime(0.5)
		end
		if self.enemy.curState.name == "forward" or self.enemy.curState.name == "forward_run" then
			self.enemy:play("stand",true)
		end
	end)
    local seq = cc.Sequence:create(moveBy, callback)
	self:pause()
	self:runAction(seq)
end
--]]

local hitSpecialCallback = {
	--[4214] = Hero.hitOnce
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function getFlyName(self)
	if self.curState.name == 4213 then	--
		return nil,"八尺咫之鞭_飞行物_循环","八尺咫之鞭_击中"
	elseif self.curState.name == 4212 then
		return nil,"无月之雷云_飞行物_循环","无月之雷云_击中"
	else
		return Hero.getFlyName(self)
	end
	--
end


function update(self,event)
	local delay = event.delay
	if self.curState.name == "rush" then
		if self:getEnemyDis() < 100 then
			self:play(self.shermie_rushId,true,true)
			self.shermie_rushId = nil
			self.canRun = nil
		end
	end
end
