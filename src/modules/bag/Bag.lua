module("Bag",package.seeall)
setmetatable(_M, {__index = EventDispatcher}) 

local function new()
	local bag = {}
	setmetatable(bag, {__index = Bag})
	bag:init()
	return bag
end

local instance = nil
function getInstance()
	if instance == nil then
		instance = new()
	end
	return instance
end

function destroyInstance()
	instance = nil
end

function init(self)
end

return Bag