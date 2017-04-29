module(...,package.seeall)
local GiftDefine = require("src/modules/gift/GiftDefine")
local GiftConfig = require("src/config/GiftConfig").Config
local GiftConditionConfig = require("src/config/GiftConditionConfig").Config
local GiftEffectConfig = require("src/config/GiftEffectConfig").Config
local GiftLogic = require('src/modules/gift/GiftLogic')

function doEffect(hero,index,...)
	local heroGift = GiftLogic.getHeroGift(hero.hero)--HeroGiftConfig[hero.hero.name].gift
	local giftId = heroGift[index]
	local giftCfg = GiftConfig[giftId]
	local giftEffectCfg = GiftEffectConfig[giftCfg.effect]
	print('----------------------------------doEffect,index,',hero.name,index,GiftDefine.EffectFunc[giftEffectCfg.etype])
	if _M[GiftDefine.EffectFunc[giftEffectCfg.etype]] then
		local ret = _M[GiftDefine.EffectFunc[giftEffectCfg.etype]](hero,giftCfg,...)
		if ret then
			return true
		else
			return false
		end
	end
	return false 
end

function doEffectByNextHero(hero,t)
	for k,giftId in pairs(t) do
		local giftCfg = GiftConfig[giftId]
		if _M[GiftDefine.EffectFunc[giftCfg.effect]] then
			local ret = _M[GiftDefine.EffectFunc[giftCfg.effect]](hero,giftCfg)
		end
	end
	return true
end

function addDyAttr(hero,giftCfg,field,value,time)
	hero.gift.dyAttr[field] = hero.gift.dyAttr[field] or 0
	
	if giftCfg.reset == 0 then
		value = value + hero.gift.dyAttr[field]
		--hero.gift.dyAttr[field] = 0
	end

	if hero.gift.timer[giftCfg.id] then
		hero:delTimer(hero.gift.timer[giftCfg.id])
		hero.gift.timer[giftCfg.id] = nil
	else
		hero.gift.dyAttr[field] = hero.gift.dyAttr[field] + value
	end
	local timerId = hero:addTimer(function()
		hero.gift.dyAttr[field] = hero.gift.dyAttr[field] - value
		hero.gift.timer[giftCfg.id] = nil
	end,time,1)
	hero.gift.timer[giftCfg.id] = timerId
end

function addPowBuf(hero,giftCfg)
	hero:addTimer(function() 
			hero:getInfo():addPower(giftCfg.effectArg[2])
		 end,giftCfg.effectArg[1],math.floor(giftCfg.effectTime/giftCfg.effectArg[1]))
end

function addPow(hero,giftCfg)
	hero:getInfo():addPower(giftCfg.effectArg[1])
end

function enemyNoPow(hero,giftCfg)
	hero.enemy.gift.noAddPower = true
	hero.enemy:addTimer(function()
		hero.enemy.gift.noAddPower = nil
	end,giftCfg.effectTime,1)
end

function powR(hero,giftCfg)
	addDyAttr(hero,giftCfg,"rageR",giftCfg.effectArg[1],giftCfg.effectTime)
end

function addHpBuf(hero,giftCfg)
	hero:addTimer(function() 
			hero:getInfo():addHp(giftCfg.effectArg[2])
		 end,giftCfg.effectArg[1],math.floor(giftCfg.effectTime/giftCfg.effectArg[1]))
end

function addHpRBuf(hero,giftCfg)
	hero:addTimer(function() 
			hero:getInfo():addHp(giftCfg.effectArg[2] * hero:getInfo():getMaxHp())
		 end,giftCfg.effectArg[1],math.floor(giftCfg.effectTime/giftCfg.effectArg[1]))
end

function addHp(hero,giftCfg)
	hero:getInfo():addHp(giftCfg.effectArg[1])
end

function addHpR(hero,giftCfg)
	hero:getInfo():addHp(giftCfg.effectArg[1] * hero:getInfo():getMaxHp())
end

function addHpWin(hero,giftCfg)
	addDyAttr(hero,giftCfg,"hpR",giftCfg.effectArg[1],giftCfg.effectTime)
end

function followCrt(hero,giftCfg)
	hero.gift.isCrtHit = true
end

function atk(hero,giftCfg)
	addDyAttr(hero,giftCfg,"atk",giftCfg.effectArg[1],giftCfg.effectTime)
end

function finalAtk(hero,giftCfg)
	addDyAttr(hero,giftCfg,"finalAtk",giftCfg.effectArg[1],giftCfg.effectTime)
end

function followFinalAtk(hero,giftCfg)
	hero.gift.followFinalAtk = hero.gift.followFinalAtk or 0
	--[[
	if giftCfg.reset == 1 then
		hero.gift.followFinalAtk = 0
	end
	--]]
	hero.gift.followFinalAtk = hero.gift.followFinalAtk + giftCfg.effectArg[1]
end

function followBlock(hero,giftCfg)
	hero.gift.isBlock = true
end

function def(hero,giftCfg)
	addDyAttr(hero,giftCfg,"def",giftCfg.effectArg[1],giftCfg.effectTime)
end

function finalDef(hero,giftCfg)
	addDyAttr(hero,giftCfg,"finalDef",giftCfg.effectArg[1],giftCfg.effectTime)
end

function atkSpeed(hero,giftCfg)
	--todo
end

function block(hero,giftCfg)
	addDyAttr(hero,giftCfg,"block",giftCfg.effectArg[1],giftCfg.effectTime)
end

function antiBlock(hero,giftCfg)
	addDyAttr(hero,giftCfg,"antiBlock",giftCfg.effectArg[1],giftCfg.effectTime)
end

function antiCrtHit(hero,giftCfg)
	addDyAttr(hero,giftCfg,"antiCrtHit",giftCfg.effectArg[1],giftCfg.effectTime)
end

function decHarmR(hero,giftCfg)
	addDyAttr(hero,giftCfg,"decHarmR",giftCfg.effectArg[1],giftCfg.effectTime)
end

function comboHarm(hero,giftCfg)
	addDyAttr(hero,giftCfg,"combo",giftCfg.effectArg[1],giftCfg.effectTime)
	
end

function breakHarm(hero,giftCfg)
	addDyAttr(hero,giftCfg,"break",giftCfg.effectArg[1],giftCfg.effectTime)
end

function addHarmR(hero,giftCfg)
	addDyAttr(hero,giftCfg,"addHarmR",giftCfg.effectArg[1],giftCfg.effectTime)
end

function nextHero(hero,giftCfg)
	hero.gift.nextHero[giftCfg.id] = giftCfg.effectArg[1]
end

function powHarm(hero,giftCfg)
	addDyAttr(hero,giftCfg,"pow",giftCfg.effectArg[1],giftCfg.effectTime)
end

function crtHit(hero,giftCfg)
	addDyAttr(hero,giftCfg,"crthit",giftCfg.effectArg[1],giftCfg.effectTime)
end

function comboHarmR(hero,giftCfg)
	addDyAttr(hero,giftCfg,"comboR",giftCfg.effectArg[1],giftCfg.effectTime)
	
end

function breakHarmR(hero,giftCfg)
	addDyAttr(hero,giftCfg,"breakR",giftCfg.effectArg[1],giftCfg.effectTime)
end


function powHarmR(hero,giftCfg)
	addDyAttr(hero,giftCfg,"powR",giftCfg.effectArg[1],giftCfg.effectTime)
end

function maxHp(hero,giftCfg)
	local add = hero:getInfo():getMaxHp() * giftCfg.effectArg[1]
	hero:getInfo():setMaxHp(hero:getInfo():getMaxHp() + add)
	--hero:getInfo():addHp(add)
end

--[[
function nextAtk(hero,giftCfg)
end

function nextCrtHit(hero,giftCfg)
end

function nextAntiCrthit(hero,giftCfg)
end
--]]
