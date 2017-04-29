module(...,package.seeall)
local Hero = require("src/modules/hero/Hero")
local Enemy = require("src/modules/hero/Enemy")

arena = arena or 
{
	fightList = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
	},
	rank = 0,
	leftTimes = 0,
	maxTimes = 0,
	nextTime = 0,
	enemyList = {
		[1] = {},
		[2] = {},
		[3] = {},
	}
}

function setArenaData(rank,fightList,leftTimes,maxTimes,nextTime,enemyList)
	arena = arena or {}
	if fightList then
		for i = 1,4 do
			arena.fightList[i] = {}
		end
		for k,v in pairs(fightList) do
			arena.fightList[v.pos] = fightList[k] or {}
		end
	--for i = 1,4 do
	--	arena.fightList[i] = fightList[i] or arena.fightList[i]
	--end
	end
	arena.rank = rank or arena.rank
	arena.leftTimes = leftTimes or arena.leftTimes
	arena.maxTimes = maxTimes or arena.maxTimes
	arena.nextTime = nextTime or arena.nextTime
	arena.enemyList = enemyList or arena.enemyList
	return arena
end

function setArenaFightList(fightList)
	--for i = 1,4 do
	--	arena.fightList[i] = fightList[i] or arena.fightList[i]
	--end
	for i = 1,4 do
		arena.fightList[i] = {}
	end
	for k,v in pairs(fightList) do
		arena.fightList[v.pos] = fightList[k] or {}
	end
end

function setArenaEnemyList(enemyList)
	for i = 1,3 do
		arena.enemyList[i] = enemyList[i] or arena.enemyList[i]
	end
end

function getArenaData()
	return arena
end

function getHeroList()
	local heroes = {}
	for i = 1,#arena.fightList do
		table.insert(heroes,Hero.heroes[arena.fightList[i].name])
		--table.insert(heroes,Hero.heroes["Terry2"])
		--table.insert(heroes,Hero.heroes["Terry"])
	end
	return heroes
end

function getEnemyHeroList(enemyId)
	local enemy = arena.enemyList[enemyId]
	local enemyHeroList = {}
	for k,v in pairs(enemy.fightList) do
		local hero = Enemy.new(v.name, v.exp, v.lv, v.quality, os.time(), v.dyAttr,v.skillGroupList,v.gift)
		table.insert(enemyHeroList,hero)
	end
	return enemyHeroList
end
