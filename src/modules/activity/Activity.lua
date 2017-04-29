module(...,package.seeall)

local def = require("src/modules/activity/ActivityDefine")
local FoundationConfig = require("src/config/FoundationActivityConfig").Config
local ActivityConfig = require("src/config/ActivityConfig").Config
ActivityList = ActivityList or {}

ActivityDb = {}

monthCardRewardDay = 0

monthCardEndDay = 0

foundationBuy = 0

vipGift = {}

monthCardInfo = {}

function setActivityInfo(aid,info)
	ActivityList[aid] = info
end

function setActivityItem(aid,id,status)
	if ActivityList[aid] == nil  then ActivityList[aid] = {} end
	ActivityList[aid][id] = {status = status}
end
function getActivityStatus(activityId,id)
	local a = ActivityList
	if ActivityList[activityId] and ActivityList[activityId][id] and ActivityList[activityId][id].status > 0 then
		return ActivityList[activityId][id].status
	else
		return def.STATUS_NOTCOMPLETED
	end
end

function sendReward(activityId,id)
	Network.sendMsg(PacketID.CG_ACTIVITY_REWARD,activityId,id)
end

function sendFoundationBuy()
	Network.sendMsg(PacketID.CG_ACTIVITY_FOUNDATION_BUY)
end

function getFoundationRmb()
	local rewardRmb = 0
	local remainRmb = 0
	for i,cfg in ipairs(FoundationConfig) do
		local status =  getActivityStatus(def.FOUNDATION_ACT,i)
		if status == def.STATUS_REWARDED then
			for _,cnt in pairs(cfg.reward) do
				rewardRmb = rewardRmb + cnt
			end
		else
			for _,cnt in pairs(cfg.reward) do
				remainRmb = remainRmb + cnt
			end
		end
	end
	return rewardRmb,remainRmb
end

function setActivityStatus(activityId,id)
end

-- function getActivityUINo(actId)
-- 	if actId == def.DAY_ACT or actId == def.LEVEL_ACT or actId == def.PHYSICS_ACT then
-- 		return 1
-- 	elseif actId == def.FIRSTCHARGE_ACT or actId == MONTHCARD_ACT then
-- 		return 2
-- 	else
-- 		return 0
-- 	end
-- end


function isActivityValid(actId)
	-- 判断actId活动是否可领取 actId=0表示所有活动
	if actId == 0 or actId == nil then
		for aid,_ in pairs(def.ActivityDefineList) do
			local ret = isActivityValid(aid)
			if ret then
				return true
			end
		end
		return false
	elseif def.ActivityDefineList[actId] and isActivityOpened(actId) then
		if actId == def.PHYSICS_ACT then
			local t = Master.getInstance().getServerTime()
			local pno = 0
			for i,p in ipairs(def.PHYSICS_PERIODS) do
				if Common.getTimeByStr(p.stime) <= t and Common.getTimeByStr(p.etime) >= t then
					pno = i
					break
				end
			end
			if pno > 0 then
				local alist = ActivityList
				if ActivityList[actId] and ActivityList[actId][pno] and ActivityList[actId][pno].status == def.STATUS_NOTCOMPLETED then
					return true
				else
					return false
				end
			else
				return false
			end
		elseif actId == def.MONTHCARD_ACT then
			for i=1,2 do
				if monthCardInfo[i].lastReceiveTime < monthCardInfo[i].monthCardEndDay and  monthCardInfo[i].lastReceiveTime <= Common.GetTodayTime() then
					return true
				end
			end
			return false
		elseif actId == def.FIRSTCHARGE_ACT then
			if getActivityStatus(def.FIRSTCHARGE_ACT,1) ~= def.STATUS_REWARDED then
				return true
			else
				return false
			end
		end
		local aa = ActivityList
		for id ,s in pairs(ActivityList[actId] or {}) do
			if s.status == def.STATUS_COMPLETED then
				return true
			end
		end
	else
		return false
	end
end
function isActivity2Valid()
	for id,s in pairs(ActivityList[def.FIRSTCHARGE_ACT]) do
		if s.status == def.STATUS_COMPLETED then
			return true
		end
	end
	return false
end

function getActivityPeriod(activityId)
	local cfg = ActivityDb[activityId]
	if cfg == nil or cfg == {} or cfg.type == 0 then
		cfg = ActivityConfig[activityId]
	end
	if cfg.type == 1 then
		return
	elseif cfg.type == 2 then
		local stime,stimeTable = Common.getTimeByString(cfg.startTime)
		local etime,etimeTable = Common.getTimeByString(cfg.endTime)
		return stime,etime,stimeTable,etimeTable
	elseif cfg.type == 3 then
		local stime = Master.getInstance().createDate
		local stimeTable = os.date("*t",stime)
		local etime = Master.getInstance().createDate + cfg.openDay*24*3600 
		local etimeTable = os.date("*t",etime)
		return stime,etime,stimeTable,etimeTable
	elseif cfg.type == 4 then
		local stime = Master.getInstance().createServer
		local stimeTable = os.date("*t",stime)
		local etime = stime + cfg.openDay*24*3600
		local etimeTable = os.date("*t",etime)
		return stime,etime,stimeTable,etimeTable
	end
end

function isActivityOpened(activityId)
	local cfg = ActivityDb[activityId]
	if cfg == nil or next(cfg) == nil or cfg.type == 0 then
		cfg = ActivityConfig[activityId]
	end

	if cfg.opened == 2 then
		return false
	end
	-- 等级限制
	local master = Master.getInstance()
	if cfg.minLv and cfg.minLv ~= 0 and master.lv < cfg.minLv then
		return false
	end
	if cfg.maxLv and cfg.maxLv ~= 0 and master.lv > cfg.maxLv then
		return false
	end

	if activityId == def.FIRSTCHARGE_ACT then
		if getActivityStatus(def.FIRSTCHARGE_ACT,1) == def.STATUS_REWARDED then
			return false
		end
	end

	--　时间限制
	local now = Master.getServerTime()
	if cfg.type == 1 then
		return true
	elseif cfg.type == 2 then
		local stime,stimeTable = Common.getTimeByString(cfg.startTime)
		local etime,etimeTable = Common.getTimeByString(cfg.endTime)
		if now < stime or now > etime then
			return false
		end
	elseif cfg.type == 3 then
		if now >= master.createDate + cfg.openDay*24*3600 then
			return false
		end
	elseif cfg.type == 4 then
		if Common.getServerDay() > cfg.openDay then
			return false
		end

	else
		return false
	end


	return true
end
