module(..., package.seeall)

local VipLevelConfig = require("src/config/VipLevelConfig").Config
local VipData = require("src/modules/vip/VipData")
local Define = require("src/modules/vip/VipDefine")

fightTimes = 0


function checkAttr(heroA,heroB,levelId)
	local cfg = VipLevelConfig[levelId]
	if cfg then
		heroA.vipLevelAttr = {}
		for i,relation in pairs(cfg.relation) do
			if relation[1] == heroA.hero.name and relation[2] == heroB.hero.name then
				for attrName,val in pairs(relation[3]) do
					if heroA.hero.dyAttr[attrName] then
						heroA.vipLevelAttr[attrName] = heroA.hero.dyAttr[attrName]*(100+val)/100
					end
				end
			end
		end
	end
end