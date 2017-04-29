-- mai,火舞 特写状态

module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Mai", _M)
Helper.initHeroConfig(require("src/config/hero/MaiConfig").Config)
local Define = require("src/modules/fight/Define")
local Flyer = require("src/modules/fight/Flyer")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "mai/Shengli.mp3",
	["start"] = "mai/Kaichang.mp3",
	["dead"] = "mai/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "mai/Shouji1.mp3"
	else
		return "mai/Shouji2.mp3"
	end
end

boneRes = {

	["右手前臂_侧6"] = {
		"mai_ 210.png",
		"mai_ 227.png",
		"mai_ 212.png",
		"mai_ 224.png",
		"mai_ 180.png",
		"mai_ 199.png",
	},

	["右手上臂_侧7"] = {
		"mai_ 214.png",
		"mai_ 198.png",
		"mai_ 197.png",
		"mai_ 227.png",
		"mai_ 213.png",
		"mai_ 200.png",
		"mai_ 226.png",
		"mai_ 179.png",
		"mai_ 178.png",
	},

	["左手前臂_侧4"] = {
		"mai_ 224.png",
		"mai_ 223.png",
		"mai_ 198.png",
		"mai_ 177.png",
		"mai_ 214.png",
		"mai_ 210.png",
		"mai_ 227.png",
	},

	["左手前臂_侧5"] = {
		"mai_ 224.png",
		"mai_ 225.png",
		"mai_ 223.png",
		"mai_ 180.png",
		"mai_ 211.png",
		"mai_ 212.png",
	},

	["武器_关闭"] = {
		"mai_ 200.png",
		"mai_ 199.png",
		"mai_ 180.png",
		"mai_ 224.png",
		"mai_ 214.png",
		"mai_ 225.png",
	},

	["右手前臂_侧"] = {
		"mai_ 211.png",
		"mai_ 212.png",
		"mai_ 210.png",
		"mai_ 200.png",
		"mai_ 223.png",
		"mai_ 225.png",
		"mai_ 197.png",
		"mai_ 227.png",
	},

	["头_侧"] = {
		"mai_ 193.png",
		"mai_ 195.png",
		"mai_ 191.png",
		"mai_ 194.png",
		"mai_ 192.png",
		"mai_ 196.png",
	},

	["身体_侧面_1"] = {
		"mai_ 189.png",
		"mai_ 188.png",
		"mai_ 187.png",
		"mai_ 190.png",
	},

	["裙子_侧"] = {
		"mai_ 185.png",
		"mai_ 184.png",
		"mai_ 186.png",
		"mai_ 183.png",
	},

	["左手上臂_侧"] = {
		"mai_ 227.png",
		"mai_ 214.png",
		"mai_ 210.png",
	},

	["右手上臂_侧"] = {
		"mai_ 214.png",
		"mai_ 200.png",
		"mai_ 199.png",
		"mai_ 227.png",
		"mai_ 213.png",
		"mai_ 211.png",
	},

	["右脚脚掌_侧"] = {
		"mai_ 206.png",
		"mai_ 207.png",
		"mai_ 220.png",
		"mai_ 204.png",
		"mai_ 182.png",
		"mai_ 205.png",
		"mai_ 217.png",
	},

	["右脚小腿_侧"] = {
		"mai_ 209.png",
		"mai_ 208.png",
		"mai_ 215.png",
	},

	["右脚大腿_侧"] = {
		"mai_ 203.png",
		"mai_ 202.png",
		"mai_ 221.png",
	},

	["头发_侧"] = {
		"mai_ 198.png",
		"mai_ 183.png",
		"mai_ 193.png",
		"mai_ 197.png",
	},

	["左脚脚掌_侧"] = {
		"mai_ 219.png",
		"mai_ 220.png",
		"mai_ 207.png",
		"mai_ 217.png",
		"mai_ 182.png",
		"mai_ 218.png",
		"mai_ 205.png",
		"mai_ 204.png",
	},

	["左脚大腿_侧"] = {
		"mai_ 216.png",
		"mai_ 215.png",
		"mai_ 208.png",
	},

	["左脚小腿_侧"] = {
		"mai_ 222.png",
		"mai_ 221.png",
		"mai_ 202.png",
	},

	["右手前臂_侧2"] = {
		"mai_ 210.png",
		"mai_ 223.png",
		"mai_ 180.png",
		"mai_ 197.png",
		"mai_ 178.png",
		"mai_ 191.png",
		"mai_ 193.png",
	},

	["蝴蝶结带_1"] = {
		"mai_ 180.png",
		"mai_ 181.png",
		"mai_ 198.png",
		"mai_ 223.png",
		"mai_ 191.png",
		"mai_ 187.png",
	},

	["左手前臂_侧3"] = {
		"mai_ 225.png",
		"mai_ 198.png",
		"mai_ 227.png",
		"mai_ 226.png",
		"mai_ 193.png",
		"mai_ 223.png",
	},
	["扇子"] = {
		"mai_ 214.png",
		"mai_ 200.png",
		"mai_ 177.png",
		"mai_ 223.png",
		"mai_ 198.png",
	},
}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/mai/MaiSkin.plist")
	Hero.setSkin(self,boneRes)
end

--[[
function getAssistType(self)
	return Define.AssistType.defense
end
--]]


function hit_1510(self,bone,evt,originFrameIndex,currentFrameIndex)
	self:setNoTurn(true)

	--[[
	if self.hiting and self.enemy.curState.lock ~= Define.AttackLock.defense then
		local boundBox = bone:getDisplayManager():getBoundingBox()
		local rect = self:changeToRealRect(boundBox)
		local isHit,hitX,hitY = self.enemy:isHit(rect)
		self.enemy:setPositionX(hitX - 40 * self.animation:getScaleX())
	end
	--]]
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end

local hitSpecialCallback = {

	--[1509] = Hero.hitOnce,		--超忍必杀忍蜂
	[1514] = Hero.hitOnce,		--飞鼠之舞

	[1510] = hit_1510,		--凤凰之舞

}


function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function getFlyName(self)
	return nil,"花扇蝶_扇子飞行循环",nil--,"花扇蝶_扇子击中"
end

--[[
function fly(self,bone,evt,originFrameIndex,currentFrameIndex)
	local boundBox = bone:getDisplayManager():getBoundingBox()
	local rect = self:changeToRealRect(boundBox)
	local flyer = Flyer.new({
		--startName = "",
		loopName = "花扇蝶_扇子飞行循环",
		endName = "花扇蝶_扇子击中",
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
--
--使用大招时黑屏
function pow(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.curState.name == 1509 then
		local boundBox = bone:getDisplayManager():getBoundingBox()
		local rect = self:changeToRealRect(boundBox)
		Stage.currentScene:displayEffect("必杀",rect.x,rect.y,self:getDirection(),true)
		Stage.currentScene:displayEffect("大招",rect.x,rect.y,self:getDirection())
		SoundManager.playEffect("common/Bishashanping.mp3")
	else
		Hero.pow(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function replay(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.replayId ~= self.playId then
		self.replayId = self.playId 
		--self.animation:getAnimation():gotoAndPlay(25)
	end
end

--[[
function startAssist(self)
	local skill = self:getAssistSkill()
	self:setCurSkill(skill)
	self:play("jump",true)
	self:pause()
	self.animation:getAnimation():pause(10)

	local lx = Stage.currentScene:getLeft() 
	local rx = Stage.currentScene:getRight()
	local tx = (lx + rx) / 2 + self:getDirection() * 150
	self:setPosition(self.master:getDirection() == Hero.DIRECTION_RIGHT and lx or rx,Stage.winSize.height)
	self:runAction(
		cc.Sequence:create(
			cc.MoveTo:create(0.2,cc.p(tx,Define.heroBottom)),
			cc.CallFunc:create(function() 
				self:resume()
			end)
		)
	)

	self:addEventListener(Event.PlayEnd,function(self,event) 
		if event.stateName == "jump" then
			self:play(1528,true)
		elseif event.stateName == 1528 then
			self.animation:runAction(cc.Sequence:create(
				cc.DelayTime:create(0.3),
				cc.FadeOut:create(0.2),
				cc.CallFunc:create(function() 
					self:removeFromParent()
				end)
			))

			--redo 加血
			skill:use(self.enemy)
		end
	end)
end

function updateAssist(self)
end
--]]

--[[
function removeSelf(self)
	self.animation:runAction(cc.Sequence:create(
		cc.FadeOut:create(0.2),
		cc.CallFunc:create(function() 
			self:removeFromParent()
		end)
	))
end

function doAfterRound(self)
	if self.isAssist then
		self:removeSelf()
	end
end

function doAfterBeat(self)
	if self.isAssist then
		if self.isDefensed then
			Stage.currentScene.fightLogic.needNextRound = true
			self:removeSelf()
		end
	else
		Hero.doAfterBeat(self)
	end
end
--]]

--[[
function startAssist(self)
	self:play("forward_run")
	self:addEventListener(Event.PlayEnd,function(self,event) 
		if event.stateName == "stand_heavy_defense" then
			if self.enemy.hiting then
				self.enemyPlayId = self.enemy.playId
			else
				self:removeSelf()
			end

		end
	end)
end

function updateAssist(self)
	self:setDirection(self.master:getDirection())
	local x = self:getPositionX()
	local masterX = self.master:getPositionX()
	if math.abs(x - masterX) < 30 and not self.firstUpdate then
		self:play("stand_heavy_defense",true)
		self.firstUpdate = true
	end
	if self.enemyPlayId and self.enemyPlayId ~= self.enemy.playId then
		self.enemyPlayId = nil
		if self.enemy.hiting then 
			self.canDefense = true
			local x = self.master:getPositionX()
			self:setPositionX(x)
			self:addTimer(function() 
				self:removeSelf()
			end,3,1)
		else
			self:removeSelf()
		end
	end
	if x < -300 or x > Stage.currentScene.mapWidth + 300 then
		self:removeFromParent()
	end
end
--]]
