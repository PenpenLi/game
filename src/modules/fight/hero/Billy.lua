--billy
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Billy", _M)
Helper.initHeroConfig(require("src/config/hero/BillyConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "ryo/Shouji1.mp3"
	else
		return "ryo/Shouji2.mp3"
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
	if event.stateName == 3516 then		--强袭飞翔棍
		self:play(3525,true,true)
		self:setPositionX(self.enemy:getPositionX() + 30 * self.enemy:getDirection())
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 3516 then
		self.billy_rushPlayId = arg.playId
		self:onPlayEnd(arg)
		return
	elseif arg.stateName == 3525 then
		arg.playId = self.billy_rushPlayId
		self.billy_rushPlayId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end

local boneRes = {
	["左手上222"] = {
		"billy_ 256.png",
		"billy_ 259.png",
	},

	["左手下"] = {
		"billy_ 258.png",
		"billy_ 256.png",
		"billy_ 257.png",
		"billy_ 259.png",
		"billy_ 213.png",
		"billy_ 246.png",
		"billy_ 224.png",
		"billy_ 247.png",
	},

	["右手指"] = {
		"billy_ 213.png",
		"billy_ 258.png",
		"billy_ 215.png",
		"billy_ 255.png",
		"billy_ 256.png",
		"billy_ 227.png",
		"billy_ 225.png",
		"billy_ 259.png",
		"billy_ 257.png",
		"billy_ 224.png",
		"billy_ 247.png",
		"billy_ 219.png",
	},

	--[[
	["武器"] = {
		"billy_ 224.png",
		"billy_ 256.png",
		"billy_ 247.png",
		"billy_ 259.png",
		"billy_ 300.png",
		"billy_ 276.png",
		"billy_ 223.png",
	},
	--]]

	["右手下"] = {
		"billy_ 247.png",
		"billy_ 259.png",
		"billy_ 224.png",
		"billy_ 248.png",
		"billy_ 246.png",
		"billy_ 244.png",
		"billy_ 258.png",
		"billy_ 257.png",
		"billy_ 221.png",
	},

	["右手上"] = {
		"billy_ 244.png",
		"billy_ 255.png",
		"billy_ 256.png",
		"billy_ 224.png",
		"billy_ 215.png",
		"billy_ 214.png",
	},

	["头"] = {
		"billy_ 215.png",
		"billy_ 221.png",
		"billy_ 219.png",
		"billy_ 217.png",
		"billy_ 218.png",
		"billy_ 216.png",
		"billy_ 220.png",
	},

	["头结"] = {
		"billy_ 220.png",
		"billy_ 215.png",
		"billy_ 219.png",
		"billy_ 223.png",
		"billy_ 182.png",
	},

	["左头带"] = {
		"billy_ 182.png",
		"billy_ 220.png",
		"billy_ 223.png",
		"billy_ 221.png",
		"billy_ 222.png",
	},

	["右头带"] = {
		"billy_ 222.png",
		"billy_ 182.png",
		"billy_ 214.png",
		"billy_ 211.png",
		"billy_ 210.png",
	},

	["身"] = {
		"billy_ 211.png",
		"billy_ 222.png",
		"billy_ 212.png",
		"billy_ 210.png",
		"billy_ 247.png",
		"billy_ 239.png",
		"billy_ 259.png",
	},

	["左手下222"] = {
		"billy_ 224.png",
		"billy_ 210.png",
		"billy_ 212.png",
		"billy_ 247.png",
		"billy_ 256.png",
		"billy_ 245.png",
		"billy_ 244.png",
		"billy_ 258.png",
		"billy_ 259.png",
		"billy_ 257.png",
		"billy_ 248.png",
		"billy_ 246.png",
		"billy_ 255.png",
		"billy_ 239.png",
		"billy_ 211.png",
	},

	["左手上333"] = {
		"billy_ 247.png",
		"billy_ 248.png",
		"billy_ 224.png",
		"billy_ 259.png",
		"billy_ 257.png",
		"billy_ 244.png",
		"billy_ 239.png",
		"billy_ 246.png",
		"billy_ 255.png",
		"billy_ 258.png",
	},

	["左手上"] = {
		"billy_ 255.png",
		"billy_ 245.png",
		"billy_ 244.png",
		"billy_ 256.png",
		"billy_ 246.png",
		"billy_ 247.png",
		"billy_ 229.png",
		"billy_ 251.png",
		"billy_ 224.png",
	},

	["左脚上"] = {
		"billy_ 250.png",
		"billy_ 251.png",
		"billy_ 239.png",
		"billy_ 240.png",
		"billy_ 238.png",
		"billy_ 249.png",
		"billy_ 242.png",
		"billy_ 230.png",
	},

	["左鞋子"] = {
		"billy_ 232.png",
		"billy_ 230.png",
		"billy_ 233.png",
		"billy_ 229.png",
		"billy_ 226.png",
		"billy_ 231.png",
		"billy_ 227.png",
		"billy_ 225.png",
		"billy_ 228.png",
		"billy_ 250.png",
		"billy_ 254.png",
		"billy_ 247.png",
	},

	["左脚下"] = {
		"billy_ 253.png",
		"billy_ 254.png",
		"billy_ 242.png",
		"billy_ 243.png",
		"billy_ 241.png",
		"billy_ 252.png",
		"billy_ 232.png",
	},

	["右脚上"] = {
		"billy_ 239.png",
		"billy_ 250.png",
		"billy_ 240.png",
		"billy_ 251.png",
		"billy_ 238.png",
		"billy_ 249.png",
		"billy_ 253.png",
		"billy_ 247.png",
		"billy_ 229.png",
	},

	["右鞋子"] = {
		"billy_ 229.png",
		"billy_ 233.png",
		"billy_ 230.png",
		"billy_ 232.png",
		"billy_ 226.png",
		"billy_ 231.png",
		"billy_ 227.png",
		"billy_ 243.png",
	},

	["右脚下"] = {
		"billy_ 242.png",
		"billy_ 243.png",
		"billy_ 253.png",
		"billy_ 254.png",
		"billy_ 241.png",
		"billy_ 172.png",
	},

	["右手2222"] = {
		"billy_ 248.png",
		"billy_ 247.png",
		"billy_ 259.png",
		"billy_ 212.png",
		"billy_ 224.png",
		"billy_ 246.png",
	},

}

function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/billy/BillySkin.plist")
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

--[[
function startAssist(self)
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

--[[
function startAssist(self)
	--跳跃重脚
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
--]]
