module(...,package.seeall)
local StrengthDefine = require("src/modules/strength/StrengthDefine")

function new()
	local o = {}
	setmetatable(o,{__index = _M})
	o:init()
	return o
end

function gridInit(cell)
	for i = 1,StrengthDefine.kMaxStrengthGridCap do
		cell.grids[i] = {}
	end
end

function init(self)
	self.id = 0
	self.lv = 0
	self.grids = {}
	self:gridInit()
end
