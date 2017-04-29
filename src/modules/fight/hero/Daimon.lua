-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Daimon", _M)
Helper.initHeroConfig(require("src/config/hero/DaimonConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

function init(self)
	Hero.init(self)
	self:addEventListener(Event.PlayEnd,onPlayEnd,self)

	--[[
	-----配置特写
	self.config["forward_run"] = Define.HeroState["forward_run"]
	self.config["forward_run"].sound = "daimon/Paobu.mp3"

	self.config["back_run"] = Define.HeroState["back_run"]
	self.config["back_run"].sound = "daimon/Jitui.mp3"
	--]]
end

function setTarget(self)
	self:addArmatureFrame("res/armature/daimon/DaimonTarget.ExportJson",0)
end

function onPlayEnd(self,event)
	if not event.isFinish then
		return
	end
	if event.stateName == 2213 then		--_里投1
		self:play("rush",true)
		self.daimon_rushId = 2214 --里投_2
		self.canRun = true
		self:setNoTurn(true)
		self:setPenetrate(true)
	elseif event.stateName == 2209 then	--大招地狱
		self:play("rush",true)
		self.daimon_rushId = 2229 --大招_2
		self.canRun = true
		self:setNoTurn(true)
		self:setPenetrate(true)
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 2213 or arg.stateName == 2209 then
		self.daimon_rushPlayId = arg.playId
		self:onPlayEnd(arg)
		return
	elseif arg.stateName == 2214 or arg.stateName == 2229 then
		arg.playId = self.daimon_rushPlayId
		self.daimon_rushPlayId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end

local soundTable = {
	["succeed"] = "daimon/Shengli.mp3",
	--["start"] = "daimon/Shengli.mp3",
	["dead"] = "daimon/Siwang.mp3",
	["forward_run"] = "daimon/Paobu.mp3",
	["back_run"] = "daimon/Jitui.mp3"
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "daimon/Shouji1.mp3"
	else
		return "daimon/Shouji2.mp3"
	end
end

local boneRes = {
	["手3"] = {
		"daimon_ 70.png",
		"daimon_ 83.png",
		"daimon_ 84.png",
		"daimon_ 74.png",
		"daimon_ 71.png",
		"daimon_ 85.png",
		"daimon_yy.png",
	},

	["左手下"] = {
		"daimon_ 89.png",
		"daimon_ 85.png",
		"daimon_ 84.png",
		"daimon_ 90.png",
		"daimon_ 83.png",
		"daimon_ 70.png",
		"daimon_ 91.png",
		"daimon_ 81.png",
		"daimon_ 92.png",
		"daimon_ 72.png",
		"daimon_ 71.png",
		"daimon_ 74.png",
	},

	["左手上"] = {
		"daimon_ 82.png",
		"daimon_ 83.png",
		"daimon_ 81.png",
		"daimon_ 84.png",
		"daimon_ 70.png",
	},

	["裤带左下"] = {
		"daimon_ 102.png",
		"daimon_ 107.png",
	},

	["裤带结"] = {
		"daimon_ 98.png",
		"daimon_ 109.png",
	},

	["裤带左上"] = {
		"daimon_ 101.png",
		"daimon_ 110.png",
	},

	["裤带右下"] = {
		"daimon_ 100.png",
		"daimon_ 112.png",
	},

	["裤带右上"] = {
		"daimon_ 99.png",
		"daimon_ 114.png",
	},

	["头带结2"] = {
		"daimon_ 107.png",
		"daimon_ 93.png",
		"daimon_ 106.png",
		"daimon_ 79.png",
		"daimon_ 120.png",
		"daimon_ 97.png",
		"daimon_ 111.png",
	},

	["头带右下2"] = {
		"daimon_ 110.png",
		"daimon_ 114.png",
		"daimon_ 111.png",
		"daimon_ 76.png",
		"daimon_ 120.png",
		"daimon_ 79.png",
		"daimon_ 67.png",
		"daimon_ 106.png",
	},

	["头带右上2"] = {
		"daimon_ 109.png",
		"daimon_ 112.png",
		"daimon_ 113.png",
		"daimon_ 76.png",
		"daimon_ 63.png",
		"daimon_ 77.png",
	},

	["头带左下2"] = {
		"daimon_ 114.png",
		"daimon_ 110.png",
		"daimon_ 108.png",
	},

	["头带左上2"] = {
		"daimon_ 112.png",
		"daimon_ 109.png",
		"daimon_ 93.png",
	},

	["头"] = {
		"daimon_ 105.png",
		"daimon_ 88.png",
		"daimon_ 103.png",
		"daimon_ 115.png",
	},

	["身"] = {
		"daimon_ 104.png",
		"daimon_ 87.png",
	},

	["头2"] = {
		"daimon_ 88.png",
	},

	["衣服下"] = {
		"daimon_ 122.png",
		"daimon_ 121.png",
		"daimon_ 79.png",
	},

	["左脚上"] = {
		"daimon_ 76.png",
		"daimon_ 75.png",
		"daimon_ 64.png",
		"daimon_ 97.png",
		"daimon_ 65.png",
		"daimon_ 77.png",
		"daimon_ 120.png",
		"daimon_ 63.png",
	},

	["鞋子左"] = {
		"daimon_ 120.png",
		"daimon_ 117.png",
		"daimon_ 119.png",
		"daimon_ 76.png",
		"daimon_ 79.png",
		"daimon_ 78.png",
		"daimon_ 67.png",
		"daimon_ 97.png",
	},

	["左脚下"] = {
		"daimon_ 79.png",
		"daimon_ 78.png",
		"daimon_ 76.png",
		"daimon_ 67.png",
		"daimon_ 66.png",
		"daimon_ 122.png",
		"daimon_ 96.png",
		"daimon_ 97.png",
	},

	["右脚上"] = {
		"daimon_ 64.png",
		"daimon_ 63.png",
		"daimon_ 65.png",
		"daimon_ 76.png",
		"daimon_ 67.png",
	},

	["左手下2"] = {
		"daimon_ 73.png",
		"daimon_ 120.png",
	},

	["左手上2"] = {
		"daimon_ 83.png",
		"daimon_ 70.png",
		"daimon_ 84.png",
	},

	["鞋子右"] = {
		"daimon_ 117.png",
		"daimon_ 119.png",
		"daimon_ 116.png",
		"daimon_ 67.png",
		"daimon_ 120.png",
		"daimon_ 66.png",
		"daimon_ 96.png",
	},

	["右脚下"] = {
		"daimon_ 67.png",
		"daimon_ 66.png",
		"daimon_ 96.png",
		"daimon_ 79.png",
		"daimon_ 78.png",
		"daimon_ 117.png",
	},

	["右手下"] = {
		"daimon_ 71.png",
		"daimon_ 73.png",
		"daimon_ 70.png",
		"daimon_ 72.png",
		"daimon_ 85.png",
		"daimon_ 68.png",
		"daimon_ 120.png",
		"daimon_ 91.png",
	},

	["右手上"] = {
		"daimon_ 69.png",
		"daimon_ 68.png",
		"daimon_ 70.png",
	},

	["头带结"] = {
		"daimon_ 107.png",
		"daimon_ 102.png",
		"daimon_ 98.png",
	},

	["头带左上"] = {
		"daimon_ 112.png",
		"daimon_ 101.png",
		"daimon_ 98.png",
		"daimon_ 99.png",
	},

	["头带左下"] = {
		"daimon_ 114.png",
		"daimon_ 102.png",
		"daimon_ 101.png",
		"daimon_ 100.png",
	},

	["头带右上"] = {
		"daimon_ 109.png",
		"daimon_ 99.png",
		"daimon_ 100.png",
		"daimon_ 101.png",
	},

	["头带右下"] = {
		"daimon_ 110.png",
		"daimon_ 100.png",
		"daimon_ 99.png",
		"daimon_ 102.png",
	},
}

function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/daimon/DaimonSkin.plist")
	Hero.setSkin(self,boneRes)
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

function getFlyName(self)
	--return nil,"霸王翔吼拳-波飞行","霸王翔吼拳-波击中"
end

function update(self,event)
	local delay = event.delay
	if self.curState.name == "rush" then
		local mx = self:getPositionX()
		local ex = self.enemy:getPositionX()
		local dis = (ex - mx) * self:getDirection()
		--if (self.daimon_rushId == 2214 and  dis > 120) or (self.daimon_rushId == 2229 and self:getEnemyDis() < 140)  then
		if self:getEnemyDis() < 150 then
			self:play(self.daimon_rushId,true,true)
			self.daimon_rushId = nil
			self.canRun = nil
		end
	end
end

function startAssist(self)
	Hero.startAssistAtk(self)
end

--[[
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
