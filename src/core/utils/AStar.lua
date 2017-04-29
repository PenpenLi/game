module("AStar", package.seeall) 

local dir8 = {{1,1},{-1,1},{1,-1},{-1,-1},{1,0},{0,1},{-1,0},{0,-1}}

function minHNode(heap)
	local h, i, node = math.huge, 0, nil
	for k,v in pairs(heap)  do
		if v.h < h then
			h = v.h
			i = k
			node = v
		end
	end
	return node,i
end

function minFNode(heap)
	local f, i, node = math.huge, 0, nil
	for k,v in pairs(heap)  do
		if v.f < f then
			f = v.f
			i = k
			node = v
		end
	end
	return node,i
end

--地图特别大的情况下，可以做小根堆来优化
function heapPush(heap, node)
	table.insert(heap, node)
end
function heapPop(heap)
	local node,i = minFNode(heap) 
	if node then
		table.remove(heap, i)
	end
	return node
end

--回溯路径
function revertPath(node)
	while node.parent do --回溯到起点
		node.parent.child = node 
		node = node.parent
	end
	local path = {node}
	while node.child do
		table.insert(path, node.child)
		node = node.child
	end
	return path 
end

function pathFind(tiles, x0, y0, x1, y1)
	local height, width = #tiles, #tiles[1]
	print("======>> find:", x0, y0, x1, y1,height, width)
	local endId = y1 * width + x1
	local open, all = {}, {}
	local current = {x = x0, y = y0, g = 0, h = 0, f = 0, parent = nil, id = y0 * width + x0}
	while current do
		if current.id ~= endId then
			for k, v in ipairs(dir8) do
				local nx, ny = current.x + v[1], current.y + v[2] 
				if nx >= 1 and nx <= width and ny >= 1 and ny <= height 
					and tiles[height - ny + 1][nx] == 0 then -- height-ny+1：左上原点转左下
					local id = ny * width + nx
					local ng = current.g + 10
					local node = all[id]
					if node then
						if ng < node.g then
							node.parent = current
							node.g = ng
							node.f = ng + node.h
						end
					else
						local nh = (math.abs(x1 - nx) + math.abs(y1 - ny)) * 10
						node = {x = nx, y = ny, g = ng, h = nh, f = ng + nh, parent = current, id = id}
						heapPush(open, node)
						all[id] = node
					end
				end
			end
		else --终点找到了
			return revertPath(current)
		end
		current = heapPop(open) 
	end
	return nil, all -- 无路,返回所有查找过的node可以用来找最近点
end

--是否可行点
function isValid(tiles, x, y) 
	local height, width = #tiles, #tiles[1]
	if x >= 1 and x <= width and y >= 1 and y <= height
		and tiles[height - y + 1][x] == 0 then -- height-y+1：左上原点转左下
		return true 
	else
		return false 
	end
end

