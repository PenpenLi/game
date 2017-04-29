-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Yamazaki", _M)
Helper.initHeroConfig(require("src/config/hero/YamazakiConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "yamazaki/Shengli.mp3",
	["start"] = "yamazaki/Kaichang.mp3",
	["dead"] = "yamazaki/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "yamazaki/Shouji1.mp3"
	else
		return "yamazaki/Shouji2.mp3"
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
	if event.stateName == 3115 then		--奔袭投掷_1
		self:play("rush",true)
		self.yamazaki_rushId = 3125		--奔袭投掷_2
		self.canRun = true
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 3115 then
		self.yamazaki_rushPlayId = arg.playId
		self:onPlayEnd(arg)
		return
	elseif arg.stateName == 3125 then
		arg.playId = self.yamazaki_rushPlayId
		self.yamazaki_rushPlayId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end

function setTarget(self)
	self:addArmatureFrame("res/armature/yamazaki/YamazakiTarget.ExportJson",0)
end

----射杀LV1
function hit_3114(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.hiting and self.enemy.curState.lock ~= Define.AttackLock.defense then
		if originFrameIndex == 2 then 
			local boundBox = bone:getDisplayManager():getBoundingBox()
			local rect = self:changeToRealRect(boundBox)
			local isHit,hitX,hitY = self.enemy:isHit(rect)
			if isHit then
				self.enemy:setPosition(hitX + 10 * self.animation:getScaleX(),hitY - 115)
			end

		elseif originFrameIndex >= 50 and originFrameIndex <= 60 then
			local boundBox = bone:getDisplayManager():getBoundingBox()
			local rect = self:changeToRealRect(boundBox)
			local isHit,hitX,hitY = self.enemy:isHit(rect)
			if isHit then
				self.enemy:setPosition(hitX - 30 * self.animation:getScaleX(),hitY - 60)
			end
		end
	end
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end
local hitSpecialCallback = {
	[3114] = hit_3114
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function getFlySpeed(self)
	return 1350
end

function getFlyName(self)
	return nil,"倍返_飞行循环特效","倍返_特效拆分_Copy1"
end

function update(self,event)
	local delay = event.delay
	if self.curState.name == "rush" then
		if self:getEnemyDis() < 150 then
			self:play(self.yamazaki_rushId,true,true)
			self.yamazaki_rushId = nil
			self.canRun = nil
		end
	end
end

local boneRes = {


	["右手上222"] = {
		"yamazaki_ 167.png",
		"yamazaki_ 143.png",
		"yamazaki_ 162.png",
		"yamazaki_ 227.png",
		"yamazaki_ 229.png",
		"yamazaki_ 180.png",
		"yamazaki_ 158.png",
		"yamazaki_ 177.png",
		"yamazaki_ 166.png",
	},

	["左手上"] = {
		"yamazaki_ 169.png",
		"yamazaki_ 143.png",
		"yamazaki_ 229.png",
		"yamazaki_ 138.png",
		"yamazaki_ 164.png",
		"yamazaki_ 227.png",
	},

	["左手下"] = {
		"yamazaki_ 165.png",
		"yamazaki_ 142.png",
		"yamazaki_ 229.png",
		"yamazaki_ 164.png",
		"yamazaki_ 227.png",
		"yamazaki_ 138.png",
		"yamazaki_ 169.png",
		"yamazaki_ 143.png",
	},

	["匕首1"] = {
		"yamazaki_ 160.png",
		"yamazaki_ 225.png",
		"yamazaki_ 180.png",
		"yamazaki_ 157.png",
	},

	["头"] = {
		"yamazaki_ 160.png",
		"yamazaki_ 225.png",
		"yamazaki_ 134.png",
		"yamazaki_ 223.png",
		"yamazaki_ 222.png",
		"yamazaki_ 159.png",
		"yamazaki_ 179.png",
	},

	["身体"] = {
		"yamazaki_ 159.png",
		"yamazaki_ 133.png",
		"yamazaki_ 247.png",
		"yamazaki_ 224.png",
		"yamazaki_ 166.png",
	},

	["左脚上"] = {
		"yamazaki_ 166.png",
		"yamazaki_ 230.png",
		"yamazaki_ 162.png",
		"yamazaki_ 163.png",
		"yamazaki_ 140.png",
		"yamazaki_ 167.png",
	},

	["左脚下"] = {
		"yamazaki_ 167.png",
		"yamazaki_ 163.png",
		"yamazaki_ 162.png",
		"yamazaki_ 141.png",
		"yamazaki_ 168.png",
	},

	["左脚"] = {
		"yamazaki_ 168.png",
		"yamazaki_ 161.png",
		"yamazaki_ 178.png",
		"yamazaki_ 228.png",
		"yamazaki_ 162.png",
		"yamazaki_ 139.png",
		"yamazaki_ 135.png",
	},

	["右脚上"] = {
		"yamazaki_ 162.png",
		"yamazaki_ 166.png",
		"yamazaki_ 230.png",
		"yamazaki_ 167.png",
		"yamazaki_ 136.png",
		"yamazaki_ 163.png",
	},

	["右脚下"] = {
		"yamazaki_ 163.png",
		"yamazaki_ 167.png",
		"yamazaki_ 166.png",
		"yamazaki_ 137.png",
		"yamazaki_ 161.png",
	},

	["右脚"] = {
		"yamazaki_ 161.png",
		"yamazaki_ 228.png",
		"yamazaki_ 168.png",
		"yamazaki_ 139.png",
		"yamazaki_ 178.png",
		"yamazaki_ 135.png",
		"yamazaki_ 164.png",
		"yamazaki_ 163.png",
		"yamazaki_ 176.png",
	},

	["右手下"] = {
		"yamazaki_ 164.png",
		"yamazaki_ 169.png",
		"yamazaki_ 138.png",
		"yamazaki_ 227.png",
		"yamazaki_ 142.png",
		"yamazaki_ 229.png",
		"yamazaki_ 143.png",
	},

	["右手上"] = {
		"yamazaki_ 142.png",
		"yamazaki_ 165.png",
		"yamazaki_ 226.png",
		"yamazaki_ 164.png",
		"yamazaki_ 126.png",
		"yamazaki_ 229.png",
		"yamazaki_ 227.png",
		"yamazaki_ 143.png",
		"yamazaki_ 138.png",
	},

	["匕首3"] = {
		"yamazaki_ 157.png",
	},


}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/yamazaki/YamazakiSkin.plist")
	Hero.setSkin(self,boneRes)
end
