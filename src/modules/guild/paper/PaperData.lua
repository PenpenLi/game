module(...,package.seeall)
local group = {}

function setData(data)
	group = data
end

function getData()
	return group
end
