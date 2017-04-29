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
	self.heroNameList = {}
	self.isStart = false
	self.coolTime = 0
	self.score = 0
	self.resetCost = 0

	self.enemyName = ''
	self.enemyHeroInfo = {}

	self.selectHeroList = {}
	self.selectEnemyList = {}

	self.prepareHeroList = {}
	self.enemyHeroList = {}

	self.seed = 0
	self.fightHeroList = {}
	self.enemyHeroList = {}

	self.dir = 0

	self.shopList = nil
	self.nextRefreshTime = 0
	self.refreshCost = 0
end

function setHeroNameList(self, val)
	self.heroNameList = val
end

function getHeroNameList(self)
	return self.heroNameList
end

function setCoolTime(self, val)
	self.coolTime = val
end

function getCoolTime(self)
	return self.coolTime
end

function setScore(self, val)
	self.score = val
end

function getScore(self)
	return self.score
end

function setEnemyName(self, val)
	self.enemyName = val
end

function getEnemyName(self)
	return self.enemyName
end

function setEnemyHeroInfo(self, val)
	self.enemyHeroInfo = val
end

function getEnemyHeroInfo(self)
	return self.enemyHeroInfo
end

function setSelectHeroList(self, val)
	self.selectHeroList = {}
	for _,name in ipairs(val) do
		self.selectHeroList[name] = true
	end
end

function getSelectHeroList(self)
	return self.selectHeroList
end

function getSelectHero(self, name)
	return self.selectHeroList[name]
end

function setSelectEnemyList(self, val)
	self.selectEnemyList = {}
	for _,name in ipairs(val) do
		self.selectEnemyList[name] = true
	end
end

function getSelectEnemyList(self)
	return self.selectEnemyList
end

function getSelectEnemy(self, name)
	return self.selectEnemyList[name]
end

function setPrepareHeroList(self, val)
	self.prepareHeroList = val
end

function getPrepareHeroList(self)
	return self.prepareHeroList	
end

function setFightHeroList(self, val)
	self.fightHeroList = val
end

function getFightHeroList(self)
	return self.fightHeroList
end

function setEnemyHeroList(self, val)
	self.enemyHeroList = val
end

function getEnemyHeroList(self)
	return self.enemyHeroList
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

function setRefreshCost(self, val)
	self.refreshCost = val
end

function getRefreshCost(self)
	return self.refreshCost
end

function setStart(self, val)
	self.isStart = val
end

function getStart(self)
	return self.isStart
end

function setResetCost(self, val)
	self.resetCost = val
end

function getResetCost(self)
	return self.resetCost
end

function setDir(self, val)
	self.dir = val
end

function getDir(self)
	return self.dir
end
