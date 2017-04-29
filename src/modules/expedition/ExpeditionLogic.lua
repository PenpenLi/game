module(...,package.seeall)

local Enemy = require("src/modules/hero/Enemy")
local expeditionData = require("src/modules/expedition/ExpeditionData").getInstance()
local Hero = require("src/modules/hero/Hero")
local TreasureConfig = require("src/config/ExpeditionTreasureConfig").Config
local BagDefine = require("src/modules/bag/BagDefine")

function composeEnemyList()
	local list = expeditionData:getEnemyList()
	local tab = {}
	for index,enemy in pairs(list) do
		Common.printR(enemy.dyAttr)
		local hero = Enemy.new(enemy.name, enemy.exp, enemy.lv, enemy.quality, index, Common.deepCopy(enemy.dyAttr), enemy.skillGroupList, enemy.gift)
		hero.fightAttr.hp = enemy.hp
		table.insert(tab, hero)
	end
	expeditionData:setEnemyHeroList(tab)
end

function composeHeroList()
	local list = expeditionData:getHeroList()
	local tab = {}
	for index,heroData in pairs(list) do
		local hero = Hero.getHero(heroData.name)
		print('name ===============================' .. heroData.name)
		--local hero = Enemy.new(curHero.name, curHero.exp, curHero.lv, curHero.quality, index, Common.deepCopy(curHero.dyAttr), Common.deepCopy(curHero:getSkillGroupList()))
		hero.fightAttr.hp = heroData.hp / 100 * hero.dyAttr.maxHp
		tab[heroData.name] = hero
	end
	expeditionData:setMyHeroList(tab)
end

function getTreasureConfig(pos)
	local lv = Master.getInstance().lv
	for _,config in pairs(TreasureConfig) do
		if pos == config.pos and config.startLv <= lv and lv <= config.endLv then
			return config
		end
	end
end

function getClearReward(passId)
	local tb = {}
	for i=1,passId-1 do
		if expeditionData:hasGetTreasure(i) == false then
			local config = getTreasureConfig(i)
			local data = {}
			data.reward = {}
			for k,v in pairs(config.rewardList) do
				if k ~= 'randType' then
					local t = {}
					if k == 'money' then
						t.rewardName = BagDefine.ITEM_ID_MONEY
					else
						t.rewardName = k
					end
					t.cnt = v[1]
					table.insert(data.reward, t)
				end
			end

			local record = {title='巡回赛第'..i..'关', reward=data}
			table.insert(tb, record)
		end
	end
	return tb
end
