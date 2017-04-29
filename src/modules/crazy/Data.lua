module(...,package.seeall)
local Define = require("src/modules/crazy/Define")

_data = {
	isOpen = false,
	harm = 0,
	rank = {},
	boss = {},
}

function setData(isOpen,harm,rank,boss)
	_data = {
		isOpen = (isOpen == 1),
		harm = harm,
		rank = rank,
		boss = boss,
	}
end

function getData()
	return _data
end

function getBossIndex()
	for k = 1,Define.MaxBoss do
		if not _data.boss[k] or not _data.boss[k].isDie then
			return k
		end
	end
	return -1
end

function getBoss(index)
	return _data.boss[index]
end

function setOpen(isOpen)
	_data.isOpen = isOpen 
end

function isOpen()
	return _data.isOpen
end
