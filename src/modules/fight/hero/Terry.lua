-- terry2, 特瑞特写状态

module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Terry", _M)
Helper.initHeroConfig(require("src/config/hero/TerryConfig").Config)
local SoundManager = require("src/modules/fight/SoundManager")
local Define = require("src/modules/fight/Define")

local soundTable = {
	["succeed"] = "terry/Shengli.mp3",
	["start"] = "terry/Kaichang.mp3",
	["dead"] = "terry/Siwang.mp3",
}
function getSoundTable(self)
	return soundTable
end

function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "terry/Shouji1.mp3"
	else
		return "terry/Shouji2.mp3"
	end
end

boneRes = {
	["头"] = {
	  [1] =  "tou_5.png",
	  [2] =  "tou_676.png",
	  [3] =  "tou_6.png",
	  [4] =  "tou_2.png",
	  [5] =  "tou_3.png",
	  [6] =  "tou_51.png",
	  [7] =  "toufa2.png",
	},
	["头2"] = {
	   "tou_2.png",
	   "tou_6.png",
	   "tou_5.png",
	   "tou_3.png",
	   "tou_676.png",
	},
	["头发3_背"] = {
	  [1] =  "toufa_2.png",
	  [2] =  "toufa_4.png",
	  [3] =  "toufa2.png",
	},
	["头发2_背"] = {
	   "toufa2.png",
	   "tou_2.png",
	   "toufa3.png",
	   "toufa_4.png",
	   "tou_5.png",
	   "tou_676.png",
	},
	["头发2侧"] = {
        "toufa2.png",
	},
	["头发3侧"] = {
	   "toufa3.png",
	   "toufa_2.png",
	},
	["衣服"] = {
	  [1] =  "yifu_1.png",
	  [2] =  "yifi_2.png",
	},
	["左脚1侧"] = {
	  [1] =  "zuojiao_5.png",
	  [2] =  "jiao2.png",
	  [3] =  "zuojiao_6.png",
	  [4] =  "youjiao_5.png",
	},
	["左脚2侧"] = {
	  [1] =  "zuojiao_3.png",
	  [2] =  "youjiao_3.png",
	  [3] =  "zuojiao_4.png",
	},
	["左脚3侧"] = {
	   [1] = "zuojiao1.png",
	   [2] = "jiao1.png",
	   [3] = "youjiao3.png",
	   [4] = "jiao_4.png",
	   [5] = "jiao3.png",
	   [6] = "jiao4.png",
	   [7] = "jiao5.png",
	},
	["右脚1侧"] = {
	   "youjiao_5.png",
	   "jiao7.png",
	   "zuojiao_6.png",
	   "zuojiao_5.png",
	},
	["右脚2侧"] = {
	   "youjiao_3.png",
	   "jiao8.png",
	   "zuojiao_4.png",
	   "zuojiao_3.png",
	},
	["右脚3侧"] = {
	   [1] = "youjiao3.png",
	   [2] = "jiao5.png",
	   [3] = "jiao_4.png",
	   [4] = "jiao3.png",
	   [5] = "jiao1.png",
	   [6] = "zuojiao1.png",
	   [7] = "jiao4.png",
	   [8] = "jiao6.png",
	},
	["右手2侧"] = {
	   "youshou_2.png",
	   "shou333.png",
	   "zuoshou2b.png",
	   "zuoshou2c.png",
	},
	["右手1侧"] = {
	   "youshou_3.png",
	   "youshou_4.png",
	   "zuoshou1c.png",
	},
}

function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/terry/TerrySkin.plist")
	Hero.setSkin(self,boneRes)
	--[[
	for name,res in pairs(boneRes) do
		local bone = self.animation:getBone(name)
		--print('----------------------------------boneName:',name)
		for k,v in pairs(res) do
			--print('--------------------k,v:',k,v)
			local skin = ccs.Skin:createWithSpriteFrameName(v)
			bone:addDisplay(skin,k - 1)
			--bone:addDisplay(cc.Sprite:createWithSpriteFrameName(v),k - 1)
			--bone:setIgnoreMovementBoneData(true)
		end
	end
	--]]
end



------------------帧回调事件
----倒跃踢
function hit_1201(self,bone,evt,originFrameIndex,currentFrameIndex)
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

function hit_1107(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.hiting then
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
		if originFrameIndex > 60 then
			local boundBox = bone:getDisplayManager():getBoundingBox()
			local x,y = self._ccnode:getPosition()
			local hitX = x + (boundBox.x + boundBox.width / 2) * self.animation:getScaleX()
			local hitY = y + boundBox.y + boundBox.height / 2

			local rect = self.enemy:getBodyBox()
			self.enemy:setPositionY(hitY - rect.y)
		end
	end
end

function hit_1207(self,bone,evt,originFrameIndex,currentFrameIndex)
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.hiting and originFrameIndex > 33 then
		if self.enemy.curState.lock ~= Define.AttackLock.beat or self.enemy.curState.name == "be_caught" then
			self.enemy:play("hit_fly_a",true)
		end
	end
end

local hitSpecialCallback = {
	[1201] = hit_1201,		--倒跃踢
	[1203] = Hero.hitOnce,		--能量波
	[1207] = hit_1207,			--max高轨

	[1206] = Hero.hitOnce,		--火焰冲拳
	[1213] = Hero.hitOnce,		--跳跃轻拳
	[1214] = Hero.hitOnce,		--跳跃轻脚
	[1215] = Hero.hitOnce,		--跳跃重拳
	[1216] = Hero.hitOnce,		--跳跃重脚
	--前跳
	[1220] = Hero.hitOnce,
	[1221] = Hero.hitOnce,
	[1222] = Hero.hitOnce,
	[1223] = Hero.hitOnce,
	--后跳
	[1224] = Hero.hitOnce,
	[1225] = Hero.hitOnce,
	[1226] = Hero.hitOnce,
	[1227] = Hero.hitOnce,

	--[1107] = hit_1107,
	--[[
	[1209] = Hero.hitStop,			--提前收招
	[1210] = Hero.hitStop,			--提前收招
	[1211] = Hero.hitStop,			--提前收招
	[1212] = Hero.hitStop,			--提前收招
	--]]
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

--使用大招时黑屏
function pow(self,bone,evt,originFrameIndex,currentFrameIndex)
	local boundBox = bone:getDisplayManager():getBoundingBox()
	local rect = self:changeToRealRect(boundBox)
	Stage.currentScene:displayEffect("必杀",rect.x,rect.y,self:getDirection(),true)
	Stage.currentScene:displayEffect("大招",rect.x,rect.y,self:getDirection())
	SoundManager.playEffect("common/Bishashanping.mp3")

	--[[
	self:pause()
	self.enemy:pause()
	local callback = function() 
		self:resume()
		self.enemy:resume()
	end
	Stage.currentScene:blackScreen(0.3,nil,callback)
	--]]
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
