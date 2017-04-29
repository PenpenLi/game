-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Shermie", _M)
Helper.initHeroConfig(require("src/config/hero/ShermieConfig").Config)
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
		"shermie_ 64.png",
		"shermie_ 69.png",
		"shermie_ 68.png",
		"shermie_ 65.png",
		"shermie_ 63.png",
	},

	["头发11"] = {
		"shermie_ 75.png",
	},

	["头发22"] = {
		"shermie_ 77.png",
	},

	["左手下"] = {
		"shermie_ 68.png",
		"shermie_ 67.png",
		"shermie_ 69.png",
		"shermie_ 64.png",
		"shermie_ 66.png",
	},

	["左手上"] = {
		"shermie_ 66.png",
		"shermie_ 62.png",
		"shermie_ 67.png",
	},

	["头"] = {
		"shermie_ 71.png",
		"shermie_ 74.png",
		"shermie_ 70.png",
		"shermie_ 72.png",
		"shermie_ 73.png",
	},

	["身体"] = {
		"shermie_ 60.png",
		"shermie_ 59.png",
		"shermie_ 61.png",
	},

	["裙子"] = {
		"shermie_ 56.png",
		"shermie_ 55.png",
		"shermie_ 57.png",
	},

	["左脚下"] = {
		"shermie_ 54.png",
		"shermie_ 44.png",
		"shermie_ 47.png",
		"shermie_ 53.png",
		"shermie_ 43.png",
		"shermie_ 49.png",
		"shermie_ 50.png",
	},

	["左脚上"] = {
		"shermie_ 52.png",
		"shermie_ 42.png",
	},

	["右脚下"] = {
		"shermie_ 44.png",
		"shermie_ 54.png",
		"shermie_ 53.png",
		"shermie_ 42.png",
		"shermie_ 47.png",
		"shermie_ 52.png",
		"shermie_ 49.png",
		"shermie_ 50.png",
		"shermie_ 48.png",
		"shermie_ 46.png",
		"shermie_ 43.png",
	},

	["右脚上"] = {
		"shermie_ 42.png",
		"shermie_ 52.png",
		"shermie_ 50.png",
		"shermie_ 54.png",
		"shermie_ 51.png",
		"shermie_ 41.png",
		"shermie_ 45.png",
	},

	["右手下"] = {
		"shermie_ 64.png",
		"shermie_ 63.png",
		"shermie_ 68.png",
		"shermie_ 62.png",
		"shermie_ 67.png",
	},

	["右手上"] = {
		"shermie_ 62.png",
		"shermie_ 66.png",
		"shermie_ 63.png",
		"shermie_ 64.png",
	},

	["头发1"] = {
		"shermie_ 75.png",
		"shermie_ 64.png",
	},

	["头发2"] = {
		"shermie_ 77.png",
		"shermie_ 64.png",
		"shermie_ 76.png",
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
	if event.stateName == 1809 then		--_1
		self:play("rush",true)
		self:setPenetrate(true)
		self.shermie_rushId = 1826		--_2
		self.canRun = true
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 1809 then
		self.shermie_rushPlayId = arg.playId
		self:onPlayEnd(arg)
		return
	elseif arg.stateName == 1826 then
		arg.playId = self.shermie_rushPlayId
		self.shermie_rushPlayId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/shermie/ShermieSkin.plist")
	Hero.setSkin(self,boneRes)
end


function setTarget(self)
	self:addArmatureFrame("res/armature/shermie/ShermieTarget.ExportJson",0)
end

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

local hitSpecialCallback = {
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
		if self:getEnemyDis() < 100 then
			self:play(self.shermie_rushId,true,true)
			self.shermie_rushId = nil
			self.canRun = nil
		end
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
