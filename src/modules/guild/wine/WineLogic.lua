module(..., package.seeall)
local WineConfig = require("src/config/WineConfig")
local WineItemConfig = require("src/config/WineItemConfig").Config
local WineBuff = {}

function getWineItems(id,lv)
	local ret = {}
	local cfg = WineConfig["Wine"..id.."Config"][lv]
	for k,v in pairs(cfg.output) do
		table.insert(ret,{id = k})
	end
	return ret 
end

function setData(wineBuff)
	if next(wineBuff) then
		table.sort(wineBuff,function(a,b)return a.time < b.time end)
	end
	WineBuff = wineBuff
end

function getData()
	return WineBuff
end

local id2name = {
	[9901001] = "money",
	[9901007] = "charExp",
	--[9901008] = "",
}

function wineBuffDeal(human,rewards,mtype)
	local wineBuff = getData()
	for k,v in pairs(wineBuff) do
		local cfg = WineItemConfig[tonumber(v.id)]
		if cfg then
			local data = cfg.buff[mtype]
			if data then
				for id,val in pairs(data) do
					local name = id2name[id]
					if rewards[id] then
						rewards[id] = math.floor(rewards[id] * (1+val/100))
					end
					if rewards[name] then
						rewards[name] = math.floor(rewards[name] * (1+val/100))
					end
				end
				--local id = data[1]
				--local val = data[2]
				--local name = id2name[id]
				--if rewards[id] then
				--	rewards[id] = math.floor(rewards[id] * (1+val/100))
				--end
				--if rewards[name] then
				--	rewards[name] = math.floor(rewards[name] * (1+val/100))
				--end
			end
		end
	end
	return rewards
end
