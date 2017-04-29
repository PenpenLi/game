module(...,package.seeall) 
local refreshTimes = {}

function setRefreshTimes(times,mtype)
	refreshTimes[mtype] = times
	return true
end

function getRefreshTimes(mtype)
	return refreshTimes[mtype]
end
