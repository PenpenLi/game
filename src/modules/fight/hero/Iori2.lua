-- iori,八神 特写状态

module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Iori2", _M)
Helper.initHeroConfig(require("src/config/hero/Iori2Config").Config)
local Define = require("src/modules/fight/Define")
local Flyer = require("src/modules/fight/Flyer")

function init(self)
	Hero.init(self)
	--self:addArmatureFrame("res/armature/effect/ioripower/IoriPower.ExportJson")
end

function setTarget(self)
	self:addArmatureFrame("res/armature/iori2/Iori2Target.ExportJson",0)
end

local soundTable = {
	["succeed"] = "iori/Shengli.mp3",
	["start"] = "iori/Kaichang.mp3",
	["fail"] = "iori/Shibai.mp3",
	["dead"] = "iori/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "iori/Shouji1.mp3"
	else
		return "iori/Shouji2.mp3"
	end
end

local boneRes = {
	
	["右脚下2"] = {
		"iori2_ 346.png",
	},

	["右脚上2"] = {
		"iori2_ 342.png",
	},

	["左脚2"] = {
		"iori2_ 362.png",
	},

	["右手下2"] = {
		"iori2_ 341.png",
		"iori2_ 340.png",
		"iori2_ 385.png",
		"iori2_ 387.png",
		"iori2_ 339.png",
	},

	["右手上2"] = {
		"iori2_ 384.png",
		"iori2_ 336.png",
	},

	["左手下"] = {
		"iori2_ 386.png",
		"iori2_ 387.png",
		"iori2_ 385.png",
		"iori2_ 340.png",
		"iori2_ 341.png",
		"iori2_ 384.png",
		"iori2__0002.png",
	},

	["左手上"] = {
		"iori2_ 383.png",
		"iori2_ 384.png",
		"iori2_ 382.png",
		"iori2_ 337.png",
		"iori2_ 341.png",
		"iori2_ 387.png",
		"iori2__0001.png",
	},

	["头"] = {
		"iori2_ 409.png",
		"iori2_ 413.png",
		"iori2_ 411.png",
		"iori2_ 408.png",
		"iori2_ 412.png",
		"iori2_ 410.png",
		"iori2__0004.png",
	},

	["上身"] = {
		"iori2_ 415.png",
		"iori2_ 416.png",
		"iori2_ 414.png",
		"iori2__0003.png",
	},

	["头22"] = {
		"iori2_ 409.png",
		"iori2_ 408.png",
		"iori2_ 413.png",
	},

	["皮带"] = {
		"iori2_ 376.png",
		"iori2_ 375.png",
	},

	["左腿上"] = {
		"iori2_ 347.png",
		"iori2_ 348.png",
		"iori2_ 342.png",
		"iori2__0010.png",
	},

	["左腿下"] = {
		"iori2_ 354.png",
		"iori2_ 346.png",
		"iori2_ 353.png",
		"iori2__0005.png",
	},

	["左脚"] = {
		"iori2_ 351.png",
		"iori2_ 359.png",
		"iori2_ 344.png",
		"iori2_ 360.png",
		"iori2_ 350.png",
		"iori2_ 362.png",
		"iori2_ 361.png",
		"iori2__0006.png",
	},

	["右脚上"] = {
		"iori2_ 342.png",
		"iori2_ 388.png",
		"iori2_ 347.png",
		"iori2__0009.png",
	},

	["右脚下"] = {
		"iori2_ 346.png",
		"iori2_ 354.png",
		"iori2_ 345.png",
		"iori2__0007.png",
	},

	["右脚"] = {
		"iori2_ 344.png",
		"iori2_ 360.png",
		"iori2_ 351.png",
		"iori2_ 350.png",
		"iori2_ 359.png",
		"iori2_ 362.png",
		"iori2_ 343.png",
		"iori2__0008.png",
	},

	["胯"] = {
		"iori2_ 373.png",
		"iori2_ 372.png",
	},

	["右手下"] = {
		"iori2_ 340.png",
		"iori2_ 341.png",
		"iori2_ 339.png",
		"iori2_ 386.png",
		"iori2_ 387.png",
		"iori2_ 385.png",
		"iori2__0012.png",
	},

	["右手上"] = {
		"iori2_ 337.png",
		"iori2_ 336.png",
		"iori2_ 383.png",
		"iori2_ 384.png",
		"iori2_ 338.png",
		"iori2_ 382.png",
		"iori2__0011.png",
	},

}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/iori2/Iori2Skin.plist")
	Hero.setSkin(self,boneRes)
end

--屑风
function hit_4016(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.hiting then
		local x,y = self:getPosition()
		if originFrameIndex == 4 then
			local boundBox = bone:getDisplayManager():getBoundingBox()
			local rect = self:changeToRealRect(boundBox)
			Stage.currentScene:displayEffect("抓起",rect.x,rect.y,self:getDirection())
			self.enemy:play("hit_light_a",true)
			self:setPenetrate(true)
			self:setNoTurn(true)
			--直接拉近
			--self.enemy:setPositionX(x - 20 * self:getDirection())
		else
			local tx = x + 80 * self:getDirection()
			local seq = cc.Sequence:create(
				cc.EaseExponentialOut:create(cc.MoveTo:create(0.6,cc.p(tx,y))),
				cc.CallFunc:create(function() 
					self:setPenetrate(false)
					self:setNoTurn(false)
				end)
			)
			self.enemy:runAction(seq)
		end
	end
end

function hit_4009(self,bone,evt,originFrameIndex,currentFrameIndex)
	if originFrameIndex == 77 then
		local x,y = self:getPosition()
		self.enemy:setPositionX(x - 40 * self:getDirection())
	end
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end

function hit_4019(self,bone,evt,originFrameIndex,currentFrameIndex)
	if originFrameIndex <= 8 then
		self.enemy:setDirection(-1 * self.enemy:getDirection())
	end
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end

function thit_4009(self,bone,evt,originFrameIndex,currentFrameIndex)
	if originFrameIndex == 21 then
		self.curState.target = {"八稚女","somesault_up_a"}
		self:startTarget()
	elseif originFrameIndex == 113 then
		self:endTarget()
		self.curState.target = nil
		self.enemy:startBurn("Fire2")
		self:setNoTurn(true)
		self:setDirection(-self:getDirection())
		self.enemy:setDirection(-self:getDirection())
		self.enemy:setPositionX(self:getPositionX() - 30 * self:getDirection())
	end
	Hero.thit(self,bone,evt,originFrameIndex,currentFrameIndex)
end

local hitSpecialCallback = {

	[4016] = hit_4016,			--屑风
	[4019] = hit_4019,			--逆逆剥
}

local thitSpecialCallback = {

	[4009] = thit_4009,			--八稚女

}


function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function thit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if thitSpecialCallback[self.curState.name] then
		thitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.thit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function rush_4009(self,bone,evt,originFrameIndex,currentFrameIndex)
	local x,y = self.enemy:getPosition()
	local mx,my = self:getPosition()
	local moveBy = cc.MoveBy:create(math.abs(x - mx) / 2000,cc.p(x - mx + self:getDirection() * 60,0))
	self:pause()
	local callback = cc.CallFunc:create(function() 
		self:resume()
		self.animation:getAnimation():gotoAndPlay(20)
		if self.enemy.curState.name == "forward" or self.enemy.curState.name == "forward_run" then
			self.enemy:play("stand",true)
		end
		if self.enemy.curState.lock == Define.AttackLock.defense then
			self:play("stand",true)
			self.enemy:play("stand",true)
		end
	end)
    local seq = cc.Sequence:create(moveBy, callback)
	self:runAction(seq)
end

function rush_4015(self,bone,evt,originFrameIndex,currentFrameIndex)
	local x,y = self.enemy:getPosition()
	local mx,my = self:getPosition()
	local moveBy = cc.MoveBy:create(0.001,cc.p(x - mx + self:getDirection() * 60,0))
	self:pause()
	local callback = cc.CallFunc:create(function() 
		self:resume()
		if self.enemy.curState.name == "forward" or self.enemy.curState.name == "forward_run" then
			self.enemy:play("stand",true)
		end
		if self.enemy.curState.lock == Define.AttackLock.defense then
			self:play("stand",true)
			self.enemy:play("stand",true)
		end
	end)
    local seq = cc.Sequence:create(moveBy, callback)
	self:runAction(seq)
end

local rushSpecialCallback = {
	[4009] = rush_4009,	--八稚女
	[4015] = rush_4015,	--琴月阴
}

--直接冲到对方位置，例如八神的八稚女
function rush(self,bone,evt,originFrameIndex,currentFrameIndex)
	if rushSpecialCallback[self.curState.name] then
		rushSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.rush(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function getFlyName(self)
	if self.curState.name == 4020 then	--暗勾手
		return nil,"暗勾手_地波",nil
	elseif self.curState.name == 4010 then	--八酒杯
		return nil,"暗勾手_地波","八酒杯_波"
	else
		return Hero.getFlyName(self)
	end
end

function replay(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.replayId ~= self.playId then
		self.replayId = self.playId 
		self.animation:getAnimation():gotoAndPlay(25)
	end
end

function penetrate(self,bone,evt,originFrameIndex,currentFrameIndex)
	self:setPenetrate(true)
	self:setNoTurn(true)
	self:runAction(cc.MoveTo:create(0.24,cc.p(self.enemy:getPositionX() + 0 * self:getDirection(),Define.heroBottom)))
end

function startAssist(self)
	Hero.startAssistAtk(self)
end

function updateAssist(self)
end
