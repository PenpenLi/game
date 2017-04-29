module(..., package.seeall)
local Define = require("src/modules/announce/AnnounceDefine")

local AnnounceConfig = require("src/config/AnnounceConfig").Config
local AnnounceList = {}

function init()
	local master = Master.getInstance()
	master:addEventListener(Event.MasterRefresh,function()
		Stage.addTimer(doAnnounce,60,-1)
	end)
end

function setAnnounceList(list)
	for _,v in pairs(list) do
		AnnounceList[v.id] = v
	end
end

function addAnnounceList(list)
	for _,v in pairs(list) do
		if v.type == Define.TYPE_ONCE then
			show(v)
		else
			AnnounceList[v.id] = v 
		end
	end
end

function delAnnounce(id)
	AnnounceList[id] = nil
end

function doAnnounce()
    local now = os.time()
    local nowTb = os.date("*t",now) 
	local parseTime = function(v)
        if v.startTime <= now and v.endTime >= now then
            if v.type == 1 then       --定时播放
                if v.hour == nowTb.hour and v.min == nowTb.min then
					show(v)
                end
            elseif v.type == 2 then     --循环播放
                if math.floor(now/60)%v.interval == 0 then
					show(v)
                end
            end
        end
	end
    for _,v in pairs(AnnounceList) do
		parseTime(v)
    end
    for _,v in pairs(AnnounceConfig) do
		parseTime(v)
	end
end

function getLoginAnnounce()
	local announce
	for id,v in pairs(AnnounceList) do
		if v.type == Define.TYPE_LOGIN then
			announce = v
			break
		end
	end
	if not announce then
		for _,v in pairs(AnnounceConfig) do
			if v.type == Define.TYPE_LOGIN then
				announce = v
			end
		end
	end
	return announce
end

function showLoginAnnounce()
	local announce = getLoginAnnounce()
	if announce then
		if Stage.currentScene.name ~= 'main' then
			return
		end
		if not Master.getInstance().loginAnnounce then
			UIManager.addUI("src/modules/announce/ui/AnnounceUI",announce)
		end
	end
end

function show(announce)
	--local ui = require("src/modules/announce/ui/MarqueeUI").new("AnnounceMsg_" .. msgIndex,announce.content)
	local ui = require("src/modules/announce/ui/MarqueeUI").getInstance()
	ui:addAnnounce(announce.content)
	--[[
	--UIManager.replaceUI("src/modules/announce/ui/MarqueeUI","AnnounceMsg_" .. msgIndex,announce.content)
	announce.type      = announce.type
	announce.pos       = announce.pos
	announce.startTime = announce.startTime
	announce.endTime   = announce.endTime 
	announce.hour      = announce.hour
	announce.min       = announce.min 
	announce.interval  = announce.interval 
	announce.title     = announce.title 
	announce.content   = announce.content 
	Common.showMsg(announce.content)
	--]]
end

init()





