module(...,package.seeall)

local rankList = rankList or {}

function setRankList(list)
	rankList = list
end

function getRankList()
	return rankList
end
