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
	self.buyList = {}
	self.dailyInfo = {}
	self.hasDaily = false
end

function setBuyList(self, list)
	self.buyList = {}
	for _,v in pairs(list) do
		self.buyList[v] = true
	end
end

function setBuy(self, lv)
	self.buyList[lv] = true
end

function hasBuy(self, lv)
	return (self.buyList[lv] == true)
end

function setDailyInfo(self, data)
	self.dailyInfo = data
end

function getDailyInfo(self)
	return self.dailyInfo
end

function setHasDaily(self, val)
	self.hasDaily = val
end

function getHasDaily(self)
	return self.hasDaily
end
