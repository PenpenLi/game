module(...,package.seeall)

_data = {
	isOpen = false,
	leftTime = 0,
	bathing = {},
	money = 0,
	rmb = 0,
	item = {},
}

_timer = nil

function setData(isOpen,leftTime,bathing,money,rmb,item)
	_data = {
		isOpen = (isOpen == 1),
		leftTime = leftTime,
		bathing = bathing,
		money = money,
		rmb = rmb,
		item = item
	}
end

function getData()
	return _data
end

function setOpen(isOpen)
	_data.isOpen = isOpen 
end

function isOpen()
	return _data.isOpen
end

function setLeftTime(leftTime)
	_data.leftTime = leftTime
end

function decLeftTime(dt)
	_data.leftTime =math.max(0,_data.leftTime - dt)
end

function getLeftTime()
	return _data.leftTime
end

function clearReward()
	_data.money = 0
	_data.rmb = 0
	_data.item = {}
end

function hasReward()
	return _data.money > 0 or _data.rmb > 0 or #_data.item > 0
end

function startTimer()
	if not _timer then
		_timer = Stage.addTimer(function()
			decLeftTime(1)
		end,1,-1)
	end
end

function stopTimer()
	if _timer then
		Stage.delTimer(_timer)
		_timer = nil
	end
end
