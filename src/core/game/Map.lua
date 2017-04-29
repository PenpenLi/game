module("Map", package.seeall)
setmetatable(Map, {__index = Control}) 

UI_MAP_TYPE = "Map"
isMap = true
--kabu尺寸 970*570 比 1.70175
--当前最窄匹配尺寸 ip5 1136*640 比 1.775
scale = 768 / 570 + (1.775 - 1.70175) -- 地图缩放系数 场景设计高768，卡布地图设计高570，
--scale = scale * 2

local gridW = 25 * scale --网格宽
local gridH = 25 * scale --网格高

function new(mapId, fileExt)
	local cfg = MapManager.mapConfig[mapId]
	assert(cfg, "mapId:" .. tostring(mapId) .. "is invalid !")

	local mp = { 
		name = cfg.name,
		mapId = mapId,
		cfg = cfg,
		uiType = UI_MAP_TYPE,
		width = Stage.width,
		height = Stage.height,
		players = {},
		monsters = {},
	}

	local url = "assets/map/" .. mapId .. (fileExt or ".png") 
	mp._ccnode = CCSprite:create(url)
	mp._ccnode:setAnchorPoint(ccp(0,0))
	mp._ccnode:setScale(scale)
	local size = mp._ccnode:getContentSize()
	mp.width = math.floor(size.width * scale)
	mp.height = math.floor(size.height * scale)
	setmetatable(mp, {__index = Map})
	return mp
end

function convertToGridSpace(x, y)
	local gridX = math.floor(x / gridW) + 1
	local gridY = math.floor(y / gridH) + 1
	return gridX, gridY 
end

function convertToSpace(gridX, gridY)
	local x = (gridX - 0.5) * gridW
	local y = (gridY - 0.5) * gridH
	return x, y
end

--路由
function route(self, x0, y0, x1, y1) 
	print("======> route:", self.mapId, x0, y0, x1, y1)

	local tiles = self.cfg.tiles
	local gridX0, gridY0 = convertToGridSpace(x0, y0)
	local gridX1, gridY1 = convertToGridSpace(x1, y1)

	local paths,all = AStar.pathFind(self.cfg.tiles, gridX0, gridY0, gridX1, gridY1)
	if not paths then
		if not AStar.isValid(tiles, gridX0, gridY0) then
			-- 起点为障碍点时，让其通行。避免角色卡死在地图上的情况！
			paths = {{x=gridX0, y=gridY0},{x=gridX1, y=gridY1}}
		elseif not AStar.isValid(tiles, gridX1, gridY1) then
			-- 终点为障碍点时，找到最近点路径
			local min = AStar.minHNode(all)
			if min then
				paths = AStar.revertPath(min)
			end
		end
	end
	return paths
end

--绘制障碍表
function drawBlock(self)
	local tiles = self.cfg.tiles
	if tiles then
		local height, width = #tiles, #tiles[1]
		for y = 1, height do
			for x = 1, width do
				if tiles[y][x] == 1 then
					local spr = Sprite.new("mapBlock" .. x .. "_" .. y, "assets/block.png")
					spr:setPosition((x - 1) * 25, (height - y) * 25)
					self:addChild(spr)
				end
			end
		end
	end
end

-- Map的逻辑实现都转写到MapLogic文件去
--[[
function mapEnter(self) 
end

function mapExit(self) 
end

-- ]]

