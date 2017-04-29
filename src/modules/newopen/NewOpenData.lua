module(...,package.seeall)
data = {
}
timeData = {
}

function setData(day,rewards)
	data = {
		day = day,
		rewards = rewards,
	}
end

function getData()
	return data
end

function setTimeData(beginTime,endTime,getEndTime)
	timeData = {
		["beginTime"] = beginTime,
		["endTime"] = endTime,
		["getEndTime"] = getEndTime,
	}
end

function getTimeData()
	return timeData
end
