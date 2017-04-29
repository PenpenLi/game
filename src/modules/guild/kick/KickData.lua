module(...,package.seeall)
SettlementUI = require('src/modules/guild/kick/ui/SettlementUI')
fightList = fightList or {}
cnt = cnt or 0
enemyFightList = enemyFightList or {}

function setFightList(list)
	SettlementUI.fightList = list
	fightList = list
end

function getCnt()
	return cnt
end

function getFightList()
	return fightList
end

function setEnemyFightList(guildId,memberId,fightList)
	enemyFightList[guildId] = enemyFightList[guildId] or {}
	enemyFightList[guildId][memberId] = fightList
end

function getEnemyFightList(guildId,memberId)
	if enemyFightList[guildId] then
		local list = enemyFightList[guildId][memberId]
		local ret = {}
		for k,v in pairs(list) do
			ret[v.pos] = v
		end
		return ret
	end
end
