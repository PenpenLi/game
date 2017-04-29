module(..., package.seeall)

local Define = require("src/modules/flower/FlowerDefine")

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
	return instance
end

function setReceiveRecordList(self, data)
	self.receiveRecordList = data
end

function getReceiveRecordList(self)
	return self.receiveRecordList
end

function setSendRecordList(self, data)
	self.sendRecordList = data
end

function getSendRecordList(self)
	return self.sendRecordList
end

function getReceiveRecordListByType(self, typeVal)
	if typeVal == Define.FLOWER_BTN_SEND then
		return self.sendRecordList
	else
		return self.receiveRecordList
	end
end

function setFlowerRefresh(self, value)
	self.isRefresh = value
end

function getFlowerRefresh(self)
	return self.isRefresh
end
