-- 矢真吹吾 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Shingo", _M)
Helper.initHeroConfig(require("src/config/hero/ShingoConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

function init(self)
	Hero.init(self)
	self:addEventListener(Event.PlayEnd,onPlayEnd,self)
end

function onPlayEnd(self,event)
	if not event.isFinish then
		return
	end
	if event.stateName == 2010 then		--外式·驱凤麟bv_1
		self:play("rush",true)
		self.shingo_rushId = 2029		--外式·驱凤麟bv_2
		self.canRun = true
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 2010 then
		self.shingo_rushPlayId = arg.playId
		self:onPlayEnd(arg)
		return
	elseif arg.stateName == 2029 then
		arg.playId = self.shingo_rushPlayId
		self.shingo_rushPlayId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end

function update(self,event)
	local delay = event.delay
	if self.curState.name == "rush" then
		if self:getEnemyDis() < 150 then
			self:play(self.shingo_rushId,true,true)
			self.shingo_rushId = nil
			self.canRun = nil
		end
	end
end

local soundTable = {
	["succeed"] = "shingo/Shengli.mp3",
	["start"] = "shingo/Kaichang.mp3",
	["dead"] = "shingo/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "shingo/Shouji1.mp3"
	else
		return "shingo/Shouji2.mp3"
	end
end
local boneRes = {
	["另补层上4"] = {
		"shingo__0051.png",
		"shingo__0023.png",
	},

	["另补层上5"] = {
		"shingo__0000.png",
		"shingo__0023.png",
		"shingo__0012.png",
		"shingo__0045.png",
		"shingo__0003.png",
		"shingo__0035.png",
	},

	["另补层上6"] = {
		"shingo__0000.png",
		"shingo__0051.png",
		"shingo__0043.png",
		"shingo__0047.png",
		"shingo__0022.png",
		"shingo__0046.png",
	},

	["另补层上7"] = {
		"shingo__0046.png",
		"shingo__0013.png",
		"shingo__0036.png",
		"shingo__0041.png",
		"shingo__0042.png",
		"shingo__0006.png",
		"shingo__0044.png",
		"shingo__0030.png",
		"shingo__0000.png",
		"shingo__0022.png",
		"shingo__0003.png",
	},

	["另补层上8"] = {
		"shingo__0013.png",
		"shingo__0046.png",
		"shingo__0026.png",
		"shingo__0023.png",
		"shingo__0041.png",
		"shingo__0030.png",
		"shingo__0036.png",
		"shingo__0043.png",
		"shingo__0040.png",
		"shingo__0035.png",
		"shingo__0045.png",
		"shingo__0012.png",
		"shingo__0051.png",
		"shingo__0033.png",
		"shingo__0047.png",
	},

	["另补层上9"] = {
		"shingo__0011.png",
		"shingo__0047.png",
		"shingo__0045.png",
		"shingo__0010.png",
		"shingo__0036.png",
		"shingo__0003.png",
		"shingo__0026.png",
		"shingo__0030.png",
		"shingo__0042.png",
		"shingo__0029.png",
		"shingo__0037.png",
		"shingo__0043.png",
		"shingo__0035.png",
		"shingo__0023.png",
		"shingo__0051.png",
		"shingo__0033.png",
		"shingo__0039.png",
		"shingo__0022.png",
	},

	["另补层上10"] = {
		"shingo__0023.png",
		"shingo__0022.png",
		"shingo__0030.png",
		"shingo__0035.png",
		"shingo__0039.png",
		"shingo__0037.png",
		"shingo__0026.png",
		"shingo__0042.png",
		"shingo__0029.png",
		"shingo__0041.png",
		"shingo__0036.png",
		"shingo__0011.png",
		"shingo__0002.png",
		"shingo__0003.png",
		"shingo__0028.png",
		"shingo__0000.png",
		"shingo__0010.png",
		"shingo__0043.png",
		"shingo__0013.png",
	},

	["另补层上11"] = {
		"shingo__0023.png",
		"shingo__0035.png",
		"shingo__0002.png",
		"shingo__0003.png",
		"shingo__0022.png",
		"shingo__0045.png",
		"shingo__0037.png",
		"shingo__0047.png",
		"shingo__0042.png",
		"shingo__0043.png",
		"shingo__0010.png",
		"shingo__0029.png",
		"shingo__0036.png",
		"shingo__0040.png",
		"shingo__0049.png",
		"shingo__0019.png",
		"shingo__0011.png",
		"shingo__0030.png",
	},

	["头_侧"] = {
		"shingo__0034.png",
		"shingo__0053.png",
		"shingo__0001.png",
		"shingo__0054.png",
		"shingo__0021.png",
		"shingo__0010.png",
	},

	["另补层上12"] = {
		"shingo__0013.png",
		"shingo__0034.png",
		"shingo__0001.png",
		"shingo__0046.png",
	},

	["另补层上13"] = {
		"shingo__0022.png",
		"shingo__0045.png",
		"shingo__0047.png",
		"shingo__0033.png",
	},

	["另补层上14"] = {
		"shingo__0046.png",
		"shingo__0051.png",
		"shingo__0043.png",
		"shingo__0013.png",
		"shingo__0026.png",
	},

	["另补层上15"] = {
		"shingo__0033.png",
		"shingo__0047.png",
		"shingo__0026.png",
		"shingo__0040.png",
		"shingo__0027.png",
		"shingo__0025.png",
		"shingo__0042.png",
		"shingo__0045.png",
	},

	["左手下_侧"] = {
		"shingo__0035.png",
		"shingo__0023.png",
		"shingo__0012.png",
		"shingo__0036.png",
		"shingo__0003.png",
		"shingo__0030.png",
	},

	["另补层中"] = {
		"shingo__0039.png",
		"shingo__0022.png",
		"shingo__0042.png",
	},

	["右手下_侧"] = {
		"shingo__0036.png",
		"shingo__0012.png",
		"shingo__0030.png",
		"shingo__0035.png",
		"shingo__0003.png",
		"shingo__0023.png",
	},

	["另补层中1"] = {
		"shingo__0039.png",
		"shingo__0002.png",
		"shingo__0022.png",
		"shingo__0037.png",
	},

	["右手上_侧"] = {
		"shingo__0037.png",
		"shingo__0022.png",
		"shingo__0002.png",
		"shingo__0011.png",
		"shingo__0036.png",
		"shingo__0029.png",
		"shingo__0039.png",
	},

	["身_侧"] = {
		"shingo__0038.png",
		"shingo__0004.png",
		"shingo__0024.png",
	},

	["另补层中2"] = {
		"shingo__0042.png",
		"shingo__0008.png",
		"shingo__0040.png",
		"shingo__0037.png",
		"shingo__0022.png",
		"shingo__0005.png",
		"shingo__0011.png",
		"shingo__0034.png",
		"shingo__0021.png",
		"shingo__0001.png",
	},

	["另补层中3"] = {
		"shingo__0039.png",
		"shingo__0042.png",
		"shingo__0040.png",
		"shingo__0043.png",
		"shingo__0026.png",
		"shingo__0041.png",
		"shingo__0006.png",
		"shingo__0009.png",
	},

	["另补层中4"] = {
		"shingo__0043.png",
		"shingo__0041.png",
		"shingo__0010.png",
		"shingo__0021.png",
	},

	["左手上_侧"] = {
		"shingo__0039.png",
		"shingo__0002.png",
		"shingo__0011.png",
		"shingo__0040.png",
		"shingo__0037.png",
		"shingo__0022.png",
		"shingo__0029.png",
		"shingo__0012.png",
	},

	["左脚上_侧"] = {
		"shingo__0040.png",
		"shingo__0042.png",
		"shingo__0025.png",
		"shingo__0005.png",
		"shingo__0027.png",
		"shingo__0008.png",
		"shingo__0022.png",
	},

	["左脚下_侧"] = {
		"shingo__0041.png",
		"shingo__0043.png",
		"shingo__0026.png",
		"shingo__0028.png",
		"shingo__0023.png",
		"shingo__0009.png",
		"shingo__0006.png",
		"shingo__0033.png",
	},

	["右脚上_侧"] = {
		"shingo__0042.png",
		"shingo__0040.png",
		"shingo__0005.png",
		"shingo__0027.png",
		"shingo__0008.png",
		"shingo__0025.png",
	},

	["右脚下_侧"] = {
		"shingo__0043.png",
		"shingo__0041.png",
		"shingo__0028.png",
		"shingo__0040.png",
		"shingo__0011.png",
		"shingo__0009.png",
		"shingo__0026.png",
		"shingo__0042.png",
	},

	["另补层中5"] = {
		"shingo__0040.png",
		"shingo__0023.png",
		"shingo__0048.png",
		"shingo__0012.png",
		"shingo__0002.png",
		"shingo__0022.png",
		"shingo__0037.png",
		"shingo__0006.png",
		"shingo__0041.png",
		"shingo__0043.png",
		"shingo__0025.png",
		"shingo__0042.png",
		"shingo__0008.png",
		"shingo__0027.png",
	},

	["另补层中6"] = {
		"shingo__0041.png",
		"shingo__0039.png",
		"shingo__0012.png",
		"shingo__0011.png",
		"shingo__0010.png",
		"shingo__0048.png",
		"shingo__0049.png",
		"shingo__0050.png",
		"shingo__0022.png",
		"shingo__0023.png",
		"shingo__0037.png",
		"shingo__0040.png",
		"shingo__0043.png",
		"shingo__0005.png",
		"shingo__0042.png",
		"shingo__0025.png",
		"shingo__0008.png",
		"shingo__0028.png",
	},

	["另补层中7"] = {
		"shingo__0050.png",
		"shingo__0049.png",
		"shingo__0010.png",
		"shingo__0030.png",
		"shingo__0048.png",
		"shingo__0039.png",
		"shingo__0037.png",
		"shingo__0011.png",
		"shingo__0051.png",
		"shingo__0033.png",
		"shingo__0022.png",
		"shingo__0034.png",
		"shingo__0043.png",
		"shingo__0005.png",
		"shingo__0040.png",
	},

	["另补层中8"] = {
		"shingo__0039.png",
		"shingo__0037.png",
		"shingo__0011.png",
		"shingo__0006.png",
		"shingo__0043.png",
		"shingo__0009.png",
		"shingo__0022.png",
		"shingo__0051.png",
		"shingo__0012.png",
		"shingo__0003.png",
		"shingo__0030.png",
		"shingo__0046.png",
		"shingo__0023.png",
		"shingo__0036.png",
	},

	["另补层中9"] = {
		"shingo__0042.png",
		"shingo__0010.png",
		"shingo__0043.png",
		"shingo__0022.png",
		"shingo__0039.png",
		"shingo__0030.png",
		"shingo__0040.png",
		"shingo__0037.png",
	},

	["另补层中10"] = {
		"shingo__0043.png",
		"shingo__0040.png",
	},

	["带子左上_侧"] = {
		"shingo__0013.png",
		"shingo__0044.png",
		"shingo__0046.png",
		"shingo__0045.png",
	},

	["带子左下_侧"] = {
		"shingo__0046.png",
		"shingo__0014.png",
		"shingo__0045.png",
		"shingo__0047.png",
		"shingo__0030.png",
		"shingo__0023.png",
		"shingo__0040.png",
		"shingo__0042.png",
		"shingo__0003.png",
	},

	["带子右上_侧"] = {
		"shingo__0045.png",
		"shingo__0015.png",
		"shingo__0046.png",
		"shingo__0013.png",
		"shingo__0003.png",
		"shingo__0047.png",
	},

	["带子右下_侧"] = {
		"shingo__0047.png",
		"shingo__0020.png",
		"shingo__0045.png",
		"shingo__0021.png",
		"shingo__0012.png",
		"shingo__0050.png",
		"shingo__0051.png",
	},

	["另补层中14"] = {
		"shingo__0037.png",
	},

	["另补层中15"] = {
		"shingo__0030.png",
	},

	["鞋子右_侧"] = {
		"shingo__0049.png",
		"shingo__0048.png",
		"shingo__0010.png",
		"shingo__0050.png",
		"shingo__0031.png",
		"shingo__0007.png",
		"shingo__0051.png",
		"shingo__0032.png",
		"shingo__0033.png",
	},

	["鞋子左_侧"] = {
		"shingo__0048.png",
		"shingo__0049.png",
		"shingo__0050.png",
		"shingo__0010.png",
		"shingo__0007.png",
		"shingo__0031.png",
		"shingo__0051.png",
		"shingo__0032.png",
		"shingo__0033.png",
	},

	["另补层下1"] = {
		"shingo__0030.png",
		"shingo__0034.png",
		"shingo__0040.png",
		"shingo__0041.png",
		"shingo__0013.png",
		"shingo__0046.png",
		"shingo__0022.png",
		"shingo__0002.png",
		"shingo__0012.png",
		"shingo__0055.png",
		"shingo__0056.png",
		"shingo__0003.png",
		"shingo__0023.png",
		"zhenwuhuangyin.png",
	},

	["另补层下2"] = {
		"shingo__0011.png",
		"shingo__0037.png",
		"shingo__0041.png",
		"shingo__0002.png",
		"shingo__0022.png",
		"shingo__0003.png",
		"shingo__0012.png",
		"shingo__0030.png",
		"shingo__0039.png",
		"shingo__0055.png",
		"shingo__0057.png",
		"shingo__0058.png",
		"shingo__0060.png",
		"shingo__0061.png",
		"shingo__0021.png",
		"zhenwuhuangyin.png",
	},

	["另补层下3"] = {
		"shingo__0030.png",
		"shingo__0036.png",
		"shingo__0012.png",
		"shingo__0010.png",
		"shingo__0031.png",
		"shingo__0003.png",
		"shingo__0022.png",
		"shingo__0055.png",
		"shingo__0056.png",
		"shingo__0058.png",
		"shingo__0059.png",
	},

	["另补层下4"] = {
		"shingo__0023.png",
		"shingo__0030.png",
		"shingo__0035.png",
	},

	["另补层下5"] = {
		"shingo__0003.png",
		"shingo__0039.png",
	},

}

function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/shingo/ShingoSkin.plist")
	Hero.setSkin(self,boneRes)
end
local hitSpecialCallback = {
	[2029] = Hero.hitOnce
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
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
