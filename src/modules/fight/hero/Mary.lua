-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Mary", _M)
Helper.initHeroConfig(require("src/config/hero/MaryConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "mary/Shengli.mp3",
	["start"] = "mary/Kaichang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "mary/Shouji1.mp3"
	else
		return "mary/Shouji2.mp3"
	end
end

function init(self)
	Hero.init(self)
	self:addEventListener(Event.PlayEnd,onPlayEnd,self)
end

function setTarget(self)
	self:addArmatureFrame("res/armature/mary/MaryTarget.ExportJson",0)
end

function onPlayEnd(self,event)
	if not event.isFinish then
		return
	end
	if event.stateName == 3209 then		--_1
		self:play("rush",true)
		self.mary_rushId = 3225		--_2
		self.canRun = true
	elseif event.stateName == 3210 then
		self:play("rush",true)
		self.mary_rushId = 3226		--_2
		self.canRun = true
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 3209 or arg.stateName == 3210 then
		self.mary_rushPlayId = arg.playId
		self:onPlayEnd(arg)
		return
	elseif arg.stateName == 3225 or arg.stateName == 3226 then
		arg.playId = self.mary_rushPlayId
		self.mary_rushPlayId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end

local hitSpecialCallback = {
	[3213] = Hero.hitOnce
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
		if self:getEnemyDis() < 140 then
			--test
			--self:setCurSkill(self:getPowerSkill())
			self:play(self.mary_rushId,true,true)
			self.mary_rushId = nil
			self.canRun = nil
		end
	end
end

local boneRes = {

	["另补上3"] = {
		"mary_0030.png",
		"mary_0026.png",
		"mary_0016.png",
		"mary_0028.png",
		"mary_0045.png",
		"mary_0002.png",
		"mary_0015.png",
		"mary_0012.png",
		"mary_0042.png",
		"mary_0029.png",
		"mary_0001.png",
	},

	["另补上2"] = {
		"mary_0030.png",
		"mary_0029.png",
		"mary_0002.png",
		"mary_0016.png",
		"mary_0026.png",
		"mary_0001.png",
		"mary_0012.png",
		"mary_0015.png",
		"mary_0042.png",
		"mary_0023.png",
		"mary_0008.png",
		"mary_0009.png",
		"mary_0020.png",
		"mary_0019.png",
		"mary_0034.png",
	},

	["另补上1"] = {
		"mary_0015.png",
		"mary_0002.png",
		"mary_0026.png",
		"mary_0001.png",
		"mary_0016.png",
		"mary_0012.png",
		"mary_0020.png",
		"mary_0036.png",
		"mary_0008.png",
		"mary_0030.png",
		"mary_0042.png",
		"mary_0034.png",
		"mary_0010.png",
		"mary_0009.png",
		"mary_0037.png",
		"mary_0013.png",
	},

	["另补上"] = {
		"mary_0012.png",
		"mary_0002.png",
		"mary_0015.png",
		"mary_0029.png",
		"mary_0008.png",
		"mary_0016.png",
		"mary_0026.png",
		"mary_0036.png",
		"mary_0023.png",
		"mary_0001.png",
		"mary_0010.png",
	},

	["头_侧"] = {
		"mary_0028.png",
		"mary_0045.png",
		"mary_0014.png",
		"mary_0000.png",
		"mary_0044.png",
	},

	["另补中3"] = {
		"mary_0038.png",
		"mary_0015.png",
		"mary_0026.png",
	},

	["另补中2"] = {
		"mary_0039.png",
	},

	["另补中1"] = {
		"mary_0001.png",
		"mary_0027.png",
		"mary_0015.png",
	},

	["左手下_侧"] = {
		"mary_0029.png",
		"mary_0002.png",
		"mary_0012.png",
		"mary_0016.png",
		"mary_0030.png",
		"mary_0026.png",
	},

	["右手下_侧"] = {
		"mary_0030.png",
		"mary_0016.png",
		"mary_0012.png",
		"mary_0026.png",
		"mary_0002.png",
		"mary_0029.png",
	},

	["右手上_侧"] = {
		"mary_0031.png",
		"mary_0001.png",
		"mary_0015.png",
		"mary_0026.png",
		"mary_0002.png",
	},

	["腰带_侧"] = {
		"mary_0032.png",
		"mary_0003.png",
		"mary_0017.png",
	},

	["另补中4"] = {
		"mary_0001.png",
		"mary_0015.png",
		"mary_0002.png",
		"mary_0027.png",
		"mary_0019.png",
		"mary_0030.png",
		"mary_0029.png",
		"mary_0034.png",
	},

	["身_侧"] = {
		"mary_0033.png",
		"mary_0004.png",
		"mary_0018.png",
	},

	["另补中5"] = {
		"mary_0038.png",
		"mary_0008.png",
		"mary_0007.png",
		"mary_0037.png",
		"mary_0026.png",
		"mary_0031.png",
		"mary_0012.png",
		"mary_0029.png",
		"mary_0015.png",
		"mary_0001.png",
		"mary_0034.png",
		"mary_0042.png",
		"mary_0028.png",
		"mary_0025.png",
		"mary_0014.png",
		"mary_0006.png",
		"mary_0000.png",
		"mary_0019.png",
		"mary_0005.png",
		"mary_0016.png",
	},

	["另补中6"] = {
		"mary_0039.png",
		"mary_0009.png",
		"mary_0025.png",
		"mary_0012.png",
		"mary_0016.png",
		"mary_0026.png",
		"mary_0031.png",
		"mary_0001.png",
		"mary_0034.png",
		"mary_0002.png",
		"mary_0015.png",
		"mary_0036.png",
		"mary_0008.png",
		"mary_0022.png",
		"mary_0038.png",
		"mary_0019.png",
		"mary_0000.png",
		"mary_0020.png",
	},

	["另补中7"] = {
		"mary_0027.png",
		"mary_0037.png",
		"mary_0010.png",
		"mary_0040.png",
		"mary_0033.png",
		"mary_0015.png",
		"mary_0012.png",
		"mary_0023.png",
		"mary_0009.png",
		"mary_0007.png",
		"mary_0038.png",
		"mary_0035.png",
		"mary_0029.png",
	},

	["左手上_侧"] = {
		"mary_0034.png",
		"mary_0008.png",
		"mary_0015.png",
		"mary_0025.png",
		"mary_0011.png",
		"mary_0001.png",
	},

	["左脚上_侧"] = {
		"mary_0038.png",
		"mary_0008.png",
		"mary_0019.png",
		"mary_0022.png",
		"mary_0035.png",
		"mary_0005.png",
	},

	["左脚下_侧"] = {
		"mary_0039.png",
		"mary_0036.png",
		"mary_0023.png",
		"mary_0009.png",
		"mary_0008.png",
		"mary_0006.png",
		"mary_0020.png",
	},

	["右脚上_侧"] = {
		"mary_0035.png",
		"mary_0005.png",
		"mary_0019.png",
		"mary_0008.png",
		"mary_0022.png",
		"mary_0038.png",
	},

	["右脚下_侧"] = {
		"mary_0036.png",
		"mary_0009.png",
		"mary_0006.png",
		"mary_0035.png",
		"mary_0020.png",
		"mary_0039.png",
		"mary_0023.png",
		"mary_0037.png",
	},

	["鞋子右_侧"] = {
		"mary_0037.png",
		"mary_0027.png",
		"mary_0042.png",
		"mary_0021.png",
		"mary_0024.png",
		"mary_0007.png",
		"mary_0040.png",
		"mary_0041.png",
		"mary_0035.png",
		"mary_0010.png",
	},

	["鞋子左_侧"] = {
		"mary_0040.png",
		"mary_0027.png",
		"mary_0010.png",
		"mary_0042.png",
		"mary_0041.png",
		"mary_0037.png",
		"mary_0007.png",
		"mary_0021.png",
		"mary_0024.png",
	},

	["另补下"] = {
		"mary_0029.png",
		"mary_0026.png",
		"mary_0015.png",
		"mary_0027.png",
		"mary_0034.png",
		"mary_0025.png",
		"mary_0001.png",
		"mary_0002.png",
		"mary_0022.png",
		"mary_0005.png",
		"mary_0038.png",
		"mary_0028.png",
		"mary_0039.png",
		"mary_0016.png",
		"mary_0021.png",
		"mary_0040.png",
		"mary_0007.png",
		"mary_0041.png",
		"mary_0035.png",
		"mary_0030.png",
		"mary_0031.png",
		"mary_0037.png",
		"mary_0011.png",
		"mary_0020.png",
		"mary_0036.png",
		"mary_0033.png",
		"mary_0004.png",
		"mary_0008.png",
		"mary_0019.png",
		"mary_0010.png",
		"mary_0032.png",
		"mary_0018.png",
	},

	["另补下1"] = {
		"mary_0011.png",
		"mary_0025.png",
		"mary_0026.png",
		"mary_0030.png",
		"mary_0016.png",
		"mary_0006.png",
		"mary_0036.png",
		"mary_0023.png",
		"mary_0009.png",
		"mary_0002.png",
		"mary_0012.png",
		"mary_0020.png",
		"mary_0015.png",
		"mary_0027.png",
		"mary_0035.png",
		"mary_0042.png",
		"mary_0029.png",
		"mary_0001.png",
		"mary_0004.png",
		"mary_0039.png",
	},

	["另补下2"] = {
		"mary_0015.png",
		"mary_0001.png",
		"mary_0027.png",
		"mary_0014.png",
		"mary_0037.png",
		"mary_0040.png",
		"mary_0010.png",
		"mary_0021.png",
		"mary_0002.png",
		"mary_0031.png",
		"mary_0026.png",
		"mary_0012.png",
		"mary_0030.png",
	},


	["effect3"] = {
		"mary_0200059.png",
		"mary_0200002.png",
		"mary_0200006.png",
		"mary_0200010.png",
		"mary_0200065.png",
		"mary_0200018.png",
		"mary_0200022.png",
		"mary_0200046.png",
		"mary_0200048.png",
		"mary_0200052.png",
		"mary_0023.png",
	},


}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/mary/MarySkin.plist")
	Hero.setSkin(self,boneRes)
end
