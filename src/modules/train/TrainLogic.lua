module(..., package.seeall)
local TrainLimitConfig = require("src/config/TrainLimitConfig").Config
local TrainDefine = require("src/modules/train/TrainDefine")
LimitConfig = LimitConfig or {}

function getTrainLimitConfig()
	if not next(LimitConfig) then
		initTrainLimitConfig()
	end
	return LimitConfig
end

function initTrainLimitConfig()
	for i = 1,#TrainLimitConfig do
		local name = TrainLimitConfig[i].hero
		local lv = TrainLimitConfig[i].lv
		LimitConfig[name] = LimitConfig[name] or {}
		LimitConfig[name][lv] = TrainLimitConfig[i]
	end
end

function init(hero)
	local o = {
		base = {},
		current = {},
	}
	for i = 1,#TrainDefine.ATTRS do
		local name = TrainDefine.ATTRS[i]
		table.insert(o.base,{name = name,val = 0})
		table.insert(o.current,{name = name,val = 0})
	end
	return o
end
