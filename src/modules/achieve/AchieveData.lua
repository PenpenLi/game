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
	self.unfinishList = {}
	self.finishList = {}
	self.commitList = {}
	self.achieveRefresh = false
end

function setUnfinishList(self, data)
	self.unfinishList = data
end

function getUnfinishList(self)
	return self.unfinishList
end

function addUnfinish(self, data)
	self.unfinishList[data.id] = data
end

function getUnfinish(self, id)
	return self.unfinishList[id]
end

function setFinishList(self, data)
	self.finishList = data
end

function getFinishList(self)
	return self.finishList
end

function getFinish(self, id)
	return self.finishList[id]
end

function setCommitList(self, data)
	self.commitList = data
end

function getCommitList(self)
	return self.commitList
end

function getCommit(self, id)
	return self.commitList[id]
end

function addCommit(self, id)
	self.commitList[id] = {id = id}
end

function setAchieveRefresh(self, val)
	self.achieveRefresh = val
end

function getAchieveRefresh(self)
	return self.achieveRefresh
end
