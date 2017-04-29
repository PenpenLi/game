-- iori,八神 特写状态

module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Iori", _M)
Helper.initHeroConfig(require("src/config/hero/IoriConfig").Config)
--Common.printR(require("src/config/hero/IoriConfig").Config[1109].hitEvent)
local Define = require("src/modules/fight/Define")
local Flyer = require("src/modules/fight/Flyer")

function init(self)
	Hero.init(self)
	self:addArmatureFrame("res/armature/effect/ioripower/IoriPower.ExportJson")
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

--[[
function getSoundEffect(self)
	if soundTable[self.curState.name] then
		return soundTable[self.curState.name]
	end
	return Hero.getSoundEffect(self)
end
--]]

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "iori/Shouji1.mp3"
	else
		return "iori/Shouji2.mp3"
	end
end

boneRes = {
	["右脚下2"] = {
		"iori_ 346.png",
	},

	["右脚上2"] = {
		"iori_ 342.png",
	},

	["左脚2"] = {
		"iori_ 362.png",
	},

	["右手下2"] = {
		"iori_ 341.png",
		"iori_ 340.png",
		"iori_ 385.png",
		"iori_ 387.png",
		"iori_ 339.png",
	},

	["右手上2"] = {
		"iori_ 384.png",
		"iori_ 336.png",
	},

	["左手下"] = {
		"iori_ 386.png",
		"iori_ 387.png",
		"iori_ 385.png",
		"iori_ 340.png",
		"iori_ 341.png",
		"iori_ 384.png",
	},

	["左手上"] = {
		"iori_ 383.png",
		"iori_ 384.png",
		"iori_ 382.png",
		"iori_ 337.png",
		"iori_ 341.png",
		"iori_ 387.png",
	},

	["头"] = {
		"iori_ 409.png",
		"iori_ 413.png",
		"iori_ 411.png",
		"iori_ 408.png",
		"iori_ 412.png",
		"iori_ 410.png",
		"iori_ 424.png",
		"iori_ 422.png",
		"iori_ 425.png",
	},

	["上身"] = {
		"iori_ 415.png",
		"iori_ 416.png",
		"iori_ 414.png",
	},

	["头22"] = {
		"iori_ 409.png",
		"iori_ 408.png",
		"iori_ 413.png",
	},

	["皮带"] = {
		"iori_ 376.png",
		"iori_ 375.png",
	},

	["左腿上"] = {
		"iori_ 347.png",
		"iori_ 348.png",
		"iori_ 342.png",
	},

	["左腿下"] = {
		"iori_ 354.png",
		"iori_ 346.png",
		"iori_ 353.png",
	},

	["左脚"] = {
		"iori_ 351.png",
		"iori_ 359.png",
		"iori_ 344.png",
		"iori_ 360.png",
		"iori_ 350.png",
		"iori_ 362.png",
		"iori_ 361.png",
	},

	["右脚上"] = {
		"iori_ 342.png",
		"iori_ 388.png",
		"iori_ 347.png",
	},

	["右脚下"] = {
		"iori_ 346.png",
		"iori_ 354.png",
		"iori_ 345.png",
	},

	["右脚"] = {
		"iori_ 344.png",
		"iori_ 360.png",
		"iori_ 351.png",
		"iori_ 350.png",
		"iori_ 359.png",
		"iori_ 362.png",
		"iori_ 343.png",
	},

	["胯"] = {
		"iori_ 373.png",
		"iori_ 372.png",
	},

	["右手下"] = {
		"iori_ 340.png",
		"iori_ 341.png",
		"iori_ 339.png",
		"iori_ 386.png",
		"iori_ 387.png",
		"iori_ 385.png",
	},

	["右手上"] = {
		"iori_ 337.png",
		"iori_ 336.png",
		"iori_ 383.png",
		"iori_ 384.png",
		"iori_ 338.png",
		"iori_ 382.png",
	},

}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/iori/IoriSkin.plist")
	Hero.setSkin(self,boneRes)
end

--屑风
function hit_1116(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.hiting then
		local x,y = self:getPosition()
		if originFrameIndex == 4 then
			local boundBox = bone:getDisplayManager():getBoundingBox()
			local rect = self:changeToRealRect(boundBox)
			Stage.currentScene:displayEffect("抓起",rect.x,rect.y,self:getDirection())
			self.enemy:play("hit_light_a",true)
			self:setPenetrate(true)
			--直接拉近
			--self.enemy:setPositionX(x - 20 * self:getDirection())
		else
			local tx = x + 80 * self:getDirection()
			local seq = cc.Sequence:create(
				cc.EaseExponentialOut:create(cc.MoveTo:create(0.6,cc.p(tx,y))),
				cc.CallFunc:create(function() 
					self:setPenetrate(false)
				end)
			)
			self.enemy:runAction(seq)
		end
	end
end

function hit_1109(self,bone,evt,originFrameIndex,currentFrameIndex)
	if originFrameIndex == 79 then
		local x,y = self:getPosition()
		self.enemy:setPositionX(x - 40 * self:getDirection())
	end
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end

function hit_1119(self,bone,evt,originFrameIndex,currentFrameIndex)
	if originFrameIndex <= 8 then
		self.enemy:setDirection(-1 * self.enemy:getDirection())
	end
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end

local hitSpecialCallback = {

	--跳攻
	[1105] = Hero.hitOnce,		--
	[1106] = Hero.hitOnce,		--
	[1107] = Hero.hitOnce,		--
	[1108] = Hero.hitOnce,		--
	[1121] = Hero.hitOnce,		--
	[1122] = Hero.hitOnce,		--
	[1123] = Hero.hitOnce,		--
	[1124] = Hero.hitOnce,		--
	[1125] = Hero.hitOnce,		--
	[1126] = Hero.hitOnce,		--
	[1127] = Hero.hitOnce,		--
	[1128] = Hero.hitOnce,		--

	[1116] = hit_1116,			--屑风
	[1109] = hit_1109,			--八稚女
	[1119] = hit_1119,			--逆逆剥

}


function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function rush_1109(self,bone,evt,originFrameIndex,currentFrameIndex)
	local x,y = self.enemy:getPosition()
	local mx,my = self:getPosition()
	local moveBy = cc.MoveBy:create(math.abs(x - mx) / 2000,cc.p(x - mx + self:getDirection() * 60,0))
	self:pause()
	local callback = cc.CallFunc:create(function() 
		self:resume()
		self.animation:getAnimation():gotoAndPlay(21)
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

function rush_1115(self,bone,evt,originFrameIndex,currentFrameIndex)
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
	[1109] = rush_1109,	--八稚女
	[1115] = rush_1115,	--琴月阴
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
	--return nil,"花扇蝶_扇子飞行循环","花扇蝶_扇子击中"
	if self.curState.name == 1120 then	--暗勾手
		return nil,"暗勾手_地波",nil
	elseif self.curState.name == 1110 then	--八酒杯
		return nil,"暗勾手_地波","八酒杯_波"
	else
		return Hero.getFlyName(self)
	end
end

--[[
function fly(self,bone,evt,originFrameIndex,currentFrameIndex)
	local boundBox = bone:getDisplayManager():getBoundingBox()
	local rect = self:changeToRealRect(boundBox)
	local flyer = Flyer.new({
		--startName = "",
		loopName = "暗勾手_地波",
		--endName = "霸王翔吼拳_波击中",
		stateName = self.curState.name,
		direction = self:getDirection(),
		master = self,
		enemy = self.enemy,
		offsetX = rect.x,
		offsetY = rect.y,
	})
	Stage.currentScene:addFlyer(flyer)

end
--]]

function replay(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.replayId ~= self.playId then
		self.replayId = self.playId 
		self.animation:getAnimation():gotoAndPlay(25)
	end
end

function penetrate(self,bone,evt,originFrameIndex,currentFrameIndex)
	self:setPenetrate(true)
	self:setNoTurn(true)
	--self:runAction(cc.MoveBy:create(0.24,cc.p(-120 * self:getDirection(),0)))
	self:runAction(cc.MoveTo:create(0.24,cc.p(self.enemy:getPositionX() + 0 * self:getDirection(),Define.heroBottom)))
end

function initAssist(self)
	--[[
	local fire = cc.ParticleSystemQuad:create("res/particles/AssistEffect.plist")
	fire:setPositionType(0)
	local bone  = ccs.Bone:create("AssistEffect")
	bone:addDisplay(fire, 0)
	bone:changeDisplayWithIndex(0, true)
	bone:setIgnoreMovementBoneData(true)
	bone:setLocalZOrder(-100)
	self.animation:addBone(bone,"右手上")
	--]]

end

function startAssist(self)
	--Hero.startAssistAtk(self)
	print('--------------------fuckyou------------------')
	local skill = self:getAssistSkill()
	self:setCurSkill(skill)
	self:play("assist",true,true)
	self:pause()
	--self.animation:getAnimation():pause(5)

	local ex = self.enemy:getPositionX()
	self:setPosition(ex - self.enemy:getDirection() * 450,Stage.winSize.height)
	self:runAction(
		cc.Sequence:create(
			cc.MoveTo:create(0.2,cc.p(ex - self.enemy:getDirection() * 100,Define.heroBottom)),
			cc.CallFunc:create(function() 
				self:setPositionX(self.enemy:getPositionX() - self.enemy:getDirection() * 100)
				self:resume()
				Stage.currentScene:shockHash(4)
				--local ret = skill:use(self.master.hero,self.enemy)
				local useType,useValue,useTime = skill:use(self.master)
				self:displayAssistEffect(useType,useValue,useTime)
			end)
		)
	)

	self:addEventListener(Event.PlayEnd,function(self,event) 
		if not event.isFinish then
			return
		end
		if event.stateName == "assist" then
			self:play("back_run",true)
		elseif event.stateName == "back_run" then
			self:play(1120,true,true)
		elseif event.stateName == 1120 then	--暗勾手
			self:play("succeed",true)
		elseif event.stateName == "succeed" then
			self.animation:runAction(cc.Sequence:create(
				cc.DelayTime:create(0.3),
				cc.FadeOut:create(0.2),
				cc.CallFunc:create(function() 
					self:removeFromParent()
				end)
			))
		end
	end)
end

function updateAssist(self)
end
