module(...,package.seeall)
local Hero = require("src/modules/hero/Hero")
--local HeroGiftConfig = require("src/config/HeroGiftConfig").Config
local GiftConfig = require("src/config/GiftConfig").Config
local GiftConditionConfig = require("src/config/GiftConditionConfig").Config
local GiftEffectConfig = require("src/config/GiftEffectConfig").Config
local GiftCondition = require("src/modules/gift/GiftCondition")
local GiftEffect = require("src/modules/gift/GiftEffect")
local MonsterConfig = require("src/config/MonsterConfig").Config
--local HeroConfig = require("src/config/HeroDefineConfig").Config
local HeroDefine = require("src/modules/hero/HeroDefine")
local GiftDefine = require("src/modules/gift/GiftDefine")

function isActivate(hero,index)
	return hero.gift[index] and hero.gift[index] == 1
end

function canActivate(hero,index)
	local ret = true
	local quality = true
	local transferLv = true
	local cfg = HeroDefine.DefineConfig[hero.name].giftCondition[index]
	if hero.quality < cfg[2] then
		--Common.showMsg("英雄星级不够")
		--return false
		ret = false
		quality = false
	end
	if hero.strength.transferLv < cfg[3] then
		--Common.showMsg("英雄宝石阶数不够")
		ret = false
		transferLv = false
		--return false
	end
	return ret,quality,transferLv
end

function getHeroGift(hero)
	if hero.monsterId then
		return MonsterConfig[hero.monsterId].gift
	else
		return HeroDefine.DefineConfig[hero.name].gift
	end
end
 
function checkDot(hero)
	if Master:getInstance().lv < 16 then
		return false
	end
	local gift = hero.gift
	for k = 1,GiftDefine.MAX_GIFT do 
		if not isActivate(hero,k) and canActivate(hero,k) then
			return true
		end
	end
	return false
end

--hero为战斗对象
function checkGift(hero,t,...)
	local gift = hero.hero.gift
	for index,isActivate in ipairs(gift) do
		if isActivate == 1 then
			local ret,ret2 = GiftCondition.checkCondition(hero,t,index,...)
			ret2 = ret2 or 1
			if ret then
				for k = 1,ret2 do
					GiftEffect.doEffect(hero,index,...)
				end
			end
		end
	end
end

function doEffectByNextHero(hero,t)
	GiftEffect.doEffectByNextHero(hero,t)
end
