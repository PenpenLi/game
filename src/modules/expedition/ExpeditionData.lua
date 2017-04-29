module(..., package.seeall)

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
	self.heroList = {}			--自己的英雄数据列表(未处理)	
	self.enemyList = {}			--敌军的英雄数据列表（未处理）

	self.heroRage = 0
	self.heroAssist = 0
	self.enemyRage = 0
	self.enemyAssist = 0
	self.curId = 0				--当前关卡
	self.gemCount = 0
	self.resetCount = 0
	self.hasBuyResetCount = 0 	--已购买重置次数
	self.hasResetCount = 0
	self.passId = 0

	self.hasGetTreasureList = {}

	self.shopList = nil
	self.nextRefreshTime = 0
	self.refreshCost = 0

	self.myHeroList = {}		--自己的hero对象列表
	self.enemyHeroList = {}		--敌军的hero对象列表

	self.expeditionList = {}

	self.lastDragX = 0
end

function setHeroList(self, data)
	self.heroList = data
end

function getHeroList(self)
	return self.heroList
end

function getHeroByName(self, name)
	for _,hero in pairs(self.heroList) do
		if hero.name == name then
			return hero
		end
	end
	return nil
end

function setHeroRage(self, data)
	self.heroRage = data
end

function getHeroRage(self)
	return self.heroRage
end

function setHeroAssist(self, data)
	self.heroAssist = data
end

function getHeroAssist(self)
	return self.heroAssist
end

function setEnemyList(self, data)
	self.enemyList = data
end

function getEnemyList(self)
	return self.enemyList
end

function setEnemyRage(self, data)
	self.enemyRage = data
end

function getEnemyRage(self)
	return self.enemyRage
end

function setEnemyAssist(self, data)
	self.enemyAssist = data
end

function getEnemyAssist(self)
	return self.enemyAssist
end

function setMyHeroList(self, data)
	self.myHeroList = data
end

function getMyHeroList(self)
	return self.myHeroList
end

function getMyHeroHpList(self)
	local tab = {}
	for _,hero in pairs(self.myHeroList) do
		local data = {}
		data.name = hero.name
		data.hp = hero.fightAttr.hp
		table.insert(tab, data)
	end
	return tab
end

function setEnemyHeroList(self, data)
	self.enemyHeroList = data
end

function getEnemyHeroList(self)
	return self.enemyHeroList
end

function getEnemyHeroHpList(self)
	local tab = {}
	for _,hero in pairs(self.enemyHeroList) do
		local data = {}
		data.name = hero.name
		data.hp = hero.fightAttr.hp
		table.insert(tab, data)
	end
	return tab
end

function setCurId(self, id)
	self.curId = id
end

function getCurId(self)
	return self.curId
end

function setGemCount(self, count)
	self.gemCount = count
end

function getGemCount(self)
	return self.gemCount
end

function setResetCount(self, count)
	self.resetCount = count
end

function getResetCount(self)
	return self.resetCount
end

function setBuyResetCount(self, count)
	self.hasBuyResetCount = count
end

function getBuyResetCount(self)
	return self.hasBuyResetCount
end

function setShopList(self, data)
	self.shopList = data
end

function getShopList(self)
	return self.shopList
end

function setRefreshTime(self, time)
	self.nextRefreshTime = time
end

function getRefreshTime(self)
	return self.nextRefreshTime
end

--设置商品已买
function setShopItemBuy(self, id)
	for _,item in pairs(self.shopList) do
		if item.shopId == id then
			item.hasBuy = 1
		end
	end
end

function resetTreasureList(self)
	self.hasGetTreasureList = {}
end

function setTreasureList(self, data)
	for _,id in pairs(data) do
		self.hasGetTreasureList[id] = 1
	end
end

function getTreasureList(self)
	return self.hasGetTreasureList
end

function addHasGetTreasure(self, id)
	self.hasGetTreasureList[id] = 1
end

function hasGetTreasure(self, id)
	return (self.hasGetTreasureList[id] ~= nil)
end

function getExpeditionList(self)
	return self.expeditionList
end

function setExpeditionList(self, value)
	self.expeditionList = value
end


function setLastDragX(self, val)
	self.lastDragX = val
end

function getLastDragX(self)
	return self.lastDragX
end

function setRefreshCost(self, val)
	self.refreshCost = val
end

function getRefreshCost(self)
	return self.refreshCost
end

function setHasResetCount(self, val)
	self.hasResetCount = val
end

function getHasResetCount(self)
	return self.hasResetCount
end

function setPassId(self, val)
	self.passId = val
end

function getPassId(self)
	return self.passId
end
