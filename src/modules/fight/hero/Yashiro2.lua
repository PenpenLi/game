-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Yashiro2", _M)
Helper.initHeroConfig(require("src/config/hero/Yashiro2Config").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "yashiro2/Shengli.mp3",
	["dead"] = "yashiro2/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "yashiro2/Shouji1.mp3"
	else
		return "yashiro2/Shouji2.mp3"
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
	if event.stateName == 4525 then		--_旋转的火花1
		self:play("rush",true)
		self.yashiro2_rushId = 4527		--_2
		self.canRun = true
	elseif event.stateName == 4526 then	--威武军刀
		self:play("rush",true)
		self.yashiro2_rushId = 4528		--_2
		self.canRun = true
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 4525 or arg.stateName == 4526 then
		self.yashiro2_rushPlayId = arg.playId
		self:onPlayEnd(arg)
		return
	elseif arg.stateName == 4527 or arg.stateName == 4528 then
		arg.playId = self.yashiro2_rushPlayId
		self.yashiro2_rushPlayId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end

function setTarget(self)
	self:addArmatureFrame("res/armature/yashiro2/Yashiro2Target.ExportJson",0)
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

local boneRes = {
	["另补上2"] = {
		"yashiro2_0024.png",
		"yashiro2_0023.png",
		"yashiro2_0032.png",
		"yashiro2_0025.png",
		"yashiro2_0040.png",
		"yashiro2_0002.png",
		"yashiro2_0013.png",
		"yashiro2_0001.png",
		"yashiro2_tx03.png",
		"yashiro2_0014.png",
		"yashiro2_0031.png",
		"yashiro2_0027.png",
		"yashiro2_tx46_1.png",
	},

	["另补上1"] = {
		"yashiro2_0024.png",
		"yashiro2_0002.png",
		"yashiro2_0014.png",
		"yashiro2_0011.png",
		"yashiro2_0023.png",
		"yashiro2_0037.png",
		"yashiro2_0018.png",
		"yashiro2_0027.png",
		"yashiro2_0016.png",
		"yashiro2_0025.png",
		"yashiro2_0028.png",
		"yashiro2_0040.png",
		"yashiro2_0013.png",
	},

	["另补上"] = {
		"yashiro2_0027.png",
		"yashiro2_0028.png",
		"yashiro2_0034.png",
		"yashiro2_0025.png",
		"yashiro2_0011.png",
		"yashiro2_0013.png",
		"yashiro2_0001.png",
		"yashiro2_0024.png",
		"yashiro2_0014.png",
		"yashiro2_0022.png",
		"yashiro2_0040.png",
		"yashiro2_0018.png",
		"yashiro2_0031.png",
		"yashiro2_0002.png",
		"yashiro2_0023.png",
	},

	["左手下"] = {
		"yashiro2_0024.png",
		"yashiro2_0013.png",
		"yashiro2_0011.png",
		"yashiro2_tx02.png",
		"yashiro2_0014.png",
		"yashiro2_0023.png",
		"yashiro2_0002.png",
		"yashiro2_0025.png",
		"yashiro2_0028.png",
	},

	["头"] = {
		"yashiro2_0026.png",
		"yashiro2_0042.png",
		"yashiro2_0012.png",
		"yashiro2_0000.png",
		"yashiro2_0043.png",
	},

	["右手下"] = {
		"yashiro2_0025.png",
		"yashiro2_0024.png",
		"yashiro2_0011.png",
		"yashiro2_0002.png",
		"yashiro2_0023.png",
		"yashiro2_0014.png",
		"yashiro2_0028.png",
		"yashiro2_0027.png",
		"yashiro2_tx02.png",
	},

	["右手上"] = {
		"yashiro2_0028.png",
		"yashiro2_0027.png",
		"yashiro2_0001.png",
		"yashiro2_0013.png",
		"yashiro2_0025.png",
		"yashiro2_0024.png",
	},

	["另补中3"] = {
		"yashiro2_0028.png",
		"yashiro2_0016.png",
		"yashiro2_0027.png",
		"yashiro2_0023.png",
		"yashiro2_0025.png",
		"yashiro2_0002.png",
	},

	["身"] = {
		"yashiro2_0029.png",
		"yashiro2_0003.png",
		"yashiro2_0015.png",
		"yashiro2_0014.png",
	},

	["另补中2"] = {
		"yashiro2_0030.png",
		"yashiro2_0034.png",
		"yashiro2_0002.png",
		"yashiro2_0023.png",
		"yashiro2_0028.png",
		"yashiro2_0008.png",
		"yashiro2_0004.png",
		"yashiro2_0013.png",
		"yashiro2_0040.png",
		"yashiro2_0016.png",
		"yashiro2_0031.png",
		"yashiro2_0012.png",
		"yashiro2_0032.png",
		"yashiro2_0017.png",
		"yashiro2_0027.png",
		"yashiro2_0020.png",
		"yashiro2_0006.png",
	},

	["另补中1"] = {
		"yashiro2_0023.png",
		"yashiro2_0001.png",
		"yashiro2_0030.png",
		"yashiro2_0028.png",
		"yashiro2_0008.png",
		"yashiro2_0032.png",
		"yashiro2_0034.png",
		"yashiro2_0016.png",
		"yashiro2_0003.png",
		"yashiro2_0011.png",
		"yashiro2_0012.png",
		"yashiro2_0014.png",
		"yashiro2_0004.png",
		"yashiro2_0031.png",
		"yashiro2_0036.png",
		"yashiro2_0017.png",
	},

	["另补中"] = {
		"yashiro2_0028.png",
		"yashiro2_0017.png",
		"yashiro2_0023.png",
		"yashiro2_0011.png",
		"yashiro2_0038.png",
		"yashiro2_0040.png",
		"yashiro2_0025.png",
		"yashiro2_0039.png",
		"yashiro2_0035.png",
		"yashiro2_0022.png",
		"yashiro2_0030.png",
		"yashiro2_0010.png",
		"yashiro2_0013.png",
		"yashiro2_0031.png",
		"yashiro2_0027.png",
		"yashiro2_0004.png",
		"yashiro2_0032.png",
		"yashiro2_0034.png",
		"yashiro2_0018.png",
		"yashiro2_0024.png",
		"yashiro2_0012.png",
	},

	["左手上"] = {
		"yashiro2_0027.png",
		"yashiro2_0018.png",
		"yashiro2_0030.png",
		"yashiro2_0032.png",
		"yashiro2_0023.png",
		"yashiro2_0022.png",
		"yashiro2_0028.png",
	},

	["右脚上"] = {
		"yashiro2_0030.png",
		"yashiro2_0004.png",
		"yashiro2_0005.png",
		"yashiro2_0031.png",
		"yashiro2_0017.png",
		"yashiro2_0016.png",
	},

	["右脚下"] = {
		"yashiro2_0032.png",
		"yashiro2_0034.png",
		"yashiro2_0018.png",
		"yashiro2_0008.png",
		"yashiro2_0006.png",
		"yashiro2_0020.png",
	},

	["鞋子右"] = {
		"yashiro2_0033.png",
		"yashiro2_0038.png",
		"yashiro2_0035.png",
		"yashiro2_0007.png",
		"yashiro2_0039.png",
		"yashiro2_0009.png",
		"yashiro2_0019.png",
		"yashiro2_0021.png",
		"yashiro2_0040.png",
		"yashiro2_0036.png",
	},

	["左脚上"] = {
		"yashiro2_0031.png",
		"yashiro2_0032.png",
		"yashiro2_0030.png",
		"yashiro2_0023.png",
		"yashiro2_0016.png",
		"yashiro2_0004.png",
		"yashiro2_0017.png",
		"yashiro2_0034.png",
		"yashiro2_0014.png",
		"yashiro2_0005.png",
	},

	["左脚下"] = {
		"yashiro2_0034.png",
		"yashiro2_0030.png",
		"yashiro2_0032.png",
		"yashiro2_0006.png",
		"yashiro2_0018.png",
		"yashiro2_0009.png",
		"yashiro2_0016.png",
		"yashiro2_0002.png",
		"yashiro2_0023.png",
		"yashiro2_0008.png",
	},

	["鞋子左"] = {
		"yashiro2_0035.png",
		"yashiro2_0038.png",
		"yashiro2_0007.png",
		"yashiro2_0009.png",
		"yashiro2_0032.png",
		"yashiro2_0018.png",
		"yashiro2_0033.png",
		"yashiro2_0039.png",
		"yashiro2_0036.png",
		"yashiro2_0021.png",
		"yashiro2_0016.png",
		"yashiro2_0019.png",
		"yashiro2_0040.png",
	},

	["另补下"] = {
		"yashiro2_0032.png",
		"yashiro2_0028.png",
		"yashiro2_0007.png",
		"yashiro2_0039.png",
		"yashiro2_0030.png",
		"yashiro2_0003.png",
		"yashiro2_0022.png",
		"yashiro2_0010.png",
		"yashiro2_0038.png",
		"yashiro2_0004.png",
		"yashiro2_0025.png",
		"yashiro2_0024.png",
		"yashiro2_0023.png",
		"yashiro2_0014.png",
		"yashiro2_0018.png",
		"yashiro2_0002.png",
		"yashiro2_0016.png",
		"yashiro2_0012.png",
		"yashiro2_0027.png",
		"yashiro2_0005.png",
	},

	["另补下1"] = {
		"yashiro2_0007.png",
		"yashiro2_0028.png",
		"yashiro2_0011.png",
		"yashiro2_0023.png",
		"yashiro2_0027.png",
		"yashiro2_0034.png",
		"yashiro2_0013.png",
		"yashiro2_0025.png",
		"yashiro2_0010.png",
		"yashiro2_0022.png",
		"yashiro2_0018.png",
		"yashiro2_0002.png",
		"yashiro2_0016.png",
		"yashiro2_0024.png",
		"yashiro2_0014.png",
		"yashiro2_0032.png",
	},

	["另补下2"] = {
		"yashiro2_0023.png",
		"yashiro2_0010.png",
		"yashiro2_0022.png",
		"yashiro2_0024.png",
		"yashiro2_0002.png",
		"yashiro2_0035.png",
		"yashiro2_0014.png",
		"yashiro2_0028.png",
		"yashiro2_0011.png",
		"yashiro2_0007.png",
		"yashiro2_0016.png",
	},

}



function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/yashiro2/Yashiro2Skin.plist")
	Hero.setSkin(self,boneRes)
end


function update(self,event)
	local delay = event.delay
	if self.curState.name == "rush" then
		if self:getEnemyDis() < 150 then
			--test
			--self:setCurSkill(self:getPowerSkill())
			self:play(self.yashiro2_rushId,true,true)
			self.yashiro2_rushId = nil
			self.canRun = nil
		end
	end
end
