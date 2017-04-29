module("QueueManager",package.seeall)
local tb = "queue"
local checkedDB = checkedDB or false

local Queue = Queue or {}
function Queue:new(name)
	local o = {
		name = name,
	}
	setmetatable(o,{__index=self})
	return o
end

function Queue:push(value)
	KbDB:instance():insert(tb,{name=self.name,value=value})
end

function Queue:pop()
	local sql = string.format("SELECT id,value FROM %s WHERE name='%s' ORDER BY id ASC LIMIT 1",tb,self.name)
	local rows = KbDB:instance():execute(sql)
	if rows and next(rows) then
		KbDB:instance():delete(tb,{id=rows[1].id})
		return rows[1]
	else
		return false
	end
end

function Queue:pushRequest(req)
	local reqType = req:getRequestType()
	local value = {
		reqType = reqType,
		url = req:getUrl(),
	}
	if reqType == CCHttpRequest.kHttpPost then
		value.reqDataSize = req:getRequestDataSize()
		value.reqData = req:getRequestData():sub(1,value.reqDataSize)
	end
	self:push(value)
end

function init()
	if not checkedDB then
		KbDB:instance():checkTb(tb,DBStruct.Queue)
	end
end

function getQueue(name)
	init()
	return Queue:new(name)
end

