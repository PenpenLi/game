module(...,package.seeall)

local MonsterConfig = require("src/config/MonsterConfig").Config
local Monster = require("src/modules/hero/Monster")

local Define = require("src/modules/orochi/OrochiDefine")
local OrochiConfig = require("src/config/OrochiConfig").Config

local OrochiData = {}
Expedition = {}

function init()
	local list = {}
	for _,v in pairs(OrochiConfig) do
		local level = {}
		level.levelId = v.levelId
		if v.preLevelId == 0  then
			level.status = Define.STATUS.CAN_FIGHT
		else
			level.status = Define.STATUS.CLOSED
		end
		list[#list+1] = level
	end
	table.sort(list,function(a,b) return a.levelId < b.levelId end)
	OrochiData.levelList = list
	OrochiData.counter = 0
	OrochiData.resetCounter = 0
	OrochiData.curDayLevelId = 0
	if not Master.getInstance():hasEventListener(Event.MasterRefresh,updateOrochiList) then
		Master.getInstance():addEventListener(Event.MasterRefresh,updateOrochiList)
	end
end

function orochiQuery()
	Network.sendMsg(PacketID.CG_OROCHI_QUERY)
	--WaittingUI.create(PacketID.GC_OROCHI_QUERY)
end

function setCounter(num)
	OrochiData.counter = num
end

function setResetCounter(num)
	OrochiData.resetCounter = num
end

function setOrochiList(data,isUpdate,curDayLevelId)
	if not isUpdate then
		init()
	end
	for _,v in pairs(data) do
		local level = getLevelByLevelId(v.levelId)
		if v.status == 0 then v.status = Define.STATUS.CLOSED end	--db空记录
		level.status = v.status
		level.fightList = v.fightList
	end
	OrochiData.curDayLevelId = curDayLevelId
	updateOrochiList()
end

function updateOrochiList()
	local lv = Master.getInstance().lv
	--找出下个可挑战关卡
	local list = getLevelList()
	for _,v in pairs(list) do
		local conf = OrochiConfig[v.levelId]
		if v.status == Define.STATUS.CLOSED and lv >= conf.openLv then
			local preLevel = getLevelByLevelId(conf.preLevelId)
			if not preLevel or preLevel.status == Define.STATUS.HAD_PASS and conf.isOpen == 1 then
				v.status = Define.STATUS.CAN_FIGHT
			end
		end
	end
end

function getCanFightLevel()
	local list = getLevelList()
	for _,v in pairs(list) do
		if v.status == Define.STATUS.CAN_FIGHT then
			return v
		end
	end
end

function getResetCounter()
	return OrochiData.resetCounter
end

function getCounter()
	return OrochiData.counter
end

function getCurChapterId()
	local level = getCanFightLevel()
	local curChapterId = 0
	if level then
		curChapterId = OrochiConfig[level.levelId].parentId
	else
		local list = getLevelList()
		local curLevelId = 0
		local pos = 0
		for i,v in ipairs(list) do
			local conf = OrochiConfig[v.levelId]
			if v.status == Define.STATUS.HAD_PASS and v.levelId >= curLevelId then
				curChapterId = conf.parentId
				curLevelId = v.levelId
				pos = i
			end
		end
		if list[pos+1] then
			local conf = OrochiConfig[list[pos+1].levelId]
			curChapterId = conf.parentId 
		end
	end
	return curChapterId
end

function getLevelList(chapterOnly)
	if chapterOnly then
		local curId = getCurChapterId()
		local list = {}
		for _,v in ipairs(OrochiData.levelList) do
			if OrochiConfig[v.levelId].parentId == curId then
				list[#list+1] = v
			end
		end
		return list
	else
		return OrochiData.levelList
	end
end

--获取当前已上阵过的英雄
function getHadFightHeroList()
	local curId = getCurChapterId()
	local list = {}
	for _,v in ipairs(OrochiData.levelList) do
		if OrochiConfig[v.levelId].parentId == curId and v.status == Define.STATUS.HAD_PASS and  v.fightList then
			if v.fightList[1] then
				list[v.fightList[1]] = v.fightList[1]
			end
		end
	end
	return list
end

function getLevelByLevelId(levelId)
	local list = getLevelList()
	for _,v in pairs(list) do
		if v.levelId == levelId then
			return v
		end
	end
	return
end

function getLevelMonster(levelId)
	local conf = OrochiConfig[levelId]
	assert(conf,"lost level conf====>" .. levelId)
	local list = {}
	list[1] = Monster.new(conf.monster[1])
	list[4] = Monster.new(conf.monster[2])
	return list
end


function getLevelBoss(levelId)
	local monsters = getLevelMonster(levelId)
	return monsters[1]
end

function fight(levelId,heroFightList)
	local heroList = {}
	for i=1,4 do
		local name = heroFightList[i]
		if not name then
			name = ""
		end
		heroList[#heroList+1] = name
	end
	Network.sendMsg(PacketID.CG_OROCHI_FIGHT,levelId,heroList)
end

function getLevelItem(levelId)
	local conf = OrochiConfig[levelId]
	local itemList = {}
	for k,v in pairs(conf.reward) do
		if type(k) == 'number' then
			itemList[#itemList+1] = k
		end
	end
	return itemList
end

function canWipe()
	local level = getCanFightLevel()
	if not level or OrochiData.curDayLevelId <= 0 then
		return false
	end
	return level.levelId <= OrochiData.curDayLevelId
end

init()







