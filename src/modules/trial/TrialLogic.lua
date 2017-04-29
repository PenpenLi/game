module(...,package.seeall)

local MonsterConfig = require("src/config/MonsterConfig").Config
local Monster = require("src/modules/hero/Monster")

local Define = require("src/modules/trial/TrialDefine")
local Config = require("src/config/TrialConfig").Config

local lastUpdateDate = 0

local TrialData = {}
local TypeFightList = {}

function init()
	local list = {}
	local typeCounter = {}
	for _,v in pairs(Config) do
		local level = {}
		level.levelId = v.levelId
		level.counter = 0 
		level.fightList = {}
		if v.preLevelId == 0 then
			level.status = Define.STATUS.CAN_FIGHT
		else
			level.status = Define.STATUS.CLOSED
		end
		list[#list+1] = level
		typeCounter[v.type] = 0
	end
	table.sort(list,function(a,b) return a.levelId < b.levelId end)

	TrialData.levelList = list
	TrialData.typeCounter = typeCounter
	if not Master.getInstance():hasEventListener(Event.MasterRefresh,updateTrialList) then
		Master.getInstance():addEventListener(Event.MasterRefresh,updateTrialList)
	end
end


function setTrial(list,typeCounterList)
	for _,v in pairs(list) do
		local level = getLevelByLevelId(v.levelId)
		level.status = v.status 
		level.fightList = v.fightList or {}
		TypeFightList[Config[v.levelId].type] = level.fightList
	end
	local typeCounter = TrialData.typeCounter
	for _,v in pairs(typeCounterList) do
		typeCounter[v.type] = v.counter
	end
	updateTrialList()
end

function updateTrialList()
	local lv = Master.getInstance().lv
	--找出下个可挑战关卡
	local list = getLevelList()
	for _,v in pairs(list) do
		local conf = Config[v.levelId]
		if lv >= conf.openLv then
			local preLevel = getLevelByLevelId(conf.preLevelId)
			if not preLevel or preLevel.status == Define.STATUS.HAD_PASS then
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
	return
end

--function getCounter(type)
function getCounterByType(type)
	local typeCounter = TrialData.typeCounter
	return typeCounter[type]
end

function getLevelList()
	return TrialData.levelList
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
	local conf = Config[levelId]
	local monsters = Common.deepCopy(conf.monster)
	local list = {}
	--默认最后一位为援助
	list[4] = Monster.new(monsters[#monsters])
	monsters[#monsters] = nil
	for i=1,3 do
		if monsters[i] then
			list[i] = Monster.new(monsters[i])
		end
	end
	return list
end

function getLevelBoss(levelId)
	local monsters = getLevelMonster(levelId)
	return monsters[1]
end

function fight(levelId,fightList)
	local heroList = {}
	for i=1,4 do
		local name = fightList[i]
		if not name then
			name = ""
		end
		heroList[#heroList+1] = name
	end
	Network.sendMsg(PacketID.CG_TRIAL_FIGHT,levelId,heroList)
end

function fightEnd(res,levelId,killCnt)
	Network.sendMsg(PacketID.CG_TRIAL_FIGHT_END,res,levelId,killCnt)
end

function getLevelItem(levelId)
	local conf = Config[levelId]
	assert(conf.showReward,"lost showReward==>" .. levelId)
	return conf.showReward
end

function reset()
	init()
	updateTrialList()
end

function getFightListById(levelId)
	local level = getLevelByLevelId(levelId)
	if not next(level.fightList) then
		TypeFightList[Config[levelId].type] = TypeFightList[Config[levelId].type] or {}
		return TypeFightList[Config[levelId].type]
	end
	return level.fightList
end

init()

--[[
function resetByDay()
	if lastUpdateDate ~= os.date("%d") then
		Network.sendMsg(PacketID.CG_TRIAL_QUERY)
		local ui = WaittingUI.create(PacketID.GC_TRIAL_QUERY)
		ui:addEventListener(WaittingUI.Event.Timeout,function()
			local tipsUI = TipsUI.showTopTips("网络不太好哦,请重试")
			tipsUI:addEventListener(Event.Confirm,function(self,event) 
				if event.etype == Event.Confirm_yes then
					resetByDay()
				elseif event.etype == Event.Confirm_no then
					ui:removeFromParent()
				end
			end)
		end)
	end
end
--]]







