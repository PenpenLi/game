module(..., package.seeall)

local RewardConfig = require("src/config/WorldBossRewardConfig").Config
local Define = require("src/modules/worldBoss/WorldBossDefine")
local BagDefine = require("src/modules/bag/BagDefine")

local sigleton = nil

function getInstance()
	if sigleton == nil then
		sigleton = new()
	end
	return sigleton
end

function new()
	local instance = {}
	setmetatable(instance, {__index = _M})
	instance:init()
	return instance
end

function init(self)
	--开启倒计时
	self.countDownTime = 0
	--挑战冷却时
	self.coolTime = 0
	--我的伤害
	self.myHurt = 0
	--排行信息
	self.rankList = {}
	--选中的英雄列表
	self.heroList = {}
end

function setRankList(self, data)
	self.rankList = data
end

function getRankList(self)
	return self.rankList
end

function setMyHurt(self, data)
	self.myHurt = data
end

function getMyHurt(self)
	return self.myHurt
end

function setCoolTime(self, data)
	self.coolTime = data
end

function getCoolTime(self)
	return self.coolTime
end

function setCountDownTime(self, data)
	self.countDownTime = data
end

function getCountDownTime(self)
	return self.countDownTime
end

function setHeroList(self, data)
	self.heroList = data
end

function getHeroList(self)
	return self.heroList
end

function getReputationByHurt(self, hurt)
	for _,config in ipairs(RewardConfig) do
		if config.type == Define.BOSS_REWARD_TYPE_HURT and config.param[1] <= hurt and 
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
