module(...,package.seeall)

local ItemConfig = require("src/config/ItemConfig").Config
local TDefine = require("src/modules/treasure/TreasureDefine")
local PublicLogic = require("src/modules/public/PublicLogic")
safeStartTime = safeStartTime or 0
safeEndTime = safeEndTime or 0

-- 自己的矿
mine = {}
--assist = {}
mapInfoTime = 0
mineList = {}  -- 地图中的矿

fightTimes = 0
refreshMapTimes = 0
extendTimes = 0
safeTimes = 0
doubleTimes = 0

function refreshMineInfo(mineInfo)
	for i,m in ipairs(mineList) do 
		if m.mineId == mineInfo.mineId then
			mineList[i] = mineInfo
		end
	end

end

function sendTreasureConsume(consumeId,mineId)
	Network.sendMsg(PacketID.CG_TREASURE_CONSUME,consumeId,mineId)
end
function sendTreasureStartOccupy(mineId)
	Network.sendMsg(PacketID.CG_TREASURE_START_OCCUPY,mineId)
end

function sendTreasureRecord()
	Network.sendMsg(PacketID.CG_TREASURE_RECORD)
end	
function sendTreasureQueryOccupied()
	Network.sendMsg(PacketID.CG_TREASURE_QUERY_OCCUPIED)
end
function sendTreasureMineInfo(mineId)
	Network.sendMsg(PacketID.CG_TREASURE_MINE_INFO,mineId)
end
function sendTreasureMapInfo(refresh)
	Network.sendMsg(PacketID.CG_TREASURE_MAP_INFO,refresh)
end
function sendTreasureChar()
	Network.sendMsg(PacketID.CG_TREASURE_CHAR)
end
function setMapInfo(mapInfoTime,mineList)
	mapInfoTime = mapInfoTime
	mineList = mineList
end

function isFreeSafe()
	return not Common.isToday(safeStartTime)
end


function getMineList()
	local mlist = {}
	for mineId,m in pairs(mine) do
		if m and m.account == Master.getInstance().account then
			table.insert(mlist,m)
		end
	end
	local function msort(a,b)
		return a.mineId < b.mineId
	end
	table.sort(mlist,msort)
	return mlist
end
--[[取消协助
function isInAssist(districtId,mineId)
	for i=1,2 do
		local a = assist 
		if a[i].districtId == districtId and a[i].mineId == mineId then
			return true
		end
	end
	return false
end
--]]
function getReward(reward)
	local r = ''
	-- for itemId,cnt in pairs(reward) do
	-- 	local name = ItemConfig[itemId].name
	-- 	r = r .. 'name*'..cnt.." "
	-- end
	for i,item in ipairs(reward) do
		local name = ItemConfig[item.itemId].name
		local cnt = item.cnt
		r = r .. name..'*'..cnt.." "
	end
	return r
end

-- function isHeroValid(name)
-- 	for i=1,TDefine.MAX_MINE_PER_PLAYER do
-- 		if mine[i] and mine[i].mineId > 0 then
-- 			for i,h in ipairs(mine[i].hero) do 
-- 				if h == name then
-- 					return false
-- 				end
-- 			end
-- 		end
-- 	end

-- 	return true
-- end
function getBusyHeroes()
	local heroes = {}
	for mId,mineInfo in pairs(mine) do
		for i=1,4 do
			if mineInfo.hero[i] and mineInfo.hero[i] ~= '' then
				table.insert(heroes,mineInfo.hero[i])
			end
		end
	end
	return heroes
end

function getForbidHero(mineId)
	--districtId,mineId 当前选择的矿id，禁止其他矿的守护英雄
	local forbid = {}
	-- for i=1,TDefine.MAX_MINE_PER_PLAYER do
	-- 	if i ~= self.selectedKuang then
	-- 		for j=1,4 do
	-- 			if Treasure.mine[i].hero[j] and Treasure.mine[i].hero[j] ~= '' then
	-- 				table.insert(forbid,Treasure.mine[i].hero[i])
	-- 			end
	-- 		end
	-- 	end
	-- end
	for mId,mineInfo in pairs(mine) do
		if mId ~= mineId then
			for i=1,4 do
				if mineInfo.guard[i] and mineInfo.guard[i].name ~= '' then
					table.insert(forbid,mineInfo.guard[i].name)
				end
			end
		end
	end
	return forbid
end

-- function getMineNo(mineId)
-- 	local no = 0
-- 	for i=1,TDefine.MAX_MINE_PER_PLAYER do
-- 		if mine[i] and mineId == mine[i].mineId then
-- 			no = i
-- 			break
-- 		end
-- 	end
-- 	return no
-- end

function getMineCnt()
	-- 获得现在拥有几个矿
	local cnt = 0
	for mineId,_ in pairs(mine) do
		cnt = cnt + 1
	end
	return cnt
end

--[[取消协助
function getAssistBonus(assistNum)
	-- 协助加成  assistNum协助的个数
	if assistNum == 1 then
		return 0.2
	elseif assistNum >= 2 then
		return 0.3
	else
		return 0
	end
end
--]]

function openTreasureUI()
	if PublicLogic.isModuleOpened('treasure') then
		local ui = WaittingUI.create(PacketID.GC_TREASURE_MAP_INFO)
		ui:addEventListener(WaittingUI.Event.Timeout,function()
			local tipsUI = TipsUI.showTopTips("网络不太好哦,请重试")
			tipsUI:addEventListener(Event.Confirm,function(self,event) 
				if event.etype == Event.Confirm_yes then
					openTreasureUI()
				elseif event.etype == Event.Confirm_no then
					ui:removeFromParent()
				end
			end)
		end,self)
		Network.sendMsg(PacketID.CG_TREASURE_MAP_INFO)
	end
end
