module(..., package.seeall)
local RewardConfig = require("src/config/GuildBossRewardConfig").Config
local GuildBossDefine = require("src/modules/guild/boss/GuildBossDefine")
local BagDefine = require("src/modules/bag/BagDefine")

function start()
	if not Stage.currentScene:hasEventListener(Event.FightHarm, onHurt) then
		Stage.currentScene:addEventListener(Event.FightHarm, onHurt)
	end
end

function onHurt(listener, evt)
	if evt.name == "heroB" then
		Network.sendMsg(PacketID.CG_GUILD_BOSS_HURT, evt.harm)
	end
end

function refreshBossHp(hp)
	if Stage.currentScene["setHeroBHp"] ~= nil then
    	local heroB = Stage.currentScene.heroB
		if heroB ~= nil then
			Stage.currentScene:setHeroBHp(hp)
		end
	end
end

function ended()
	if Stage.currentScene:hasEventListener(Event.FightHarm, onHurt) then
		Stage.currentScene:removeEventListener(Event.FightHarm, onHurt)
	end
end

function getRewardByHurt(hurt)
	for _,config in ipairs(RewardConfig) do
		if config.type == GuildBossDefine.BOSS_REWARD_TYPE_HURT and config.param[1] <= hurt and 
			(config.param[2] == nil or config.param[2] >= hurt) then
			local rewardList = config.reward
			for _,v in pairs(rewardList) do 
				if v[1] == BagDefine.ITEM_ID_MONEY then
					return v[2]
				end
			end
		end
	end
	return 0
end
