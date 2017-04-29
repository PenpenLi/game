-- choi 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Choi", _M)
Helper.initHeroConfig(require("src/config/hero/ChoiConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "choi/Shengli.mp3",
	["start"] = "choi/Kaichang.mp3",
	["dead"] = "choi/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "choi/Shouji1.mp3"
	else
		return "choi/Shouji2.mp3"
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
	if event.stateName == 4109 then		--
		self:play("rush",true)
		self.choi_rushId = 4110--
		self.canRun = true
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 4109 then
		self.choi_rushPlayId = arg.playId
		self:onPlayEnd(arg)
		return
	elseif arg.stateName == 4110 then
		arg.playId = self.choi_rushPlayId
		self.choi_rushPlayId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end

local boneRes = {
	["另补上2"] = {
		"choi_038.png",
		"choi_051.png",
		"choi_002.png",
		"choi_001.png",
		"choi_039.png",
		"choi_023.png",
		"choi_016.png",
		"choi_030.png",
		"choi_040.png",
		"choi_046.png",
		"choi_027.png",
		"choi_031.png",
	},

	["另补上3"] = {
		"choi_019.png",
		"choi_018.png",
		"choi_039.png",
		"choi_011.png",
		"choi_040.png",
		"choi_046.png",
		"choi_032.png",
		"choi_021.png",
		"choi_051.png",
		"choi_043.png",
		"choi_014.png",
		"choi_016.png",
		"choi_027.png",
		"choi_002.png",
	},

	["另补上4"] = {
		"choi_056.png",
		"choi_001.png",
		"choi_042.png",
		"choi_019.png",
		"choi_052.png",
		"choi_012.png",
		"choi_049.png",
		"choi_038.png",
		"choi_045.png",
		"choi_031.png",
		"choi_024.png",
		"choi_040.png",
		"choi_016.png",
		"choi_027.png",
		"choi_010.png",
		"choi_051.png",
	},

	["另补上5"] = {
		"choi_001.png",
		"choi_046.png",
		"choi_020.png",
		"choi_038.png",
		"choi_010.png",
		"choi_016.png",
		"choi_027.png",
		"choi_057.png",
	},

	["左手下"] = {
		"choi_001.png",
		"choi_016.png",
		"choi_028.png",
		"choi_032.png",
		"choi_027.png",
		"choi_002.png",
		"choi_046.png",
	},

	["左手上"] = {
		"choi_002.png",
		"choi_026.png",
		"choi_031.png",
	},

	["带子右上"] = {
		"choi_005.png",
		"choi_003.png",
		"choi_034.png",
		"choi_036.png",
	},

	["带子右下"] = {
		"choi_037.png",
		"choi_004.png",
		"choi_035.png",
		"choi_006.png",
	},

	["带子左下"] = {
		"choi_003.png",
		"choi_005.png",
		"choi_036.png",
		"choi_034.png",
	},

	["带子左上"] = {
		"choi_004.png",
		"choi_037.png",
		"choi_043.png",
		"choi_052.png",
		"choi_006.png",
		"choi_035.png",
	},

	["头"] = {
		"choi_007.png",
		"choi_030.png",
		"choi_054.png",
		"choi_055.png",
		"choi_029.png",
		"choi_053.png",
	},

	["另补中1"] = {
		"choi_027.png",
		"choi_031.png",
		"choi_001.png",
		"choi_038.png",
		"choi_016.png",
		"choi_002.png",
		"choi_009.png",
		"choi_051.png",
		"choi_043.png",
		"choi_039.png",
		"choi_040.png",
	},

	["另补中2"] = {
		"choi_002.png",
		"choi_001.png",
		"choi_011.png",
		"choi_025.png",
		"choi_016.png",
		"choi_042.png",
		"choi_031.png",
		"choi_051.png",
		"choi_039.png",
	},

	["身"] = {
		"choi_008.png",
		"choi_033.png",
		"choi_018.png",
	},

	["另补中3"] = {
		"choi_040.png",
		"choi_045.png",
		"choi_052.png",
		"choi_020.png",
		"choi_051.png",
		"choi_009.png",
		"choi_019.png",
		"choi_029.png",
		"choi_002.png",
		"choi_010.png",
		"choi_016.png",
		"choi_039.png",
		"choi_031.png",
		"choi_038.png",
	},

	["另补中4"] = {
		"choi_040.png",
		"choi_052.png",
		"choi_001.png",
		"choi_029.png",
		"choi_051.png",
		"choi_024.png",
		"choi_026.png",
		"choi_013.png",
		"choi_042.png",
		"choi_011.png",
		"choi_015.png",
	},

	["另补中5"] = {
		"choi_052.png",
		"choi_022.png",
		"choi_007.png",
		"choi_014.png",
		"choi_029.png",
		"choi_026.png",
		"choi_040.png",
		"choi_001.png",
	},

	["另补中6"] = {
		"choi_043.png",
		"choi_013.png",
		"choi_055.png",
		"choi_027.png",
		"choi_040.png",
	},

	["衣布前"] = {
		"choi_009.png",
		"choi_038.png",
		"choi_019.png",
	},

	["另补中8"] = {
		"choi_039.png",
		"choi_032.png",
		"choi_027.png",
		"choi_016.png",
		"choi_043.png",
	},

	["左脚上"] = {
		"choi_010.png",
		"choi_039.png",
		"choi_023.png",
		"choi_020.png",
		"choi_042.png",
		"choi_013.png",
	},

	["左脚下"] = {
		"choi_011.png",
		"choi_040.png",
		"choi_052.png",
		"choi_043.png",
		"choi_022.png",
		"choi_014.png",
		"choi_025.png",
	},

	["鞋子左"] = {
		"choi_012.png",
		"choi_052.png",
		"choi_015.png",
		"choi_023.png",
		"choi_048.png",
		"choi_051.png",
		"choi_049.png",
		"choi_050.png",
		"choi_041.png",
		"choi_021.png",
		"choi_044.png",
	},

	["右脚上"] = {
		"choi_013.png",
		"choi_042.png",
		"choi_023.png",
		"choi_039.png",
		"choi_020.png",
		"choi_010.png",
	},

	["右手上33"] = {
		"choi_045.png",
		"choi_021.png",
		"choi_040.png",
	},

	["右脚下"] = {
		"choi_014.png",
		"choi_043.png",
		"choi_040.png",
		"choi_011.png",
		"choi_025.png",
		"choi_022.png",
	},

	["鞋子右"] = {
		"choi_015.png",
		"choi_052.png",
		"choi_012.png",
		"choi_048.png",
		"choi_051.png",
		"choi_021.png",
		"choi_041.png",
		"choi_044.png",
	},

	["右手下"] = {
		"choi_016.png",
		"choi_001.png",
		"choi_028.png",
		"choi_029.png",
		"choi_046.png",
		"choi_027.png",
		"choi_032.png",
	},

	["右手上"] = {
		"choi_026.png",
		"choi_031.png",
		"choi_045.png",
		"choi_037.png",
		"choi_002.png",
	},

	["衣布后"] = {
		"choi_017.png",
		"choi_004.png",
		"choi_047.png",
	},

	["另补下2"] = {
		"choi_056.png",
		"choi_038.png",
		"choi_042.png",
		"choi_009.png",
		"choi_016.png",
		"choi_039.png",
		"choi_023.png",
		"choi_051.png",
		"choi_002.png",
		"choi_001.png",
		"choi_010.png",
		"choi_032.png",
		"choi_045.png",
		"choi_029.png",
		"choi_048.png",
		"choi_040.png",
	},

	["另补下1"] = {
		"choi_033.png",
		"choi_043.png",
		"choi_001.png",
		"choi_017.png",
		"choi_040.png",
		"choi_052.png",
		"choi_042.png",
		"choi_028.png",
		"choi_032.png",
		"choii_tx-2010001.png",
		"choii_tx-2010003.png",
		"choii_tx-2010009.png",
		"choii_tx-2010004.png",
		"choii_tx-2010005.png",
		"choii_tx-20100077.png",
		"choii_tx-20100088.png",
		"choi_046.png",
		"choi_011.png",
		"choi_013.png",
		"choi_029.png",
		"choi_027.png",
		"choi_002.png",
		"choi_012.png",
		"choi_057.png",
	},

	["另补下3"] = {
		"choi_016.png",
		"choi_048.png",
		"choi_052.png",
		"choi_026.png",
		"choi_023.png",
		"choi_043.png",
		"choii_tx-2010002.png",
		"choii_tx-2010003.png",
		"choii_tx-2010005.png",
		"choii_tx-20100077.png",
		"choii_tx-20100088.png",
		"choi_014.png",
		"choi_046.png",
	},

	["另补下4"] = {
		"choi_016.png",
		"choi_027.png",
		"choi_017.png",
		"choi_028.png",
		"choii_tx-2010002.png",
		"choii_tx-20100077.png",
		"choi_012.png",
	},


}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/choi/ChoiSkin.plist")
	Hero.setSkin(self,boneRes)
end

function hit_4113(self,bone,evt,originFrameIndex,currentFrameIndex)
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

local hitSpecialCallback = {
	[4113] = hit_4113,
	--[4115] = Hero.hitOnce,
	--[4117] = Hero.hitOnce,
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
		if self:getEnemyDis() < 150 then
			--test
			self:play(self.choi_rushId,true,true)
			self.choi_rushId = nil
			self.canRun = nil
		end
	end
end
