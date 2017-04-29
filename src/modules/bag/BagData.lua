module(...,package.seeall)
local BagDefine = require("src/modules/bag/BagDefine")
local BAG_OP = BagDefine.BAG_OP
local BAG_TAG = BagDefine.BAG_TAG
local ItemConfig = require("src/config/ItemConfig").Config

bag =
{
	grids = {
	},
	changePos = 0,
	changeId = 0,
}

function getBagCap()
	return #bag.grids
end

function getItemNumByItemId(itemId)
	local cnt = 0
	for k,v in pairs(bag.grids) do
		if v.id == itemId then
			cnt = cnt + v.cnt
		end
	end
	return cnt
end

function getItemByPos(pos)
	if pos > 0 and pos <= #bag.grids then
		return bag.grids[pos].id,bag.grids[pos].cnt
	end
	return 0,0
end

function getPosByItemIdAtLeast(itemId,cnt)
	for k = 1,#bag.grids do
		if bag.grids[k].id == itemId and bag.grids[k].cnt >= cnt then
			return k
		end
	end
	return 0
end

function clearGrids()
	bag.grids = {}
end

function setBagData(op,bagData)
	if op == BAG_OP.kSendAll then
		clearGrids()
	end
	for i = 1,#bagData do
		local seq = bagData[i]
		if seq.pos > #bag.grids then
			table.insert(bag.grids,{id = seq.id,cnt = seq.cnt})
		elseif seq.mtype == BagDefine.BAG_GRID_OP.kDel then
			table.remove(bag.grids,seq.pos)
			if bag.changePos == 0 or seq.pos < bag.changePos then
				bag.changePos = seq.pos
				bag.changeId = seq.id
			end
		else
			bag.grids[seq.pos] = {id = seq.id,cnt = seq.cnt}
			if bag.changePos == 0 or seq.pos < bag.changePos then
				bag.changePos = seq.pos
				bag.changeId = seq.id
			end
		end
	end
	Bag.getInstance():dispatchEvent(Event.BagRefresh,{etype=Event.BagRefresh})
end

function getChangePos()
	return bag.changePos,bag.changeId
end
function getItemTag(itemId)
	local cfg = ItemConfig[itemId]
	return cfg and cfg.tag or 0
end

function getItemByTag(tag)
	local res = {}
	for k=1,#bag.grids do
		local grid = bag.grids[k]
		if grid and (tag == BAG_TAG.kTagAll or tag == getItemTag(grid.id)) then
			table.insert(res,{pos = k,id = grid.id,cnt = grid.cnt})
		end
	end
	return res
end

function getItemType(itemId)
	return Common.Div(itemId,1000)
end

function getItemByType(kType)
	local res = {}
	for k=1,#bag.grids do
		local grid = bag.grids[k]
		if grid and (kType == getItemType(grid.id)) then
			table.insert(res,{pos = k,id = grid.id,cnt = grid.cnt})
		end
	end
	return res
end
