module(..., package.seeall)
local SignInConfig = require("src/config/SignInActivityConfig").Config

local SignInMonth = 0
local SignInInfo = {}

function setInfo(month, info)
	SignInMonth = month 
	SignInInfo = info
	checkInfo()
	table.sort(SignInInfo)
end

function checkInfo()
	local now = Master.getServerTime()
	local t = os.date('*t', now)
	if t.month ~= SignInMonth then
		SignInMonth = t.month
		SignInInfo = {}
	end
end

function getCount()
	return #SignInInfo
end

function isSignIn(n, today)
	local begin = (SignInInfo[1] or today) - 1
	local day = n + begin 
	for k, v in ipairs(SignInInfo) do
		if v == day then
			return true, day
		end
	end
	return false, day
end

function dotRefresh()
	local now = Master.getServerTime()
	local t = os.date('*t', now)
	for k,v in ipairs(SignInInfo) do
		if v == t.day then
			return false 
		end
	end
	return true 
end

