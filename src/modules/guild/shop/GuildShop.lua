module(...,package.seeall) 
local refreshTimes = 0

function setRefreshTimes(times)
	refreshTimes = times
	return true
end

function getRefreshTimes()
	return refreshTimes
end
