module(...,package.seeall)

local Enemy = require("src/modules/hero/Enemy")
local Data = require("src/modules/peak/PeakData")
local Hero = require("src/modules/hero/Hero")
local Define = require("src/modules/peak/PeakDefine")
local PeakConfig = require("src/config/PeakConfig").Config[1]

function composeHeroList(list)
	local tab = {}
	for _,name in ipairs(list) do
		print('hname =======================' .. name)
		local hero = Hero.getHero(name)
		table.insert(tab, hero)
	end
	print('len ==============' .. #tab)
	Data.getInstance():setPrepareHeroList(tab)
end

function composeFightEnemyList(data)
	local tab = {}
	print('showEnemy=====================================')
	Common.printR(data)
	for _,enemy in ipairs(data) do
		print('compose enemy.name ===========' .. enemy.name)
		local hero = Enemy.new(enemy.name, enemy.exp, enemy.lv, enemy.quality, index, Common.deepCopy(enemy.dyAttr), enemy.skillGroupList, enemy.gift)
		table.insert(tab, hero)
	end
	Data.getInstance():setEnemyHeroList(tab)	
end

function composeFightHeroList(data)
	local tab = {}
	for _,name in ipairs(data) do
		local hero = Hero.getHero(name)
		table.insert(tab, hero)
	end
	Data.getInstance():setFightHeroList(tab)
end

function isOpen()
	local left = Common.getCronEventLeftTime(Define.CRONTAB_PEAK)
	if left > (24*3600-PeakConfig.continueTime) then
		return true
	end
	return false
end

function getLeftTime()
	local left = Common.getCronEventLeftTime(Define.CRONTAB_PEAK)
	return left - (24*3600 - PeakConfig.continueTime)	
end

