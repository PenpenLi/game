-- terry, 特瑞特写状态

module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Terry", _M)
Helper.initHeroConfig(require("src/config/hero/TerryConfig").Config)
local Define = require("src/modules/fight/Define")




------------------帧回调事件
----倒跃踢
function hit_1101(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.hiting and self.enemy.curState~= Define.AttackLock.defense then
		local boundBox = bone:getDisplayManager():getBoundingBox()
		--[[
		local x,y = self._ccnode:getPosition()
		local hitX = x + (boundBox.x + boundBox.width / 2) * self.animation:getScaleX()
		local hitY = y + boundBox.y + boundBox.height / 2
		--]]
		local rect = self:changeToRealRect(boundBox)
		local isHit,hitX,hitY = self.enemy:isHit(rect)
		self.enemy:setPosition(hitX - 30 * self.animation:getScaleX(),hitY - 60)
	end
	Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
end

--能量波
function hit_1103(self,bone,evt,originFrameIndex,currentFrameIndex)
	if self.hiting then
		if self.hitId ~= self.playId then
			self.hitId = self.playId
			Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
		end
	end
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

local hitSpecialCallback = {
	[1101] = hit_1101,		--倒跃踢
	[1103] = Hero.hitOnce,		--能量波
	[1106] = Hero.hitOnce,		--火焰冲拳
	[1113] = Hero.hitOnce,		--跳跃轻拳
	[1114] = Hero.hitOnce,		--跳跃轻脚
	[1115] = Hero.hitOnce,		--跳跃重拳
	[1116] = Hero.hitOnce,		--跳跃重脚
	--前跳
	[1120] = Hero.hitOnce,
	[1121] = Hero.hitOnce,
	[1122] = Hero.hitOnce,
	[1123] = Hero.hitOnce,
	--后跳
	[1124] = Hero.hitOnce,
	[1125] = Hero.hitOnce,
	[1126] = Hero.hitOnce,
	[1127] = Hero.hitOnce,

	--[1107] = hit_1107,
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

