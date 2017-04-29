-- robert, 罗卜头 特写状态

module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Robert", _M)
local config = require("src/config/hero/RobertConfig").Config
Helper.initHeroConfig(config)
config[1412].hitEvent.cnt = config[1412].hitEvent.cnt + 9
local Define = require("src/modules/fight/Define")
local Flyer = require("src/modules/fight/Flyer")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "robert/Shengli.mp3",
	["start"] = "robert/Kaichang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "robert/Shouji1.mp3"
	else
		return "robert/Shouji2.mp3"
	end
end
local boneRes = {
	["图层 2"] = {
		"robert_ 77.png",
		"robert_ 76.png",
		"robert_ 75.png",
		"robert_ 78.png",
		"robert_ 81.png",
		"robert_ 82.png",
		"robert_ 83.png",
		"robert_ 79.png",
		"robert_ 80.png",
		"robert_ 73.png",
		"robert_ 74.png",
	},

	["左脚_脚掌3s"] = {
		"robert_ 116.png",
		"robert_ 111.png",
		"robert_ 128.png",
	},

	["辫子2s"] = {
		"robert_ 85.png",
		"robert_ 86.png",
		"robert_ 84.png",
		"robert_ 122.png",
		"robert_ 138.png",
	},

	["左手_上臂2s"] = {
		"robert_ 141.png",
		"robert_ 138.png",
		"robert_ 139.png",
		"robert_ 123.png",
		"robert_ 137.png",
		"robert_ 122.png",
	},

	["左手_前臂s"] = {
		"robert_ 138.png",
		"robert_ 122.png",
		"robert_ 137.png",
		"robert_ 139.png",
		"robert_ 141.png",
		"robert_ 123.png",
		"robert_ 138.png",
		"robert_ 129.png",
	},

	["右手_前臂s"] = {
		"robert_ 122.png",
		"robert_ 139.png",
		"robert_ 123.png",
		"robert_ 141.png",
		"robert_ 106.png",
		"robert_ 109.png",
		"robert_ 121.png",
		"robert_ 137.png",
	},

	["右手_上臂s"] = {
		"robert_ 125.png",
		"robert_ 124.png",
		"robert_ 126.png",
		"robert_ 109.png",
		"robert_ 123.png",
		"robert_ 122.png",
		"robert_ 138.png",
	},

	["头"] = {
		"robert_ 106.png",
		"robert_ 109.png",
		"robert_ 104.png",
		"robert_ 105.png",
		"robert_ 107.png",
		"robert_ 108.png",
		"robert_ 132.png",
		"robert_ 124.png",
		"robert_ 123.png",
	},

	["身体"] = {
		"robert_ 103.png",
		"robert_ 102.png",
		"robert_ 101.png",
	},

	["左手_上臂"] = {
		"robert_ 141.png",
		"robert_ 138.png",
		"robert_ 137.png",
		"robert_ 140.png",
	},

	["右脚_小腿"] = {
		"robert_ 119.png",
		"robert_ 118.png",
		"robert_ 120.png",
		"robert_ 141.png",
		"robert_ 116.png",
	},

	["右脚_脚掌"] = {
		"robert_ 115.png",
		"robert_ 133.png",
		"robert_ 131.png",
		"robert_ 114.png",
		"robert_ 117.png",
		"robert_ 116.png",
		"robert_ 130.png",
		"robert_ 132.png",
		"robert_ 118.png",
		"robert_ 109.png",
		"robert_ 128.png",
	},

	["右脚_大腿"] = {
		"robert_ 112.png",
		"robert_ 111.png",
		"robert_ 113.png",
		"robert_ 132.png",
		"robert_ 128.png",
	},

	["左脚_大腿"] = {
		"robert_ 128.png",
		"robert_ 127.png",
		"robert_ 129.png",
		"robert_ 132.png",
		"robert_ 113.png",
		"robert_ 112.png",
	},

	["左脚_小腿"] = {
		"robert_ 135.png",
		"robert_ 136.png",
		"robert_ 134.png",
		"robert_ 118.png",
		"robert_ 112.png",
		"robert_ 128.png",
		"robert_ 119.png",
	},

	["左脚_脚掌"] = {
		"robert_ 131.png",
		"robert_ 133.png",
		"robert_ 117.png",
		"robert_ 114.png",
		"robert_ 130.png",
		"robert_ 132.png",
		"robert_ 116.png",
		"robert_ 112.png",
		"robert_ 118.png",
		"robert_ 134.png",
	},

	["辫子"] = {
		"robert_ 85.png",
		"robert_ 86.png",
		"robert_ 84.png",
		"robert_ 104.png",
		"robert_ 106.png",
		"robert_ 137.png",
	},

	["右手_上臂2"] = {
		"robert_ 122.png",
		"robert_ 139.png",
		"robert_ 123.png",
		"robert_ 124.png",
		"robert_ 141.png",
		"robert_ 131.png",
		"robert_ 137.png",
	},

	["右手_前臂2"] = {
		"robert_ 126.png",
		"robert_ 122.png",
		"robert_ 137.png",
		"robert_ 139.png",
		"robert_ 141.png",
		"robert_ 118.png",
	},

	["右手_前臂3"] = {
		"robert_ 139.png",
		"robert_ 137.png",
		"robert_ 123.png",
		"robert_ 112.png",
	},

	["右手_上臂3"] = {
		"robert_ 124.png",
		"robert_ 137.png",
		"robert_ 126.png",
		"robert_ 115.png",
		"robert_ 121.png",
	},

	["右脚_大腿3"] = {
		"robert_ 111.png",
		"robert_ 119.png",
		"robert_ 132.png",
		"robert_ 137.png",
		"robert_ 138.png",
		"robert_ 113.png",
	},

	["右脚_小腿3"] = {
		"robert_ 119.png",
		"robert_ 118.png",
		"robert_ 120.png",
		"robert_ 117.png",
		"robert_ 104.png",
		"robert_ 133.png",
		"robert_ 124.png",
		"robert_ 135.png",
	},

	["右脚_脚掌4"] = {
		"robert_ 115.png",
		"robert_ 117.png",
		"robert_ 131.png",
		"robert_ 133.png",
		"robert_ 130.png",
		"robert_ 132.png",
		"robert_ 137.png",
		"robert_ 111.png",
		"robert_ 112.png",
		"robert_ 122.png",
	},

	["头2"] = {
		"robert_ 104.png",
		"robert_ 106.png",
		"robert_ 139.png",
		"robert_ 118.png",
		"robert_ 119.png",
	},

	["左手_前臂5"] = {
		"robert_ 139.png",
		"robert_ 137.png",
		"robert_ 141.png",
		"robert_ 122.png",
		"robert_ 132.png",
		"robert_ 128.png",
		"robert_ 138.png",
		"robert_ 123.png",
		"robert_ 140.png",
	},

	["右脚_小腿5"] = {
		"robert_ 118.png",
		"robert_ 119.png",
		"robert_ 124.png",
		"robert_ 133.png",
		"robert_ 134.png",
	},

	["右脚_脚掌5"] = {
		"robert_ 130.png",
		"robert_ 131.png",
		"robert_ 133.png",
		"robert_ 132.png",
		"robert_ 135.png",
		"robert_ 141.png",
		"robert_ 116.png",
		"robert_ 114.png",
	},

	["右脚_大腿6"] = {
		"robert_ 113.png",
		"robert_ 112.png",
		"robert_ 111.png",
		"robert_ 137.png",
	},
}


function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/robert/RobertSkin.plist")
	Hero.setSkin(self,boneRes)
end

function hit_1412(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.hiting and self.enemy.curState.lock ~= Define.AttackLock.defense then
		if originFrameIndex >= 74 and originFrameIndex <=89 then
			local boundBox = bone:getDisplayManager():getBoundingBox()
			local rect = self:changeToRealRect(boundBox)
			local isHit,hitX,hitY = self.enemy:isHit(rect)
			self.enemy:setPosition(hitX - 30 * self.animation:getScaleX(),hitY - 60)
			
		end
	end
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end

local hitSpecialCallback = {
	[1401] = Hero.hitOnce,		--霸王翔吼拳

	--跳攻
	[1407] = Hero.hitOnce,		--
	[1408] = Hero.hitOnce,		--
	[1409] = Hero.hitOnce,		--
	[1410] = Hero.hitOnce,		--
	[1419] = Hero.hitOnce,		--
	[1420] = Hero.hitOnce,		--
	[1421] = Hero.hitOnce,		--
	[1422] = Hero.hitOnce,		--
	[1423] = Hero.hitOnce,		--
	[1424] = Hero.hitOnce,		--
	[1425] = Hero.hitOnce,		--
	[1426] = Hero.hitOnce,		--

	[1415] = Hero.hitOnce,		--飞燕神龙腿
	[1412] = hit_1412,			--龙虎乱舞
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

--直接冲到对方位置，例如八神的八稚女
function rush(self,bone,evt,originFrameIndex,currentFrameIndex)
	local x,y = self.enemy:getPosition()
	local mx,my = self:getPosition()
	local dx = x - mx + self:getDirection() * 60
	local t = math.abs(x-mx)/1500
	local moveBy1 = cc.MoveBy:create(t/3,cc.p(dx / 3,0))
	local moveBy2 = cc.MoveBy:create(2*t/3,cc.p(2*dx/3,40))
	self:pause()
	local callback = cc.CallFunc:create(function() 
		self:resume()
		self:setPositionY(Define.heroBottom)
		self.animation:getAnimation():gotoAndPlay(21)
		if self.enemy.curState.name == "forward" or self.enemy.curState.name == "forward_run" then
			self.enemy:play("stand",true)
		end
	end)
    local seq = cc.Sequence:create(moveBy1,moveBy2, callback)
	self:runAction(seq)
end

function getFlyName(self)
	return nil,"霸王翔吼拳_波飞行循环","霸王翔吼拳_波击中"
end

function getFlySpeed(self)
	return 1350
end

--[[
function fly(self,bone,evt,originFrameIndex,currentFrameIndex)
	local boundBox = bone:getDisplayManager():getBoundingBox()
	local rect = self:changeToRealRect(boundBox)
	local flyer = Flyer.new({
		--startName = "",
		loopName = "霸王翔吼拳_波飞行循环",
		endName = "霸王翔吼拳_波击中",
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
		self.animation:getAnimation():gotoAndPlay(22)
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
