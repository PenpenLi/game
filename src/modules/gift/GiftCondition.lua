module(...,package.seeall)
local GiftDefine = require("src/modules/gift/GiftDefine")
--local HeroGiftConfig = require("src/config/HeroDefineConfig").Config
local GiftConfig = require("src/config/GiftConfig").Config
local GiftConditionConfig = require("src/config/GiftConditionConfig").Config
local GiftEffectConfig = require("src/config/GiftEffectConfig").Config
local GiftLogic = require('src/modules/gift/GiftLogic')
local FightDefine = require("src/modules/fight/Define")

function checkCondition(hero,t,index,...)
	--print('--------------------------checkCondition:',hero.name,GiftDefine.ConditionFunc[t],t,index)
	hero.gift = hero.gift or {}
	hero.gift.cnt = hero.gift.cnt or {}
	hero.gift.cd = hero.gift.cd or {}
	local heroGift = GiftLogic.getHeroGift(hero.hero)--HeroGiftConfig[hero.hero.name].gift
	local giftId = heroGift[index]
	local giftCfg = GiftConfig[giftId]
	local giftConditionCfg = GiftConditionConfig[giftCfg.condition]
	for _,s in ipairs(giftCfg.obviate) do
		if Stage.currentScene.fightType == s then
			print('------------------0--------------------:',s)
			return false
		end
	end
	if t ~= giftConditionCfg.ctype then
		--print('------------------1--------------------:',giftConditionCfg.ctype)
		return false
	end
	hero.gift.cnt[giftId] = hero.gift.cnt[giftId] or 0
	if hero.gift.cnt[giftId] >= giftCfg.cnt and giftCfg.cnt ~= -1 then
		--print('------------------2--------------------')
		return false
	end
	local time = os.clock()
	hero.gift.cd[giftId] = hero.gift.cd[giftId] or 0
	if time - hero.gift.cd[giftId] < giftCfg.cd then
		--print('------------------3--------------------')
		return false
	end

	if _M[GiftDefine.ConditionFunc[t]] then
		local ret,ret2 = _M[GiftDefine.ConditionFunc[t]](hero,giftCfg,...)
		if ret then
			hero.gift.cnt[giftId] = hero.gift.cnt[giftId] + 1
			hero.gift.cd[giftId] = time
			print('--------------------------condition success--------------------:',ret2)
			return true,ret2
		else
		print('------------------4--------------------')
			return false
		end
	end
	print('------------------5--------------------')
	return false 
end

function all(hero,giftCfg)
	return true
end

function teammateFight(hero,giftCfg)
	local fightControl = Stage.currentScene.fightControl
	local list
	if hero.name == "heroA" then
		list = fightControl.heroAList
	else
		list = fightControl.heroBList
	end
	for k = 1,#list - 1 do
		if list[k].name == giftCfg.conditionArg[1] then
			return true
		end
	end
	return false
end

function teammateAssist(hero,giftCfg)
	local fightControl = Stage.currentScene.fightControl
	local name 
	if hero.name == "heroA" then
		name = fightControl:getAssistA().name
	else
		name = fightControl:getAssistB().name
	end
	if name == giftCfg.conditionArg[1] then
		return true
	else
		return false
	end
end

function useSkill(hero,giftCfg,groupId)
	if giftCfg.conditionArg[1] == -1 or giftCfg.conditionArg[1] == groupId then
		return true
	else
		return false
	end
end

function useCombo(hero,giftCfg)
	return true
end

function useBreak(hero,giftCfg)
	return true
end

function usePow(hero,giftCfg)
	return true
end

function hit(hero,giftCfg,hitCnt)
	if hitCnt >= giftCfg.conditionArg[1] then
		return true
	else
		return false
	end
end

function opponent(hero,giftCfg)
	if hero.enemy.hero.name == giftCfg.conditionArg[1] then
		return true
	else
		return false
	end
end

function crtHit(hero,giftCfg)
	return true
end

function block(hero,giftCfg)
	return true
end

function enemyCrtHit(hero,giftCfg)
	return true
end

function enemyBlock(hero,giftCfg)
	return true
end

function hp(hero,giftCfg,hpPre)
	--return  hpPre >= giftCfg.conditionArg[1] and hero:getInfo():getHp() < giftCfg.conditionArg[1]
	return  hero:getInfo():getHp() < giftCfg.conditionArg[1]
end

function hpR(hero,giftCfg,hpRPre)
	--print('-------------------------hpRPre,arg[1]:',hpRPre,giftCfg.conditionArg[1])
	--return hpRPre >= giftCfg.conditionArg[1] and hero:getInfo():getHpPercent() / 100 < giftCfg.conditionArg[1]
	return hero:getInfo():getHpPercent() / 100 < giftCfg.conditionArg[1]
end

function decHp(hero,giftCfg,hp)
	hero.gift.decHp = hero.gift.decHp or 0
	hero.gift.decHp = hero.gift.decHp + hp
	if hero.gift.decHp >= giftCfg.conditionArg[1] then
		local cnt = math.floor(hero.gift.decHp / giftCfg.conditionArg[1])
		hero.gift.decHp = hero.gift.decHp % giftCfg.conditionArg[1]
		return true,cnt
	end
	return false
end

function decHpR(hero,giftCfg,hpR)
	hero.gift.decHpR = hero.gift.decHpR or 0
	hero.gift.decHpR = hero.gift.decHpR + hpR
	if hero.gift.decHpR >= giftCfg.conditionArg[1] then
		local cnt = math.floor(hero.gift.decHpR / giftCfg.conditionArg[1])
		hero.gift.decHpR = hero.gift.decHpR % giftCfg.conditionArg[1]
		return true,cnt
	end
	return false 
end

function pow(hero,giftCfg)
	local cnt = hero:getInfo():getPowerCnt(FightDefine.powPower)
	if cnt >= giftCfg.conditionArg[1] then
		return true
	else
		return false
	end

end

function roundEnd(hero,giftCfg)
	return true
end

function win(hero,giftCfg)
	return true
end

function lost(hero,giftCfg)
	return true
end

function beat(hero,giftCfg)
	return true
end

function heroIndex(hero,giftCfg)
	local fightControl = Stage.currentScene.fightControl
	local list
	local nowIndex
	if hero.name == "heroA" then
		list = fightControl.heroAList
		nowIndex = fightControl.heroAIndex
	else
		list = fightControl.heroBList
		nowIndex = fightControl.heroBIndex
	end
	if giftCfg.conditionArg[1] > 0 then
		return giftCfg.conditionArg[1] == nowIndex
	else
		return #list + giftCfg.conditionArg[1] == nowIndex
	end
end

function enemyIndex(hero,giftCfg)
	local fightControl = Stage.currentScene.fightControl
	local list
	local nowIndex
	if hero.name == "heroB" then
		list = fightControl.heroAList
		nowIndex = fightControl.heroAIndex
	else
		list = fightControl.heroBList
		nowIndex = fightControl.heroBIndex
	end
	if giftCfg.conditionArg[1] > 0 then
		return giftCfg.conditionArg[1] == nowIndex
	else
		return #list + giftCfg.conditionArg[1] == nowIndex
	end
end

function hpGt(hero,giftCfg)
	return hero:getInfo():getHp() > hero.enemy:getInfo():getHp()
end

function hpLt(hero,giftCfg)
	return hero:getInfo():getHp() < hero.enemy:getInfo():getHp()
end
